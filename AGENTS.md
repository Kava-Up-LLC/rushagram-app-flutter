# AGENTS.md — rushagram_app (Rushagram)

Guide for any coding agent (Claude Code, Codex, Cursor…) working in this repo. Read it first.
Behavioral guidelines in the parent `../CLAUDE.md` (apps_cms) apply here too: think first, keep it simple,
touch only what you must, verify.

## What this is

Rushagram — the word of the day against the clock. A Flutter app (iOS + Android) on AppAmbit: Database, Cloud Code
(HTTP + scheduled), Push, Analytics and crash reports. App 03 of the "7 apps in 7 days" series.

## Source of truth

| File | Defines |
|---|---|
| **`docs/tech/rushagram/tech_rushagram.md`** | Everything: scope (6 features, nothing more), rules, data model, the cloud functions, folder structure, how state works, screens, acceptance criteria, risks. |
| `DESIGN.md` | The look: colors, type, spacing, components, screens. |
| `prompts.md` | The 3 prompts the app is built with, in order. |

Build only what the spec describes. If something is missing or unclear, ask — don't invent features.

## Hard rules

1. **No state-management packages** (`provider`, `riverpod`, `bloc`, `get_it`, `mobx`…). Controllers extend
   `ChangeNotifier`; views use `ListenableBuilder`. **No `setState` for app data** (spec §7.2).
2. **No other packages** than the ones in spec §3 without asking.
3. All AppAmbit SDK calls live in `lib/core/appambit/`. Views never touch the SDK.
4. **The phone never sees the word** and never writes to the database. Everything goes through Cloud Code.
5. Time comes from the database clock, never the phone (the on-screen timer is only for show).
6. Online only: no cache, no queue, no sync-later. Network failure → "No connection" banner + Retry.
7. Screens in English. No login, no accounts.
8. Never print, paste or commit App Keys, `.env`, `google-services.json` secrets or push credentials.
9. Work on branch **`dev`**. Never commit to `main`. One commit per prompt, clear message.
10. In UI copy, comments for the video and summaries, don't say "server" — say "AppAmbit" or "the cloud".
11. Push from the cloud: `ctx.appambit.push({ title, body, data, consumer_id })` inside Cloud Code. It only reaches
    phones of the AppAmbit app the function runs in, so `morning_push` runs in **each** app for its own players.
    A player's `consumer_id` is saved by `today` from `ctx.consumer.id`.
12. Design: match `DESIGN.md`. While it says "proposal", ask before building screens.

## Commands

```bash
flutter pub get
flutter analyze
flutter test
node --test cloud_functions/*.test.mjs
flutter run -d <device>          # flutter devices
flutter build apk --debug
flutter build ios --debug --no-codesign
```

## Reference code (read, don't copy blindly)

- `../app_shoplist/cloud_functions/` — Cloud Code contract, `fake_ctx.mjs`, tests against in-memory SQLite, push by
  `consumer_id`, the README notes on triggers and push timing.
- `../app_shoplist/lib/core/appambit/` and `lib/main.dart` — SDK start with per-platform keys, push start,
  `setNotificationsEnabled`, error mapping.
- `../app_shoplist/prompts.md` — the push setup that works (Firebase BoM, google-services plugin only if the file
  exists, `APS_ENVIRONMENT` per build config).

Grocelet uses the same architecture (no packages for state). Take the SDK knowledge and the patterns, not its
features.

## After each prompt

End with a short table: **What the agent did** — one column for **AppAmbit**, one for **the Rushagram app** — in plain
words, with counts (tables, functions, screens, tests). It goes on screen in the video.
