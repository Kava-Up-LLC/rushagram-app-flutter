-- RushagramDb — run once in the AppAmbit SQL editor. Dates are text from the database clock.
CREATE TABLE IF NOT EXISTS words (
  word        TEXT PRIMARY KEY,
  used_on     TEXT
);
CREATE TABLE IF NOT EXISTS puzzles (
  day         TEXT PRIMARY KEY,
  number      INTEGER NOT NULL UNIQUE,
  word        TEXT NOT NULL REFERENCES words(word),
  letters     TEXT NOT NULL,
  created_at  TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS players (
  id           TEXT PRIMARY KEY,
  nickname     TEXT NOT NULL,
  platform     TEXT NOT NULL CHECK (platform IN ('ios','android')),
  consumer_id  TEXT,
  created_at   TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS runs (
  player_id   TEXT NOT NULL REFERENCES players(id),
  day         TEXT NOT NULL REFERENCES puzzles(day),
  started_at  TEXT NOT NULL,
  solved_at   TEXT,
  time_ms     INTEGER,
  guesses     INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (player_id, day)
);
CREATE INDEX IF NOT EXISTS idx_runs_rank ON runs(day, time_ms, solved_at);
