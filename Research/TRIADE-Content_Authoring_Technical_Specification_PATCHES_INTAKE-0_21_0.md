# PATCHES / INTAKE — Content Authoring Technical Specification re-proof

**Aligned to Triade:** v0.21.0  
**Companion to:** `TRIADE-Content_Authoring_Technical_Specification-0_21_0.md`  
**Date:** 10 August 2026  
**Status:** **RETIRED 10 Aug 2026** — TS-R7 disposed `authored`; proof accepted by the central process; active-document adoption attested by the operator. Moved to `Research\`, untracked.  
**Authority:** technical-stream handoff only; not authoritative corpus content

---

## Intake item

| Field | Record |
| --- | --- |
| **Local patch label** | **TS-R7** — local label only; not a design ID |
| **Type** | `FINDING` |
| **Finding / implementation pressure** | Central intake R7 is wholly technical. It has now been implemented on the supplied `triade-data` repository and exact Grist working copy: generated/populated `ref_rules`, then migrated `fixture_coverage.rule_id` from Text to `Reference → ref_rules`. `◈P7` remains closed; no design ruling was authored. |
| **Evidence** | `triade-data/docs/R7_IMPLEMENTATION_PROOF.md`; generated `content/csv/ref_rules.csv`; before/after schema and coverage snapshots; deterministic exports; machine-readable `r7_result.json`; tests; `VERSION-MANIFEST.md` handoff; central intake R7; P·Part 8 closure; P·Part 9 rules **P-C8**, **P-H5**, **P-C10**, **P-C11**. |
| **Affected documents / exact references checked** | Technical specification §1, §4.13, §4.18, §5.22, §8.2, §9, §11 and §12; central intake R7. |
| **Recommended target document + section** | Technical specification only: §4.13.1 for the generated seed contract; §8.2 for migration acceptance and proof boundary. |
| **Recommended wording** | “R7 implementation proof accepted: 143 unique source-derived rule rows, 81/48/14 split, lossless Reference migration, unresolved-ID rejection and stable-ID export proved. Retire R7 after the updated working copy is adopted as the active document.” |
| **Impact if not adopted** | The central intake remains administratively open and the active self-hosted document may remain on the pre-R7 schema, despite the completed and reversible implementation artifact. |
| **Implementation blocker** | **No** — the technical implementation and proof gates pass. Active-document import and central acknowledgement remain operational/governance actions. |
| **Central disposition** | **`authored`** — the finding is realised in the technical specification **§4.13.1** (generated seed contract) and **§8.2** (migration acceptance and proof boundary). Central intake **R7 retired** in the same pass. |
| **Reconciliation notes** | R7 changed technical implementation and technical documentation only. No canonical game data, design rule, validation rule, vocabulary lock or authored design decision changed. The running `localhost:8484` instance was not directly mutated. |

## Authored design decisions

None.

## No patch required

Reviewed and found to require no new central patch from this pass:

- **P — Content Pipeline & Data Model:** Parts 2.1, 2.3, 7.1, 8 and 9. R7 implements the existing model and closed `◈P7` state.
- **Lexicon:** no new term, renamed term or vocabulary lock.
- **Open Items Index:** no new `[OPEN]`, `[SIM]` or `[GAP]` marker; `◈P7` remains closed.
- **Validation-rule source tables:** no rule was authored, removed, renumbered or re-severitised.
- **Validation Rules Index:** consumed as a derived compilation surface; not edited.
- **ROADMAP:** no sequencing change beyond taking the manifest's R7 handoff as the next technical action.
- **VERSION-MANIFEST:** R7 is already named as `next_action`; the central process may update the technical status after accepting this proof.
- **Technical-stream Project Instructions:** v1.1 remains applicable; no replacement required.
- **Other technical documents:** none registered.

## Proof summary

**Verified from the available governed 0.21.0 corpus copy and central handoff:**

- current version is 0.21.0;
- `◈P7` and `◈P7a` are closed;
- current validation suite has 143 rows with severity split 81/48/14;
- every rule ID cited by the technical specification resolves in the current Validation Rules Index;
- R7 is the only item holding the central intake record open.

**Mechanically verified on the supplied implementation surfaces:**

- deterministic 143-row seed and 143 unique non-empty IDs;
- exact 81 Critical / 48 High / 14 Medium split and sort order 1–143;
- byte-identical seed regeneration and Grist round-trip export;
- `fixture_coverage.rule_id` as `Reference → ref_rules`, shown by stable `rule_id` and stored as `INTEGER DEFAULT 0`;
- coverage row/value preservation at 0→0 on the supplied document;
- populated synthetic migration/export (`P-C8`), unresolved-ID rejection (`P-C999`), idempotence and SQLite integrity;
- R7 repository tooling, tests and proof artifacts.

**Not verified / not executed:**

- import/replacement of the running self-hosted Grist document at `localhost:8484`;
- independent re-crawl of all rule home documents—the source-derivability proof is inherited from the governed central closure of `◈P7`;
- access to the tracked `X:\Documentation` store;
- full all-table deterministic export, canonical JSON compilation, DuckDB import or trace implementation.

---

*Retirement condition: the updated Grist working copy is adopted, the central intake records this proof, and no new cross-document consequence is found.*

---

## Central acceptance — 10 Aug 2026

**Verified by the central process against the governed corpus, not taken on the covering note:**

| Claim | Corpus | Proof | |
| --- | --- | --- | --- |
| rule count | 143 | 143 | match |
| unique IDs | 143 | 143 | match |
| Critical / High / Medium | 81 / 48 / 14 | 81 / 48 / 14 | match |
| seed regeneration byte-identical | — | `seed_sha256 == ref_rules_export_sha256` | match |
| rule IDs cited resolving in the index | — | all but `P-C999` | see below |

**`P-C999` is a negative fixture, not a rule.** It appears once, mid-sentence in a verification note, and **never leads a line**, so the **P-C8** positional census cannot mistake it for an authored rule. Checked explicitly.

**Authority check passed.** The update originates no rule, number, term or vocabulary lock: `[LOCKED]`, `[SIM]`, `[GAP]` and `[OPEN]` counts are unchanged from the previous revision, and the only new section — §4.13.1 — states that `ref_rules` is a generated table and *not* an authoring surface, which is the index-derives-never-issues rule applied to the implementation.

**Operator-attested, not evidenced here.** This record lists import into the running Grist instance as *not executed*. Adoption into active document `3TwLJyu7fythPjAj1e1424`, and the active-document verification of 143 rules, the 81/48/14 split and `Fixture_coverage.rule_id` as `Reference → Ref_rules`, are **attested by the operator** after this record was written. The central process records the attestation and does not claim to have verified it.

**One note, not a blocker.** §4.13.1 hard-codes **143** as the acceptance total. That number will go stale the moment a rule is added — the same class of defect as the swept counts repaired earlier at 0.21.0. The section's own instruction to treat rule changes as a generated-seed diff requiring corpus re-proof is the mitigation; if it proves insufficient, the total should be read from the index rather than restated.
