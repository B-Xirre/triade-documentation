# Triade — [SIM] Numbers Register

**Version:** 0.45.0
**Date:** 2 October 2026
**Status:** Generated from `[SIM]` markers across the ten-document set. **Derived, not authored.**

**Governing principle**, from M: *"Numbers are the output of this process, not an input."*

---

## Convention

| Field | Meaning |
| --- | --- |
| **Value** | Current placeholder. Never authoritative |
| **Source** | Where the number lives. Edit there, regenerate here |
| **Basis** | `derived` (falls out of locked geometry) · `precedent` (shipped game or study) · `arbitrary` (plausible, nothing behind it) |
| **Gate** | The metric that validates or rejects it |
| **On failure** | What the design does if the sweep rejects it. *A number with no failure path is not a `[SIM]` number — it is an unexamined assumption* |

---

## 1. Locked numbers — *not* in this register

| Value | What | Ref |
| --- | --- | --- |
| `ΣF ≤ 0.45` | Floor budget | T · A.2 |
| `F ≤ 0.25` | Per-corner cap | T · A.2 |
| `T = 0.35` | Region threshold | T · A.3 |
| `12 × 3 + 1 = 37` | Grid addresses | T · A3.1 |
| `9` | Stat count | T · A4.1 |
| Edge cap `0–3` | Moment-scale credit | T · B.2 |
| `dm + df + di = 0` | Zero-sum vector rule | T · A2.4 |
| `16 bytes` | Per logical tile cell | W · 9 |
| `2–4` | Zones per combat room — **no exception**; `complex_room` exempts the floor only | K · 4, W · 12 |
| `4` | Visible condition cap | K · 12 |
| `3` | Wound severity tiers | H · 6.4 |
| `14` | Damage types | M · 2A.3 |
| **`N` = 1 / 2 / 3** | **Storeys per Delve level by Stratum band. Derived from the locked 3/6/1 structure and fixed — no archetype override** | **W · 5.8** *(new 0.12.0)* |
| **×9 career** | **Effective-damage multiple, run start to career end. Derived per storey: `9^(1/18)` = 1.130. Compounds across bands — A ×1.44, B ×4.33, C ×1.44** | **M · 9.2** *(new 0.14.0)* |
| **18** | **Storeys per career — `S-W01` levels × `W·5.8` `N`. The pacing unit, not the Delve level** | **M · 9.1** *(new 0.14.0)* |
| **`N` = 2, 3 every 10th** | **Storeys per `[Incursion]` depth. No `N`=1 tier — the Relic gate replaces the teaching band** | **W · 5.9** *(new 0.12.0)* |

**Why the storey counts are locked rather than swept.** `N` partitions the Delve level's space budget rather than multiplying it, so it changes shape, not size. That is what leaves S-W01/S-W02 undisturbed — and it is also why sweeping `N` would be sweeping the wrong thing: the tunable quantity is the *space budget*, not the number of pieces it is cut into.

---

## 2. Register by domain

### 2.1 Credit economy

| ID | Value | What | Basis | Gate | On failure |
| --- | --- | --- | --- | --- | --- |
| S-K01 | 70–85% | Loop Grit share | derived | Loop/Flow/Endure share (K16) | Trickles too generous |
| S-K02 | ≤15% each | Flow and Endure Grit share | derived | as above | Reduce trickle magnitude |
| S-K03 | 60–70% | Edge conversion, competent play | arbitrary | Edge conversion (K16) | Below → noise; above → automatic |
| S-T03 | *unset* | Opening decay rate | arbitrary | Opening age at read (K16) | Governs the read timing window |
| S-T02 | *unset* | Modification budget per run | arbitrary | Class-identity divergence (T·I.4) | The "classless character" failure |

### 2.2 Combat

