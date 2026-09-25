# Technical PATCHES / INTAKE — 0.37.0 hand-off

**Aligned to:** Triade v0.37.0  
**Source package:** `0_37_0.zip`  
**Authority:** central hand-off only; this file authors no design decision and mints no design ID  
**Technical replacements:** `C-Content_Authoring_Technical_Specification_TRIADE-0_37_0.md`; `Z-Technical_Stream_Project_Instructions_TRIADE-0_37_0.md`

## Scope and disposition summary

The technical stream accepts central's narrow M14 adoption as **M-C12–M-C14** and keeps the separate node-payload/aiming intake unresolved. CP-3 is applied in the replacement C. No implementation, Grist mutation, repository migration, fixture execution, central sign-off, or design authorship is claimed.

| Local label | Type | Recommended disposition | Implementation blocker |
| --- | --- | --- | --- |
| TS37-F1 | FINDING | `authored` — remove stale closed-item wording in M | No |
| TS37-F2 | FINDING | `authored` — remove stale closed-item dependency in P | No |
| TS37-F3 | FINDING | `authored` — retire CP-3 and correct the manifest hand-off | Yes, for a clean retirement check |
| TS37-F4 | FINDING | `authored` — adopt the two complete technical replacements and update the manifest support row | Yes, for version alignment |

## TS37-F1 — M still says magnitudes are open

**Type:** `FINDING`  
**Finding and pressure:** M·2A.10a closes its unarmed comparison with **“Magnitudes are `◇M14`.”** The same document now closes `◈M14` and authors M-C12–M-C14. An implementation reader can therefore encounter both an adopted numeric contract and a sentence saying its owner is still open.

**Evidence checked:** `M-Stats_Items_Equipment_design_TRIADE-0_37_0.md`, M·2A.10a, the adopted *Innate magnitude* and *Unarmed builds* subsections, and rules M-C12–M-C14; `B-Open_Items_Index_TRIADE-0_37_0.md`, closed `◈M14` row.

**Recommended target:** M·2A.10a, final paragraph.  
**Recommended wording:** replace the last sentence with: **“Innate and striking-equipment magnitudes resolve under M-C12–M-C14.”**  
**Impact if not adopted:** stale dependency language; no schema ambiguity after reading the rules.  
**Central disposition / reconciliation notes:** **`enforced-elsewhere`, 0.37.0** — implemented against M-C12–M-C14 and the released 0.37.0 suite; no design rule originates here.

## TS37-F2 — P11 still waits on a closed item

**Type:** `FINDING`  
**Finding and pressure:** `◇P11` correctly excludes unarmed from faculty profiles, but its final sentence still says **“Magnitudes wait on `◇M14`.”** M14 is closed. P11 remains open for concrete Arcana/Mudra/Psyche instances, not for innate magnitude.

**Evidence checked:** `P-Content_Pipeline_design_TRIADE-0_37_0.md`, `◇P11`; M·2A.10a and M-C12–M-C14; T·A4.8a.

**Recommended target:** P·Part 8, `◇P11` row.  
**Recommended wording:** delete the final sentence. Do not close or narrow the remaining faculty-instance gap.  
**Impact if not adopted:** a false blocker survives in the owning authoring document.  
**Central disposition / reconciliation notes:** **`enforced-elsewhere`, 0.37.0** — implemented against M-C12–M-C14 and the released 0.37.0 suite; no design rule originates here.

## TS37-F3 — CP-3 is applied, but the manifest keeps the retired token live

**Type:** `FINDING`  
**Finding and pressure:** the replacement C changes `duration_kind` from `n_turns` to `n_ticks`, exactly as CP-3 requests. The current manifest's `blocking` field still states that `n_turns` is valid in C, and `retirement-check.sh` counts that sentence as a live survivor. After adopting C, the statement is also factually stale.

**Evidence checked:** `01-Counter_Patch_Technical_Spec_TRIADE-0_37_0.md`, CP-3; replacement C §5; `VERSION-MANIFEST.md`, hand-off `blocking` field and 0.37.0 release summary; `tools/retirement-check.sh` execution.

**Recommended targets and actions:**

1. remove CP-3 from the current `blocking` field;
2. retire `01-Counter_Patch_Technical_Spec_TRIADE-0_37_0.md` under its own retirement rule;
3. preserve the release-summary history using explicit retired-token wording accepted by the check, rather than claiming the enum is still live; and
4. regenerate the ledger after adoption.

