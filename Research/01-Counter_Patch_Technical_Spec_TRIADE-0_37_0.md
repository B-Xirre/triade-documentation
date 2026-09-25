# Counter-patch — Content Authoring Technical Specification

**Raised by:** design stream · **Aligned to:** Triade v0.36.0 · **Date:** 14 August 2026
**Target:** `C-Content_Authoring_Technical_Specification_TRIADE-[V_e_r].md`
**Authority:** request only. This process does not edit stream-owned documents.

## Items

| # | Section | Requested change | Reason |
| --- | --- | --- | --- |
| **CP-3** | §5, `duration_kind` (line 714) | `Choice → instant / n_turns / while_active` → **`instant` / `n_ticks` / `while_active`** | `n_turns` was retired at 0.36.0 with the turn as a unit of time. T·A2.3 is now *Tick resolution* and its duration field is `n_ticks`; an actor at AP rate 6 and one at rate 2 cross a 60-tick band at different counts, so a turn no longer denotes a quantity of time (**K-C11**) |

## How it was found

By **`tools/retirement-check.sh`**, on its first live run. The check sweeps for **what a release removed** rather than what it added, and requires every surviving occurrence of a retired token to be a negation, a changelog row or dated history. `n_turns` in an enum is none of those.

**It survived four technical re-audit rounds and six green checks**, because every other check reads syntax and this one reads intent. Recorded because it is the first evidence that the countermeasure works on live text rather than on a tamper test.

## Note

No design decision is requested. `n_ticks` is already the authored term in T; this aligns the enum to it.

## Retirement — closed 14 August 2026

**CP-3 fulfilled.** C's `duration_kind` enum now reads `instant` / `n_ticks` / `while_active`; the single surviving `n_turns` is C's own changelog row recording the replacement, which is history and correct.

**Verified against the tracked store, not the report.** C reports 186 — 117/55/14, matching the corpus measured independently, and mints zero rule IDs.

**Found by `tools/retirement-check.sh` on its first live run**, after four technical re-audit rounds and six green checks had passed C as re-proofed. That is the countermeasure's first catch on live text, and the reason it exists: every other check reads what was added.

Retired to Research.
