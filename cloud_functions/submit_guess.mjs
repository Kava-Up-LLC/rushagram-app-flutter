// submit_guess — check the word in the cloud.
// Runs on AppAmbit Cloud Code. HTTP trigger: /api/fn/submit_guess. Deployed to both apps.
// In:  { player_id, guess }
// Out: right → { ok: true, time_ms, rank, total, top } · wrong → { ok: false, error: "WRONG" }
//      { ok: false, error: "NO_RUN" | "BAD_INPUT" }
// Wrong guesses are free but the clock keeps running. A second "right" returns the saved result.

// ---- shared (same block in every Rushagram function: Cloud Code deploys single files)
export const rows = (res) => {
  const r = res?.results?.[0];
  if (!r) return [];
  return (r.rows ?? []).map((row) =>
    Array.isArray(row) ? Object.fromEntries(r.columns.map((c, i) => [c, row[i]])) : row,
  );
};
const written = (res) => Number(res?.results?.[0]?.rows_written ?? 0);
const input = (ctx) => ctx.req?.body ?? ctx.req ?? ctx.event ?? {};
const q = async (ctx, sql, params = []) => rows(await ctx.appambit.db(sql, params));
const NOW = "strftime('%Y-%m-%d %H:%M:%f','now')"; // database clock, milliseconds
const iso = (t) => (t ? `${String(t).replace(' ', 'T')}Z` : null);
const validId = (v) => typeof v === 'string' && /^[A-Za-z0-9-]{8,64}$/.test(v);

export const scramble = (word, rand = Math.random) => {
  for (let i = 0; i < 50; i++) {
    const a = word.split('');
    for (let j = a.length - 1; j > 0; j--) { const k = Math.floor(rand() * (j + 1)); [a[j], a[k]] = [a[k], a[j]]; }
    const s = a.join('');
    if (s !== word && s.slice(0, 2) !== word.slice(0, 2)) return s;
  }
  return word.slice(3) + word.slice(0, 3);
};

// Today's puzzle (UTC day). Created on first need: by pick_word at midnight, or by the first player
// of the day if the schedule didn't run. INSERT OR IGNORE makes the race safe: everyone reads the same row.
export const ensurePuzzle = async (ctx) => {
  const [{ day }] = await q(ctx, "SELECT date('now') AS day");
  let [p] = await q(ctx, 'SELECT day, number, word, letters FROM puzzles WHERE day = ?', [day]);
  if (p) return p;
  const [w] = await q(ctx, 'SELECT word FROM words WHERE used_on IS NULL ORDER BY random() LIMIT 1');
  if (!w) throw Object.assign(new Error('word list is empty'), { code: 'NO_WORDS' });
  const ins = await ctx.appambit.db(
    `INSERT OR IGNORE INTO puzzles (day, number, word, letters, created_at)
     VALUES (?, (SELECT COALESCE(MAX(number), 0) + 1 FROM puzzles), ?, ?, ${NOW})`,
    [day, w.word, scramble(w.word)]);
  if (written(ins) > 0) await ctx.appambit.db('UPDATE words SET used_on = ? WHERE word = ?', [day, w.word]);
  [p] = await q(ctx, 'SELECT day, number, word, letters FROM puzzles WHERE day = ?', [day]);
  return p;
};

// Your time, rank and the top 20 for a solved run. Faster first; same time → who solved first.
export const result = async (ctx, playerId, day) => {
  const [me] = await q(ctx, 'SELECT time_ms, solved_at FROM runs WHERE player_id = ? AND day = ? AND solved_at IS NOT NULL', [playerId, day]);
  if (!me) return null;
  const [{ total }] = await q(ctx, 'SELECT COUNT(*) AS total FROM runs WHERE day = ? AND solved_at IS NOT NULL', [day]);
  const [{ ahead }] = await q(ctx,
    `SELECT COUNT(*) AS ahead FROM runs WHERE day = ? AND solved_at IS NOT NULL
     AND (time_ms < ? OR (time_ms = ? AND solved_at < ?))`, [day, me.time_ms, me.time_ms, me.solved_at]);
  const top = await q(ctx,
    `SELECT p.nickname, r.time_ms, r.player_id FROM runs r JOIN players p ON p.id = r.player_id
     WHERE r.day = ? AND r.solved_at IS NOT NULL ORDER BY r.time_ms, r.solved_at LIMIT 20`, [day]);
  return {
    time_ms: Number(me.time_ms), rank: Number(ahead) + 1, total: Number(total),
    top: top.map((t, i) => ({ position: i + 1, nickname: t.nickname, time_ms: Number(t.time_ms), me: t.player_id === playerId })),
  };
};

// ---- this function
const sameLetters = (a, b) => a.split('').sort().join('') === b.split('').sort().join('');

export const handler = async (ctx) => {
  const { player_id: playerId, guess } = input(ctx);
  const g = typeof guess === 'string' ? guess.trim().toLowerCase() : '';
  if (!validId(playerId) || !/^[a-z]{6}$/.test(g)) return { ok: false, error: 'BAD_INPUT' };
  const p = await ensurePuzzle(ctx);
  const [run] = await q(ctx, 'SELECT solved_at FROM runs WHERE player_id = ? AND day = ?', [playerId, p.day]);
  if (!run) return { ok: false, error: 'NO_RUN' };
  if (run.solved_at) return { ok: true, ...(await result(ctx, playerId, p.day)) };
  if (!sameLetters(g, p.letters)) return { ok: false, error: 'BAD_INPUT' };
  if (g !== p.word) {
    await ctx.appambit.db('UPDATE runs SET guesses = guesses + 1 WHERE player_id = ? AND day = ?', [playerId, p.day]);
    return { ok: false, error: 'WRONG' };
  }
  // Both timestamps come from the database clock; time_ms is their difference.
  await ctx.appambit.db(
    `UPDATE runs SET solved_at = ${NOW}, guesses = guesses + 1,
       time_ms = CAST(ROUND((julianday(${NOW}) - julianday(started_at)) * 86400000) AS INTEGER)
     WHERE player_id = ? AND day = ? AND solved_at IS NULL`, [playerId, p.day]);
  return { ok: true, ...(await result(ctx, playerId, p.day)) };
};
