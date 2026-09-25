# PATCHES / INTAKE — central inconsistencies found while re-proofing the technical specification

**Raised by:** the technical implementation stream
**Landed by:** the central design-stream process, 10 Aug 2026
**Aligned to:** v0.21.0
**Status:** **RETIRED 10 Aug 2026** — all seven items disposed. R1 `enforced-elsewhere`; R2, R3, R5, R6, R7 `authored`; R4 `struck`. Moved to `Research\`, untracked.

> **This record is a handoff, not authoritative corpus content.** Its premises were verified against the live corpus before disposal, per *a patch record is a proposal, not a finding*. Two of the four claims did not survive that check unchanged, and one was false.

## Items

| # | Type | Finding as raised | Verified? | Disposition |
| --- | --- | --- | --- | --- |
| **R1** | `FINDING` | `◇P7` is closed in P·Part 8 and the 0.20.0 release summary | **Confirmed** | `enforced-elsewhere` — already correct in **P** and the manifest; no change needed there |
| **R2** | `FINDING` | Open Items Index, ROADMAP, Validation Rules Index and the technical specification still describe `◇P7` as open | **Confirmed, and wider than raised** — 6 sites in the Open Items Index, 1 in ROADMAP, 9 in the Validation Rules Index, **11 in the technical specification** including a Stage 2c exit condition and an implementation decision holding `ref_rules` empty | `authored` — Open Items Index §1 + header caveat; ROADMAP Stage 2c; Validation Rules Index §"the index is not fully derived"; technical specification §1 status, §8.2, §390, §442, §849, stage list, open-questions table |
| **R3** | `FINDING` | The Validation Rules Index contains conflicting totals — 139, 140 and 142 in different passages | **Confirmed, and misdiagnosed** — not merely conflicting. **Historical figures had been overwritten**, so changelog rows and release summaries asserted counts that were never true at the time. Cause: blanket string replacement in the *central* process at 0.19.0, 0.20.0 and 0.21.0, compounding each release | `authored` — 5 changelog rows and 8 release-summary claims restored from `Archive/v0.16.0`–`v0.20.0`; live suite table corrected to **143 — 81 / 48 / 14**; by-document tally regenerated from the rows |
| **R4** | `FINDING` | The manifest handoff still requests the retired counter-patch | **False against the live corpus.** The handoff reads `blocking: none` and records the counter-patch retired with all five items `authored`. **The stream read a Google Drive copy; Drive has diverged from `X:\Documentation`, which is the tracked store** | `struck` — no defect in the corpus. **Raised as a new concern instead: there is no rule governing which store is authoritative**, and the ledger cannot see Drive |

## What the central process got wrong, stated plainly

**R3 is central's defect, not the stream's.** The instruction *"never blanket-replace a version string — changelog rows are history"* exists because of the 0.12.0 falsified-history failure. It was violated three releases running by `s.replace("139 rules", "142 rules")`-style sweeps applied across all files, including changelog rows and release summaries.

**The rule caught nothing because nothing checked it.** The sweep rule is prose in the design-stream instructions with no test behind it. The archives were the only surviving record of the true figures, and they are what the repair was derived from.

## Recommended, not yet adopted

| # | Recommendation | Target |
| --- | --- | --- |
| **R5** | **`authored` — P-C11**, plus `tools/history-check.sh`. Scoped to *factual claims* after the first draft returned 71 hits that were deliberate notation migration. **Found nine further violations my manual repair had missed**, all now restored | **P**·Part 9, tracked tool |
| **R6** | **`authored`** — design-stream instructions, §Working environment, plus **`tools/drive-sync.py`**. A mirror *is* achievable, but not with the MCP connector and not from the sandbox: the connector has no update or delete, and the sandbox proxy refuses `*.googleapis.com` with 403. A service account run **on the user's machine** gives update-in-place and trash — but **a service account owns what it creates and has no storage quota on a consumer account**, so creates must come from the owner. Run 10 Aug: 9 updates applied, 4 creates made through the Drive connector as the owner | Design-stream instructions · `tools/drive-sync.py` |
| **R7** | **`authored` — closed 10 Aug 2026.** `ref_rules` populated with 143 source-derived rows and `fixture_coverage.rule_id` migrated to `Reference → ref_rules`, shown by stable `rule_id`. Proof accepted: 143 rows, 143 unique IDs, 81/48/14, byte-identical seed regeneration, unresolved-ID rejection, idempotent rerun, SQLite integrity `ok`. **Realised in the technical specification §4.13.1 and §8.2**; active-document adoption operator-attested | **Technical stream** — implementation, not design |

## No patch required

Reviewed and found consistent: **P**·Part 8 · **P**·Part 9 (`P-C8`, `P-H5`, `P-C10`) · `VERSION-MANIFEST` handoff block · Lexicon §0 and §10A · `FOLDER-LEDGER.json` · `.markdownlint.jsonc` · both instruction documents.

---

## Retirement record

**Measured, not asserted.** Before retiring, the orphan count was re-run: `history-check` clean, ledger clean, and the published regeneration command recovers **143 of 143**. This record raised no orphan.

| Item | Disposition | Where it landed |
| --- | --- | --- |
| **R1** | `enforced-elsewhere` | already correct in **P**·Part 8 and the manifest |
| **R2** | `authored` | 27 stale `◇P7` sites across the Open Items Index, ROADMAP, Validation Rules Index and the technical specification |
| **R3** | `authored` | 5 changelog rows and 8 release summaries restored from `Archive/v0.16.0`–`v0.20.0`; suite corrected |
| **R4** | `struck` | false against the live corpus — the claim described a Drive copy. Raised **R6** instead |
| **R5** | `authored` | **P-C11** and `tools/history-check.sh`, which then found nine further violations |
| **R6** | `authored` | design-stream instructions §Working environment and `tools/drive-sync.py` |
| **R7** | `authored` | technical specification §4.13.1 and §8.2, with the companion record's proof |

**The lane worked end to end.** A stream report arrived, four claims were verified against the corpus before any of them were believed, one was false, one was worse than stated, and the residue produced two enforceable rules and a working tool. That is what the intake lane was built for at 0.20.0, and this is its first full cycle.
