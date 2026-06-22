# Sukoon — a salah commitment app

A gentle commitment device for building a salah habit — accountability with
dignity, never punishment. You commit to praying for **N days** and set aside a
small amount per prayer. Keep your prayers → nothing moves. A prayer is
genuinely missed → that small amount later joins a pooled **sadaqah** for people
in need, in sha Allah. Unused money is refunded or rolled into the next
commitment.

> **This is the UI/UX phase, on mock data.** There is **no** Supabase or Razorpay
> SDK yet — the app is fully clickable on seeded fixtures, architected so the real
> backend drops in behind unchanged repository interfaces.

## Run it

You need the Flutter SDK (3.44+, Dart 3.12+) and a device or emulator.

```bash
flutter pub get
flutter run
```

First launch fetches the fonts (Newsreader, Hanken Grotesk, Amiri) over the
network via `google_fonts`; offline it falls back to system fonts. For production
these should be bundled as assets.

### Seeing every state — the dev panel

In a debug build, tap the **flask icon** at the top-right of the Today screen to
open the developer panel. From there you can jump between:

- **Fresh user** — the onboarding journey
- **Active · mid-commitment** — Day 12 of 30, with a few honest misses
- **Depleted wallet** — the calm top-up prompt
- **Completed · pending refund** — roll over or refund to source

…plus jumps into a **locked past day**, the **simulated top-up sheet**, and the
**commitment-end summary**. Every state in the spec is one tap away.

## Architecture

```
lib/
  core/         theme (light "Sahar" + dark "Layl"), motion, money/date/haptics
  domain/       models (money = integer paise), enums, rules (grace-lock, settlement)
  data/         repository interfaces  +  in-memory mock backend & fixtures
  application/  Riverpod providers — THE swap point for the real backend
  presentation/ screens, the Day's Arc, and the hand-built components
design/         THESIS.md (the point of view) · NOTES.md (build log & critique)
```

- **State management:** Riverpod. Every screen reads through repository interfaces
  and a `PaymentService`; swapping mock → real Supabase + Razorpay is one binding
  change per interface in `application/providers.dart`. No backend SDK is imported,
  and no Supabase/Razorpay types appear in `presentation` or `domain`.
- **The signature:** the *Day's Arc* (`presentation/widgets/day_arc/`) — five prayer
  nodes along a sun-path arc over a living, time-of-day sky. Logging blooms a node
  into light.

## Verify

```bash
flutter analyze   # clean
flutter test      # boots active Today · fresh→onboarding · depleted→top-up
```

See `design/THESIS.md` for the design rationale and `design/NOTES.md` for the
build log, anti-slop self-critique, and known next steps.
