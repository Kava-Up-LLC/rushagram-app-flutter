// morning_push — "Today's Rushagram is ready."
// Runs on AppAmbit Cloud Code. Schedule trigger: every day at 14:00 UTC (8 am Mexico City), cron "0 14 * * *".
// Also callable over HTTP (/api/fn/morning_push) to test it by hand.
// ctx.appambit.push only reaches phones of the AppAmbit app the function runs in, so it is deployed to BOTH apps
// and each one pushes its own players. Env var PLATFORM = "ios" (Rushagram - iOS) or "android" (Rushagram - Android).
// Out: { ok, notified, failed }

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
export const TITLE = 'Rushagram';
export const BODY = "Today's Rushagram is ready.";

export const handler = async (ctx) => {
  const platform = ctx.env?.PLATFORM ?? ctx.secrets?.PLATFORM ?? process.env?.PLATFORM ?? null;
  const players = await q(ctx,
    platform ? 'SELECT DISTINCT consumer_id FROM players WHERE consumer_id IS NOT NULL AND platform = ?'
             : 'SELECT DISTINCT consumer_id FROM players WHERE consumer_id IS NOT NULL',
    platform ? [platform] : []);
  // Each AppAmbit push takes a few seconds, so they all go out at the same time.
  const sent = await Promise.all(players.map(async ({ consumer_id: consumerId }) => {
    try {
      await ctx.appambit.push({ title: TITLE, body: BODY, data: { open: 'play' }, consumer_id: Number(consumerId) });
      return 1;
    } catch (e) {
      ctx.log?.('push failed', String(e?.code ?? e?.message ?? e));
      return 0;
    }
  }));
  const notified = sent.reduce((a, b) => a + b, 0);
  return { ok: true, notified, failed: sent.length - notified };
};
