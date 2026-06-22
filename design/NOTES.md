# NOTES — build log & design critique

A running record of what was tried, what was cut, and the self-critique against
§7 (anti-slop) and §9 (quality bar). Honest, not promotional.

## Stack & architecture decisions

- **State management: Riverpod.** Chosen over Bloc for how cleanly it expresses
  the stream-backed reads (wallet balance, logs, ledger) and the single swap
  point. Every repository interface is bound to a mock in `application/providers.dart`
  — that file is the *only* thing that changes when Supabase + Razorpay arrive.
- **Money is integer paise everywhere**, mirroring the eventual DB. Formatting
  (Indian grouping, tabular figures, typographic minus) lives in `core/utils/money.dart`.
- **Business rules client-side but isolated** in `domain/rules/` and enforced in
  `data/mock/mock_backend.dart` (the lock rejects writes; deductions stop at zero;
  lenient settlement). Widgets never see a rule — they see computed `DayLog`s.
- **Reactive "completed → pending refund"** is derived from data (a commitment
  with no rollover/refund ledger entry) rather than a flag, so resolving it
  updates the UI with no special wiring.
- **Real clock, relative-seeded dates.** Fixtures are seeded relative to *today*
  so the lock rule, the sky, and "Day 12 of 30" stay coherent without a fake clock.

## The signature — Day's Arc (Pass 3)

- Built from a shared `DayArcGeometry` (sun-path `sin(πt)` lift) used identically
  by the painter and the positioned nodes, so they never disagree.
- The bloom is Register A: radial light scales 0.6→1.0 + opacity 0→1 over 480ms,
  a ring expands and fades once, the core settles with a damped ease. Haptic fires
  on the same frame the tap starts the bloom (fast-path logging on Today).
- Nodes are coloured for the **sky**, not the theme (a fixed warm palette + a soft
  dark "seat" so light reads on any hour), because they live over the live gradient.
- **Chanel rule — the element removed:** an early idea placed a moving "now" marker
  (a small sun) on the arc at the current time. Cut it. The arc encodes *prayers*,
  whose spacing is not linear clock time; a time marker on it would have lied about
  the geometry. The sky already carries time — so time lives there, and the arc
  stays purely about the five prayers.
- Could not screen-record here (headless container). Timing/weight were tuned by
  reading the numbers against §5; **on-device recording is the next step** before
  final sign-off, per Pass 3.

## Self-critique against §7 (anti-slop)

- **Stock widgets at defaults** → hand-built: switch (`SukoonSwitch`), bottom nav
  (`SukoonNavBar`), toast (`showAppToast`, replacing SnackBar), button (`AppButton`,
  no gradient glow), segmented toggle, loader (`Pulse`, replacing the spinner),
  prayer node. No `AlertDialog`/`SnackBar`/`Switch` left at defaults.
- **One radius / one shadow everywhere** → radii differ by role (12 controls / 16
  cards / 24 ceremonial / pill); elevation is hairline + tint by default, soft
  shadow only on the primary button and floating surfaces.
- **Uniform 16 padding** → a 4-pt scale used with rhythm; screens breathe at 24.
- **Default ease / all-at-once entrances** → two registers in `motion.dart`; the
  arc nodes stagger Fajr→Isha; nothing uses `Curves.linear`.
- **Emoji-as-icons / mixed sets** → one rounded Material set via `AppIcons`.
- **System-voiced copy** → all copy is user-side and active ("Loaded", "Set aside
  for sadaqah", "Add funds"), never "Submit"/"webhook"/"deduct".
- **Missing states** → empty (fresh user, empty ledger, no history), depleted,
  locked-day, pending top-up (sheet), pending refund are all reachable via the dev
  panel and have in-voice copy.
- **The three AI clichés** (cream+serif+terracotta / near-black+acid / broadsheet
  hairlines) — explicitly refused; see THESIS.

## Religious framing audit (§2)

- No banned words anywhere: searched for "pay off / clear / settle your prayer /
  kaffarah / penalty / expiation" — the only occurrence of "expiation" is the
  Giving screen stating it is **not** expiation. ✓
- Setup copy is one-time self-discipline, not a vow; no "nadhr" language. ✓
- A missed prayer is met with dignity (clay rose, no red, no alarm) and always an
  offer of qada. ✓
- Balance is a quiet chip; the day and prayer are the hero on every screen. ✓
- Sadaqah screen leads with transparency and recipient dignity, never "don't lose ₹X". ✓

## Known gaps / next steps (honest)

- ~~Fonts fetch at runtime via `google_fonts`.~~ **Resolved:** Newsreader, Hanken
  Grotesk, and Amiri are now bundled as assets (`assets/fonts/`) and the
  `google_fonts` dependency is removed — the type system renders reliably offline.
  Newsreader/Hanken are variable fonts; Flutter maps `fontWeight` to the `wght`
  axis. Confirmed present in the web build's `FontManifest.json`.
- **RTL is wired** (locale `ar` → MaterialApp RTL; Arabic via Amiri + forced RTL in
  `ArabicPhrase`) but a full right-to-left visual audit needs a device.
- **No on-device 60/120fps capture yet** — the Arc is wrapped in `RepaintBoundary`,
  animates transforms/shaders not layout, and honours reduced-motion, but the fps
  target must be confirmed on a real low-end Android.
- Notifications, timezone editing, and prayer-time source are mock/placeholder UI.

## Verification done in this environment

- `flutter analyze` — clean (0 issues).
- `flutter test` — 3 widget smoke tests pass: boots into active Today, fresh user
  → onboarding, depleted wallet → calm top-up prompt. The full widget tree compiles
  (the test imports the whole app).
- `flutter build web` — the entire app compiles via dart2js (~62s) and the three
  bundled fonts register in `FontManifest.json`.
