# DESIGN.md — Rushagram · "Stopwatch Tiles"

The look of Rushagram. Match it exactly: colors, type, spacing, components and screens.
Status: **proposal (2026-11-18)** — waiting for Jesús's OK before Prompt 2.

## 1. The idea

Rushagram is a race against a stopwatch with six letter tiles. The screen is a calm **slate board** (pale
blue-gray), the letters are **white tiles** with a hard drop, like real game tiles on a table, and the race has its
own color: **amber**. Amber paints the timer, the Start button, your time and your rank. When amber shows up, the
clock is involved.

Three rules:
1. **Amber means "the clock"** and nothing else: Start, the timer pill, "Solved in 0:23", your rank. Strong color only
   on small things. **Big blocks use soft fills with dark text**, never a saturated fill.
2. **Nothing is black** (Quotation already owns black). Text is deep indigo; normal buttons are indigo.
3. **Tiles are physical.** Tiles, slots, cards and buttons use a hard 3 px drop **without blur**. No soft gray shadows,
   no gradients.

## 2. Colors

| Token | Hex | Use | Contrast |
|---|---|---|---|
| `board` | `#ECEFF5` | Screen background (Scaffold) | — |
| `tile` | `#FFFFFF` | Letter tiles, cards, fields | — |
| `ink` | `#23264A` | Letters on tiles, all main text | 14.6:1 on tile |
| `inkMuted` | `#5D6283` | Secondary text, ranking times | 5.9:1 on tile · 5.1:1 on board |
| `edge` | `#C6CBDB` | Hard drop under tiles, cards, fields | — |
| `slot` | `#DDE1EC` | Empty answer slot fill | — |
| `indigo` | `#3A3F8C` | Primary buttons (Let's play, Share), Shuffle/Clear text and border, links | white on indigo 9.0:1 |
| `indigoDeep` | `#292D6A` | Hard drop under indigo buttons | — |
| `amber` | `#C9751B` | The clock only, small things: Start button, timer pill, your rank number | white on amber 3.6:1 → use **Bold 20+** for text on it |
| `amberDeep` | `#9A5813` | Hard drop under amber buttons | — |
| `amberSoft` | `#FBEBD6` | Fill of the "Solved" card and your row in the ranking | ink on it 13:1 |
| `butter` | `#F4E8C4` | "No connection" banner background (ink text) | ink on it 12:1 |
| `onColor` | `#FFFFFF` | Text on indigo and amber | — |

There is **no red** anywhere. A wrong word is shown by the shake and a line of `ink` text, not by color.

## 3. Type

One family: **Rubik**, bundled in `assets/fonts/` (static instances of the Google Fonts variable font, OFL license
included): Regular 400, Medium 500, SemiBold 600, Bold 700, ExtraBold 800.

```yaml
# pubspec.yaml (already there)
fonts:
  - family: Rubik
    fonts:
      - { asset: assets/fonts/Rubik-Regular.ttf, weight: 400 }
      - { asset: assets/fonts/Rubik-Medium.ttf, weight: 500 }
      - { asset: assets/fonts/Rubik-SemiBold.ttf, weight: 600 }
      - { asset: assets/fonts/Rubik-Bold.ttf, weight: 700 }
      - { asset: assets/fonts/Rubik-ExtraBold.ttf, weight: 800 }
```

| Style | Size / line | Weight | Use |
|---|---|---|---|
| `display` | 56 / 60 | 800 | "Solved in 0:23" time, tile letters use `tileLetter` |
| `tileLetter` | 34 / 34 | 700 | Letters on tiles and slots, uppercase |
| `title` | 28 / 34 | 800 | Screen titles ("Rushagram #12") |
| `heading` | 20 / 26 | 700 | "#14 of 230 today", card titles |
| `body` | 16 / 24 | 400 | Text |
| `label` | 14 / 18 | 600 | Buttons, chips, ranking nicknames |
| `timer` | 22 / 26 | 700, tabular figures (`FontFeature.tabularFigures()`) | Timer pill, ranking times |

Sentence case everywhere except tile letters. No all-caps labels.

## 4. Spacing, radius, drops

- Spacing scale: 4, 8, 12, 16, 24, 32, 48. Screen padding 24.
- Radius: tiles and slots 12, buttons 14, cards 16, timer pill fully round.
- Drop: `Offset(0, 3)` with blur 0 in `edge` (tiles, cards, fields), `indigoDeep` (indigo buttons), `amberDeep`
  (amber buttons). Pressed: the widget moves down 2 px and the drop shrinks to 1 px.

## 5. Components

| Component | Spec |
|---|---|
| **Letter tile** | 52×52 (fits 6 across a 360 px phone with 8 gaps), `tile` fill, `ink` letter, `edge` drop. Used tile: same place, `slot` fill, no letter, no drop. |
| **Answer slot** | 52×52, `slot` fill, radius 12, no drop. Filled: looks like a tile. The 6 slots sit above the 6 tiles. |
| **Timer pill** | `amber` fill, white `timer` text "0:23", 8×16 padding, top center. Before Start it shows "0:00" in `inkMuted` on `slot`. |
| **Start button** | Full width, 56 high, `amber`, white "Start" Bold 20, `amberDeep` drop. |
| **Primary button** | Full width, 52 high, `indigo`, white label, `indigoDeep` drop. |
| **Secondary button** | `tile` fill, `indigo` 2 px border and text, `edge` drop (Shuffle, Clear). |
| **Solved card** | `amberSoft` fill, `edge` drop, radius 16: "Solved in" (`heading`, `inkMuted`) + time (`display`, `ink`) + "#14 of 230 today" (`heading`, the "#14" in `amber`). |
| **Ranking row** | 44 high: position (`label`, `inkMuted`), nickname (`label`, `ink`), time (`timer` 16, `inkMuted`, right). Your row: `amberSoft` fill. |
| **No connection banner** | `butter` fill, `ink` text "No connection", **Retry** as a text button in `indigo`. |

## 6. Screens

1. **Nickname** — title "Rushagram", body "One word a day. Everyone gets the same letters.", six tiles spelling
   R U S H · · as decoration (static), field "Your nickname", primary **Let's play**.
2. **Play, before Start** — title "Rushagram #12", the timer pill at 0:00, six face-down tiles (`slot` fill, no
   letters), body "Same letters for everyone today. The clock starts when you tap Start.", **Start**.
3. **Play, running** — timer pill counting, 6 slots, 6 tiles, Shuffle + Clear side by side. Wrong word: tiles shake
   (3 × 8 px, 350 ms), slots empty, line "Not this one. Keep going." under the slots for 2 s.
4. **Result** — Solved card, "Top 20 today" heading, ranking list, primary **Share**, body
   "Next Rushagram in 5h 12m" (`inkMuted`).
5. **Notifications ask** (once, on Result after the first solve) — soft card: "Get a nudge when tomorrow's word is
   ready?" with **Not now** / **Turn on**.

## 7. Copy

| Where | Text |
|---|---|
| Wrong guess | Not this one. Keep going. |
| Share | `Rushagram #12 · 0:23 · #14 today` |
| Push | Title "Rushagram" · body "Today's Rushagram is ready." |
| Already played | (lands on Result) "You've played today's Rushagram." |
| No connection | No connection · Retry |
| Nickname error | Use 2 to 16 letters or numbers. |

## 8. Motion

- Tile tap: the letter flies to the next free slot (160 ms, ease-out).
- Wrong: shake (above). Right: the 6 slots flip to amber one after another (40 ms apart), then Result.
- Shuffle: tiles swap places (200 ms). Respect "reduce motion": no flight, no flip, just a fade.

## 9. Flutter mapping

- `core/theme/app_colors.dart` — the tokens above as `static const Color`.
- `core/theme/app_text.dart` — the styles above (`fontFamily: 'Rubik'`).
- `core/theme/app_theme.dart` — `ThemeData(useMaterial3: true, scaffoldBackgroundColor: board, fontFamily: 'Rubik')`,
  buttons built as our own widgets (Material elevation/shadows off).

## 10. Don't

- No black, no red, no gradients, no blurred shadows.
- No amber on anything that isn't the clock or the result.
- No confetti, no sounds, no emoji in the UI.
