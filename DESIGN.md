# DESIGN.md — Rushagram · "Arcade sticker"

The look of Rushagram. Match it exactly: colors, type, spacing, components and screens.
Status: **approved (2026-11-20)**, option B of the redesign canvas
(https://claude.ai/artifact/LnNooQEaX614n14YjE7EKr, row "Opción B"). It replaces "Stopwatch Tiles".

## 1. The idea

Rushagram is a race against a stopwatch with six letter tiles. It must feel like a **game**, not a form. The screen is
a light slate board and everything on it is a **sticker**: white or colored pieces with a thick ink outline and a solid
ink shadow, like stickers stuck on a table. The clock is a real **stopwatch** (crown on top, tick marks, a needle and an
amber slice that grows with the seconds).

Three rules:
1. **Everything is a sticker.** Tiles, cards, buttons, fields and the top bar have a 3 px `ink` outline and a solid
   `ink` drop with no blur. No soft shadows, no gradients.
2. **Amber is the race**: the Start / Let's play buttons, the stopwatch slice and needle, your time, your rank badge and
   the solved tiles. Indigo is the game table: the top bar and the tile tray.
3. **Nothing is black, nothing is red.** Text and outlines are deep indigo (`ink`). A wrong word is shown by the shake and
   a speech bubble, not by color.

## 2. Colors

| Token | Hex | Use |
|---|---|---|
| `board` | `#ECEFF5` | Screen background |
| `tile` | `#FFFFFF` | Letter tiles, cards, fields, white buttons |
| `ink` | `#23264A` | All main text, every outline and every sticker drop |
| `inkMuted` | `#4A4F7A` | Secondary text (7:1 on board) |
| `indigo` | `#3A3F8C` | Top bar, tile tray, Share button (white text) |
| `indigoLight` | `#5A60B8` | Face-down tiles, the dashed edge of a used tile spot |
| `indigoDark` | `#323779` | A used tile spot in the tray |
| `onIndigoMuted` | `#C9CCF0` | The "?" on face-down tiles |
| `slot` | `#E1E4F0` | Empty answer slot fill |
| `slotEdge` | `#9AA0C8` | Dashed edge of an empty slot, the stopwatch at rest |
| `amber` | `#F0A23B` | Start / Let's play, solved tiles, your time card, rank badges (ink text on it, 6.9:1) |
| `amberDeep` | `#C9751B` | The stopwatch needle |
| `amberSoft` | `#FBD9A6` | The stopwatch slice |
| `highlight` | `#FFF3E0` | The next free slot, your row in the ranking |
| `onColor` | `#FFFFFF` | Text on indigo |

## 3. Type

One family: **Rubik**, bundled in `assets/fonts/` (Regular 400 … ExtraBold 800). Headings and numbers use 800.

| Style | Size | Weight | Use |
|---|---|---|---|
| `hero` | 40 | 800 | "Rushagram" on the lobby |
| `banner` | 32 | 800 | "Solved!" ribbon |
| `bigNumber` | 46 | 800, tabular | Your time, your rank |
| `clock` | 34 / 52 | 800, tabular | Stopwatch label (running) / stopwatch at rest |
| `tileLetter` | 26 | 800 | Letters on tiles (scales with the tile) |
| `button` | 22 | 800 | Start / Let's play; 17 for Shuffle/Clear, 20 for Share |
| `heading` | 17 | 800 | Card titles ("How it plays", "Top 20 today") |
| `body` | 16 / 15 | 400 | Text |
| `label` | 14 | 700 | Field label, chips, top bar |

Sentence case everywhere except tile letters.

## 4. Spacing, radius, outline, drop

- Screen padding 20, top 16 under the safe area. Spacing 8, 12, 14, 16, 22, 24, 42.
- Radius: tiles 10, slots 10, buttons 16–18, cards 18–20, top bar 18, chips 9–10, pills fully round.
- Outline: 3 px `ink` (the stopwatch 4 px).
- Drop: solid `ink`, `Offset(0, 4)` tiles, `Offset(0, 5)` cards and the top bar, `Offset(0, 6)` big buttons, `Offset(0, 7)`
  the stopwatch. Pressed: the piece moves down 3 px and the drop shrinks to 2 px.

## 5. Components

| Component | Spec |
|---|---|
| **Top bar** | `indigo`, outline + drop, radius 18. Left: `#12` chip (`amber`, ink outline 2 px). Center: "Rushagram" (long-press = test crash, spec §10). Right: nickname. |
| **Stopwatch** | 200 px white circle, 4 px outline, drop 7. Crown on top (amber with outline), 12 tick marks. Running: an `amberSoft` slice and an `amberDeep` needle that go round once a minute, the time on a small white label with outline. At rest: "0:00" big in `slotEdge`, no slice. |
| **Answer slot** | 50×50, `slot` fill, 3 px dashed `slotEdge`. The next free one: solid ink outline on `highlight`. Filled: a tile. |
| **Letter tile** | 50×50 (fits 6 across 360 px), white, outline, drop 4, ink letter. In the tray each tile is tilted a little (±3°). |
| **Tray** | `indigo` card with outline + drop. A used letter leaves a dashed `indigoLight` spot on `indigoDark`. Before Start: six face-down tiles (`indigoLight`, "?" in `onIndigoMuted`). |
| **Big button** | Full width, 64–66 high, `amber`, ink text with an icon (Start: stopwatch; Let's play: play). |
| **White button** | `tile` fill, outline, drop 5, ink text and icon (Shuffle, Clear, Not now). |
| **Share button** | `indigo`, white text and icon. |
| **Field** | White, outline, drop 4, radius 16, 56 high, label above. |
| **Speech bubble** | White, outline, drop 4, a tail pointing up at the slots: "Not this one. Keep going." for 2 s. |
| **Ranking card** | White card. Rows 40 high: position badge (white, 2 px outline; 1st and your row `amber`), nickname, time. Your row: `highlight` with outline. Below the top 20 your row is added after a "···". |
| **No connection** | White sticker: "No connection" + **Retry** in `indigo`. |

## 6. Screens

1. **Lobby** (first open) — the logo mark, "Rushagram" (`hero`), a tilted white chip "Daily word · new word in 5h 12m"
   (countdown to 00:00 UTC, phone clock), a "How it plays" card with three numbered steps (Tap Start. The clock begins. /
   Build the 6-letter word from the tiles. / Beat everyone's time. One try a day.), then at the bottom "Your player name"
   field and **Let's play**.
2. **Play, before Start** — top bar, stopwatch at rest, six empty slots, the tray with face-down tiles, "Same letters for
   everyone today. The clock starts when you tap Start.", **Start** at the bottom.
3. **Play, running** — the stopwatch runs, slots fill, tray tiles leave dashed spots, hint "Tap a letter to place it. Tap
   a placed one to send it back.", **Shuffle** and **Clear** side by side at the bottom.
4. **Wrong word** — the tray shakes (3 × 8 px, 350 ms), the letters go back, the speech bubble shows for 2 s. The clock
   keeps running.
5. **Result** — a "Rushagram #12" chip and your nickname, "You've played today's Rushagram." when you come back, the
   "Solved!" ribbon, the word in amber tiles (only right after solving: the phone never gets the word from the cloud),
   two tilted cards ("Your time" amber · "Rank today" white with "of 230 today"), the notifications ask (once), the
   ranking card, **Share my time** and "Next word in 5h 12m".

## 7. Copy

| Where | Text |
|---|---|
| Wrong guess | Not this one. Keep going. |
| Share | `Rushagram #12 · 0:23 · #14 today` |
| Push | Title "Rushagram" · body "Today's Rushagram is ready." |
| Already played | "You've played today's Rushagram." |
| No connection | No connection · Retry |
| Nickname error | Use 2 to 16 letters or numbers. |
| Notifications ask | Get a nudge when tomorrow's word is ready? · Not now / Turn on |

## 8. Motion

- Tile tap: the letter goes to the next free slot (160 ms, ease-out).
- Wrong: tray shake (above). Right: the slots flip to amber one after another (40 ms apart), then Result.
- Respect "reduce motion": no flip, no shake.

## 9. Flutter mapping

- `core/theme/app_colors.dart` — the tokens above. `core/theme/app_text.dart` — the styles above.
- `core/widgets/sticker.dart` — the outline + solid drop box (pressable). Buttons, field, top bar, cards build on it.
- `features/daily/widgets/stopwatch.dart` — the stopwatch (CustomPainter), only draws time; the real time is measured in
  the cloud.

## 10. Don't

- No black, no red, no gradients, no blurred shadows.
- No emoji, no confetti, no sounds.
