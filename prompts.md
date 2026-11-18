# The prompts behind Rushagram

Rushagram is one word puzzle a day, the same for everyone. Six scrambled letters, a clock, one run. Solve it and
you see your time and your rank in the world today.

> *As a player, I want one quick word puzzle a day, the same for everyone, so I can see how fast I am compared to
> the world.*

The app is built with **three prompts** sent to a coding agent (Claude Code) with the **AppAmbit MCP** connected.

| Step | Where | What it builds |
|---|---|---|
| 0 | By hand | The AppAmbit apps, their keys and the push credentials |
| 1 | Agent + AppAmbit MCP | The database, the word list and the cloud functions: today's letters, the run, the rank |
| 2 | Agent, Flutter | The game: nickname, play against the clock, result and ranking, share |
| 3 | Agent, Flutter + AppAmbit | The morning notification |

---

## 0. By hand

1. AppAmbit dashboard: create **App Rushagram - ios** and **App Rushagram - Android** (stack Flutter).
2. Put both App Keys in `.env` (template `.env.example`). Never in the chat.
3. App id on both platforms: `com.kavaup.rushagram`.
4. Android push: in Firebase, add an Android app with that package and download `google-services.json` to
   `android/app/` (git-ignored). Then Project settings → Service accounts → **Generate new private key**, and upload
   that JSON to **App Rushagram - Android** in AppAmbit.
5. iOS push: upload an APNs `.p8` key (environment **Sandbox & Production**) to **App Rushagram - ios** with its
   Key ID, your Team ID and the bundle id. The Grocelet key can be reused.

---

## 1. The backend in AppAmbit

```text
Use the AppAmbit MCP to set up the backend for Rushagram, a daily word puzzle.
Call get-started-tool first and work on the apps "App Rushagram - ios" and "App Rushagram - Android".
Follow AGENTS.md and docs/tech/rushagram/tech_rushagram.md.

The idea: once a day everyone gets the same 6 scrambled letters. You tap Start, the clock
runs, and you build the word. One run per day. Your time and your rank today come from the
cloud, so nobody can fake them. No login.

FIRST, CHECK THE SCHEDULE
- Schedule triggers never fired in this team before. Deploy a tiny test function on a
  schedule every few minutes and confirm it runs. If it doesn't, stop and tell me.

DATABASE
- Create RushagramDb and link BOTH apps to it, so iPhone and Android share one ranking.
- words: word, used_on
- puzzles: day (UTC date), number, word, letters, created_at
- players: id, nickname, platform (ios | android), consumer_id, created_at
- runs: player_id, day, started_at, solved_at, time_ms, guesses — one run per player per day
- Dates always come from the database clock, never from the phone.

THE WORD LIST
- Write cloud_functions/words.txt: about 500 common English 6-letter words, family friendly,
  no names, and only words with one answer (no other common word uses the same letters).
- Load it into words once.

CLOUD CODE (deploy each function to both apps, HTTP trigger with the same name)
- today: save the player and their AppAmbit consumer id, and return today's number and
  letters, and their run if they have one. If today's puzzle doesn't exist yet, pick it.
- start_run: start the clock. Calling it again returns the same start time.
- submit_guess: check the word in the cloud. Wrong: say so, the clock keeps running.
  Right: save the time and return it with the rank ("#14 of 230") and the top 20.
- ranking: the same result, for opening the app again the same day.
- pick_word: on a schedule at 00:00 UTC, pick a new word and scramble it.
- The phone never receives the word, only the letters.
- Unit tests against a real in-memory SQLite with the same schema.
- Then run them for real with two test players, check both get the same letters and the
  ranking order, and delete the test data.

End with a table "What the agent did": AppAmbit | Rushagram app.
```

---

## 2. The game

```text
Build the Rushagram Flutter app for iPhone and Android on AppAmbit. Follow AGENTS.md and match
DESIGN.md exactly (the "Stopwatch Tiles" look, Rubik already in assets/fonts). App id
com.kavaup.rushagram, display name Rushagram, Android minSdk 24. Screens in English.

KEEP IT SIMPLE
- No state-management packages: one controller per feature that extends ChangeNotifier, and
  views that rebuild with ListenableBuilder. No setState for app data.
- Two features: player and daily. Every AppAmbit call lives in lib/core/appambit/.
- The game rules (tap, untap, shuffle, clear) are plain Dart, tested without widgets.
- Packages: appambit_sdk_flutter, flutter_dotenv, shared_preferences, uuid, share_plus.

NICKNAME (no login)
- Each phone gets a player id the first time it opens; that is how it's identified.
- First open: pick a nickname, then play. Start AppAmbit with the iOS or Android key from .env.

PLAY
- "Rushagram #12" with the tiles face down and Start. Start calls start_run and the clock runs.
- Tap a tile to send its letter to the next slot; tap a slot to send it back. Shuffle, Clear.
- When the 6 slots are full, submit_guess. Wrong: the tiles shake, "Not this one. Keep going."
- Closing the app doesn't stop the clock; opening it again picks up the same run.

RESULT
- "Solved in 0:23", "#14 of 230 today", the top 20 with your row marked, Share
  ("Rushagram #12 · 0:23 · #14 today"), and "Next Rushagram in 5h 12m".
- Opening the app again the same day lands here. You can't play twice.

ONLINE ONLY
- No internet: a "No connection" banner with Retry. Nothing is saved for later.

ANALYTICS
- nickname_set, puzzle_opened, run_started, guess_wrong, puzzle_solved, result_shared.
  No nicknames in the events.

Tests for the game rules, the controller and the main screens, with fake repositories.
flutter analyze clean. End with a table "What the agent did": AppAmbit | Rushagram app.
```

---

## 3. Every morning

```text
Now bring people back every day: the morning notification.

PUSH
- Add appambit_sdk_push_notifications and start it right after the core SDK, as its README says.
- Android uses Firebase: add firebase-messaging (Firebase BoM) and apply the google-services
  plugin only when android/app/google-services.json exists. Declare POST_NOTIFICATIONS.
- iOS: Push Notifications capability, remote-notification background mode, and
  aps-environment = development in Debug and production in Release (APS_ENVIRONMENT in the
  xcconfigs).
- On Android call setNotificationsEnabled(true) when the permission is granted, and on every
  start if it already was.
- Ask once, on the result after the first solve: "Get a nudge when tomorrow's word is ready?"
  with Not now / Turn on. Never ask again.
- Tapping the notification opens today's puzzle.

THE MORNING PUSH
- morning_push in Cloud Code, on a schedule every day at 14:00 UTC (8 am in Mexico City),
  deployed to each app for its own players: "Today's Rushagram is ready."
- Test it for real on both phones by running it by hand.

ANALYTICS
- push_opened.

Then the real test with both phones: same letters on both, the iPhone solves first, the
Android phone second, and both see the ranking in the right order. End with a table
"What the agent did": AppAmbit | Rushagram app.
```