| ID | Value | What | Basis | Gate | On failure |
| --- | --- | --- | --- | --- | --- |
| S-K04 | 2–3 turns | Out-of-combat position decay | arbitrary | run pacing | Primary pacing lever |
| S-K05 | *unset* | TTK band | arbitrary | Fastest clear must not ignore Instinct and Edge | Lengthen TTK or raise burst cost |
| S-K06 | *unset* | Turn-order churn per round | arbitrary | >1–2 slots average → damping | Readiness noisy not informative |
| S-K07 | *unset* | Finisher frequency | arbitrary | decisive but earned | Retune the Fractured + `[Back-foot]` gate |
| S-K08 | ≈20 | Damage-type matchup surface | precedent | portfolio constraint (M·5.4) | Players cannot learn exceptions |
| **S-K09** | *unset*, non-negative | Aimed-mode surcharge applied to `effective_AP_cost` before commit | arbitrary pending sweep | aimed actions buy meaningful placement leverage without becoming mandatory or free | Too low → every eligible action aims; too high → aimed mode is dead content |

### 2.3 Anatomy & health

| ID | Value | What | Basis | Gate | On failure |
| --- | --- | --- | --- | --- | --- |
| **S-H01** | sums to 110 | Body node coverage weights — **relative, per-pair** | **derived** — normalised by H-M2; the 110 sum is legal | wound incidence by node | *Reclassified 0.13.0. It was never a defect: H·5.4 said the weights were relative, the schema said so, and H-M2 already normalised them. The register restated an existing rule* |
| S-H02 | 1.40 / 1.25 / 1.20 | `hp_transfer` per node | arbitrary | wound incidence by node | Vitals unfrightening, or lethal lottery |
| S-H03 | 1.75 / 1.50 / 1.70 | `systemic_weight` per node | arbitrary | crisis-state onset rate | Fires too early or never |
| S-H04 | 0.20 / 0.45 / 0.70 | Minor / Major / Critical thresholds | precedent — AIS | severity distribution | Compressed or unreachable tiers |
| S-H05 | routing shares | Six archetype profiles + deltas | arbitrary | wound-family distribution | Collapse or expand archetype count |
| S-H06 | ≤ ~5% | Death-spiral index | arbitrary but **a real ceiling** | death-spiral index (H·14) | Loosen recovery or soften fields |
| S-H07 | *unset* | Recovery clock / treatment costs in Marks | arbitrary | service usage non-trivial. **Now also gates S-W13** | Services become dead content |
| S-H08 | `max(Φ_safe_x, 0.5 × Φ_base_x)` | Trauma Safety Clamp | `Φ_safe_x` **derived**; 0.5 arbitrary | region residency non-zero everywhere | Clamp failing = H-C1 violation |
| **S-H09** | *unset*, **< 1.0** | `AIM_CEILING` — max aim weight on the coverage cascade | **derived** — the mirror of A3.7's potency floor above zero | node distribution under aimed fire stays non-degenerate | At 1.0 aiming is deterministic and coverage weights become decorative |
| **S-H10** | *unset* | Occult load threshold converting to ward scars | arbitrary | town rite usage non-trivial; in-combat purge stays strategically partial | Too high → the rite is dead content; too low → purge is pointless |

### 2.4 Enemies

| ID | Value | What | Basis | Gate | On failure |
| --- | --- | --- | --- | --- | --- |
| S-E01 | *unset* | Behaviour tag library size | arbitrary | tag learnability. **Harness: `[Incursion]` depth (◇E9)** | Players stop learning tags |
| S-E02 | *unset* | Encounter tag diversity threshold | arbitrary | encounter variety. **Harness: `[Incursion]` depth (◇E9)** | Three enemies play as one |
| S-E03 | *unset* | Commander Signature frequency | arbitrary | "threatening but preventable" (K16) | **Now also gates S-W14** |

### 2.4a Run contract

| ID | Value | What | Basis | Gate | On failure |
| --- | --- | --- | --- | --- | --- |
| **S-M01** | **2 per storey** (36 career) | Major acquisitions | **precedent** — best-documented comparator gives ~24–25 cards + ~15–21 relics per winning run; band B at 24 sits on it | per-pick value stays perceptible; dead-build incidence < 5% | Adjust drop density, **not** affix count — the 6.3% constant is what makes loot legible |
| **S-M02** | **×9** | Career effective-damage multiple | **derived** — per storey from locked geometry; inside the 8–15× comparator band | career power spread; cleared bands do not trivialise | Below → progression feels flat; above → four-digit numbers and a forced squish |
| **S-M03** | **×3** | Career effective survivability | precedent — grows slower than output universally | death-spiral index (S-H06) | Raise if TTK against the player collapses late |
| **S-M04** | `0.92 + 0.18x` | Enemy encounter-budget ratio | arbitrary — shape derived from "start below, end above" | challenge ratio across bands | **The guard against a ×9 career trivialising cleared bands** (◇W17/◇E11) |
| ~~**S-M05**~~ | ~~*unset*~~ | **STRUCK 0.29.0** — the shield split was **authored** in M·2A.11 (buckler 2/0, standard 1/1, tower 0/2), not measured. A register entry whose value is decided by design has no gate to pass and no failure path of its own | — | — | — |

