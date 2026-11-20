// Test helper: a ctx like AppAmbit's, backed by a real in-memory SQLite with RushagramDb's schema (schema.sql).
import { DatabaseSync } from 'node:sqlite';
import { readFileSync } from 'node:fs';

const here = new URL('.', import.meta.url);
export const SCHEMA = readFileSync(new URL('schema.sql', here), 'utf8');
export const WORDS = readFileSync(new URL('words.txt', here), 'utf8').split('\n').map((w) => w.trim()).filter(Boolean);

export const newDb = ({ words = WORDS } = {}) => {
  const db = new DatabaseSync(':memory:');
  db.exec(SCHEMA);
  const ins = db.prepare('INSERT OR IGNORE INTO words (word) VALUES (?)');
  for (const w of words) ins.run(w);
  return db;
};

export const fakeCtx = ({ db = newDb(), body = {}, consumer = null, env = {}, pushFails = false } = {}) => {
  const pushes = [];
  return {
    db, pushes,
    ctx: {
      req: { body }, consumer, env, secrets: {}, log: () => {},
      appambit: {
        db: async (sql, params = []) => {
          const st = db.prepare(sql);
          if (/^\s*select/i.test(sql)) {
            const out = st.all(...params);
            const columns = out.length ? Object.keys(out[0]) : [];
            return { results: [{ columns, rows: out.map((r) => columns.map((c) => r[c])), rows_written: 0 }] };
          }
          const info = st.run(...params);
          return { results: [{ columns: [], rows: [], rows_written: Number(info.changes) }] };
        },
        push: async (p) => { if (pushFails) throw Object.assign(new Error('x'), { code: 'push_failed' }); pushes.push(p); return { result: { queued: true } }; },
      },
    },
  };
};
