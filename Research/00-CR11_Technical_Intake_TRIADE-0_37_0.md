# CR-11 Technical Stream PATCHES / INTAKE — Triade 0.36.0

**Input:** `round 3.zip`  
**Input SHA-256:** `2ae7c8f1e2a2c11be69b0fa2719a0ed2b0a0d96066d4307a4f41c5a96c63e52e`  
**Technical re-audit:** **PASS**  
**Candidate status on arrival:** `signed_off` PENDING  
**Released baseline on arrival:** 0.35.0  
**Stream replacements:** C and technical-stream Z supplied with this intake  
**AUTHORED DESIGN DECISION:** none

## Adoption ruling

Round three closes the remaining CR-11 blockers:

- T's Dot Framework now evaluates by tick and stores `n_ticks`, explicitly against `world_tick`, rather than turns.
- H's `hp_tick` is an integer `_q` quantity per elapsed `world_tick`, not a binary float per elapsed AP.
- The manifest is dated 14 August 2026 and correctly states that the unsigned 0.36.0 candidate is not for mirroring before stream sign-off.
- W·11 layering remains restricted to mutually exclusive state at one carrier address + face + domain + exclusive group.
- `◇W7` remains open and Stage 3 continues to forbid ADM/CDM/EDM influence until it is separately resolved.

The design candidate is technically coherent for CR-11 intake. Central may adopt the supplied stream-owned replacements and then move `signed_off` from PENDING to its signed-off state. Until central performs that adoption, the package remains unsigned and 0.35.0 remains the released baseline.

## Executable proof

| Check | Exit | Measured result |
| --- | ---: | --- |
| ZIP integrity | 0 | 26 governed files; no compressed-data error |
| Ledger | 0 | 26 stored / 26 current; CLEAN |
| History | 3 | External archive absent; historical comparison not executed |
| Version | 0 | 30 current-state claims; only expected stream-owned warnings for stale C ×2 and Z ×1 |
| Fence | 0 | 19 files; 0 unclosed; 1 informational long span |
| Suite | 0 | **183 rules — 114 Critical / 55 High / 14 Medium**; ID, section, uniqueness, printed totals and by-document totals agree |
| Markdown lint | 0 | CLEAN |
| Shell syntax | 0 | CLEAN |
| Python compile | 0 | CLEAN |

The missing external archive is the only unexecuted governance check. This intake makes no new historical claim from the absent archive.

## Replacement summary

### C — Content Authoring Technical Specification

- aligned from internal 0.35.1 to **0.36.0**;
- separates the current **183-rule design denominator** from the proved but stale **148-rule v0.29.0 Grist candidate**;
- registers P·3's five CR-11 families as pending technical realization without claiming tables, migrations or fixtures that were not executed;
- records CR-11 acceptance boundaries for pinned revisions, normalized repeatables, `world_tick`, K-C15 order, W-C32 state separation, W-C34 batching and P-C12 fixed point;
- preserves every prior implementation checkpoint and hold;
- records **no AUTHORED DESIGN DECISION**.

### Z — Technical Stream Project Instructions

- changes only `Aligned to Triade: v0.34.0` → `v0.36.0`;
- retains instructions version 1.2 and every workflow/authority rule;
- remains within the 8,000-character project-instruction limit.

## Intake items

### TS-CR11-R3-01 — Residual conceptual float notation

**Type:** FINDING  
**Evidence:** H·7.3 still uses `float` for `severity`, `hp_max_cap` and `opening_mod`; T·A2.4 illustrates dynamics as `0.0 | small`.  
**Sources checked:** P-C12; P·3; H·7.3; T·A2.4; W·10.  
**Affected documents:** H, T.  
**Recommended target:** H·7.3 and T·A2.4 editorial cleanup.  
**Impact if not adopted:** a reader may mistake conceptual notation for a canonical binary-float contract.  
**Implementation blocker:** no.  
**Central disposition:** `enforced-elsewhere` — P-C12 already controls canonical persistence and proof digests; C now implements that boundary explicitly. No new rule is required.

### TS-CR11-R3-02 — CR-11 tables are registered, not implemented

