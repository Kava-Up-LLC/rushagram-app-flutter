// node --test cloud_functions/*.test.mjs
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { fakeCtx, newDb, WORDS } from './fake_ctx.mjs';
import * as today from './today.mjs';
import * as startRun from './start_run.mjs';
import * as submit from './submit_guess.mjs';
import * as ranking from './ranking.mjs';
import * as pickWord from './pick_word.mjs';
import * as morning from './morning_push.mjs';

const call = (fn, db, body, extra = {}) => fn.handler(fakeCtx({ db, body, ...extra }).ctx);
const A = 'player-aaaa-0001', B = 'player-bbbb-0002', C = 'player-cccc-0003';
const join = (db, id, nickname, platform = 'ios', consumer = 7) =>
  call(today, db, { player_id: id, nickname, platform }, { consumer: { id: consumer } });
const word = (db) => db.prepare("SELECT word FROM puzzles WHERE day = date('now')").get().word;
// Move a run's start back in time, so tests don't have to wait.
const ago = (db, id, ms) => db.prepare(
  `UPDATE runs SET started_at = strftime('%Y-%m-%d %H:%M:%f', 'now', '-' || (? / 1000.0) || ' seconds') WHERE player_id = ?`).run(ms, id);

test('word list: 500 words, 6 lowercase letters, one answer each', () => {
  assert.equal(WORDS.length, 500);
  for (const w of WORDS) assert.match(w, /^[a-z]{6}$/);
  const sorted = new Set(WORDS.map((w) => w.split('').sort().join('')));
  assert.equal(sorted.size, WORDS.length, 'two words share the same letters');
});

test('two players get the same letters, and never the word', async () => {
  const db = newDb();
  const a = await join(db, A, 'Ana');
  const b = await join(db, B, 'Leo', 'android', 8);
  assert.equal(a.ok, true);
  assert.equal(a.letters, b.letters);
  assert.equal(a.number, 1);
  assert.notEqual(a.letters, word(db));
  assert.equal(a.letters.split('').sort().join(''), word(db).split('').sort().join(''));
  for (const r of [a, b]) assert.ok(!JSON.stringify(r).includes(word(db)), 'the word leaked to the phone');
  assert.equal(db.prepare('SELECT COUNT(*) AS n FROM puzzles').get().n, 1);
  assert.equal(db.prepare('SELECT consumer_id FROM players WHERE id = ?').get(B).consumer_id, '8');
});

test('the lazy pick is race-safe: one puzzle, one used word', async () => {
  const db = newDb();
  const all = await Promise.all([pickWord, today, today].map((fn, i) =>
    fn === pickWord ? call(pickWord, db, {}) : join(db, i === 1 ? A : B, 'Pat')));
  assert.equal(db.prepare('SELECT COUNT(*) AS n FROM puzzles').get().n, 1);
  assert.equal(db.prepare('SELECT COUNT(*) AS n FROM words WHERE used_on IS NOT NULL').get().n, 1);
  assert.equal(all[1].letters, all[2].letters);
});

test('start_run starts once; calling it again keeps the same start', async () => {
  const db = newDb();
  await join(db, A, 'Ana');
  const s1 = await call(startRun, db, { player_id: A });
  const s2 = await call(startRun, db, { player_id: A });
  assert.equal(s1.ok, true);
  assert.equal(s1.started_at, s2.started_at);
  assert.match(s1.started_at, /^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/);
  assert.equal((await call(startRun, db, { player_id: C })).error, 'NO_PLAYER');
});

test('a wrong guess keeps the clock running; the right one returns time and rank', async () => {
  const db = newDb();
  await join(db, A, 'Ana');
  assert.equal((await call(submit, db, { player_id: A, guess: word(db) })).error, 'NO_RUN');
  await call(startRun, db, { player_id: A });
  ago(db, A, 23000);
  const letters = db.prepare("SELECT letters FROM puzzles").get().letters;
  const wrong = await call(submit, db, { player_id: A, guess: letters });
  assert.deepEqual(wrong, { ok: false, error: 'WRONG' });
  assert.equal((await call(submit, db, { player_id: A, guess: 'zzzzzz' })).error, 'BAD_INPUT');
  const right = await call(submit, db, { player_id: A, guess: word(db).toUpperCase() });
  assert.equal(right.ok, true);
  assert.ok(right.time_ms >= 23000 && right.time_ms < 25000, `time ${right.time_ms}`);
  assert.equal(right.rank, 1);
  assert.equal(right.total, 1);
  assert.deepEqual(right.top[0], { position: 1, nickname: 'Ana', time_ms: right.time_ms, me: true });
  assert.equal(db.prepare('SELECT guesses FROM runs').get().guesses, 2);
});

