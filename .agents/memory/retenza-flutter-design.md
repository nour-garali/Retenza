---
name: Retenza Flutter brand & swarm design system
description: Where the real brand tokens live vs. the ai_swarm generated design system, for Retenza's Flutter app.
---

The actual `retenza_flutter/` app has no shared `design_system/` folder — each screen defines its own inline styling (colors, fonts) via `GoogleFonts`. Real brand identity: brick red `#D73E26` / `#A82C18`, cream surfaces `#FBF8F6` / `#F4EFEB`, ink text `#18110C` / `#6E5B52`, headings in `GoogleFonts.bricolageGrotesque` (w800), body in `GoogleFonts.inter`. Rounded corners ~14-20px, soft brand-colored glow shadows.

`ai_swarm/output/flutter/lib/design_system/` (and the sibling `ai_swarm/Retenza/` copy) is real generated output, but from a **different, unrelated feature run** (an expense-tracking/insights feature) — it uses a neon cyan/violet-on-black palette that does not match the Retenza brand at all.

**Why:** Blindly reusing `ai_swarm/output`'s design system for other screens would break brand consistency. The swarm is per-feature-run; each run's `design_system` output should be judged against the current brand before reuse.

**How to apply:** Before reusing anything from `ai_swarm/output/`, check whether it matches the target app's real brand tokens (inline styles in the screens). If mismatched, either run the swarm fresh with a brand-aware feature request, or hand-craft new UI using the real inline tokens as source of truth — do not import the mismatched palette as-is.

Also note: this Replit environment has no Flutter/Dart SDK installed, so `flutter analyze`/`pub get` cannot be run to verify Dart changes — review Flutter code changes manually and carefully for syntax/type correctness.