**Type:** FINDING  
**Evidence:** P·3 fixes five row grains; the supplied Grist/repository checkpoint contains none of their concrete tables, migrations or proof fixtures.  
**Sources checked:** P·3; W·11; G·5; K·3.5–3.6; C·5.24 and C·8.9.  
**Affected documents:** technical C and future repository/Grist implementation only.  
**Recommended target:** next technical implementation run.  
**Impact if not adopted:** CR-11 remains design-authoritative but unavailable to canonical content authoring.  
**Implementation blocker:** yes for CR-11 implementation, no for design-set adoption.  
**Central disposition:** `enforced-elsewhere` — design ownership already exists in P/W/G/K; implementation work is recorded in C rather than duplicated as a new design item.

### TS-CR11-R3-03 — `ref_rules` requires 148→183 migration

**Type:** FINDING  
**Evidence:** the last mechanically proved offline candidate contains 148 unique v0.29.0 rules; the current suite measures 183.  
**Sources checked:** R; `tools/suite-check.sh`; C·4.13, C·8.2 and C·9.  
**Affected documents:** technical C, Grist `ref_rules`, `fixture_coverage`, export seed and repository proof artifacts.  
**Recommended target:** next technical implementation run, before adopting the old offline candidate.  
**Impact if not adopted:** 35 current design rules cannot resolve through the protected reference layer.  
**Implementation blocker:** yes for operator adoption of that candidate, no for design-set adoption.  
**Central disposition:** `enforced-elsewhere` — P-C8 and the current R index already own derivability; this is a technical migration, not a new design decision.

### TS-CR11-R3-04 — Non-normative editorial residue

**Type:** FINDING  
**Evidence:** M line 97 retains an unfinished quotation; R's 0.36.0 changelog omits W-C34/K-C15; K·3.4a retains executable-looking prose under an expressly retired heading.  
**Sources checked:** M·1.5; R changelog; K·3.4a; K-C11/K-C12/K-C15.  
**Affected documents:** M, R, K.  
**Recommended target:** next central editorial pass.  
**Impact if not adopted:** avoidable reader ambiguity; no current rule conflict because the owning current rules are explicit.  
**Implementation blocker:** no.  
**Central disposition:** `backlog` — cleanup only; do not mint a new design rule or open-item ID.

## No patch required

Reviewed without further central patch: A, B, E, G, V, W, Y, P's CR-11 row grains, K-C15 ordering, H-C8, L's CR-11 terms, W-C32/W-C33/W-C34, the open `◇W7` home/index pair, the strengthened suite check, design-stream instructions, ledger and governed filenames.

## Central adoption steps

1. Replace governed technical C with the supplied 0.36.0-aligned C.
2. Replace governed technical-stream Z with the supplied v0.36.0-aligned Z.
3. Update the manifest's technical-document and instruction status from awaiting replacement to current.
4. Move `signed_off` from PENDING only after reading back both replacements.
5. Regenerate the ledger and rerun version, fence, suite and Markdown checks.
6. Run history verification with the external archive attached.
7. Mirror only after final central sign-off; the candidate's own manifest correctly forbids pre-sign-off mirroring.

## Deliverables — central adoption

- [x] W·11 layering precedence narrowed — `W-World_Generation_design` · §11, W-C32
- [x] Stage 3 revised without answering `◇W7` — `W-World_Generation_design` · §18 stage table
- [x] Airborne Volume, deterministic batching, atomic geometry — `W-World_Generation_design` · §11, W-C34
- [x] `world_tick` pulse propagation, `contamination` activated — `W-World_Generation_design` · §11, W-C33
- [x] Timeline nodes, milestones, Intent Markers, Ghost Track — `K-Combat_design` · §3.5, K-C13, K-H3
- [x] Environmental nodes, manipulation, same-tick priority — `K-Combat_design` · §3.6, K-C15
- [x] Armed Intercept Nodes, Watch economy preserved — `K-Combat_design` · §8.1a, K-C14
- [x] Fourth surface expanded, not a fifth added — `V-Visual_design` · §4.8
- [x] Condition durations on `world_tick` — `H-Damage_Health_design` · §7.1b
- [x] Record families with row grains — `P-Content_Pipeline_design` · Part 3
- [x] Transmission-hook contract — `G-Tile_Pipeline_design` · Part 5
- [x] Elapsed-time integration bound to `world_tick` — `T-Core_Mechanic_design` · G.3
- [x] Perception-limited bot inputs — `E-Enemies_design` · F.2
- [x] Environmental and timeline vocabulary — `L-Lexicon_design` · §9D

**Every item names a document and a section**, so the claim is checkable by grep rather than by memory. `tools/intake-check.sh` enforces it.