**Impact if not adopted:** `retirement-check.sh` remains red and the hand-off reports a blocker already fixed.  
**Central disposition / reconciliation notes:** **`enforced-elsewhere`, 0.37.0** — implemented against M-C12–M-C14 and the released 0.37.0 suite; no design rule originates here.

## TS37-F4 — stream-owned replacements are ready for manual insertion

**Type:** `FINDING`  
**Finding and pressure:** central returned governed filenames containing C v0.36.0 and technical instructions v1.2 aligned to v0.36.0. The replacements align both documents to Triade v0.37.0; C re-proofs the 186-rule denominator, applies CP-3, registers M14 lint contracts, and identifies obsolete candidate `innate` faculty rows; Z v1.3 requires the complete manifest check set at session start and remains below 8,000 characters.

**Evidence checked:** source C and Z; manifest current-state/support rows; M-C12–M-C14; T·A4.8a; `◇P13`; node-payload/aiming intake; measured replacement Z length.

**Recommended targets and actions:** manually insert both complete replacements without partial merge; update the manifest support row to **technical instructions v1.3, aligned v0.37.0**; update the technical implementation status to distinguish the proved legacy candidate from an adoptable current candidate; regenerate indexes/ledger only where central governance requires.

**Impact if not adopted:** the governed package keeps two stream-owned documents behind the released design set and obscures the lineage migration hold.  
**Central disposition / reconciliation notes:** **`enforced-elsewhere`, 0.37.0** — implemented against M-C12–M-C14 and the released 0.37.0 suite; no design rule originates here.

## Existing unresolved design intake — no duplicate opened

The 0.37.0 node-payload/aiming intake remains the sole record for §§5–13. This hand-off does not rule, encode, or rename:

- node-bound skill availability;
- payload modules or automatic renditions;
- carrier proof against final resolved damage;
- armour/slot interception and target layers;
- anatomical target normalization;
- aimed modes or enemy-tier access;
- the authoring automation pipeline; or
- UI/legibility.

Its four central rulings remain required, including whether *Incidental / Dedicated / Apex* become load-bearing vocabulary and how new aiming work reconciles with `aim_weight` / `AIM_CEILING`.

## No patch required

- **T:** T·A4.8a already owns lineage node footprints; no technical rewrite proposed.
- **H:** H-C8 already owns Permanent-only innate-profile alteration; existing aim rules remain authoritative.
- **K:** no carrier-proof rule was adopted; existing resolution remains untouched.
- **W/G/E/V/L:** no 0.37 technical implementation change required; L waits for the intake's grade-vocabulary ruling.
- **R/B/Y/A:** derived indexes and roadmap were read for reconciliation and are not hand-edited by this stream.
- **Design-stream instructions:** central authority and stream boundary remain compatible.

## Central adoption boundary

Central owns insertion, disposition, index/ledger regeneration, archive handling, release facts and final sign-off. The technical stream supplies complete replacements and findings only.

---

## Central disposition — 0.37.0

**Delivered** — each names the document and section that carries it:

- [x] C adopted, aligned 0.37.0, reporting 186 — 117/55/14 — `C-Content_Authoring_Technical_Specification` · header, §8
- [x] Z adopted at instructions v1.3, 7,887 of 8,000 characters — `Z-Technical_Stream_Project_Instructions` · header
- [x] CP-3 fulfilled — `n_turns` → `n_ticks` — `C-Content_Authoring_Technical_Specification` · §5 `duration_kind`
- [x] Stale *"magnitudes are `◇M14`"* cleared — `M-Stats_Items_Equipment_design` · §2A.11
- [x] Stale *"magnitudes wait on `◇M14`"* cleared — `P-Content_Pipeline_design` · `◇P11` row
- [x] Manifest CP-3 blocker removed — `VERSION-MANIFEST` · handoff `blocking`

**Not deliveries, and deliberately outside the checklist:**

**M-C12–M-C14 are acknowledged as implementation and lint contracts.** No design change was requested or made; the rules remain M's, and the technical stream implements against them.

**Legacy `innate` faculty candidate rows are barred from unchanged adoption.** `[Innate]` left the faculty record for the lineage at 0.32.0, so those rows describe a shape that no longer exists. **Lineage realisation stays blocked by `◇P13`** — there is still no normalised actor-lineage grain in P.

**Node-payload and aiming remains at 0 of 9**, tracked in `00-Intake_Node_Payload_and_Aiming`, with four rulings outstanding. **Nothing was silently adopted.**

*Stated separately because an intake that reports what it did without what it left is how "Set 2 complete" happened.*
