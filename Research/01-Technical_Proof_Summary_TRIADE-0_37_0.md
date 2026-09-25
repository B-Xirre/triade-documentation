# Technical proof summary — 0.37.0 hand-off

**Aligned to:** Triade v0.37.0  
**Date:** 14 August 2026  
**Source:** locally extracted `0_37_0.zip`  
**Scope:** package verification, central-adoption reconciliation, and read-back of the two stream-owned replacements

## Outcome

The central package is structurally intact and M14 is adopted narrowly under M-C12–M-C14. The replacement C and technical Z are ready for manual insertion. C applies CP-3 and aligns to the 186-rule suite; Z v1.3 aligns to 0.37.0 and remains within its hard size limit. No design decision, live Grist mutation, repository migration, fixture run, archive change, or sign-off change is claimed.

Two central-source corrections remain in the companion intake: stale `◇M14` dependency wording in M and P, plus manifest/counter-patch retirement after CP-3 adoption.

## Supplied package — pre-edit verification

| Check | Exit | Measured result |
| --- | ---: | --- |
| `ledger.sh check` | 0 | 34 stored / 34 present; clean |
| `history-check.sh` | 3 | External `Documentation-Archive/Archive` not supplied beside the package |
| `version-check.sh` | 0 | 30 current-state claims; C and technical Z reported as the two internally 0.36.0-aligned stream files awaiting replacement |
| `fence-check.sh` | 0 | 23 files; 0 unclosed; one informational 62-line span in H |
| `suite-check.sh` | 0 | 186 rules; 117/55/14 by ID and by section |
| `retirement-check.sh` | 1 | Two live `n_turns` occurrences: C's enum and the manifest blocker sentence |
| `intake-check.sh` | 0 | 3 records; 14 delivered; 15 open — node-payload 0/9, W18 0/6 |
| `bump-check.sh` | 3 | The ZIP did not include the external `Archive/v0.36.0/` path requested by the command |
| `markdownlint-cli2` | 127 | Executable unavailable in the supplied environment |

These results separate package defects from external-proof dependencies: the ledger, version, fences, suite and intake were clean; history and the first bump invocation lacked their external baseline; markdownlint was unavailable.

## Replacement-overlay verification

The checks were repeated after changing only C and technical Z. The overlay deliberately does not regenerate the central ledger.

| Check | Exit | Measured result |
| --- | ---: | --- |
| `ledger.sh check` | 1 expected | Exactly two modifications: C and technical Z; no added/removed governed file |
| `history-check.sh` | 3 | Same absent external archive dependency |
| `version-check.sh` | 0 | 30 current-state claims aligned to manifest 0.37.0 |
| `fence-check.sh` | 0 | 23 files; 0 unclosed; same informational H span |
| `suite-check.sh` | 0 | 186 rules; 117/55/14 on both axes |
| `retirement-check.sh` | 1 | C is clean; the only survivor is `VERSION-MANIFEST.md:17`, which central must reconcile when retiring CP-3 |
| `intake-check.sh` | 0 | 3 records; 14 delivered; 15 open; no unresolved intake was closed by the replacements |
| `bump-check.sh ../audit-0360-reaudit-3` | 0 | 6 new rule rows and 16 new headings; minor digit is consistent |
| `markdownlint-cli2` | 127 | Executable unavailable; not represented as a pass |

## C replacement read-back

- Header states technical version/alignment **0.37.0**.
- Current design denominator is **186 — 117 Critical / 55 High / 14 Medium**; the proved implementation candidate remains the historical 148-row checkpoint.
- `duration_kind` is `instant / n_ticks / while_active`; operational `n_turns` is removed.
- M-C12, M-C13 and M-C14 are registered as future validation obligations only.
- The separate node-payload/aiming intake is explicitly excluded from the M14 implementation contract.
- The legacy candidate's `innate` reference-family/origin values and `faculty.innate_upper@1` / `faculty.innate_bite@1` rows are marked obsolete and adoption-blocking, not silently deleted or reinterpreted.
- No actor-lineage table or field is invented while `◇P13` remains open.
- The 0.37.0 changelog row states **No AUTHORED DESIGN DECISION**.

## Technical-instructions replacement read-back

- Instructions version **1.3**, aligned to Triade **v0.37.0**.
- Session start now requires every check listed in the current manifest and distinguishes unavailable external dependencies.
- The stop boundary includes unexplained ledger drift, retirement survivors and incomplete intake claims.
- Complete replacement length: **7,919 bytes of the 8,000-byte limit**.
- Authority, PATCHES / INTAKE, replacement, proof and central-adoption boundaries are preserved.

## Verified versus unverified

**Verified:** package membership; ledger integrity before edits; exact replacement-only drift; current version claims; fenced Markdown closure; rule counts and severity axes; intake denominators; bump class against the available full 0.36.0 corpus; replacement instruction length; anchored read-back of every changed current-state contract.

**Not verified or not executed:** external archive continuity at the manifest's stated path; markdownlint; live Grist migration; repository mutation; candidate adoption; 148→186 rule migration; removal of legacy innate rows from actual data; M-C12–M-C14 linter execution; CR-11 schemas; canonical JSON/DuckDB/simulation/traces.

## Manual central adoption sequence

1. Insert the complete C and Z replacements; do not partial-merge them.
2. Apply the three central text/status reconciliations in the companion intake.
3. Retire CP-3 and its counter-patch after confirming C's `n_ticks` enum.
4. Update the manifest support/status rows and regenerate the ledger.
5. Re-run all nine checks with the real `Archive/v0.36.0/` present and markdownlint installed.
6. Preserve the node-payload/aiming intake at 0/9 until central rules its scope and four design questions.