**S-M02 is `derived`, not `arbitrary`.** Choose the career target and the per-band split is arithmetic. The per-acquisition value then falls out at `9^(1/36)` = **6.3%, constant across the career** — that constant is the design property, not a tuning dial.

### 2.5 World & meta-progression

| ID | Value | What | Basis | Gate | On failure |
| --- | --- | --- | --- | --- | --- |
| S-W01 | 3 / 6 / 1 | Delve levels per Stratum band | derived from boss placement | run-length distribution | Rebalance band lengths |
| S-W02 | **30–45 / 60–90 / 75–110 min** | Band length targets *(band C reduced from 2–3 hr at 0.14.0)* | **precedent** — turn-based comparators cluster 45–90 min per complete run | run-length distribution | Adjust density, not numbers |
| S-W03 | *unset*, **steeply increasing** | Stratum lock cost | shape derived, magnitude arbitrary | push-vs-bank split | **The widest blast radius in the design.** A carried `[Relic]` now adds a third banking pressure, which relieves it |
| S-W04 | *unset*, decreasing with depth | Descent unlock cost | shape derived | depth pacing | — |
| S-W05 | 0.15–0.35 / 0.30–0.55 / 0.45–0.70 | Cover density by Territory axis | arbitrary | cover density in band | Territories stop reading as their axis |
| S-W06 | *unset* | `N` — technique slots per run | arbitrary, fixed constant | build variety | Depth buys power not choice |
| S-W07 | ≤ 50 ms | Generation budget per level | precedent | perf | **Redefined at 0.12.0 — see §2.7** |
| **S-W08** | *unset* | `complex_room` template frequency cap per Delve level | arbitrary | zone-count distribution ≥95% within 2–4 | Authored set-pieces dominate |
| **S-W09** | *unset* | Storey-boundary streaming budget | arbitrary | no player-visible hitch at transition | Pre-stream or reduce storey size |
| **S-W10** | *unset* | Render-bake budget per level | arbitrary | no hitch at descent | Stream or amortise |
| **S-W11** | *unset* | Upper-deck footprint cap over path-critical lower cells | **derived — the integer proxy for readability** | validated against V·4.9's render suite | Raise cap, add cutaway |
| **S-W12** | *unset* | `[Incursion]` saturation depth | **derived from max Location Delve** | no drop exceeds M·2.5's band | Hard cap on ilvl |
| **S-W13** | *unset* | **Net Marks per `[Incursion]` run, after recovery** | derived — the band is set by H's recovery pricing | within band of an equivalent-duration Location run (S-H07) | Too high → recovery stops biting; too low → dead content. **Reagent share is the first dial** |
| **S-W14** | *unset* | `high_ground` zone density band | **derived-pending — must be set against S-E03** | Commander Signature frequency stays "threatening but preventable" | Reduce vertical quota or re-gate Advantage-banking |

### 2.5a Content pipeline

| ID | Value | What | Basis | Gate | On failure |
| --- | --- | --- | --- | --- | --- |
| ~~**S-P01**~~ | **12 000** — *closed 0.34.0* | Fixed-point scale for `_q` columns | **derived** — the smallest scale exactly representing the Triade fractions the corpus actually uses: `1/3 = 4 000_q`, `1/12 = 1 000_q`, `0.05 = 600_q`, `0.25 = 3 000_q`, `0.35 = 4 200_q`, `0.45 = 5 400_q` — and `1/6`, `0.1` besides | **Closed by ruling, not by sweep.** It was never a tuning dial: **W-C10** bars float-derived values from the proof digest, so this is a correctness constant | — |
| **S-P02** | *unset* | Trace rows and bytes per 10k-seed sweep at full analytical density | arbitrary | partition strategy holds; DuckDB queries stay interactive | Reduce capture level, or partition by encounter rather than run date |

