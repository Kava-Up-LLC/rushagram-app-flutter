# Cloud Code — Rushagram

Six functions on AppAmbit Cloud Code. Both AppAmbit apps (**Rushagram - iOS** and **Rushagram - Android**) share the
database **RushagramDb**, so iPhone and Android players get the same letters and one ranking.

| Function | Trigger | In | Out |
|---|---|---|---|
| `today` | HTTP, both apps | `{ player_id, nickname, platform }` | `{ ok, day, number, letters, now, next_at, run }` |
| `start_run` | HTTP, both apps | `{ player_id }` | `{ ok, started_at, now, letters }` |
| `submit_guess` | HTTP, both apps | `{ player_id, guess }` | right `{ ok: true, time_ms, rank, total, top }` · `{ ok: false, error: "WRONG" \| "NO_RUN" \| "BAD_INPUT" }` |
| `ranking` | HTTP, both apps | `{ player_id }` | `{ ok: true, time_ms, rank, total, top }` · `{ ok: false, error: "NOT_SOLVED" }` |
| `pick_word` | Schedule `0 0 * * *` (00:00 UTC), one app | — | `{ ok, day, number }` |
| `morning_push` | Schedule `0 14 * * *` (14:00 UTC = 8 am Mexico City), **both apps**, + HTTP to test | — | `{ ok, notified, failed }` |

- **The word never leaves the cloud.** Phones get the scrambled letters; guesses are checked in `submit_guess`.
- **Time comes from the database clock** (`strftime('%Y-%m-%d %H:%M:%f','now')`): `started_at` on Start, `solved_at` on
  the right word, `time_ms` is the difference. `now` is returned so the phone's timer stays in step.
- **Lazy pick:** if `pick_word` didn't run (schedule triggers never fired in this team when tested for Grocelet,
  2026-11-17), the first call of the day picks the puzzle. `INSERT OR IGNORE` makes the race safe.
- **Rank:** faster first; same time → whoever solved first. `top` has 20 rows with `me: true` on yours (no player ids
  of other people leave the cloud).
- **Push:** `ctx.appambit.push` only reaches phones of the app the function runs in, so `morning_push` is deployed to
  each app with env var `PLATFORM` = `ios` / `android`, and each one pushes its own players by `consumer_id`
  (saved by `today` from `ctx.consumer.id`).
- Single files, Node built-ins only. The shared helpers (`rows`, `ensurePuzzle`, `result`, `scramble`) are copied
  into each file because Cloud Code deploys one file per function.

## Database

`schema.sql` (4 tables + the rank index) and `seed_words.sql` (the 500 words) — run once in the RushagramDb SQL editor.
`words.txt`: 500 common 6-letter English words, family friendly, no names, no plurals, and only words with one
answer (no other dictionary word uses the same letters; checked against the LibreOffice en_US dictionary).

## Tests

Against a real in-memory SQLite with the same schema (`fake_ctx.mjs`):

```bash
node --test cloud_functions/*.test.mjs
```
