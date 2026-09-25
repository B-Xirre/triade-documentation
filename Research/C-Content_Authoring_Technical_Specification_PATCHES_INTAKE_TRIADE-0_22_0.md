# Content Authoring Technical Specification — PATCHES / INTAKE

**Aligned Triade version:** 0.22.0  
**Companion to:** `C-Content_Authoring_Technical_Specification_TRIADE-0_22_0.md`  
**Purpose:** handoff from the M10 dependency-layer technical run to the central process  
**Status:** **RETIRED 10 Aug 2026** — all five items disposed at 0.23.0. Moved to `Research\`, untracked.  
**Authority:** non-authoritative intake record; no design IDs are minted here

## Intake items

### TS-M10D-1 — Standard Shield integrity path

- **Type:** `AUTHORED DESIGN DECISION`
- **Decision:** for the M10 Standard Shield working implementation, use `stable → cracked → broken_guard`; exclude `fractured` from this shield profile.
- **Implementation pressure:** `Integrity_states` requires an ordered state set before `shield.standard@1` can reference a complete integrity profile.
- **Evidence:** M·2A.6 states `Stable → Cracked → Fractured`, plus `Broken Guard` for shields and rigid off-hand defence; M·2A.11 requires a shield-owned integrity track separate from body armour.
- **References checked:** M·2A.6; M·2A.11; P·1.1; C·5.7; C·5.12; R rule M-C4.
- **Affected documents:** M, C, and later fixture/equipment records.
- **Recommended target:** M·2A.6.
- **Recommended wording:** “Shield and rigid off-hand profiles replace the general `Fractured` terminal with `Broken Guard`: `Stable → Cracked → Broken Guard`. Body-armour profiles retain `Stable → Cracked → Fractured`.”
- **Implementation consequence:** `integrity.shield_standard` contains three ordered states; `broken_guard` disables Discipline Opening-creation; `_q` modifiers remain blank.
- **Material alternative rejected:** four-state shield path `Stable → Cracked → Fractured → Broken Guard`; rejected because it makes the shield pass through the body-armour Finisher-gate state without a source statement that a broken shield opens a body Finisher.
- **Impact if not adopted:** central must select another shield path and the three seeded `Integrity_states` rows must be migrated before approval.
- **Implementation blocker:** no for the working fixture; yes for authoritative approval.
- **Central disposition:** **`authored` — M·2A.6, 0.23.0.** The reading is correct and the rejected four-state alternative is rejected for the right reason: K·2 gates the Finisher on *Fractured/Broken Guard*, which are alternative terminals, and nothing states that a broken shield opens a **body** Finisher. Authored with the trade-off named — shield attrition is coarser by one step than body armour's.
- **Reconciliation notes:** now centralised. **P-C10 satisfied**; the technical document may cite it as an existing rule from 0.23.0.

### TS-M10D-2 — Standard Shield has no medium Bridge-2 mapping

- **Type:** `FINDING`
- **Finding:** M·2A.11 classifies the Standard Shield as `medium`, while M·2A.7 and the technical enum provide mechanisms only for heavy, light and cloth/none. No source states the Standard Shield's `bridge2_mechanism`.
- **Implementation pressure:** `construction.shield_standard` has a typed `bridge2_mechanism` field.
- **Evidence:** M·2A.7 maps heavy → `edm_damping`, light → `home_well_strengthening`, cloth → neither; M·2A.11 calls Standard Shield medium.
- **References checked:** M·2A.7; M·2A.11; C·5.8.
- **Affected documents:** M and C.
- **Recommended target:** M·2A.7.
- **Recommended wording:** define whether medium uses `none`, a blend, or a fourth mechanism class; then patch C's Choice enum if required.
- **Impact if not adopted:** Standard Shield construction remains incomplete and the defence/lean-scaling stage cannot claim full Bridge-2 validation.
- **Implementation blocker:** no for dependency identity; yes for complete shield physical authoring.
- **Central disposition:** **`backlog` — ◇M11, home M.** Registered in M·2A.11 and the Open Items Index. **The finding understates it:** `medium` is not merely unmapped, it is **not a member of the weight-class set M·2A.7 defines** — three classes exist, each with a displacement mechanism, and `medium` is none of them. Either 2A.7 gains a fourth class or 2A.11 stops using the value. Not resolvable by derivation, so it is backlogged rather than decided.
- **Reconciliation notes:** leaving the field blank is correct. Blank is not `none`, and `none` is Cloth's mechanism — writing it would assert a design answer.

### TS-M10D-3 — 0.22.0 technical alignment corrections

- **Type:** `FINDING`
- **Finding:** the renamed 0.22.0 technical specification retained internal `Aligned to Triade: v0.21.0`, `content_version = 0.21.0`, and pre-adoption R7 status text.
- **Implementation pressure:** new rows and proof artefacts must state their actual governed design-set version.
- **Evidence:** VERSION-MANIFEST current version 0.22.0; C header, C·5.3 and C·8.2 in the Drive copy.
- **References checked:** VERSION-MANIFEST; C header; C·1; C·5.3; C·8.2; C·9.
- **Affected documents:** C only, plus manifest status wording.
- **Recommended target:** C header, C·1, C·5.3, C·8.2, C·9 and changelog.
- **Recommended wording:** use `v0.22.0`, set new authored rows to `content_version = 0.22.0`, record active R7 adoption as complete, and mark M10 dependency population complete.
- **Impact if not adopted:** future rows claim the wrong content version and technical status remains behind the governed set.
- **Implementation blocker:** yes for closing this technical run.
- **Central disposition:** **`authored`** — updated C document accepted at 0.23.0. Authority check passed: no rule, term or marker count changed, and `P-C999` remains a negative fixture that never leads a line.
- **Reconciliation notes:** corrected in the supplied replacement C document; no game-design change.

### TS-M10D-4 — VERSION-MANIFEST technical status

- **Type:** `FINDING`
- **Finding:** the manifest still says the R7 active document is operator-attested but not centrally verified and does not record partial completion of Stage 2 step 8.
- **Implementation pressure:** the user confirms central validation and the dependency candidate now has executable proof.
- **Evidence:** active-document R7 proof: 143 rows, 81/48/14 split, stable rule Reference; current dependency proof: 5/1/3/2 rows and byte-identical exports.
- **References checked:** VERSION-MANIFEST Supporting; C·1; C·9; `docs/M10_DEPENDENCY_IMPLEMENTATION_PROOF.md`.
- **Affected documents:** VERSION-MANIFEST.
- **Recommended target:** Supporting → Technical implementation status; Session handoff → next action.
- **Recommended wording:** record R7 as centrally validated; record M10 dependency layer complete in candidate; next action is active adoption followed by the five equipment revisions.
- **Impact if not adopted:** handoff status remains stale and may cause R7 rework or skipped dependency adoption.
- **Implementation blocker:** no.
- **Central disposition:** **`authored`** — manifest Supporting and handoff updated at 0.23.0.
- **Reconciliation notes:** correct not to edit it here.

### TS-M10D-5 — ROADMAP Stage 2c progress

- **Type:** `FINDING`
- **Finding:** ROADMAP still states “M10 data population is next”; the dependency subset is now implemented and proved, while equipment revisions remain next.
- **Implementation pressure:** stage tracking should distinguish dependency completion from equipment/faculty/fixture completion.
- **Evidence:** `m10_dependencies_result.json` and byte-identical exports.
- **References checked:** A-ROADMAP Stage 2c; C·6.1; C·9.
- **Affected documents:** A-ROADMAP.
- **Recommended target:** Stage 2c → implementation progress.
- **Recommended wording:** “M10 dependency layer complete in an offline candidate: 5 chassis, 1 shield integrity profile, 3 shield states, 2 construction profiles. Five equipment revisions are next.”
- **Impact if not adopted:** roadmap understates completed work but no implementation rule is affected.
- **Implementation blocker:** no.
- **Central disposition:** **`authored`** — A-ROADMAP Stage 2c updated, dependency layer only.
- **Reconciliation notes:** honoured; the whole M10 population is **not** marked complete.

## No patch required

- **P — Content Pipeline & Data Model:** logical relations and scalar-authoring rules already cover this implementation.
- **R — Validation Rules Index:** no rule was added, removed or reworded.
- **B — Open Items Index:** ◇P3 and ◇P8 remain unchanged; the authored decision receives no ID before a central design home.
- **L — Lexicon:** only technical machine IDs were introduced; no authoritative game term was added.
- **H, K, E, W, G, V, T:** reviewed for direct dependency consequences; none requires a source change from this stage.
- **Technical-stream Project Instructions:** no governance/workflow change occurred; no replacement is required.

## Change log

| Version | Date | Change |
| --- | --- | --- |
| 0.22.0 | 10 Aug 2026 | Initial companion for the M10 dependency-layer run: one authored design decision and four findings. |


---

## Central disposition summary — 0.23.0

| Item | Type | Disposition | Home |
| --- | --- | --- | --- |
| **TS-M10D-1** | `AUTHORED DESIGN DECISION` | **`authored`** | M·2A.6 |
| **TS-M10D-2** | `FINDING` | **`backlog`** | **◇M11**, home M |
| **TS-M10D-3** | `FINDING` | `authored` | C accepted at 0.22.0 content, 0.23.0 rename |
| **TS-M10D-4** | `FINDING` | `authored` | VERSION-MANIFEST |
| **TS-M10D-5** | `FINDING` | `authored` | A-ROADMAP Stage 2c |

**Premises verified against the corpus before disposal, not taken from the record.** M·2A.6's wording, K·2's Finisher gate, M·2A.7's three weight classes and M·2A.11's `medium` assignment were each read in the source document. Two survived unchanged; **TS-M10D-2 was understated** and is recorded as the wider defect it is.

**First use of `AUTHORED DESIGN DECISION`, and the lane behaved as designed.** The stream resolved a question it could not proceed without, implemented against it, marked it non-authoritative, and handed it over. The central process checked the reasoning against the sources and authored it. **P-C10 is now satisfied**: from 0.23.0 the technical document may cite `Stable → Cracked → Broken Guard` as an existing rule rather than as authored-but-not-yet-centralised.