**S-P01 is not a tuning dial.** It is a correctness constant: **W-C10** bars float-derived values from the proof digest, so the scale must be chosen once, versioned, and never silently changed. A changed scale invalidates every stored trace.

### 2.6 Tile pipeline

| ID | Value | What | Basis | Gate | On failure |
| --- | --- | --- | --- | --- | --- |
| **S-G01** | *unset* | Tile family count per Territory package | arbitrary | authoring cost per package | Reduce variant count, lean on symmetry classes |
| **S-G02** | *unset* | Socket vocabulary size | arbitrary | adjacency matrix auditable by hand | Split vocabularies per pass |

### 2.7 UI & legibility

| ID | Value | What | Basis | Gate | On failure |
| --- | --- | --- | --- | --- | --- |
| **S-V01** | < 0.5 s | Posture recognition time | precedent, **and a locked instruction** | prototype test (T·J.9, ◇V6) | **"Simplify the maths — not the UI"** |
| S-V02 | < 0.5 s | Wounded-enemy anchor-neighbourhood read | same | prototype (V·4.8) | Wound overlay does not ship |
| S-V03 | *unset* | Tooltip number cap | arbitrary | readability | Five resources spendable at town |
| **S-V04** | *unset* | Posture recognition at a **fixed** angle | **derived from S-V01** | ◇V6 prototype | **The ◇V2 camera amendment does not stand.** Restore discrete viewpoints or rotation |

### 2.8 The generation budget, redefined at 0.12.0

S-W07's ≤50 ms was written before the pipeline had fourteen stages. It is now scoped by stage class rather than raised:

| Class | Stages | Budget |
| --- | --- | --- |
| **Runtime logical generation** | Brief → mission → storey graph → room graph → embedding → **progression placement** → deck masks → tile realisation → progression proof → furnishing → surfaces → zone extraction | **≤ 50 ms** (S-W07 as locked) |
| **Runtime render bake** | Tilemap layers, pivots, occlusion, cutaway masks, collision/nav | S-W10, amortisable / streamable |
| **Offline corpus proofing** | 10k-seed sweeps, encounter sim, expressive-range metrics | Unbounded, CI |

---

## 3. Sweep dependency order

```
LOCKED GEOMETRY (never swept)
  └─> S-H08 Φ_safe_x
        └─> S-H06 death-spiral index
              └─> S-H02/03/04/05 anatomy magnitudes
                    └─> S-H09 AIM_CEILING     <-- NEW 0.13.0
                    (S-H01 no longer blocks — reclassified, not a defect)

S-H07 recovery cost
  └─> S-H10 occult load threshold             <-- NEW 0.13.0
        └─> occult economy sink pricing

S-K01/02 Grit shares
  └─> S-K03 Edge conversion
        └─> S-K05 TTK band
              └─> S-H06

S-W01 band structure
  └─> S-W03 lock cost      <-- widest blast radius
        └─> S-W04 descent discount

S-E03 Commander Signature frequency        <-- NEW BRANCH 0.12.0
  └─> S-W14 high-ground density
        └─> vertical profile quota (W-H7)

S-H07 recovery cost
  └─> S-W13 net Incursion Marks
        └─> reagent share (first dial)

S-V01 posture recognition
  └─> S-V04 posture at fixed angle
        └─> ◇G4 projection lock
              └─> every tile asset ever produced
```

**Three observations.**

**S-H01 no longer blocks anything.** Reclassified at 0.13.0 from `defect` to `derived`: the weights are relative and H-M2 normalises them, so the 110 sum was always legal. The register had carried a restatement of an existing rule as a blocking defect for two versions. **The anatomy branch is open.**

**S-V04 is new and has the longest downstream chain.** The projection lock gates every tile asset, and a failed posture test after assets exist is the most expensive failure in this register. It should be run before the tile pipeline produces anything.

**S-E03 gained a dependent.** High-ground density is now a boss-difficulty input, so Commander Signature frequency must settle before vertical quotas are set — not after.

---

## 4. Basis audit

