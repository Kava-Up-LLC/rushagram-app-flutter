# The prompt behind Rushagram

Rushagram is one word puzzle a day, the same for everyone. Six scrambled letters, a clock, one run. Solve it and
you see your time and your rank in the world today.

> *As a player, I want one quick word puzzle a day, the same for everyone, so I can see how fast I am compared to
> the world.*

The app is built with **one prompt** sent to a coding agent (Claude Code) with the **AppAmbit MCP** connected.

| Step | Where | What it builds |
|---|---|---|
| 0 | By hand (done) | The AppAmbit apps and their keys in `.env`, Firebase `google-services.json`, push credentials |
| 1 | Agent + AppAmbit MCP + Flutter | Everything: backend, the game, the morning notification, tests, the real test on two phones |

---

## 0. By hand (done 2026-11-20)

1. AppAmbit: **App Rushagram - ios** and **App Rushagram - Android**. Both App Keys are in `.env` (git-ignored).
2. Firebase: Android app `com.kavaup.rushagram`; `android/app/google-services.json` is in place (git-ignored).
   Service account uploaded to **App Rushagram - Android**.
3. iOS push: APNs `.p8` uploaded to **App Rushagram - ios** (Sandbox & Production), bundle id `com.kavaup.rushagram`.

Record the terminal while the prompt is pasted (1 s still before, paste, Enter, 5 s after). It goes in the video.

---

## 1. The prompt

```text
Build Rushagram, a daily word puzzle for iPhone and Android, on AppAmbit, from start to finish.
Use the AppAmbit MCP (call get-started-tool first) with the apps "App Rushagram - ios" and
"App Rushagram - Android". Follow AGENTS.md, docs/tech/rushagram/tech_rushagram.md and DESIGN.md.

The idea: once a day everyone gets the same 6 scrambled letters. Tap Start, the clock runs, build
the word. One run per day. Your time and your rank today come from the cloud, so nobody can fake
them. Every morning a notification: "Today's Rushagram is ready." No login.

1. SET UP THE APP
- Change the app id to com.kavaup.rushagram on both platforms with the change_app_package_name
  package (dev dependency), display name Rushagram, Android minSdk 24. Keys are already in .env.

2. THE BACKEND (AppAmbit)
- First check a schedule trigger fires (tiny test function every few minutes). If it doesn't,
  tell me and keep going with the lazy pick; don't invent another workaround.
- RushagramDb linked to BOTH apps: words, puzzles, players, runs (spec §5). Dates from the
  database clock only.
- cloud_functions/words.txt: ~500 common 6-letter English words, family friendly, one answer each.
  Load it once.
- Cloud Code on both apps, HTTP trigger with the same name: today, start_run, submit_guess,
  ranking. Schedules: pick_word at 00:00 UTC, morning_push at 14:00 UTC (each app pushes its own
  players). The phone never receives the word, only the letters.
- Unit tests against a real in-memory SQLite. Then run it for real with two test players (same
  letters, right ranking order) and delete the test data.

3. THE GAME (Flutter)
- No state-management packages: ChangeNotifier controllers + ListenableBuilder, no setState for
  app data. Every AppAmbit call in lib/core/appambit/. Game rules in plain Dart, tested.
- Nickname on first open → Play ("Rushagram #12", tiles face down, Start; tap tiles into slots,
  tap a slot to send it back, Shuffle, Clear; wrong word shakes the tiles and the clock keeps
  running) → Result ("Solved in 0:23", "#14 of 230 today", top 20, Share
  "Rushagram #12 · 0:23 · #14 today", "Next Rushagram in 5h 12m"). One run per day.
- Long-press the "Rushagram" title calls AppAmbitSdk.generateTestCrash (for the crash demo).
- No internet: "No connection" banner with Retry. Analytics events from spec §8.

4. EVERY MORNING (push)
- appambit_sdk_push_notifications started after the core SDK. Android: Firebase BoM messaging,
  google-services plugin only if the file exists, POST_NOTIFICATIONS, setNotificationsEnabled(true).
  iOS: Push capability, remote-notification background mode, APS_ENVIRONMENT per build config.
- Ask once, on the result after the first solve. Tapping the notification opens today's puzzle.
- Run morning_push by hand and check it arrives on both phones.

5. PROVE IT
- flutter analyze clean, flutter test and node --test green.
- Real test on a real iPhone and a real Android phone: same letters on both, the iPhone solves
  first, the Android second, both see the ranking in the right order.

End with a table "What the agent did": AppAmbit | Rushagram app, with counts.
```