test('one run per day: solving again returns the saved result, start does not restart', async () => {
  const db = newDb();
  await join(db, A, 'Ana');
  const s = await call(startRun, db, { player_id: A });
  ago(db, A, 10000);
  const first = await call(submit, db, { player_id: A, guess: word(db) });
  const again = await call(submit, db, { player_id: A, guess: word(db) });
  assert.deepEqual(again, first);
  const s2 = await call(startRun, db, { player_id: A });
  assert.notEqual(s2.started_at, s.started_at); // moved back by ago(), never reset to now
  const t = await join(db, A, 'Ana');
  assert.equal(t.run.solved, true);
  assert.equal(t.run.time_ms, first.time_ms);
});

test('ranking order: faster first, ties go to who solved first; top 20 and your row', async () => {
  const db = newDb();
  const ids = Array.from({ length: 24 }, (_, i) => `player-${String(i).padStart(4, '0')}-xx`);
  for (const [i, id] of ids.entries()) { await join(db, id, `P${i}`); await call(startRun, db, { player_id: id }); }
  // P0 is the slowest; everyone else ~1 s apart.
  for (const [i, id] of ids.entries()) { ago(db, id, i === 0 ? 90000 : 10000 + i * 1000); await call(submit, db, { player_id: id, guess: word(db) }); }
  const r0 = await call(ranking, db, { player_id: ids[0] });
  assert.equal(r0.total, 24);
  assert.equal(r0.rank, 24);
  assert.equal(r0.top.length, 20);
  assert.equal(r0.top[0].nickname, 'P1');
  for (let i = 1; i < r0.top.length; i++) assert.ok(r0.top[i - 1].time_ms <= r0.top[i].time_ms);
  assert.ok(r0.top.every((t) => !t.me));
  const r5 = await call(ranking, db, { player_id: ids[5] });
  assert.equal(r5.rank, 5);
  assert.equal(r5.top[4].me, true);
  assert.equal((await call(ranking, db, { player_id: C })).error, 'NOT_SOLVED');
  // a tie on time: the earlier solve ranks first
  db.prepare('UPDATE runs SET time_ms = 5000').run();
  db.prepare("UPDATE runs SET solved_at = '2000-01-01 00:00:00.000' WHERE player_id = ?").run(ids[9]);
  assert.equal((await call(ranking, db, { player_id: ids[9] })).rank, 1);
});

test('bad input is refused', async () => {
  const db = newDb();
  assert.equal((await call(today, db, { player_id: A, nickname: 'x', platform: 'ios' })).error, 'BAD_INPUT');
  assert.equal((await call(today, db, { player_id: A, nickname: 'Ana!', platform: 'ios' })).error, 'BAD_INPUT');
  assert.equal((await call(today, db, { player_id: 'x', nickname: 'Ana', platform: 'ios' })).error, 'BAD_INPUT');
  assert.equal((await call(today, db, { player_id: A, nickname: 'Ana', platform: 'web' })).error, 'BAD_INPUT');
  assert.equal((await call(submit, db, { player_id: A, guess: 'abc' })).error, 'BAD_INPUT');
});

test('morning_push pushes this app\'s players only, and counts failures', async () => {
  const db = newDb();
  await join(db, A, 'Ana', 'ios', 11);
  await join(db, B, 'Leo', 'android', 12);
  await call(today, db, { player_id: C, nickname: 'Sam', platform: 'ios' }); // no consumer id
  const { ctx, pushes } = fakeCtx({ db, env: { PLATFORM: 'ios' } });
  assert.deepEqual(await morning.handler(ctx), { ok: true, notified: 1, failed: 0 });
  assert.deepEqual(pushes, [{ title: 'Rushagram', body: "Today's Rushagram is ready.", data: { open: 'play' }, consumer_id: 11 }]);
  const failing = fakeCtx({ db, env: { PLATFORM: 'android' }, pushFails: true });
  assert.deepEqual(await morning.handler(failing.ctx), { ok: true, notified: 0, failed: 1 });
});

test('scramble never returns the word or the same first two letters', () => {
  for (const w of WORDS.slice(0, 100)) {
    const s = today.scramble(w);
    assert.notEqual(s, w);
    assert.notEqual(s.slice(0, 2), w.slice(0, 2));
    assert.equal(s.split('').sort().join(''), w.split('').sort().join(''));
  }
});