| Basis | Count | Reading |
| --- | ---: | --- |
| `derived` | 12 | Falls out of locked geometry. Low sweep risk |
| `precedent` | 5 | Directional, not authoritative |
| `arbitrary` | 25 | Plausible placeholder, nothing behind it |
| **defect** | **0** | *S-H01 reclassified at 0.13.0 — it was never one* |

**Forty-three values, twenty-five arbitrary.** The `derived` count rose from 7 to 12, mostly because the 0.12.0 decisions were taken *against* locked geometry rather than alongside it — `N`, S-W11, S-W12, S-W13 and S-W14 all derive from something already fixed.

---

## 5. Regeneration

```bash
grep -nE "\[SIM\]" [A-Z]-*_TRIADE-0_45_0.md
```

---

## Changelog

| Version | Change |
| --- | --- |
| **0.45.0** | Regenerated after C1-A–E; no tuning values or SIM identities added or removed. Existing numerical register retained; enhancement tuning remains later content work. |
| **0.44.0** | Regenerated after P12-C. No `[SIM]` marker opens, closes or changes; plan windows and response delays remain authored per action rather than universal balance constants. |
| **0.43.0** | Regenerated after P12-B candidate-readiness reconciliation. No `[SIM]` marker opens, closes or changes. |
| **0.42.0** | Regenerated after P12-A entitlement reconciliation. No `[SIM]` marker opens, closes or changes. |
| **0.41.0** | Regenerated after P11 Faculty reconciliation. No `[SIM]` marker opens, closes or changes. |
| **0.40.0** | Regenerated after P13/Somatic reconciliation. No `[SIM]` marker opens, closes or changes. |
| **0.39.0** | **S-K09 registered** from K·3.4 — the aimed-mode action-time surcharge. Its sign and timing are authored; its curve remains a measured balance output. |
| **0.38.0** | 3 Territory projections regenerated from source markers. |
| **0.29.0** | **`S-M05` struck** — the shield split was authored in M·2A.11 rather than measured. A value decided by design has no gate to pass. |
| **0.28.0** | **`S-M05` registered** — the shield split position. Ordering is locked by 2A.11's sub-family table; the spacing is arbitrary and gated on the dominance test. Its failure path names **M-C9**, not itself. |
| **0.27.0** | Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Ref **Y**. §regeneration glob repointed. Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **8 glyphed identifiers in this document.** |
| **0.15.0** | **Two values added** — S-P01 (fixed-point scale) and S-P02 (trace volume per sweep), both from the new **P** document. S-P01 is flagged as a *correctness* constant rather than a tuning dial: it is chosen once and versioned, and changing it invalidates every stored trace. |
| **0.14.0** | **Four values added** — S-M01…S-M04, the run contract. **Two values promoted into §1 as locked:** the ×9 career multiple and the 18-storey career, both derived from geometry already fixed. **S-W02's band C reduced from 120–180 to 75–110 min** and its basis raised from `arbitrary` to `precedent`: the old figure asked 8–18× the per-Delve pace of bands A and B and contradicted W·5.8's own partition rule. Both independent Gate 0 studies derived that contradiction separately. |
| **0.13.0** | **Two values added** — S-H09 (`AIM_CEILING`, derived from A3.7's potency floor by symmetry) and S-H10 (occult load → ward scar threshold). **S-H01 reclassified from `defect` to `derived`**, removing the register's only defect and unblocking the entire anatomy sweep branch; the entry had restated rule H-M2 while presenting itself as a blocker. Defect count 1 → 0. |
| **0.12.0** | Regenerated for nine documents. **Nine values added** — S-W08…S-W14, S-G01, S-G02, S-V04. Two storey counts moved into §1 as **locked, not swept**, with the reason stated: `N` partitions space rather than multiplying it, so the tunable quantity is the space budget. S-W07 rescoped by stage class rather than raised. Two new sweep branches: S-E03 → S-W14 (high-ground density is a boss-difficulty input) and S-H07 → S-W13 (Incursion Marks against recovery cost). S-V04 identified as having the longest downstream chain in the register — it gates the projection lock and therefore every tile asset. |
| **0.11.0** | Register created. Thirty-four values catalogued. Locked numbers separated. S-H01 flagged as a defect; S-W03 identified as highest-leverage. |
