# THESIS — Sukoon Salah Commitment

> Written before any widget. This is the point of view the whole app is built to defend.

## The feeling (two sentences)

The calm of pre-dawn — the sky not yet bright, the house quiet, the day not yet
spent — and the steady rhythm of returning five times. Reverent, quiet, premium;
it should feel like a well-made object you are trusted with, not a product trying
to keep you.

Anti-anchor: it is **not** fintech (no balance hero, no green-up/red-down), **not**
gamified (no streaks-as-points, no confetti, no bounce), and **not** "spiritual-app
kitsch" (no mosque silhouettes, no gold filigree, no glowing crescents).

---

## Palette rationale (why these, not the defaults)

The arc of a single day — `dawn → night` — is the whole metaphor, so the palette
is a *time of day*, not a brand.

- **Ground is cool sage, not cream.** `#EDF1EF` (Sahar) / `#0C1B22` (Layl). Cream +
  serif + terracotta is AI-default #1; we refuse it. The light ground is a
  desaturated green-grey — the colour of the sky before sunrise — so the warm
  accents read as *light arriving on a cool world*.
- **Ink is deep teal, not black.** `#14242A`. Pure near-black + acid accent is
  AI-default #2. A dark teal ink keeps even the text inside the dawn→night world.
- **Primary is a deep, grounded teal-green** `#14695A`, not emerald and not fintech
  blue. It carries water/garden/jannah associations without the cliché saturated
  Islamic green.
- **Two accents, each with a *job*, never decoration:**
  - `dawn` `#E3A857` — warm amber. Used **only** for light and completion: the
    bloom of a logged prayer, the arc filling, a finished commitment. Spending
    boldness here, and almost nowhere else, is the §4 instruction.
  - `sadaqah` `#C97A6D` — a muted clay rose. Used **only** where money becomes
    giving. It is deliberately *not* a "danger red"; a missed prayer is met with
    dignity, never alarm.
- **Hairlines, not boxes.** `#DDE4E1` / `#1E3A44`. Structure comes from tinted
  surfaces + hairlines + low soft shadow, never from heavy borders or AI-default #3
  (broadsheet hairline-everything).

Dark ("Layl") is hand-tuned, not auto-derived: the primary brightens to `#2E9C86`
and dawn warms to `#E9B36A` so light still *reads as light* against deep teal-navy,
and surfaces step up by tint (`#122A33 → #16323C`) rather than by shadow, because
shadows disappear on dark grounds.

---

## Type-pair rationale

- **Display / ceremonial: Newsreader** (soft editorial serif). Reserved for prayer
  *names* (Fajr, Dhuhr…) and the occasional line of meaning. A serif gives reverence
  and editorial calm; using it *with restraint* (not on chrome) is what keeps it from
  becoming "spiritual-app" kitsch.
- **Body / UI: Hanken Grotesk** (humanist sans, warm). Chosen specifically because
  it is **not Inter** — Inter-everywhere is the single biggest "framework, not studio"
  tell. Weights 400/500/600 only.
- **Money / data: tabular figures.** Hanken Grotesk with `FontFeature.tabularFigures`
  so balances and amounts don't shimmer when they change. Money never gets a
  heavier or louder treatment than the prayer — it stays quiet on purpose (§2.4).
- **Arabic: Amiri** (quality Naskh), shaped + RTL, for spiritual phrases only.

Scale (sp): Display 32 / Title 24 / Headline 19 / Body 16 / Label 14 / Caption 12.

---

## The two-register motion philosophy

Motion is the soul here, and it has exactly two voices that never blur:

- **Register A — Ceremonial / ambient.** The sky, the light, the bloom. Slow
  (600–1400ms), eased like breath (sine / slow cubic). The sky behind the Arc maps
  to the real time of day and carries a ~7s breathing shimmer. This is where beauty
  is allowed to take its time.
- **Register B — Tactile / responsive.** Taps, toggles, sheets. Quick and alive
  (tap 120 / state 220 / transition 320–360ms) but **critically damped — no bounce.**
  Bounce reads as a toy. A toy is the wrong feeling for worship, so the springs are
  tuned to *settle*, never to wobble.

The rule that prevents slop: nothing animates with linear/default ease, and nothing
enters all-at-once. Today's five nodes stagger Fajr→Isha ~60ms apart as the sky
settles.

---

## The single signature element

**The Day's Arc.** Five prayer nodes sit along a gentle arc that traces the sun's
path across a sky that reflects the real current time and breathes. Fajr sits
dawn-left, Isha night-right — *position encodes the day, it doesn't decorate it.*
Logging a prayer blooms its node into amber light. Everything else in the app is
kept deliberately quiet so the Arc is the one thing the app is remembered by. It is
built with a CustomPainter (sky, arc, light) and iterated against a screen recording.

---

## One aesthetic risk (justified)

**A living, real-time sky gradient as the home backdrop.** Risk: time-driven colour
can read as a gimmick and can fight text legibility as it shifts from pale dawn to
deep night. I'm taking it anyway because the relationship between the five prayers
and the sun *is* the subject — a static brand colour would throw away the core idea.
Mitigations: (1) a consistent contrast scrim sits between sky and content so type
legibility is constant regardless of the hour; (2) the shimmer amplitude is tiny
(luminance only, ~3%), never a colour rave; (3) reduced-motion collapses the whole
ambient layer to a still gradient.

---

## "Would a generic agent land here?" — what I changed

| Generic default | What this app does instead |
|---|---|
| Balance / streak number as the hero | The **day and sky** are the hero; balance is a quiet chip you can ignore (§2.4 requires this) |
| Cream + serif + terracotta | Cool sage ground + teal ink; warm amber reserved only for *light* |
| Progress bar for "12/30 days" | A single quiet line of text; progress is felt in the arc's accumulated light, not a meter |
| Red for a missed prayer | Clay rose, no alarm — "a missed prayer is met with quiet dignity" |
| Bouncy, springy micro-interactions | Critically-damped springs; the only slow/organic motion is *light* |
| Material Switch / SnackBar / AppBar at defaults | Hand-built toggle, toast, and nav — the components that carry the feel |
| "Submit", "Pay", "webhook" voice | Plain, user-side, active voice; each action keeps one name across its flow |

The Chanel rule is applied last on the Arc: when it looked finished, one element was
removed (see design/NOTES.md).
