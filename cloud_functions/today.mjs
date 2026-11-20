// today — what the phone needs on every start.
// Runs on AppAmbit Cloud Code. HTTP trigger: /api/fn/today. Deployed to both apps (Rushagram - iOS, Rushagram - Android).
// In:  { player_id, nickname, platform }
// Out: { ok, day, number, letters, now, next_at, run: null | { started_at, solved, time_ms, rank, total, top } }
// Saves the player (and the AppAmbit consumer id, for the morning push). Never returns the word.

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
export const handler = async (ctx) => {
  const { player_id: playerId, nickname, platform } = input(ctx);
  const nick = typeof nickname === 'string' ? nickname.trim() : '';
  if (!validId(playerId) || !/^[A-Za-z0-9 ]{2,16}$/.test(nick) || !['ios', 'android'].includes(platform)) {
    return { ok: false, error: 'BAD_INPUT' };
  }
  const consumerId = ctx.consumer?.id != null ? String(ctx.consumer.id) : null;
  await ctx.appambit.db(
    `INSERT INTO players (id, nickname, platform, consumer_id, created_at) VALUES (?, ?, ?, ?, ${NOW})
     ON CONFLICT(id) DO UPDATE SET nickname = excluded.nickname, platform = excluded.platform,
       consumer_id = COALESCE(excluded.consumer_id, players.consumer_id)`,
    [playerId, nick, platform, consumerId]);

  const p = await ensurePuzzle(ctx);
  const [clock] = await q(ctx, `SELECT ${NOW} AS now, date('now', '+1 day') AS next_day`);
  const [run] = await q(ctx, 'SELECT started_at, solved_at FROM runs WHERE player_id = ? AND day = ?', [playerId, p.day]);
  let out = null;
  if (run) {
    const r = run.solved_at ? await result(ctx, playerId, p.day) : null;
    out = { started_at: iso(run.started_at), solved: Boolean(run.solved_at), ...(r ?? {}) };
  }
  return { ok: true, day: p.day, number: Number(p.number), letters: p.letters, now: iso(clock.now), next_at: `${clock.next_day}T00:00:00.000Z`, run: out };
};
