# Counter-patch — Technical Stream Project Instructions

**Issued by:** the central design-stream process
**Aligned to:** v0.21.0
**Target:** `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`
**Status:** **RETIRED 10 Aug 2026** — replacement landed as `TRIADE-Technical_Stream_Project_Instructions-0_21_0.md` (v1.1, aligned v0.21.0, **7,990 characters**). All five items disposed `authored`. Moved to `Research\` and untracked; no version bump.

> **Why this file exists.** The central process governs the technical-stream instructions but does not author them. Changes it needs are requested here, one item per change, and applied by the technical stream. This is the mirror of a PATCHES / INTAKE record and carries the same discipline: one home per item, a reason in writing, no retirement until every item is disposed.
>
> **The file in the set is byte-identical to what the stream authored.** The central process renamed it and changed nothing inside. An earlier draft of this release repointed two references directly, on a "mechanical sweep" exception; that pushed the file **220 characters over its 8,000 limit** and the exception has since been narrowed to exclude any document authored by another stream. Nothing here has been applied.

## The character budget comes first

**The 8,000-character limit is a standing rule.** The file as authored is **7,995 characters — five spare.** Every change below is priced, and cuts are proposed to pay for them. A counter-patch that ignores the budget is not adoptable.

| | Characters |
| --- | --- |
| As authored | 7,995 |
| CP1 + CP2 applied | **+117** |
| Would total | **8,112 — 112 over** |
| Cuts proposed below | **−192** |
| Result if all adopted | **7,920 — 80 spare** |

## Items

| # | Section | Change requested | Cost | Reason | Disposition |
| --- | --- | --- | --- | --- | --- |
| **CP1** | header, *Supplemental Project Instructions* | Own filename becomes `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md` — two occurrences | **+30** | The file is now a governed document in `X:\Documentation`, renamed by the central bump like any other | `authored` — v1.1 |
| **CP2** | *Purpose and authority*, *Before technical work* | `PROJECT-INSTRUCTIONS.md` is now `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md` — three occurrences | **+87** | The central instructions were renamed at 0.21.0. Left unapplied, these three references resolve to nothing | `authored` — v1.1 |
| **CP3** | *Supplemental Project Instructions* | "This file is versioned independently from Triade" is now half true. The **internal** instructions version stays independent; the **filename** carries the design-set version, set by the central bump | **0** | Adopted 0.21.0 so a reader sees the file was co-authored during the last bump without opening it. Both instruction documents follow it | `authored` — v1.1 |
| **CP4** | *Mandatory PATCHES / INTAKE companion* | Keep the disposition list identical to the design stream's: five values, and **type** is a separate axis — an item is (`FINDING` \| `AUTHORED DESIGN DECISION`) **and** one of (`authored`, `enforced-elsewhere`, `backlog`, `struck`, `unresolved`) | **0** | Central enforces the shape as **P-C9**. The two lists drifting would be invisible from either side | `authored` — v1.1 |
| **CP5** | header — *Aligned to Triade* | Re-proof against 0.21.0, then advance the line. **Deliberately left at v0.20.0** by the central process | **0** | A filename is a co-authorship marker central can set. *Aligned to* is a claim that the stream has re-proofed its assumptions, and central cannot make that claim on the stream's behalf. **The filename reading 0.21.0 while this reads 0.20.0 is the correct state until the stream closes it — not drift, and not to be "fixed" by a later sweep** | `authored` — v1.1 |

## Proposed cuts to pay for CP1 and CP2

Suggestions only — the stream owns the wording and may pay the 117 characters however it prefers.

| Section | Cut | Saves |
| --- | --- | --- |
| *Authored design decisions* | "including choosing between alternatives, defining an unresolved technical/design boundary, or identifying a design rule required by implementation constraints." → "including choosing between alternatives or defining an unresolved boundary." | **−82** |
| *Proofing* | Drop three of the eight evidence examples; the list is illustrative | **−55** |
| *Purpose* | "ChatGPT sessions implementing Triade systems and producing technical documentation" → "sessions implementing Triade and producing technical documentation" | **−24** |
| *Patch coverage* | Fold "other technical docs/cross-references" and "Project Instructions" into one line | **−18** |
| *Patch coverage* | "Where useful, list reviewed documents under **No patch required**." → "List reviewed documents under **No patch required**." | **−13** |

**Do not cut the `AUTHORED DESIGN DECISION` section.** It is the load-bearing addition of this release and central has taken the matching obligation as **P-C10**.

## No patch required

Reviewed and consistent with the central process at 0.21.0: *Technical documents* · *Version alignment* · *Session → technical documentation* · *Open items and blockers* · *Proofing* · *Default durable-work deliverables*.

**`AUTHORED DESIGN DECISION` was adopted wholesale**, not amended. It names a state the 0.17.0 authority lock left undefined — a design question resolved because implementation could not proceed, then recorded nowhere. That is what `L-M1` and `L-M2` looked like eight versions later.


---

## Retirement record

**Verified against the returned file, not asserted.**

| Item | Disposition | Evidence in v1.1 |
| --- | --- | --- |
| **CP1** | `authored` | `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md` — header and *Default durable-work deliverables*, 2 occurrences |
| **CP2** | `authored` | `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md` — *Purpose*, *Before technical work*, *Supplemental*, 3 occurrences; the former name appears nowhere |
| **CP3** | `authored` | *Supplemental*: "Instruction version is independent; filename follows the central design-set version" |
| **CP4** | `authored` | Five dispositions present; `type: FINDING or AUTHORED DESIGN DECISION` retained as a separate axis |
| **CP5** | `authored` | `**Aligned to Triade:** v0.21.0`; instructions version 1.1 |

**Budget.** Predicted 7,920 characters if every proposed cut were taken. Actual **7,990 — ten spare**, so the stream took four of the five cuts and paid the +117 differently. Within limit either way.

**Content loss, reported per the stream's own rule.** The *Proofing* evidence list dropped three of eight examples — **linting, migrations, reproducible commands**. Illustrative, not obligations, and the surrounding rule ("a clean exit code is insufficient when coverage can be measured") is intact. Worth one note: the central process adopted **linting** as verification at 0.20.0 in the same week the technical stream dropped it from its examples. Nothing is broken by that; it is only worth knowing.

**Nothing else changed.** Heading set identical; the diff is exactly the five items and the four cuts.
