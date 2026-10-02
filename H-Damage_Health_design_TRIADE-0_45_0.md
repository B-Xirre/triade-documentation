# Triade Roguelike — Damage & Health Design Plan

**Version:** 0.45.0
**Date:** 2 October 2026
**Status:** Merged draft — architecture settled, numbers pending simulation
**File convention:** `H-Damage_Health_design_TRIADE-0_45_0.md` → `outputs/analysis/`

---

## Provenance markers

This document is a reconciliation of two independently written reports plus the decisions settled in discussion. Every non-obvious decision is marked so the merge is auditable:

| Marker | Meaning |
| --- | --- |
| **[W]** | Carried from the Claude-authored report |
| **[U]** | Carried from the user-authored report |
| **[BOTH]** | Independently converged in both reports — treated as high-confidence |
| **[NEW]** | Emerged during reconciliation discussion; in neither original |
| **[LEXICON+]** | New term proposed as *provisional* for `triade-lexicon` |
| **[SIM]** | Number is a provisional target; final value derived from simulation per K17 |
| **[OPEN]** | Explicitly unresolved; listed in §17 |

## Source documents consumed

All at **0.39.0**, from the authoritative `X:\Documentation` set. This is one of **ten** design documents; filename convention standardised at 0.10.0 to `TRIADE-[System Name] design-[Version]`:

| Ref | Document | Filename |
| --- | --- | --- |
| **T** | Core Mechanic | `T-Core_Mechanic_design_TRIADE-0_45_0.md` |
| **M** | Stats, Items, Equipment | `M-Stats_Items_Equipment_design_TRIADE-0_45_0.md` |
| **L** | Lexicon | `L-Lexicon_design_TRIADE-0_45_0.md` |
| **V** | Visual Design | `V-Visual_design_TRIADE-0_45_0.md` |
| **K** | Combat Design | `K-Combat_design_TRIADE-0_45_0.md` |
| **W** | World, Maps & Dungeons | `W-World_Generation_design_TRIADE-0_45_0.md` |
| **H** | **Damage & Health** — *this document* | `H-Damage_Health_design_TRIADE-0_45_0.md` |
| **E** | Enemies & Bestiary | `E-Enemies_design_TRIADE-0_45_0.md` |
| **G** | Tile Pipeline | `G-Tile_Pipeline_design_TRIADE-0_45_0.md` |
| **P** | **Content Pipeline & Data Model** | `P-Content_Pipeline_design_TRIADE-0_45_0.md` |
| — | *Open Items Index* | `B-Open_Items_Index_TRIADE-0_45_0.md` |
| — | *SIM Numbers Register* | `Y-SIM_Numbers_Register_TRIADE-0_45_0.md` |
| — | *Validation Rules Index* | `R-Validation_Rules_Index_TRIADE-0_45_0.md` |

This document is **H**. It owns the anatomical damage model, damage distribution, injury effects, mitigation and recovery, the health management system, and injury-side safety brakes. It does **not** own the Triade state model, the credit economy, the action contract, zone-graph combat rules, armour integrity, or the world/meta-progression economy.

**Inbound dependency discharged.** W§5.6a formally reassigned three items to this workstream (◈W2e): **injury persistence**, the **injury→stat-modifier→effective-field pathway**, and the **crushed-field lockout risk**. All three are resolved here — §9.3, §6.1, and §10.2 respectively. W may now re-derive its §16 proofing and §18.1 save-state sizing against §9.3 rather than against the provisional symmetric assumption.

---

## 1. Reconciliation summary

### 1.1 Independent convergence [BOTH]

Both reports arrived at the following without contact. This convergence is the strongest evidence in either document and these points are treated as settled:

| Decision | Status |
| --- | --- |
| **Dual-layer model** — HP stays the primary kill condition; anatomy adds a local wound ledger | Settled |
| Anatomy resolves **after** the existing K11 mitigation stack, before conditions finalise | Settled |
| Wound effects route **only** through the two locked channels — temporary stat modifiers and `[CDM]` | Settled |
| Hierarchical body graph, not independent per-part HP bars | Settled |
| Hit distribution is **biased by coverage**, never uniform | Settled |
| Armour integrity and anatomical trauma are **separate systems** | Settled |
| Three-band UI: ambient posture / ≤4 HUD conditions / full inspection | Settled |
| Grit stays positional; medicine is a separate channel — no Grit-as-healing | Settled |
| A named brake against the injury spiral is mandatory | Settled |
| All magnitudes are [SIM]; the schema ships complete, the content ships small | Settled |

### 1.2 Adopted from the user report [U]

| Element | Reason |
| --- | --- |
| `hp_transfer` / `systemic_weight` twin scalars (§6.3) | Best single idea in either report — makes vitals lethal *through* HP, the legal route, rather than gating an instakill |
| **Parallel tissue routing** over sequential layer penetration (§6.2) | Armour already did layered ordering at K·11.2; sequential absorption is redundant computation and a large tuning surface for a property armour owns |
| Full **14-type routing table** (§6.2) | Complete where W covered five types plus gestures |
| **Derived crisis states** — blood loss, breath debt, neurotrauma (§7.4) | The aggregation layer that makes W's own ≤4 ambient cap implementable |
| Concrete stat linkages (§5.2) | W stayed abstract; U named actual stats, all of which verify |
| **Three severity tiers** over a continuous accumulator (§6.4) | Cleaner and more legible than W's five-tier AIS ladder |
| Minor auto-downgrade at encounter boundary (§9.2) | Correct low-friction default |
| Free post-fight field dressing (§10.1) | A real third brake |
| Two-term safety clamp (§10.2) | Both terms do distinct jobs; the `max()` is correct |

### 1.3 Adopted from the Claude report [W]

| Element | Reason |
| --- | --- |
| **Computed `Φ_safe_x`** + linter check (§10.2) | A hand-tuned constant silently desynchronises from region thresholds with no test failing |
| **Sum-of-squares combination rule** (§7.5) | U's model accumulated trauma with no combination rule — the exact gap where Mythras death-spirals |
| `converts_to_scar` **permanent flag in schema, default off** (§7.3) | Hook now, economy later; painful retrofit otherwise |
| **Vital-hit backstop** (§9.4) | U's unguarded `vital_multiplier` could delete a full-HP player, violating U's own stated constraint |
| **Downed state** before death (§9.4) | Creates a rescue/finish window and gives the Finisher somewhere to live |
| **State-dependent routing modulation** (§6.2) | Preserves M·2A.4 rigid-discontinuity at the cost of one modifier lookup |
| Prior-art failure-mode warnings (§2) | U's report was better *bound*; W's was better *validated* |

### 1.4 Corrections and additions made during reconciliation [NEW]

| Correction | Origin |
| --- | --- |
| **Severity-gated *paid* town recovery** replaces both free reset and unpriced persistence | U's own mitigation table priced bone-set and surgical restoration as real services; free town reset made them dead content |
| **Recovery is priced in renewable resources only** — never in progress currencies (§8.1) | Charging recovery against `Location Grounding`/`[Imprint]` creates a ratchet where healing retroactively destroys banked descent progress |
| **"Grounding" confirmed real** (W§5.1), not drift — then renamed player-facing to **`[Imprint]`** | An intermediate reconciliation step wrongly struck it after checking only L, where it had never been propagated. The rename resolves ◈W5's Form-adjacency concern |
| **Wound persistence splits by channel** (§9.3) | Field modifiers are Temporary-tier and clear at the run boundary per ◈W2f; `[CDM]`, HP-cap and function loss persist. Resolves a direct violation of a Steward lock |
| **Body graph is an instantiable template**, not a fixed node list (§5.3) | Non-humanoid bodies are a schema-shape decision — cheap now, structural surgery later |
| **Tiered enemy anatomy derived from the capability ladder** (§11) | Depth of anatomy = which loop stages exist to degrade. Not a cost compromise; a derivation from T·F.0 |
| **Enemy wound legibility rides the existing posture telegraph** (§12.2) | A wound crushes Reach, which changes which skills the enemy can use — which T·A3.7 already displays |
| **Wound rendering must not share the integrity channel** (§12.3) | Both read as "damaged"; confusing them breaks the Bridge 1 read |
| **Wound→stat mapping derived from capacity/application/resilience** (§5.2) | T·A4.1's group structure supplies the rule; hand-assignment is unnecessary |
| **14-type routing authored as 6 archetypes plus deltas** (§6.2) | Removing the five-type MVP scope made hand-authoring ~56 cells indefensible |
| **`Φ_safe_x` guards *Reach*, not geometric reachability** (§10.2) | Injury *lowers* floors, which enlarges the reachable triangle. The lockout is mute-in-region, not locked-out-of-region |

---

## 2. Prior art — what was taken and what was refused

Condensed from the step-1 study. Full comparative analysis is in that report; this section records only the load-bearing lessons and the specific failures being designed against.

### 2.1 Patterns adopted

| Source | Pattern taken |
| --- | --- |
| **Warhammer FRP 4e** | Buffer-then-consequence: HP absorbs, only overflow injures. Death as a *tally* of serious wounds, not one bar hitting zero |
| **Blades in the Dark** | Bounded harm levels, always legible as a phrase, healed by a downtime clock. The gold standard for low-bookkeeping persistent injury |
| **RimWorld (hediffs)** | `Hediff` on `BodyPartRecord` with `severity`, stages gated by `minSeverity`, `capMods`, and tend-state. Maps near one-to-one onto our temporary-stat-modifier machinery |
| **CDDA (`wound` / `wound_fix`)** | Schema shape: `damage_types`, `damage_required`, `weight`, `limit`; fixes declare `wounds_removed`, `wounds_added`, `time`, `skills` |
| **Escape from Tarkov** | Different tool per condition under time pressure; restored parts carry a reduced max |
| **Kenshi / Caves of Qud** | Prosthetics that restore or exceed function; permanent loss needs an *interesting* recovery path or it reads as time-wasting |
| **AIS / ISS (clinical)** | Non-linear ordinal severity; ISS's sum-of-squares ethic — many small wounds must matter far less than one severe one |
| **ABCDE primary survey** | "Treat first what kills first" as a mitigation-priority ordering |

### 2.2 Failure modes explicitly designed against

| Failure | Source | Guard in this design |
| --- | --- | --- |
| **Cumulative small wounds kill you** | Mythras per-location HP; widely reported as too lethal on the second strike | Sum-of-squares combination (§7.5) |
| **Death spiral: injured → weaker → more injured** | Generic; named by T·I.5 and W§5.6a | Four named brakes (§10) |
| **Unreadable condition walls** | RimWorld hediff lists; community built a compaction mod | ≤4 ambient cap, family refresh/escalate (§7.6) |
| **Anatomy as sole kill condition** | Dwarf Fortress creatures without vital organs take "very, very long" to kill | HP remains primary; anatomy modifies transfer, never replaces the win condition (§9.1) |
| **Silent instakill lottery** | Tarkov head/thorax at 0 | Vital-hit backstop gates lethality on HP/Downed (§9.4) |
| **Permanent loss without recovery path** | Qud dismemberment reads as wasted time | Permanent flag ships off; prosthetic/regrow economy is a separate workstream with its own reward loop |
| **Table lookup bogging the loop** | Rolemaster critical charts | Severity derived from a continuous accumulator; no per-weapon chart proliferation |

---

## 3. Design goals and non-goals

### Goals

| # | Goal | Test |
| --- | --- | --- |
| ◉H1-H§3 | HP remains the primary victory condition | No damage path kills a target above the Finisher threshold except by HP depletion |
| ◉H2-H§3 | Anatomy changes *how* you deteriorate, never *whether* HP matters | Removing the wound layer must leave a playable, coherent combat loop |
| ◉H3-H§3 | No injury state renders a region mechanically mute | `Φ_eff` clamp holds against every combination of wounds and surfaces |
| ◉H4-H§3 | Injury changes the player's problem, not merely their numbers | Wounded builds show region-residency *shift*, not uniform residency collapse |
| ◉H5-H§3 | Ambient bookkeeping stays inside the legibility budget | ≤4 surfaced wound families at any time; full detail on inspection only |
| ◉H6-H§3 | Recovery never costs progress currency | Linter forbids `Location Grounding` (player-facing `[Imprint]`) and Temper in any `economy_cost` |
| ◉H7-H§3 | The baseline invariant survives injury | `ΣF_rendered == ΣF_baseline` at run start, unconditionally (W§16.1) |
| ◉H8-H§3 | Enemy wound state is readable through an existing channel | No new enemy UI surface; posture telegraph carries it |

### Non-goals

- **⦻H1** — No trauma simulator. Plausibility, not gore; no wound ballistics, no bleeding-rate physiology.
- **⦻H2** — No per-location HP pools. The one-general-pool-plus-ledger structure is deliberate (§9.1).
- **⦻H3** — No second kill race. Anatomy is setup and attrition, exactly as Structural damage is (M·2A.6, Bridge 1).
- **⦻H4** — No permanent-injury economy in this document. The `converts_to_scar` flag ships off; prosthetic/regrow/rite is a separate workstream.
- **⦻H5** — No infection or disease layer in MVP. Additive, not prerequisite; deferred (§17).
- **⦻H6** — No agent authority over clamp values, brake thresholds, or the vital-hit gate.

---

## 4. Design pillars

**HP1 — Anatomy decides the *manner* of deterioration, never the *fact* of it.** [BOTH] HP is the kill condition. The body graph decides whether residual damage became a bleed, a fracture, a punctured lung or a clean flesh wound — and therefore what the player must *do about it* — but never whether the target dies. This is the exchange-control thesis (K1) applied one layer down: damage is the consequence, injury is the texture of the consequence.

**HP2 — Two channels, no third.** [BOTH] Every wound expresses itself as a temporary stat modifier on effective fields (T·A4.2a), a zero-sum `[CDM]` influence (T·A2.1), or both — plus the bookkeeping quantities HP and AP that already exist. There is no wound-specific resolution path, no third effect stack, and no new state the Interpreter must learn to narrate.

**HP3 — Injury changes the problem, not the size of the numbers.** [W, from K·7.7] A fractured sword-arm should redirect a player toward a different region and vocabulary, not merely subtract damage. Where a wound closes an option it should, where possible, open or cheapen another. This is the same ethic K·7.7 states for being pushed out of a build's preferred region: *change the player's problem, do not eliminate their turn.*

**HP4 — Severity is non-linear; count is sub-linear.** [NEW] One Grievous wound must be far more dangerous than six Grazes. This is the ISS sum-of-squares ethic and it is the primary structural guard against the death spiral — it makes attrition survivable and single catastrophes decisive, which is the correct shape for a game whose bosses are met three times.

**HP5 — Recovery costs renewable resources, never progress.** [NEW] Progress currencies encode *what you have achieved*. Charging recovery against them lets injury retroactively erase achievement, compounding punishment with failure instead of creating a decision. Money, materials, reagents and time are legitimate; `Location Grounding`/`[Imprint]` and Temper are not.

**HP6 — Depth of model, shallowness of display.** [BOTH] The simulation tracks the full body graph. The player sees posture, four condition families, and an inspection panel. This is the Dwarf Fortress/RimWorld lesson taken deliberately: the data model scales, the display must not.

---

## 5. The anatomical model

### 5.1 Vocabulary and collision avoidance

**[CONFLICT — resolved by naming.]** Anatomical areas may **never** be called *regions* (locked: Instinct/Pressure/Discipline, T·C.1) or *zones* (locked: the physical battlefield, K4). The player-facing term is **[Body Location]** [LEXICON+]; the design-model term is *anatomical node*.

The protective stack is **[Tissue Layer]** [LEXICON+]: `skin → muscle → bone → organ`. This extends M·2A.4's rigid-discontinuity principle inward past armour — rigid layers (bone, skull) absorb large force then fail abruptly (Shatter); flexible layers (skin, muscle) degrade gracefully (Tear/Slash). Armour and anatomy therefore share one physical logic rather than having two.

### 5.2 Stat linkage — derived, not authored [NEW]

All nine stat names in the user report verify against **T·A4.1**, correctly grouped:

| | Capacity | Application | Resilience |
| --- | --- | --- | --- |
| **Momentum** | Strength | Finesse | Stamina |
| **Mind** | Intellect | Will | Spirit |
| **Form** | Frame | Poise | Constitution |

T·A4.1 defines the group structure as *what you have / how you direct it / how you withstand its domain*. That supplies a **derivation rule** for wound→stat mapping, replacing per-wound authoring:

| Tissue outcome | Hits | Rationale |
| --- | --- | --- |
| Bone / structural trauma | **capacity** — Strength, Intellect, Frame | the thing you have is broken |
| Tendon, nerve, joint, fine-motor | **application** — Finesse, Will, Poise | you cannot direct it |
| Organ, bleed, systemic, respiratory | **resilience** — Stamina, Spirit, Constitution | you cannot withstand it |

**Emergent consequence — wound type counters build archetype.** T·A4.1/A4.4's *render emphasis* holds that Reach emphasises capacity+application while Floor emphasises resilience. Therefore:

- Breaking bones and cutting tendons crushes **capacity+application** → crushes **Reach** → **the striker loses their spike**
- Bleeding, drowning a lung, poisoning crushes **resilience** → crushes **staying Floor** → **the controller loses their dwell**

Bone-breakers counter strikers; bleeders counter controllers. This falls out of the existing render structure at zero authoring cost and is a genuine counterplay axis neither report designed.

### 5.3 Body graph as template [NEW]

The body graph is an **instantiable template**, not a fixed node list. A template declares node archetypes with coverage weights, layer stacks, function tags and stat links; a body instance realises the template with sides and counts. Consequences:

- Non-humanoid bodies (beasts, constructs, unique bosses) are new templates, not schema changes
- Tiered enemy anatomy (§11) is a *smaller template*, not separate content
- Commander weak points are template extensions

**Templates are reached through `[Chassis]`, and `[Chassis]` is universal.** [LOCKED 0.13.0] Every actor — player or enemy — carries exactly one chassis, and the chassis names the body template. Enemies take theirs from the bestiary tag (E·F.1); players take theirs from an as-yet-undesigned character-creation layer (**◇H15**).

**The player chassis comes from the lineage** [AUTHORED 0.27.0]. `[Chassis]` and lineage are one object (T·A4.8a): the lineage names the body template, the available sizes and the zero-sum stat offset. `◈H15` closed — the source was never missing, only unnamed.

**A player chassis supplies anatomy only, never floor shape.** Stated as a negative because the enemy case does both and someone will otherwise "restore" the symmetry: an enemy's chassis declares a base floor shape which is then renormalised (E·F.1), whereas a player's floor is *rendered* from stat fields (T·A4.2–A4.4) with class supplying a zero-sum stat offset (T·A4.8). A player chassis that also declared a floor shape would double-count against that offset, which is linter-enforced.

### 5.4 The node table

Coverage figures are **neutral-stance defaults** for a standing humanoid with no shield interception, multiplied at runtime by attack height, arc, pose, exposure, cover and shield position (§6.2). They are not hard hit chances.

| Node archetype | Structure | Main muscle groups | Organs | Coverage weight [SIM] | Function tags | Stat links | Capacity class |
| --- | --- | --- | --- | ---: | --- | --- | --- |
| **Head** | skull | jaw, neck stabilisers | brain, eyes, ears, teeth | 8 | cognition, perception, speech | Intellect, Will, Spirit | `vital_core` |
| **Shoulder** ×2 | scapula, clavicle | deltoid, trapezius, rotator cuff | — | 8 | weapon control, guard posture | Strength, Finesse, Poise | `lever_core` |
| **Sternum** | sternum | pectorals | — | 6 | breath bracing, chest structure | Frame, Constitution | `vital_core` |
| **Rib cage** | ribs | intercostals, upper core | lungs, heart, liver | 16 | respiration, circulation, posture | Constitution, Spirit, Frame | `vital_core` |
| **Spine** | vertebral column | erector spinae, deep core | spinal cord | 8 | posture, pivot, brace | Frame, Poise, Constitution | `vital_core` |
| **Hip / pelvis** | hip-bone | gluteals, hip flexors, lower core | — | 10 | locomotion, stance stability | Frame, Poise, Stamina | `heavy_core` |
| **Upper arm** ×2 | humerus | biceps, triceps | — | 10 | striking force | Strength, Finesse | `limb_major` |
| **Forearm** ×2 | radius, ulna | flexors, extensors, pronators | — | 8 | precision, grip setup | Finesse, Strength | `limb_major` |
| **Hand** ×2 | hand, fingers | finger flexors, intrinsics | — | 6 | grip, manipulation | Finesse | `limb_fine` |
| **Thigh** ×2 | femur | quadriceps, hamstrings, adductors | — | 12 | drive, charge, base movement | Strength, Stamina, Poise | `limb_major` |
| **Knee** ×2 | patella | patellar chain | — | 4 | directional change | Poise, Finesse | `hinge` |
| **Shin** ×2 | tibia, fibula | calves, tibialis, peroneals | — | 8 | footing, recovery | Poise, Stamina | `limb_major` |
| **Foot** ×2 | foot | plantar, intrinsics | — | 6 | footing, stance acquisition | Poise, Finesse | `limb_fine` |

**Weights are relative, and the convention is per-pair.** [LOCKED 0.13.0 — closes ◈H2]

The column is a **relative weight, not a percentage**. Weights are normalised to 1.0 at instantiation (`BodyNodeArchetype.coverage_weight`, rule **H-M2**), so the listed figures need not and do not sum to 100. They sum to 110. That is legal by construction and is not a defect.

**Per-pair convention, locked.** For a paired archetype (`×2`) the listed weight is the **total for the pair**, split evenly across realised instances at instantiation. The reason is that the figures track burn-assessment body-surface shares: read per-pair, both arms entire come to 24 and both legs to 30, against the rule of nines' 18 and 36. Read per-node they come to 48 and 60, which is anatomically absurd. The table was authored against that reference and never summed.

Per-pair also keeps authoring semantics uniform — every row is a whole-body share regardless of pairing — so a six-legged template author writes total leg share, not per-leg.

*The two readings are not cosmetically different: per-pair normalises the head to 0.073 and the rib cage to 0.145; per-node gives 0.047 and 0.093. A ~36% relative shift in vital-node incidence, which moves S-H02, S-H03 and S-H06 directly.*

### 5.5 Propagation

- **Coverage cascade.** Hit selection walks parent → child by coverage weight; an organ is reached only through its containing node.
- **Upward.** Damaging a child registers proportional stress on the parent — an organ hit also stresses the rib cage.
- **Downward, neurological.** Spine and nerve damage cascades *down the body*: a spine wound penalises every node below it. Modelled as a strong sustained `[CDM]` force plus function loss — **not** as a field crush (§10.2 fork B).
- **Vital gate.** Brain and heart destruction is lethal irrespective of HP *only* under the §9.4 backstop conditions. Anatomy never adds a silent instant kill.

---

## 6. Damage distribution and the damage table

### 6.1 Resolution sequence

Anatomy enters **after** the locked K11 mitigation stack and **before** conditions finalise. Shield, Form mitigation, armour group mitigation and type exceptions all do their job first; the body system then decides what the residual hit did to flesh, bone, tendon or organ. This preserves the combat order, keeps armour meaningful, and adds no fields to the locked action contract — H *wraps* the contract exactly as K·5.1 requires.

```
1. Select impacted body node          (coverage cascade × situational biases)
2. Apply existing defensive ordering  (K·11.2 — shield → Form → armour group → type exception)
3. Produce residual damage
4. Route residual into tissue layers  (parallel share, §6.2)
5. Accumulate local trauma on the node
6. Derive: HP loss · wound grade · emitted conditions
           · local function penalties · opening/exposure modifiers
```

**This is the injury→stat-modifier→effective-field pathway** that W§5.6a reassigned here. Step 6 emits `Condition` records; each carries at most a `field_modifier` (→ effective field, T·A4.2a) and a `cdm_influence` (→ dot, T·A2.1). Nothing else reaches the Triade.

### 6.1a The layer trace is an output, not a second resolver [AUTHORED 0.38.0]

The selected body node and the complete defensive chain emit one immutable **layer trace**. Shield interception and M-owned covering equipment precede H-owned tissue layers. Each entry identifies the damage type, layer, optional item or body node, incoming amount, absorbed or transferred amount, residual and integrity/trauma delta.

K · 5.2a may test a Payload's contracted carrier route against this trace exactly once. The trace never chooses a Payload, adds a damage type or re-runs mitigation. A positive unrelated damage entry cannot prove the contracted carrier. Failure at one route does not erase the primary action; it only denies that Payload delivery.

Representative routes are typed by the layer evidence they require: inoculation reaches viable tissue; surface contact reaches an exposed body or covering surface; armour corrosion damages a covering-equipment layer; thermal transmission records positive transfer through the struck chain; structural implantation breaches an explicitly permitted structure/body layer. Exact magnitudes and curves remain K/[SIM] work.

### 6.2 Tissue routing — archetypes plus deltas

Routing is **parallel share**, not sequential absorption. Because removing the five-type MVP scope means the full 14-type taxonomy ships, routing is authored as **six archetype profiles with per-type deltas** rather than ~56 hand-authored cells. The sim harness tunes archetypes; types carry only their distinguishing offset.

**Archetype base profiles** [SIM] — share into `muscle / bone / tendon-nerve / organ`:

| Archetype | Members | muscle | bone | tendon-nerve | organ |
| --- | --- | ---: | ---: | ---: | ---: |
| **Kinetic-sharp** | Slash, Pierce, Tear | 50 | 10 | 20 | 20 |
| **Kinetic-blunt** | Impact, Shatter, Explosive | 25 | 50 | 10 | 15 |
| **Thermal** | Fire, Cold | 45 | 10 | 25 | 20 |
| **Chemical** | Corrosive, Poison | 30 | 10 | 15 | 45 |
| **Neural** | Lightning, Psychic | 25 | 5 | 50 | 20 |
| **Occult** | Chaos, Divine | 20 | 10 | 30 | 40 |

**Per-type deltas and identity** — the full 14, preserving locked status hooks (M·2A.5):

| Type | Group (M·2A.3) | Archetype | Delta / identity | Best targets | Emitted family |
| --- | --- | --- | --- | --- | --- |
| **Slash** | Physical | Kinetic-sharp | +muscle, shallow-wide | forearm, hand, shoulder, face | Bleeding, Lacerated |
| **Pierce** | Physical | Kinetic-sharp | **+organ heavily**, deep-narrow | eyes, rib cage, sternum, hands, feet | Punctured, Pinned |
| **Impact** | Physical | Kinetic-blunt | +organ shock; blunt fracture | skull, sternum, ribs, spine, pelvis, knees | Bruised, Staggered, Fracture |
| **Shatter** | **Structural** | Kinetic-blunt | **+bone/integrity heavily** — checks integrity, not typed defence | skull, sternum, ribs, spine, long bones | Cracked, Broken |
| **Tear** | **Structural** | Kinetic-sharp | +muscle/fascia; rends unarmoured flesh | limbs, cloth-leather gaps | Rent, Opened |
| **Explosive** | Volatile | Kinetic-blunt | **multi-node scatter**; +armour integrity | exposed limbs, torso clusters | Blasted, Multi-wound |
| **Fire** | Volatile | Thermal | +pain, +gear; lungs by inhalation | muscles, hands, face, lungs | Ignited, Burned |
| **Cold** | Volatile | Thermal | +bone brittleness, +armour brittling | hands, feet, ribs, joints | Chilled, Brittle |
| **Lightning** | Volatile | Neural | +muscle spasm | head, spine, arms, chest | Shocked, Spasm |
| **Corrosive** | Corruptive | Chemical | **+gear/armour heavily** | torso armour, face, hands | Eroded, Chemical burn |
| **Poison** | Corruptive | Chemical | +bloodstream, delayed onset | pierce wounds, lungs, liver | Envenomed |
| **Chaos** | Occult | Occult | +cognition, +focus, **+corruption** | head, spine, chest | Warped |
| **Divine** | Occult | Occult | **+ward**; purges corruption and displacement | chest, head, **spine** *(Warped-bearing nodes)* | Purged, Consecrated |
| **Psychic** | Occult | Neural | **+cognition heavily**, −physical, **+displacement** | skull, eyes, ears, spine | Dazed, Focus-broken |

**Correction at 0.13.0 — this column is anatomy only.** Divine's entry previously read *"chest, head, **corrupted targets**"*, mixing an anatomical affinity with a target predicate. Corruption load is a **damage scalar** (§6.2b), not a body region. `Warped` is anatomical — it sits on head and spine (§7.2) — so those are Divine's affinity, and the predicate has moved out.

**Structural note.** Shatter and Tear resolve on the **integrity** path, not typed defence (M·2A.3). Anatomically, *bone integrity* and *flesh integrity* are the natural per-node extension of that same path — bone fracture and open wounds are integrity events at the body-location level, exactly parallel to armour integrity at the item level. This avoids a parallel resolution system.

**State-dependent modulation** [W]. Routing shares are modified by the node's current state: a node whose bone is already fractured routes more to organ on the next hit; a node with an open wound routes more to organ for Pierce. One modifier lookup, and it preserves the rigid-discontinuity property that rigid layers fail abruptly while flexible ones degrade.

### 6.2a Aim — a bias on the cascade, never a branch around it [LOCKED 0.13.0 — closes ◈H4]

An aimed action does **not** select its node. It weights the coverage cascade toward the chosen node and resolves through the same single path as an unaimed hit.

For each successful single-node attack, runtime computes one distribution over the target's **eligible realised nodes**:

```text
effective_weight(node)
= relative coverage weight
× pose and exposure
× range and attack arc
× cover and shield-position exposure

P(node | successful attack)
= effective_weight(node) / Σ effective_weight(eligible nodes)
```

The weights are renormalised after every situational multiplier; authored values never need to total 100. Cover or shield position may change what is exposed before this normalisation, while actual shield/equipment interception remains step 8 of K·5.2 after the node is sampled. Armour therefore never rewrites anatomical probability merely because it covers a node. A state with no eligible positive-weight node is invalid rather than a silent miss table.

This is not new machinery. §5.4 already states the coverage figures are neutral-stance defaults *"multiplied at runtime by attack height, arc, pose, exposure, cover and shield position (§6.2). They are not hard hit chances."* Focus is one more term in that product.

**Aim weight is a check, and it resolves through T·C.6 like every other check** — scaling on anchor potency, the relevant channel stat, and Triade position. Three consequences:

| | |
| --- | --- |
| **Aim degrades, never fails** | From a good position the hit lands where it was meant; from a bad one it relaxes smoothly toward the unaimed distribution |
| **Called shots become a Mind and Instinct expression** | Not a free tactical toggle available to every build at equal value |
| **No new primitive** | No stat, no resource, no binary — and it answers ◈H4's *"interacts with Skill Anchors"* natively |

**`AIM_CEILING` < 1.0 is required** [SIM: **S-H09**]. Without it every aimed action picks the highest-`hp_transfer` node and the coverage weights become decorative. The symmetry is exact and worth stating: **T·A3.7 gives anchors a potency floor above zero; aim gets a weight ceiling below one.** Both exist to stop an extreme collapsing into degeneracy.

*Named `focus` when this section was written at 0.13.0 and renamed in the same version. **Focus** was already load-bearing on the Mind side — Chaos's `+focus`, `Focus-broken`, the *"Will / focus tax"* — so an attacker's aim quality and a defender's mental attribute were sharing a word. An L-M2 census was run and the collision missed.*

**Lethality needs no second guard.** **H-C4** already gates vital-organ lethality on HP below the Finisher threshold or the target Downed (K2), so a perfectly weighted head hit above that threshold converts to a Critical wound plus a deep `[Opening]`, exactly as an unaimed one does.

**Aim resolution is bounded by target anatomy, not by the attacker.** §11's tier table already sets this — *no* against Trash, *coarse* against Standard's five nodes, *targeted* against a Commander. A finer template is what makes finer aim meaningful; aim weight cannot invent nodes that the target's template does not realise.

### 6.2b Divine purge — one action, two faces [LOCKED 0.13.0]

Divine damage does not scale on the attack. **It scales on what the target is carrying**, and the purge that removes the state *is* the damage.

| Target | Resolution |
| --- | --- |
| Clean | Minimal. Divine is not a general-purpose attack |
| Carrying corruption or displacement | Damage scales with the state load consumed |
| Self or ally carrying it | State removed, no damage |

One action, two faces, decided by the **target's state** rather than by a targeting mode. §6.2's routing is unchanged — it is still Occult damage through the Occult archetype; only the scalar is state-driven.

**Named brake, per T-H1: purge consumes the state entirely.** No sequence extracts more than was invested. It is a conversion, never a generator — without this, apply-purge-reapply is exactly the self-funding loop K-C6 exists to prevent. Rule **H-H6**.

**This makes Divine setup-conversion, not a second kill race** — the same shape as Structural damage (M·2A.6 Bridge 1) and consistent with HN3. It also builds a cross-actor loop: Chaos or Psychic applies, Divine converts.

**Trade-off named.** Solo Divine has weak offence. It is a combination type, and its power curve is content-dependent — strong in occult-heavy content where enemies apply the states themselves, weak elsewhere. That is a real cost, not a rounding error, and it is why Divine keeps its slot among the locked 14 types rather than becoming a support school outside them.

### 6.3 Node transfer table — `hp_transfer` and `systemic_weight` [U]

The two scalars that make vitals frightening without a second defeat bar:

- **`hp_transfer`** — how efficiently residual damage at that node becomes global HP loss
- **`systemic_weight`** — how much the node contributes to derived crisis states (§7.4)

| Node | Capacity class | `hp_transfer` | `systemic_weight` | Most dangerous types | Minor | Major | Critical |
| --- | --- | ---: | ---: | --- | --- | --- | --- |
| **Head** | `vital_core` | 1.40 | 1.75 | Impact, Pierce, Psychic, Lightning | Dazed; −Intellect/Will | Concussed; sensory penalty, weak reads | Brain trauma; severe Mind loss |
| **Shoulder** | `lever_core` | 0.85 | 0.60 | Slash, Tear, Impact | +1 AP on that hand's actions | Dislocation; block penalty | Arm near-disabled; shield/two-hand compromised |
| **Sternum** | `vital_core` | 1.10 | 1.10 | Impact, Pierce, Shatter | Breath tax; Guard-shaken | Reduced Form mitigation | Chest collapse; cardiac shock risk |
| **Rib cage** | `vital_core` | 1.25 | 1.50 | Pierce, Impact, Fire, Shatter | Winded; shallow bleed | Punctured lung or liver shock | Respiratory crisis |
| **Spine** | `vital_core` | 1.20 | 1.70 | Impact, Pierce, Lightning | Posture penalty; Pivot tax | Severe Poise loss | Collapse; locomotion and guard failure |
| **Hip / pelvis** | `heavy_core` | 1.00 | 1.20 | Impact, Shatter, Pierce | Step tax | Pelvic instability | Near-immobility; fall risk |
| **Upper arm** | `limb_major` | 0.75 | 0.50 | Slash, Tear, Impact | −Strength/Finesse that side | Fracture or deep tear | Hand heavily impaired |
| **Forearm** | `limb_major` | 0.70 | 0.45 | Slash, Tear, Pierce | Precision and parry loss | Cracked radius; tendon damage | Grip conversion greatly reduced |
| **Hand / fingers** | `limb_fine` | 0.55 | 0.35 | Slash, Pierce, Cold | Grip slip; item-use tax | Broken fingers | Disarm risk; `[Combo-Action]` denied |
| **Thigh / femur** | `limb_major` | 0.85 | 0.65 | Impact, Pierce, Tear, Shatter | Movement tax; charge penalty | Femur trauma | Collapse; cannot drive deep |
| **Knee** | `hinge` | 0.65 | 0.50 | Impact, Pierce, Cold | `[Pivot]` +1 AP | Joint instability; Poise loss | Leg buckling |
| **Shin / tibia** | `limb_major` | 0.75 | 0.55 | Impact, Shatter, Cold | Weaker stance recovery | Tibia fracture; home-well recovery loss | Leg near-unusable |
| **Foot** | `limb_fine` | 0.60 | 0.45 | Impact, Pierce, Cold, Corrosive | Footing loss; zone-move tax | Crushed foot | Cannot hold angles |

### 6.4 Severity tiers

**[Wound Severity]** [LEXICON+] — three tiers derived from a continuous `trauma` accumulator (0..1) per node:

| Tier | Threshold [SIM] | Meaning | Default persistence |
| --- | ---: | --- | --- |
| **Minor** | 0.20 | Real but shallow; auto-downgrades between encounters | encounter |
| **Major** | 0.45 | Needs intervention to heal well | run, until treated |
| **Critical** | 0.70 | Severe function loss; may worsen if rest is skipped | run, town-grade treatment |

A fourth state exists only as a **flag**, not a tier: `converts_to_scar` (§7.3), default `false` and out of scope for this document.

### 6.5 Data model — damage distribution

```
DamageEvent {                        // produced by K·5.2 step 8, consumed here
  id: uuid
  source_action: ref(combat_action)  // K·5.1 — contract unchanged
  final_footprint: { type: enum14, pips: int }[]   // AFTER 2A.9 redistribution
  residual: float                    // post-K11 mitigation
  aim: enum(unaimed | aimed)         // §6.2a — 'aimed' biases, never overrides
  aim_target?: ref(BodyLocation)
  aim_weight: float                  // 0..AIM_CEILING; resolved per C.6
  situational: { height_bias, arc_bias, pose_mod,
                 exposure_mod, cover_mod, shield_intercept_mod }
}

LayerTrace {                         // emitted by the same authoritative resolution
  target_node: ref(BodyNode)
  entries: [ {
    damage_type: enum14,
    layer: enum(shield | equipment | skin | muscle | bone | organ),
    item?: ref(ItemRevision),
    incoming, absorbed_or_transferred, residual, integrity_or_trauma_delta
  } ]
}

BodyTemplate {                       // §5.3 — instantiable
  id: string
  nodes: BodyNodeArchetype[]
}
// Referenced, never inlined: every actor carries exactly one [Chassis], and the
// chassis holds body_template: ref(BodyTemplate)  (E·F.1, H-C6). Many chassis,
// few templates — inlining weights per chassis is the authoring explosion §5.3
// exists to prevent, and would force H·11's tier ladder to be re-cut per chassis.

BodyNodeArchetype {
  id, parent?, bone, muscle_groups[], contained_organs[]
  coverage_weight: float             // relative, PER-PAIR (§5.4); normalised at instantiation
  armour_slot: ref
  function_tags: string[]
  stat_links: { stat: enum9, weight: float }[]
  capacity_class: enum(vital_core|heavy_core|lever_core|limb_major|limb_fine|hinge)
  hp_transfer: float
  systemic_weight: float
  thresholds: { minor: float, major: float, critical: float }
  safety_clamped: bool               // participates in §10.2
}

BodyNode {                           // runtime instance
  archetype: ref(BodyNodeArchetype)
  side: enum(left|right|centre)
  trauma: float                      // 0..1 accumulator
  grade: enum(none|minor|major|critical)
  layer_state: { skin, muscle, bone, organ : float }   // drives §6.2 modulation
  treated: bool
  wounds: ref(Condition)[]
}

// Resolution — deterministic, seeded on the 'combat'/'health' stream (M·0.3)
resolve(DamageEvent e):
  node = sample_by_coverage(root, e.situational ⊕ aim_bias(e), e.seed)
         // one path. aim_bias() weights e.aim_target upward by e.aim_weight,
         // clamped to S-H09 AIM_CEILING < 1.0. No deterministic branch.
  for each footprint f in e.final_footprint:
      arch   = archetype_of(f.type)
      shares = arch.base ⊕ delta_of(f.type) ⊕ modulate(node.layer_state)
      for layer in {muscle, bone, tendon_nerve, organ}:
          node.layer_state[layer] += e.residual × shares[layer]
                                     × vulnerability[node][f.type]
  node.trauma = recompute(node.layer_state)
  node.grade  = grade_from(node.trauma, archetype.thresholds)
  hp_loss     = e.residual × archetype.hp_transfer
                × vital_multiplier(node, §9.4 gate)
  propagate_up(node); propagate_neuro(node)
  return WoundOutcome[]              // → §7
```

---

## 7. Temporary and persistent effects

### 7.1 The binding thesis

> **An injury effect is nothing new.** It is a persistent instance of the two channels K12 already supports: a temporary stat modifier shifting effective fields (T·A4.2a), and/or a `[CDM]` influence pushing the dot (T·A2.1). A wound is a `Condition` with a longer lifetime and a body-location anchor.

A fractured leg is a `Condition` whose field modifier lowers the Momentum group's effective field **and** applies a mild `[CDM]` force toward Form — you favour the good leg. Both already render through the floor and the dot. There is no third channel.

### 7.1b Condition duration is `world_tick` [ADOPTED 0.35.0, CR-11]

**Condition lifetimes are expressed in `world_tick`, not in elapsed AP or rounds.** AP stopped being a resource at 0.34.0 — it is a rate — so a duration counted in AP no longer denotes an amount of anything. A 60-tick band is a cadence, and an actor at rate 6 passes through it in the same time as one at rate 2.

| Expressed as | Because |
| --- | --- |
| `world_tick` durations and expiry | One authoritative timestamp; no second clock (**K-C11**) |
| Scheduled due events, not per-frame polling | Deterministic replay and digest stability |
| Exposure and threshold counters against `world_tick` | Contact time is real time, not turn count |

**Town Temporal Suspension holds.** Time in Town does not advance adventuring `world_tick`, so corrosion, Rot, contamination and condition expiry tied to adventuring time do not progress there. Town crafting may run isolated recipe-local clocks; they advance nothing in a suspended location.

**H-C8 is unchanged and now load-bearing for CR-11.** Only **Permanent**-tier sources may alter an innate profile — so temporary contamination or Infection **cannot** grant a profile-gated skill, however long it persists in ticks. Duration is not permanence.

### 7.1a What may alter an innate profile [AUTHORED 0.32.0]

T·A4.8a puts a lineage's unarmed footprint **on the body node**. That raises a question this section owns: *can a condition change it?* A rabid wolf whose bite turns venomous would gain access to skills its teeth could not previously reach, because 2A.10's requirement check reads the base footprint.

**T·G.3 already answers it.** An innate profile is a property of the body, on the same channel as floor shape:

| Permanence (T·G.3) | May alter an innate profile | Why |
| --- | --- | --- |
| **Permanent** — tomes, training, rituals | **Yes** | Already the channel that may reshape a body's baseline |
| **Worn** — equipment, affixes | **No — it composes instead** | A striking glove adds a source at the node (M·2A.10a); it does not rewrite what the body is |
| **Temporary** — consumables, encounter states | **Never** | This is 2A.10's object-boundary rule at body scale: *a blessed character with a mace still cannot thrust* |

**State the negative, because it is the whole of the current answer: nothing is on that channel for the body yet.** Permanence for an injury is `converts_to_scar` (§7.3), which **ships off** by `⦻H4` — no permanent-injury economy lives in this document. So in this build **no condition can alter an innate profile**, the hook exists, and the feral wolf is a design intention with no mechanism, deliberately.

**What this buys is that the answer will not have to be retrofitted.** When the prosthetic/regrow/rite workstream opens `⦻H4`, it inherits a decision already made: profile alteration is Permanent-tier or it does not happen. Nothing needs to relitigate whether a two-turn buff can hand a creature a new skill.

### 7.2 Effects table

| Effect family | Sources (node + type) | Temporary effect | Persistent if untreated | Channel output |
| --- | --- | --- | --- | --- |
| **Pain** | any major hit | small AP tax; slight push toward Form | chronic AP tax within run | `[CDM]` + small mixed stat penalty |
| **Bleeding / Opened** | Slash/Tear to limbs, torso | HP loss per elapsed **`world_tick`**; easier follow-up | escalates to blood-loss state | `hp_tick` + `opening_mod` |
| **Bruised / Guard-shaken** | Impact to sternum, ribs, shoulders | reduced guard efficiency; short Stagger | usually clears at encounter end | short-duration stat mod |
| **Fracture** | Shatter/Impact to skull, arm, ribs, pelvis, femur, tibia | large local function penalty | severe run-persistent disablement until splinted | heavy **capacity** stat mod + AP/move tax |
| **Dislocation** | shoulder, knee, hip | local range / block / pivot loss | unstable joint; reinjury risk | **application** stat mod + vulnerability tag |
| **Concussed** | skull; Impact/Lightning/Psychic | poor read checks; Dazed; weaker Mind floor | long within-run cognitive penalty | Intellect/Will/Spirit loss + `[CDM]` |
| **[Blinded]** *(illustrative in L§6)* | eyes; Pierce/Slash/Corrosive | accuracy and read penalty | one eye may persist as partial loss | Instinct **read** potency crush |
| **[Deafened]** [LEXICON+] | ears; Impact/Explosive/Psychic | reduced telegraph clarity | mild persistent reaction penalty | readiness / read tax |
| **Jaw / teeth trauma** | face; Impact/Slash | speech and incantation difficulty | reduced vocal/occult use within run | Will / focus tax |
| **Respiratory trauma** | ribs, sternum, lungs | AP tax; cannot sustain deep commitments | recurring breath debt until sealed | Constitution/Spirit loss + `hp_tick` |
| **Cardiac trauma** | heart via sternum/rib Pierce | huge systemic strain spike | near-fatal until advanced treatment | HP spike + severe stat drop |
| **Liver trauma** | low rib cage; Pierce/blunt | delayed HP loss; weakness | strong within-run attrition | delayed `hp_tick` + Stamina loss |
| **Spinal trauma** | spine; Impact/Lightning | Pivot, Move, Guard and Watch all worsen | severe locomotion and posture instability | Frame/Poise/Constitution loss + `[CDM]` |
| **Pelvic instability** | hip-bone; Impact/Shatter | zone movement and charge degrade | near-run-ending mobility problem | move tax + Poise/Frame loss |
| **[Hobbled]** [LEXICON+] | leg/foot; Shatter/Tear | Momentum field down; zone-move cost up | slow to heal | Momentum stat mod + move tax |
| **Burned / Ignited** | exposed flesh, hands, face, lungs | ongoing HP loss; grip penalty | scarred pain until run end | `hp_tick` + Finesse loss |
| **Shocked / Spasm** | head, spine, arms, chest | interrupts; action unreliability | lingering tremor | Finesse/Will loss + short `[CDM]` |
| **Chilled / Brittle** | hands, feet, ribs, joints | weaker recovery; fracture-prone | clears with warmth/time | Poise/Finesse loss |
| **Envenomed** | pierce wounds, chest, liver | delayed HP loss; suppression | long attrition until cleansed | `hp_tick` + Stamina/Spirit loss |
| **Eroded tissue** | Corrosive hits | armour efficacy loss; exposed flesh | deep tissue pain until treated | armour mod + pain |
| **Warped / Focus-broken** | Psychic/Chaos to head and spine | read failure; stance disruption | lingering mental instability | Mind group penalties + `[CDM]` |
| **Nerve damage** | spine/limb nerve; Pierce/Shatter | **function loss without HP loss** | rare; cascades below spine | function denial + strong `[CDM]` |

### 7.2a Faculty execution hooks and their gates [LOCKED 0.13.0, CORRECTED 0.41.0]

M·2A.10a's four Faculty families resolve through existing anatomy and `function_denial`; this section names the exact function each reads.

| Family | Hook | Gate | Existing §7.2 / §6.3 entry |
| --- | --- | --- | --- |
| `[Arcana]` | voice | functional vocal apparatus | speech/incantation difficulty and vocal-use denial |
| `[Mudra]` | fingers | selected hand's fingers; two-hand Mudra selects two distinct hands | selected hand denied or occupied; either selected hand for a two-hand form |
| `[Psyche]` | Brain | Brain only | Brain function denial, including qualifying cognitive trauma |
| `[Somatic]` | selected bound node | binding source node | that node's own state — broken arm, `[Hobbled]`, destroyed gland |

These populate `function_denial` (§6.5) rather than adding a mechanism. A BodyTemplate may realise vocal function through jaw anatomy, but teeth are not a universal Arcana hook. Somatic denial is route-scoped: a destroyed venom gland disables Apply Venom and any direct Poison rendition that requires fresh gland provision, while active teeth, hands or feet retain their own plain Techniques.

### 7.3 Data model — conditions

Modelled on RimWorld's `Hediff`/stages and CDDA's `wound`, expressed in Triade terms:

```
Condition {                          // superset already named in L§6; [Wound] is a subtype
  id: uuid
  def: ref(ConditionDef)
  location?: ref(BodyNode)           // null = whole-body (poison, chill)
  severity: float                    // 0..1
  grade: enum(minor|major|critical)  // derived
  persistence: enum(encounter | run | cross_run)
  // --- the two locked channels, nothing else ---
  field_modifier?: TemporaryStatMod  // Temporary-tier; CLEARS at run boundary (◈W2f)
  cdm_influence?: Influence          // zero-sum, force-mode; PERSISTS (§9.3)
  // --- bookkeeping quantities that already exist ---
  hp_tick?: int                      // _q at scale 12 000 per elapsed world_tick (P-C12, K-C11)
  hp_max_cap?: float                 // persists (§9.3)
  ap_tax?: int
  move_tax?: int
  function_denial?: string[]         // e.g. ["combo_action", "off_hand"]
  opening_mod?: { against_self: float }
  // --- lifecycle ---
  decay: { mode: enum(scene|home_well|treatment_only|never),
           rate?, tended_rate? }
  stack_rule: enum(refresh | escalate | independent)
  converts_to_scar: bool = false     // ⦻H4 — hook only, economy out of scope
  treatable_by: ref(RemedyDef)[]
  visibility_priority: int           // ABCDE ordering, §12.1
  display: { icon, summary_phrase, inspection_detail }
}
```

### 7.4 Derived crisis states [U]

Aggregation from active wound families, **derived not stored**, weighted by `systemic_weight`:

| State | Fed by | Drives |
| --- | --- | --- |
| `blood_loss_rate` | Bleeding, Opened, liver, heavy bleeds | `hp_tick` magnitude; Downed proximity |
| `breath_debt` | Respiratory, sternum, rib cage, Winded | AP cost inflation |
| `neurotrauma` | Concussed, spinal, Shocked, Psychic | Mind-group field pressure; read reliability |
| `systemic_strain` | sum-of-squares over all (§7.5) | overall crisis banding, UI priority |

These are the layer that collapses 21 nodes into four readable things. Without them the ≤4 ambient cap is unimplementable.

### 7.5 Combination rule — sum-of-squares [W]

Systemic strain must be **super-linear in maximum severity and sub-linear in count**:

```
systemic_strain = sqrt( Σ over wounds ( severity_i × systemic_weight_i )² )
```

Six Minor wounds must remain far less dangerous than one Critical. This is the ISS ethic and it is the structural guard that makes the safety clamp guard the *right* failure — without it the clamp catches one catastrophic wound and misses death-by-a-thousand-grazes, which is precisely the Mythras failure.

### 7.6 Legibility cap

Inherits K12. At most **four** wound families surface at the ambient/HUD tier simultaneously, ordered by `visibility_priority` (ABCDE — life-threatening first). Same-family wounds **refresh or escalate** into one entry rather than stacking near-duplicates. The full ledger lives at V·4.6 inspection only.

---

## 8. Mitigation, treatment and recovery

### 8.1 The currency rule [NEW — load-bearing]

> **Recovery is priced in renewable resources only — never in progress currencies.**

**Forbidden:** `Location Grounding` — player-facing **[Imprint]** (W§5.1); **Temper** (T·B.2).
**Permitted:** **Marks** (ordinary money), **named reagent items**, downtime time, opportunity cost.

**Cross-check added at 0.12.0.** W§5.9's `[Incursion]` both inflicts wounds and awards currency, which puts a second faucet on the same sink. The gate is **net** Marks per Incursion run after recovery cost, not gross yield (S-W13, ◇W14): too high and recovery stops biting, dissolving the banking pressure §8.1 exists to create; too low and the mode is a net drain nobody enters. **The reagent share is the first dial to turn** — medicine is priced in Marks *plus named reagents*, and reagents are loot, so a generous reagent yield keeps recovery affordable inside the loop while the Marks supply stays flat. That decouples the two failure modes so they can be tuned independently, which a single Marks dial cannot do.

**Why this is a hard rule and not a preference.** W§5.5 establishes that collapse already destroys **Delve access**, **unspent Grounding**, *and* **earned `[Modification Ceiling]`**. Grounding's two sinks are asymmetric: descent unlock is *acquisition*, stratum lock is *loss-prevention*. Inserting healing as a third claimant creates a ratchet — heal at depth, fail to afford the stratum lock, and collapse erases access you already paid Grounding to unlock. **The healing spend retroactively destroys the descent spend.** That is negative progress, which for a roguelike is worse than raw punishment and is the meta-scale form of the death spiral this document exists to prevent.

Grounding being *per-Location* sharpens it: there is no cross-subsidy from a Location you are well-Grounded in.

**Contribution to a problem W flagged.** W§5.6a notes that two pressures pull toward pushing deeper (descent gets cheaper, earnings richer) against only one pulling toward banking (the scaling lock cost), and that the lock cost "may need to carry more than §5.3 assumed." Injury priced in money and time adds a **second force toward banking** without claiming Grounding — it makes returning more attractive, which makes the lock-vs-descend choice bite harder using machinery already in place.

### 8.2 Mitigation table

| Means | Window | Targets | Immediate effect | Persistent benefit | Cost / drawback |
| --- | --- | --- | --- | --- | --- |
| **Bandage roll** | combat / interlude | slash-tear limb and flesh wounds | removes one Bleeding tier | prevents escalation to blood-loss | small AP; no fracture help |
| **Tourniquet** | emergency combat | severe limb bleed | halts heavy Bleeding immediately | prevents collapse from blood loss | strong Finesse/Poise penalty that limb; timer |
| **Field splint** | combat / interlude | arm, forearm, thigh, knee, shin fractures | downgrades fracture instability | holds node at *treated major* for the run | slower actions with that limb |
| **Sling / shoulder brace** | interlude | shoulder, clavicle, scapula | suppresses dislocation penalties | stops reinjury escalation | weakens two-handed actions |
| **Chest seal** | combat / interlude | punctured lung, pierced rib cage | stops respiratory HP spike | keeps puncture manageable until town | occupies chest slot; no bone repair |
| **Burn salve** | combat / interlude | fire and corrosive surface trauma | removes Ignited; lowers pain | reduces scar severity in run | no help for deep organ burn |
| **Antivenom** | combat / interlude | poison states | halves or clears Envenomed | prevents delayed collapse | rare; wasted on non-toxins |
| **Neutralising wash** | interlude | corrosive wounds and gear | arrests Eroded progression | protects armour and flesh | limited charges |
| **Eye rinse** | combat / interlude | eyes, face, particulates | downgrades `[Blinded]` to hindered vision | keeps perception functional | no help for punctured eye |
| **Ear pack** | interlude | ear trauma, explosive shock | reduces `[Deafened]` | faster reaction recovery | minor mind-fog |
| **Dental wax / jaw cinch** | interlude | teeth, jaw | reduces speech pain | restores basic vocal skill use | no help for skull trauma |
| **Pain draught** | combat / interlude | any major pain family | removes AP tax, some Dazed | makes treatment possible under pressure | rebound pain on expiry; **masks worsening** |
| **Breath tonic** | combat / interlude | respiratory, sternum, rib cage | reduces breath AP tax | temporary dwell and home-well recovery | resilience only, never reach |
| **Stoneblood tonic** | combat / interlude | spine, pelvis, fracture-prone | boosts Constitution/Frame/Poise | stronger holding power under injury | sluggish; weaker Momentum actions |
| **Clarity tincture** | combat / interlude | concussion, psychic, shock | improves Will/Spirit; reduces Dazed | stabilises reads and reactions | not a cure |
| **Suture kit** | interlude / town | open lacerations, tears | closes Opened wounds | prevents run-long bleed attrition | slow; poor in combat; botch risk |
| **Bone-set service** | **town** | major skeletal injuries | clears persistent fracture/dislocation | node reset to healed baseline | **money + time**, moderate |
| **Surgical restoration** | **town** | lungs, heart-adjacent, liver, spine, eye | clears critical internal flags | full reset of critical vital wounds | **money + reagents + time**, steep; skill-gated |
| **Blessing / ward rite** | town / rare | chaos, psychic, divine trauma | clears Warped, Focus-broken, ward scars | stabilises Mind-side health | occult economy, not generic loot |
| **Armour** *(existing)* | passive | prevents wounds landing | Bridge-2 `[EDM]` damping; integrity gate | — | existing encumbrance |

### 8.2a Occult load — the ratchet that makes the rite matter [LOCKED 0.13.0]

In-combat Divine purge (§6.2b) clears the **encounter-scoped state**. It does not clear the **persistent layer**, and the two are not the same thing.

**Every application of corruption or displacement adds to a cumulative occult load, whether or not it is purged.** Purging in combat removes the effect; it does not remove the exposure. Past a threshold the load converts to **ward scars**, and only H·8.2's *Blessing / ward rite* — priced in the occult economy, *"not generic loot"* — clears those.

| Layer | Cleared by | Scope |
| --- | --- | --- |
| Corruption / displacement state | Divine purge, in combat | Encounter |
| **Occult load** | nothing — it accumulates | Run |
| Ward scars | Blessing / ward rite, in town | Persistent |

**In-combat purge is therefore tactically complete and strategically partial.** This is what stops a Divine caster making the town rite redundant, and it is the same channel split §9 already applies to wounds — it needed no new machinery, only stating.

**Occult load is not a seventh tracked number.** It lives in H's wound ledger beside conditions and integrity, not in the Triade state that A.4 caps at six. Stated because it will otherwise be raised.

### 8.3 The no-free-reach rule [U]

Medical consumables must default to **resilience-side** benefits — Constitution, Spirit, Poise, Stamina, home-well pull, AP-floor protection, bleed suppression — never capacity/application spikes that would let a player buy deep-region access without paying the positional exposure. Per T·G.3 permanence tiers, temporary items may alter **dwell only**. *Mitigation buys staying power, not peak access.*

### 8.4 Data model — remedies

```
RemedyDef {
  id, remedy_type: enum(consumable|tool|surgery|rest|service|rite)
  // NOT `category` [RENAMED 0.16.0]: `category` is the locked item classification
  // (M·2.1, P·1.3) and a remedy IS an item — it carries scarcity_tier (M·2.2)
  // and affix_slots (M·2.3). One record cannot hold two `category` fields with
  // different meanings, and P·7.1's category-completeness lint is unwritable
  // against an ambiguous field name. The two enums overlap on `consumable`
  // and diverge on five values, which is what made the collision invisible.
  availability_contexts: enum(combat|interlude|town)[]
  target_scope: enum(single_node|family|whole_body)
  targets: ref(BodyNodeArchetype)[]
  cure_tags: string[]                      // maps to ConditionDef families
  treats: { condition_def: ref, grade_reduction: int }[]
  may_add: ref(ConditionDef)[]             // scarring, re-open, tourniquet starvation
  efficacy: { hp_restore?, field_restore?: {corner, amount},
              clears_cdm?, caps_hp_tick?, dwell_bonus? }
  time_cost: { combat_ap?: int, downtime_actions?: int }
  economy_cost: {
     magnitude: enum(trivial|moderate|steep|gated)
     marks?: int                           // ordinary town money
     reagents?: ref(item)[]                // NAMED items, not a fungible currency
     // HARD CONSTRAINT: no field may denominate cost in
     // Location Grounding / [Imprint], or in Temper. Linter-enforced (§13, H-C3).
     // Scrap and Flux are salvage / reforge materials and are NOT
     // valid medical currencies — see §8.5.
  }
  skill_req?: { skill: ref, min_level: int }
  failure: { chance: float, on_fail: enum(no_effect|worsen|infect) }
  side_effects: ref(ConditionDef)[]
  scarcity_tier: enum(common|uncommon|rare|unique)   // M·2.2
  affix_slots?: Affix[]                              // M·2.3
  stack_group: string
}
```

### 8.5 No medical currency [NEW]

Medicine is priced in **Marks plus named reagent items**, never in a fifth fungible token.

**Scrap** (salvage from dismantling) and **Flux** (affix reforging) are *crafting* materials belonging to the itemisation economy. Routing medical costs through them would make the treatment loop compete with gear crafting for the same pool — a smaller version of the ratchet §8.1 exists to prevent, and one that would push players to leave wounds untreated to preserve reforge material.

Rare treatment is therefore gated by **scarcity of specific things**, not by another number:

| Tier | Priced in |
| --- | --- |
| Field consumables (bandage, splint, salve) | **Marks**; also common loot |
| Town services (bone-set) | **Marks** + downtime time |
| Gated services (surgical restoration, rite) | **Marks** + named reagents + time + skill gate |

This keeps the currency count at four and makes the deepest treatments feel like *finding the right thing* rather than *saving up*, which is the better fit for a loot-driven design (M) and for W§5.7's rerun-mode loot economy.

**Interaction with affixes.** `RemedyDef.affix_slots` (§8.4) means remedies may carry affixes and are therefore rerollable with **Flux** like any other item. That is consistent — Flux acts on the item, never on the wound.

---

## 9. The health management system

### 9.1 Representation — argued

**Two layers: HP plus `[Wound]`.** Both extremes are refused.

- **Against pure HP** — no injury texture; damage is meaningless until zero. K1's thesis wants texture.
- **Against pure per-location HP** — death-spirals (Mythras), out-books the attention budget (Dwarf Fortress), and compounds with position-scaling checks (T·C.6) and floor gates to double-punish.

The adopted model is **isomorphic to the game's own timescale spine**, which is the strongest available evidence it fits:

| Timescale | Credit economy (locked) | Health model |
| --- | --- | --- |
| Moment | Edge | shock / Minor wound |
| Encounter | Grit | **HP** |
| Run / band | Temper accrual | **`[Wound]`** |
| Across runs | Temper spend | untreated wound residue (§9.3) |

### 9.2 Recovery loops

- **In-encounter.** HP is not freely healed; K·9.2's refusal of Grit-as-healing stands. `Use item` can stop a bleed or mask pain; it cannot un-wound.
- **Between encounters.** Encounter-scoped effects decay (K17). Minor wounds **auto-downgrade one step** if no active bleed, poison or burn. One **free field dressing** per character, **Minor-scoped only** (§10.1). Major and Critical persist and may be *stabilised* but not healed.
- **At town.** Severity-gated paid services (§8.2). Town return *is* the run boundary (W§5.4) and coincides with the Temper spend trigger — one trip does resupply, upgrade, banking and treatment.

### 9.3 Persistence policy — resolving the ◈W2f conflict [NEW]

**The conflict.** ◈W2f is Steward-locked (28 July 2026): *Temporary-tier modifiers clear at the run boundary*, enforced by the Critical proofing rule `ΣF_rendered == ΣF_baseline` at run start (W§16.1). Since wounds emit temporary stat modifiers, and W§5.4 makes town return the run boundary, paid town recovery and ◈W2f appear to collide directly.

**The resolution — persistence splits by channel.** ◈W2f protects the *rendered floor*. `[CDM]` does not touch the floor; it pushes the dot. HP caps and function denial do not touch the floor either. Therefore:

| Channel | Crosses run boundary | Touches `ΣF_rendered` |
| --- | --- | --- |
| `field_modifier` (effective field) | **No** — clears per ◈W2f | yes, in-run only |
| `cdm_influence` | **Yes** | no |
| `hp_max_cap` | **Yes** | no |
| `function_denial`, vocabulary loss | **Yes** | no |

An untreated wound carried across a run boundary manifests as **reduced max HP, a persistent `[CDM]` force, and lost function — but not a crushed field.** `ΣF_rendered == ΣF_baseline` holds at run start unconditionally (◇H7). ◈W2f is preserved without amendment; no Steward escalation is required.

**Three consequences:**

1. **The crushed-field lockout is automatically bounded to one run**, because the only channel capable of crushing a field is the channel that clears at the boundary. §10.2's clamp therefore only ever has to hold *within* a run.
2. **Paid recovery survives.** You pay to clear the persistent residue — HP cap, `[CDM]`, function loss — not to clear a field modifier that would have expired anyway.
3. **It reads correctly in fiction.** The acute debilitation fades; the lasting handicap remains. A man with a badly set arm is not fighting through fresh agony — he simply cannot do certain things.

**Persistence table:**

| Layer | Within encounter | Across encounters (in run) | Across run boundary | On death |
| --- | --- | --- | --- | --- |
| HP | depletes | resets to max, capped by wounds | reset, capped | reset |
| Encounter effects | active | decay (K17) | gone | gone |
| `field_modifier` from wounds | active | persists | **clears (◈W2f)** | gone |
| `[CDM]` / HP cap / function loss | active | persists | **persists until treated** | **reset** |
| `converts_to_scar` wounds | — | — | out of scope (⦻H4) | — |

### 9.4 Death, incapacitation and the vital-hit backstop

- **Primary death remains HP depletion plus the Finisher** (K2). Anatomy adds no silent instant kill.
- **Vital-hit backstop [W].** A vital-organ hit resolves as lethal **only** when the target is already below the Finisher threshold or is Downed. Otherwise it converts to a Critical wound plus a deep `[Opening]`. This keeps HP meaningful as K2 requires, and prevents both the Dwarf Fortress *no-vital-organs-means-unkillable* failure and the Mythras *one-unlucky-blow* failure simultaneously.
- **Downed [W].** HP 0, or a Critical head or spine wound, produces **Downed** — a scene state, not death. Creates a rescue-or-finish decision window and gives the Finisher a natural home.
- **Run end.** Lethal vital hit while Downed, or HP 0 with no revive.

### 9.5 Unified health state

```
CharacterHealth {
  hp: { current, max, max_cap_from_wounds }
  body: BodyNode(root)                       // instantiated from BodyTemplate
  conditions: Condition[]
  downed: bool
  treatment_slots_used: string[]             // one chest seal, one splint per node
  // derived, never stored:
  blood_loss_rate, breath_debt, neurotrauma  // §7.4
  systemic_strain = sqrt(Σ (sev × sys_weight)²)          // §7.5
  effective_fields = baseline_fields
                   ⊕ clamp_total(Σ field_modifier, Φ_safe)   // §10.2, HARD
  active_cdm      = Σ cdm_influence           // Σ must satisfy dm+df+di = 0
}
```

---

## 10. Safety systems — four named brakes

T·I.5 requires every reinforcing loop to carry a named brake, and W§5.6a names *injured → weaker → more injured* as exactly such a loop. Four brakes are provided; the requirement is over-satisfied deliberately, because each guards a different failure.

### 10.1 The four brakes

| # | Brake | Guards against | Source |
| --- | --- | --- | --- |
| **1** | **Trauma Safety Clamp** (§10.2) | field crush making a region mute | [U] structure, [W] derivation |
| **2** | **AP-rate minimum floor** (locked, K·3.3 — *you cannot be slowed past a point*) | wound AP taxes reducing a turn to nothing | existing |
| **3** | **Free field dressing**, Minor-scoped | trivial-wound accumulation between fights | [U] |
| **4** | **Clumsiness cap** (locked, T·E.4 — *capped, so off-class drops stay usable*) | arm/hand/grip wound penalties spiralling | existing |

**Brake 3 scoping [NEW].** The free dressing clears **Minor only**. If it touched Major it would delete the triage decision the between-encounter loop is built on.

**Brake 4 routing [NEW].** Wound-induced weapon-handling penalties route through the existing **Clumsiness** mechanism rather than a new penalty type, inheriting its cap for free.

### 10.2 The Trauma Safety Clamp — derived, not tuned

**What the lockout actually is.** Injury *lowers* effective fields, which *lowers* floors, which *enlarges* the reachable triangle. Geometric reachability is not the failure mode. The failure is on the other render: `Φ` also drives **Region Reach** (`f(max Φ)`, T·A4.4), and `Usable level` (T·A4.7) makes reach the gate on which skill level can be fired, against `[Reach Cost]` and `[Level Requirement]`. A crushed field means **you can still stand in Instinct but cannot reach deep enough to fire anything in it** — geometrically present, mechanically mute. This also names the specific existing guarantee that weakens: T·I.5's Mind-lockout brake, *"floor `F_i` guarantees a basic Mind action is always reachable."*

**The clamp — two terms, both required:**

```
Φ_eff_x_after_injury ≥ max( Φ_safe_x , 0.5 × Φ_base_x )
```

| Term | Job |
| --- | --- |
| `Φ_safe_x` | **Guarantees region access.** Derived (below), not tuned |
| `0.5 × Φ_base_x` | **Limits absolute loss** on high-baseline builds. Proportional, separate job |

**`Φ_safe_x` is computed, not authored:**

> `Φ_safe_x` = the field value at which the **Reach render** still satisfies the lowest `[Reach Cost]` / `[Level Requirement]` in the character's vocabulary for each region in which they hold vocabulary.

Per-character, per-build, derived from skill data. It degrades correctly: a character holding only deep skills in a region hits their clamp earlier than one with a shallow entry skill, because the clamp protects **access to your actual kit**, not an abstract coordinate. **Generic actions** (T·A.3 — available from any position) remain the absolute floor beneath the clamp, so a clamped character is never actionless.

**Why it must be computed.** A hand-tuned constant silently desynchronises from region thresholds the first time anyone touches `T = 0.35`, `ΣF ≤ 0.45` or the `F ≤ 0.25` per-corner cap — and no test would fail. Computed, it tracks automatically.

**The clamp applies to the summed total, not per-source.** W§11.4 establishes that **surfaces also emit temporary stat modifiers on effective fields**. A wounded character standing in corrosion is subject to both. The clamp must therefore be applied to `Σ (all effective-field reductions from all sources)`, not per-wound and not per-system.

**Spinal and nerve injury use `[CDM]`, not field crush.** Paralysis-class effects are modelled as a strong sustained `[CDM]` force pinning the dot plus explicit function denial — the field stays intact, the dot is merely held. This is more fictionally vivid and structurally safer than crushing the field toward the clamp.

---

## 11. Enemy anatomy depth

### 11.1 Derivation from the capability ladder

T·F.0 defines the four enemy tiers *"by which loop stages they possess, not by stat size."* Anatomy depth follows the same principle: **depth of anatomy equals what there is to degrade.** A wound is interesting on an enemy exactly insofar as it can break something that enemy *does*. This is a derivation, not a cost compromise — and performance is explicitly *not* the binding constraint, since hit resolution is one weighted sample rather than a per-node iteration. The binding constraints are authoring (solved by templates, §5.3) and legibility.

| Tier | Loop stages possessed (T·F.0) | Body template | Wound ledger | Called shots | `[Wounded]` behaviour |
| --- | --- | --- | --- | --- | --- |
| **Trash** | has position; exploitable | **none** — HP + integrity | none | no (damage only) | no |
| **Standard** | + creates Openings, applies `[Back-foot]` | **reduced, 5 nodes** | limited families | coarse | **yes** |
| **[Elite]** | + reads Openings → `[Advantage]` action | **full** | full | yes | **yes** |
| **[Commander]** | + banks Grit → `[Signature Action]` | **full + signature-linked nodes** | full + unique | yes, targeted | **yes** |

### 11.2 Standard's five nodes

`head · torso · primary limb · offhand limb · stance-limbs`

These are aggregations of the same finer body-template weights, not a second hand-authored probability table. Each coarse node receives the sum of its realised descendants before situational multipliers and renormalisation. Elite and Commander templates expose the finer nodes; Trash exposes none.

The limb split is what makes it five, and it is required rather than cosmetic: M·2A.10's **no pip pooling** rule means a skill draws from the hand used, so breaking one arm must be distinguishable from breaking the other, and `[Combo-Action]` requires both sources intact.

### 11.3 Commander weak points

*Full + signature-linked nodes* means a boss's `[Signature Action]` can be anatomically anchored — the thing it winds up with is a thing that can be broken. This is the natural home for unique anatomy (a construct's core, a beast's extra limb) and it arrives free from the template system. It also fits W§5.2's escalating-boss structure: the same boss met at Delve 3, 9 and 10 can expose progressively more anatomy as it reveals more of its kit.

### 11.4 `[Wounded]` behaviour tag

Enemies do not triage with items. Instead, a **`[Wounded]` behaviour modifier** [LEXICON+] shifts AI policy toward defence or disengagement. This is native: T·F.1 establishes behaviour as a typed tag and states *"the tag set **is** the behaviour policy — learnable and transferable."*

Applies to **Standard, Elite and Commander**. Trash has no wound ledger and therefore no tag. Note that Standard has **no credit economy** (T·F.0), so its wounded policy is a stance and aggression shift only — nothing that spends.

---

## 12. UI, rendering and legibility

### 12.1 Three bands

| Band | Carries | Surface |
| --- | --- | --- |
| **Ambient** | limping, arm guarding, laboured breathing, concussed sway, blood trails | posture rig (V·4.2) |
| **HUD** | ≤4 wound families, ABCDE-ordered worst-first | condition strip (K12 cap) |
| **Inspection** | full body graph, node grades, treatment tags, exact stat effects | hover panel (V·4.6) |

V·4.6 already covers *"buffs, debuffs, conditions... integrity state"* — the wound ledger slots into an existing surface with no new UI.

### 12.2 Enemy legibility rides the posture telegraph

**Requirement 5 (V·4.3)** locks that enemy posture must telegraph capability, because *"enemies carry positions and anchors, so their stance reveals which skills they can currently use."*

A wound crushes the enemy's effective field → crushes its Reach → **genuinely changes which skills it can currently use** → which the posture telegraph already displays. Enemy wound legibility is therefore **not a new channel**; it is the existing telegraph correctly reflecting a degraded field. The player reads *"that thing can't reach its heavy anymore"* through the same channel they already read *"that thing is leaning Pressure."*

No icons on enemies at any tier. Ambient posture only; inspection for Elite and Commander detail.

### 12.3 Wound rendering must not share the integrity channel [NEW — hard rule]

> **Canonicalised at 0.10.0 as V · 4.8, Requirement 8.** This section states the reasoning; V holds the authoritative encoding spec and the half-second gate.

V·4.4 Requirement 6 renders Cracked / Fractured / Broken Guard via **material swaps and decals**, and integrity feeds Bridge 1 — a player must see compromised armour *to understand why their Openings are landing deeper*. Wounds and integrity both read as "that thing is damaged." Confusing them breaks the Bridge 1 read, because they imply completely different play.

**Separate render targets, which ◇V2's one-rig architecture already provides:**

| State | Render target | Channel |
| --- | --- | --- |
| Armour integrity | equipment **mesh + material** | material swap, decals |
| Shield integrity | shield mesh, **displayed separately** (locked, V·4.4) | material swap |
| **Wounds** | **body rig — skeletal deformation** | limb-local pose offsets |

Armour is a mesh that swaps; a wound is the skeleton underneath moving differently. Orthogonal by construction rather than by art discipline. The design already carries a three-way precedent — shield integrity is *already* required to display separately from body armour; flesh becomes the third.

**Blood decals are specifically forbidden on equipment surfaces**, as they read as integrity damage. Bleed cues must be motion or trail, never a surface decal.

### 12.4 The fourth posture channel

V·4.2 establishes that posture already carries **three** things — stance, trajectory and exposure. Wounds make four. Safe encoding:

| Channel | Physical aspect |
| --- | --- |
| stance | whole-body blend direction (`(m,f,i)` blend tree, ◇V1) |
| trajectory | motion and velocity of the blend |
| exposure | commitment depth |
| **wounds** | **limb-local, static, asymmetric deformation** |

Limb-local and static is orthogonal to whole-body and dynamic. A dragging leg does not read as a Momentum lean, because the lean is a torso and weight-distribution signal.

**Note on scope.** The *two failure modes rule* is a **skill bar** requirement (V·4.1) — it governs button treatment, distinguishing angular unavailability from radial weakness. It does not constrain the posture display, so the wound overlay does not touch it.

**The live risk is signal-to-noise, not rule violation.** V·4.3 requires enemy posture to be *"distinct enough between anchor neighbourhoods."* Overlay noise degrading that distinctness is the real failure mode.

**Gate — already locked, not invented here.** ◇V6, carrying T·J.9: *"Prototype the state display before finalising the maths. If the state cannot be read in under half a second, simplify the maths — not the UI."* The wound overlay ships **only if a wounded enemy's anchor neighbourhood still reads in under half a second.** If it fails, the locked instruction is to simplify the wound model, not to add UI.

---

## 13. Consolidated invariants

*H's `H-C{n}` notation became the set-wide standard at 0.11.0. Full cross-document suite in `R-Validation_Rules_Index_TRIADE-0_45_0.md`.*

```
INVARIANTS (extend K16 / W§16.1):

H-C1  Σ (all effective-field reductions, all sources) per corner
      ≥ max(Φ_safe_x, 0.5 × Φ_base_x)                    [CRITICAL]
H-C2  At run start, ΣF_rendered == ΣF_baseline            [CRITICAL, ◈W2f]
H-C3  No RemedyDef may denominate economy_cost in
      Location Grounding (player-facing [Imprint])
      or in Temper. Rule binds the INTERNAL name, so a
      player-facing rename cannot evade it                 [CRITICAL]
H-C4  Vital-organ lethality gated on HP < Finisher
      threshold OR target Downed                          [CRITICAL]
H-C5  Wound/temporary effects never alter baseline floors,
      region thresholds, or global geometry               [CRITICAL]
H-H1  All wound cdm_influence vectors satisfy dm+df+di = 0 [HIGH]
H-H2  Ambient wound summary ≤ 4 items; same-family
      wounds refresh or escalate, never stack             [HIGH]
H-H3  Every remedy's cure_tags resolve to at least one
      reachable ConditionDef (no dead treatments)         [HIGH]
H-H4  Every ConditionDef is treatable by at least one
      RemedyDef reachable at its scarcity tier            [HIGH]
H-C6  Every actor resolves to exactly one [Chassis], and
      every [Chassis] to exactly one BodyTemplate         [CRITICAL]
H-H5  Aim never overrides the coverage cascade; resolved
      aim_weight < AIM_CEILING < 1.0             [HIGH, S-H09]
H-C7  An unarmed footprint is authored per NODE on the
      lineage and is live while that node is; no slot
      table, never per chassis                            [CRITICAL]
H-C8  Only Permanent-tier sources (T·G.3) may alter an
      innate profile; Worn composes, Temporary never
      touches it                                          [CRITICAL]
H-C9  Primary resolution emits one immutable layer trace;
      Payload delivery reads it once and never reruns
      mitigation or substitutes unrelated damage          [CRITICAL]
H-C10 Every successful single-node attack samples one
      eligible realised node from effective weights
      normalised after situational multipliers; tiered
      anatomy aggregates those weights, never reauthors
      a parallel probability table                         [CRITICAL]
H-H6  Divine purge consumes the state it converts —
      no sequence extracts more than was invested   [HIGH, T-H1]
H-M1  Wound render targets disjoint from integrity
      render targets                                      [MEDIUM]
H-M2  Coverage weights normalise to 1.0 per template.
      Weights are relative and PER-PAIR (§5.4); they are
      not required to sum to 100                          [MEDIUM]
```

---

## 14. Sim harness metrics and gates

Extends K16/K17. All architecture is settled; **every number below is [SIM]**.

| Metric | Gate | Action on breach |
| --- | --- | --- |
| **Death-spiral index** — share of wounded encounters ending unrecoverable | ≤ ~5% | loosen recovery, or soften field-modifier magnitudes |
| **Region-residency shift under injury** | must stay non-zero in every region | clamp is failing — live check on H-C1 |
| **Ambient wound-icon count** | ≤ 4, always | tighten same-family refresh rule |
| **Wound incidence per encounter**, by tier | within band | adjust coverage or thresholds |
| **TTK / TTL under injury** (K13 benchmark) | exchange loop must not be skipped | wounds too harsh |
| **Treatment-service usage rate** | non-trivial at Major and Critical | services are dead content — reprice |
| **Return-vs-descend split under injury** | injury measurably shifts toward banking | confirms §8.1's contribution to W's imbalance |
| **Posture read time, wounded enemy** | < 0.5 s (◇V6 / T·J.9) | **simplify the wound model, not the UI** |
| **Systemic strain distribution** | super-linear in max severity | sum-of-squares miscalibrated |

---

## 15. Staging

| Phase | Content | Gate to advance |
| --- | --- | --- |
| **0 — Schema** | Body template, Condition, RemedyDef, invariants as CI linter rules | All H-C rules assertable and green on fixtures |
| **1 — Core loop** | HP + wound ledger, one wound per archetype, `hp_transfer`/`systemic_weight`, three tiers | 10k-seed sweep; 0 Critical failures; death-spiral index in band |
| **2 — Brakes** | Clamp with computed `Φ_safe_x`, free dressing, Clumsiness routing | Region-residency non-zero in all regions across all reference builds |
| **3 — Full taxonomy** | All 14 types via 6 archetypes + deltas; full effects table | No archetype requires more than its delta budget |
| **4 — Mitigation economy** | Full remedy table, town services, severity-gated recovery | Service usage non-trivial; H-C3 green |
| **5 — Enemy anatomy** | Tiered templates, `[Wounded]` behaviour tag | Standard/Elite/Commander read distinctly under load |
| **6 — Rendering** | Posture wound overlay, integrity separation | **Half-second read test passes**, else revert to §12.1 HUD-only |

---

## 16. Lexicon additions

All **provisional**, pending Steward review.

| Term | Definition | Ref |
| --- | --- | --- |
| **[Wound]** | A locational, persistent injury held on a body node; a `Condition` subtype surviving beyond the encounter and healed only by treatment. Distinct from HP loss | H§7.1 |
| **[Body Location]** | A node in the skeletal/muscular/organ graph carrying coverage, layers, function tags and stat links. **Never** *region* (locked: Instinct/Pressure/Discipline) or *zone* (locked: battlefield, K4) | H§5.1 |
| **[Tissue Layer]** | The `skin → muscle → bone → organ` stack. Rigid layers fracture (Shatter); flexible layers tear (Tear). Extends M·2A.4 inward past armour | H§5.1 |
| **[Wound Severity]** | Three-tier ordinal — Minor / Major / Critical — derived from a continuous per-node trauma accumulator | H§6.4 |
| **[Hobbled]** | Leg or foot wound state: Momentum field down, zone-move cost up, readiness down | H§7.2 |
| **[Deafened]** | Ear wound: readiness down, telegraph clarity reduced. Complements the illustrative `[Blinded]` | H§7.2 |
| **[Wounded]** | Behaviour tag shifting AI policy toward defence or disengagement. Standard tier and above | H§11.4 |
| **Trauma Safety Clamp** | The two-term lower bound on injury-driven effective-field loss, guaranteeing every held region stays mechanically reachable. Resolves W§5.6a's crushed-field lockout | H§10.2 |
| **`Φ_safe_x`** | The computed per-corner floor at which the Reach render still meets the lowest `[Reach Cost]`/`[Level Requirement]` in the character's vocabulary. Derived, never authored | H§10.2 |
| **Systemic strain** | Sum-of-squares aggregate over active wounds weighted by `systemic_weight`. Super-linear in severity, sub-linear in count | H§7.5 |
| **`hp_transfer`** | Per-node efficiency converting residual damage into global HP loss | H§6.3 |
| **`systemic_weight`** | Per-node contribution to derived crisis states | H§6.3 |
| **Body template** | An instantiable body-graph definition. Non-humanoid and tiered-enemy bodies are new templates, not schema changes | H§5.3 |

**Terms reused without redefinition:** Condition, `[CDM]`/`[EDM]`, temporary stat modifier, baseline/effective field, Slash/Impact/Pierce/Shatter/Tear and the full 14-type taxonomy, damage groups, integrity states, status hooks, Bridges 1–3, HP, AP, Clumsiness, `[Combo-Action]`, `[Pivot]`, `[Watch]`, Finisher, `[Opening]`, `[Back-foot]`, `[Advantage]`, Edge/Grit/Temper, `[Modification Ceiling]`, `[Delve level]`, `[Stratum]`.

### Currency vocabulary consumed by H

Settled in reconciliation; **owned by the Economy/World workstream**, recorded here because §8 prices against it.

| Function | Player-facing | Internal | Register |
| --- | --- | --- | --- |
| Ordinary town money | **Marks** | Marks | neutral (or steel — a smith's maker's mark) |
| Item salvage material | **Scrap** | Scrap | steel |
| Affix reroll material | **Flux** | Flux | steel — the smelting agent that lets a bond take |
| Per-Location progression | **[Imprint]** | `Location Grounding` | geological — strata contain imprints |
| Moment / encounter / run credit | Edge / Grit / Temper | same | steel (locked) |

**Two consequences for W**, which owns these terms:

1. `Location Grounding` must be **unbracketed** in W§5.1 and W§21 (demoted to design-model), with `[Imprint]` added as the bracketed player-facing term. This follows the existing Lexicon convention: bracketed = *"named quantities the player or systems reference directly"*, unbracketed = *"design-model concepts."*
2. **◈W5 is resolved by this rename.** *Grounding* did read Form-adjacent — "grounded" is the natural word for a Form-heavy stance. *Imprint* carries no such shadow, and simultaneously satisfies ◈W6's request that the geological register extend to the spend-facing name.

**Collision check performed.** No term proposed *by H* shadows locked vocabulary; the single hazard — calling body areas *regions* or *zones* — is avoided by `[Body Location]`. Two residual risks in the inherited currency set are recorded as ◇H11 and ◇H12 (§17).

---

## 17. Open questions

| # | Question | Blocking |
| --- | --- | --- |
| ~~◈H1~~ | **RESOLVED.** Money is **Marks**; medicine takes no dedicated currency (§8.5). `[Imprint]` replaces `[Location Grounding]` player-facing, resolving ◈W5 and ◈W6 | — |
| ~~◈H2~~ | **RESOLVED 0.13.0.** Not a defect. Weights are relative and normalised by H-M2; the 110 sum is legal. Convention locked **per-pair** (§5.4) | — |
| ◇H3 | **Concussion granularity.** Full GCS-style consciousness sub-track vs single Mind-field penalty. Bookkeeping vs texture | Balance |
| ~~◈H4~~ | **RESOLVED 0.13.0.** Aim biases the coverage cascade rather than branching around it; aim weight is a C.6 check bounded by `AIM_CEILING` (§6.2a, S-H09) | — |
| ◇H5 | **Infection / disease.** In scope later or permanently out? CDDA and Zomboid treat it as major; deferred here (⦻H5) | Scope |
| ◇H6 | **Cross-run scar carry.** `converts_to_scar` ships off. Whether it ever turns on belongs to the prosthetic/regrow/rite workstream | Separate workstream |
| ◇H7 | **Enemy wound persistence.** Do Elite/Commander wounds persist between encounters within a run, or reset? Affects boss escalation across Delve 3/9/10 (W§5.2) | Balance |
| ◇H8 | **Treatment slot limits.** One splint per node is assumed; whole-body caps on simultaneous treatments undecided | Balance |
| ◇H9 | **Routing delta budget.** How far a type may deviate from its archetype before it warrants its own archetype | Content |
| ◇H10 | All magnitudes — coverage, thresholds, `hp_transfer`, `systemic_weight`, clamp constants, recovery costs, decay rates | Sim [SIM] |
| ◇H11 | **Flux as a reserved word.** *Flux* is the standard physics term for field flow, and the doc set uses `Φ`/"field" throughout. Currently free — no source doc uses the word — but it should be declared *currency only, never a field quantity* in the Lexicon before it surfaces naturally in field discussion | Lexicon |
| ◇H12 | **Marks vs. landmark / `[Pressure Marches]`.** *Landmark* is locked twice (T·A3.1 boundary landmarks; L "landmark vs transition cell") and W§4 uses landmarks as authored anchors. "Spend 80 Marks in the Marches" is a live sentence. Substring and near-rhyme, not homonym — judged acceptable, recorded so it is not rediscovered | Lexicon |
| ◇H13 | **Scrap ↔ Flux conversion.** Independent sinks, or is there a conversion path? Independence permits Scrap-rich / Flux-poor states, which is either useful friction or pure annoyance. Does dismantling yield both? | Economy |
| ~~**◈H15**~~ | **CLOSED 0.27.0.** The player chassis is the **lineage** (T·A4.8a) — one record carrying body template, available sizes with a `typical` flag, and a zero-sum 9-stat offset measured at typical. `[Race]` stayed rejected; **lineage** was free | — |
| ◇H14 | **Town screen currency load.** Marks, Scrap, Flux, Temper and `[Imprint]` are all spendable at town — five simultaneous resources against M·0.10's open readability budget, which is *"tighter than usual, because the Triade already consumes screen attention"* | UI |

### Dependencies discharged to other workstreams

| Item | To |
| --- | --- |
| Prosthetic / regrow / rite economy, and whether `converts_to_scar` ever activates | **Separate workstream** (⦻H4) |
| Formal adoption of Marks / Scrap / Flux / `[Imprint]`; unbracketing `Location Grounding` in W§5.1 and §21 | **Economy / World** (resolves ◈W5 and ◈W6) |
| Boss anatomical weak points per escalation form | **Content** (relates to ◇W8) |
| Town treatment service siting | **World** (relates to ◇W9) |
| ~~`[Location Grounding]` lexicon collision check~~ | **RESOLVED** — renamed to `[Imprint]`; ◈W5 and ◈W6 both closed |
| ~~Corner-floor render affinity under injury-driven field range~~ | **RESOLVED 0.13.0** — stated in T·A4.4 and promoted to rule **T-C11**; ◈W2d closed in W. H§10.2's clamp is what bounded the render's exercised domain and made it statable |

---

## 18. References

**Tabletop injury systems** — Iron Crown, *Rolemaster: Arms Law* (critical tables A–E); Steve Jackson Games, *GURPS* (hit locations, crippling thresholds, shock, bleeding); Design Mechanism, *Mythras* (per-location HP, minor/serious/major wounds); Cubicle 7, *Warhammer Fantasy Roleplay 4e* (Wounds buffer, Critical Wounds, Toughness-Bonus death tally); Harper, *Blades in the Dark* (harm levels, healing clock, downtime); Sword Dream / OSR death-table traditions.

**Video-game injury models** — Ludeon, *RimWorld* (`Hediff`, `BodyPartRecord`, coverage cascade, `capMods`, stages, tending); Bay 12, *Dwarf Fortress* (tissue layers, nerve and spine cascade, material-driven wounding); Battlestate, *Escape from Tarkov* (per-limb HP, blacked limbs, fracture vs bleed tooling); CDDA contributors, *Cataclysm: Dark Days Ahead* (`wound` / `wound_fix` JSON schema, limb HP, pain, bleeding stages); Freehold, *Caves of Qud* (dismemberment, regrowth reagents); Indie Stone, *Project Zomboid*; Lo-Fi Games, *Kenshi* (limb loss, prosthetics); FakeFish, *Barotrauma* (per-limb continuous afflictions).

**Clinical severity and triage** — Association for the Advancement of Automotive Medicine, *Abbreviated Injury Scale* (six-point ordinal, non-linear); Baker et al., *Injury Severity Score* (sum of squares of top-three body-area AIS AIS); Teasdale & Jennett, *Glasgow Coma Scale* (1974); ATLS *ABCDE* primary survey.

**Injury epidemiology (distribution shape only)** — US Army Joint Theater Trauma Registry 2005–2009, reported ACS 2011 (extremity-weighted wound distribution); Eastridge et al., *Death on the Battlefield (2001–2011)*, J Trauma 2012 (truncal-weighted fatal hemorrhage). Cited to justify a torso-and-extremity-biased distribution, not any exact table.

**Design writing** — death-spiral and granularity-vs-playability discussions in the OSR and simulationist design literature; Mothership's stress-to-XP conversion as an "engagement over punishment" pattern.

---

*Merged from two independent design reports, 28 July 2026. Architecture settled; numbers pending simulation per K17. Discharges ◈W2e (W§5.6a). Preserves ◈W2f without amendment.*

## Changelog

| Version | Change |
| --- | --- |
| **0.45.0** | Version and cross-reference alignment; Tarot acquisition/layout authority belongs to P·2.3f–i and does not alter this document's existing rules. |
| **0.44.0** | Version alignment only. P12-C consumes live H-owned function denial and recipient compatibility at their declared milestones without changing anatomy, coverage, wound or layer-trace authority. |
| **0.43.0** | Version alignment only. P12-B consumes H-owned function denial as candidate-local source/hook evidence and changes no anatomy, BodyTemplate, wound or denial contract. |
| **0.42.0** | Version alignment only. P12-A reuses H-owned function denial and changes no anatomy, BodyTemplate, wound or route-scoped denial contract. |
| **0.41.0** | **Faculty hook correction.** §7.2a now reads voice/vocal function for Arcana, selected fingers plus occupancy for Mudra, Brain only for Psyche, and the selected bound node for Somatic. Denial remains H-owned `function_denial` and is route-scoped. |
| **0.40.0** | Version alignment only. P·2.3a references H-owned BodyTemplates and nodes without moving anatomical authority; Somatic authorization adds no physical source or node semantics. |
| **0.39.0** | **A2 anatomical targeting reconciled into existing authority.** Effective weights are renormalised after situational multipliers, Standard's five nodes aggregate the same finer weights, and no parallel probability table exists (**H-C10**). Aim still biases rather than selects (**H-H5**). |
| **0.38.0** | 2 other-spatial misuses of the reserved word replaced — `body-node group` and `body-area AIS`. **Session A:** §6.1a authors the immutable node/equipment/tissue layer trace consumed by K's delivery proof (**H-C9**). |
| **0.35.0** | **§7.1b — condition durations expressed in `world_tick`**, not elapsed AP or rounds, since AP is a rate and no longer denotes an amount. Town Temporal Suspension holds. **H-C8 unchanged**: duration is not permanence, so temporary contamination cannot grant a profile-gated skill. |
| **0.33.0** | **`usage_phase` → `availability_contexts`** — `phase` is locked to sequencing steps `X⇥n`, and these values are availability contexts, not a temporal order. |
| **0.32.0** | **§7.1a and `H-C8`: what may alter an innate profile.** Only **Permanent**-tier sources (T·G.3) — Worn composes, Temporary never touches it. Nothing is on that channel for the body today, because `converts_to_scar` ships off under `⦻H4`. **H-C7 restated**: per node, no slot table. |
| **0.27.0** | **`◈H15` closed** — the player chassis is the lineage. The source was unnamed, not missing. Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | Its six non-goals become **⦻H1**–**⦻H6**. `H3` had been a non-goal, a goal *and* a live open item; `⦻H3`, `◉H3-H§3` and `◇H3` are now three strings. Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | Its eight design goals become **◉H1-H§3**–**◉H8-H§3**. `H3`, `H5`, `H6`, `H7` and `H8` had been *simultaneously* a goal and a live open item inside this document; the glyph is what now separates ◉H3-H§3 from ◇H3. Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **69 glyphed identifiers in this document.** |
| **0.12.0** | §8.1 cross-checked against W§5.9's `[Incursion]`: paid recovery must be proofed against a second currency faucet, with net-after-recovery as the gate and the reagent share as the first dial. No structural change to the damage model. Document set grows to nine. |
| **0.16.0** | **`RemedyDef.category` renamed `remedy_type`** (§8.4). A remedy is an item — it carries `scarcity_tier` (M·2.2) and `affix_slots` (M·2.3) — so it already holds the locked item `category` (M·2.1, P·1.3), and one record cannot carry two fields of that name meaning different things. The two enums **overlapped on `consumable` and diverged on five values**, which is precisely why the collision survived from 0.10.0: a partial overlap reads as a coincidence rather than a clash. P·7.1's category-completeness lint was unwritable against the ambiguity. Rule **L-M2**, caught by a sweep rather than a census. |
| **0.13.0** *(Stage 1)* | **§6.2b, §7.2a, §8.2a added.** Divine purge resolves as one action with two faces — the state it consumes is the damage it deals — braked by **H-H6**: purge consumes entirely, so it converts rather than generates. **§8.2a adds occult load**, a cumulative ratchet that accrues whether or not a state is purged in combat, converting past threshold to ward scars that only the town rite clears; in-combat purge is tactically complete and strategically partial. **§7.2a names the faculty gates** — every one already existed in §7.2 and §6.3 before the families were named. **§6.2's Occult rows corrected**: the affinity column mixed anatomy with a target predicate, so *corrupted targets* moved out to become a damage scalar and Warped's own nodes (head, spine) became Divine's affinity. **Stage 0 term renamed in the same version** — `FOCUS_CEILING`/`focus` became `AIM_CEILING`/`aim_weight` after an L-M2 collision with the pre-existing Mind-side *focus* was missed at Stage 0. New rules **H-C7**, **H-H6**. |
| **0.13.0** | **◈H2 and ◈H4 closed.** ◈H2 was **not a defect** — §5.4's weights are relative, the schema said so, and H-M2 already normalised them; the SIM Register's "must normalise" entry restated an existing rule. The genuine question was the convention, now locked **per-pair** with the burn-assessment reference stated inline. Coverage column renamed *Coverage weight* and the misleading `%` sign struck from 13 values. **◈H4 closed by §6.2a**: aim biases the coverage cascade rather than branching around it, the deterministic `called_shot` branch in `resolve()` is struck, and focus resolves as a T·C.6 check bounded by `AIM_CEILING` (**S-H09**) — the mirror of A3.7's potency floor. **`[Chassis]` made universal** (§5.3): every actor carries exactly one and it names the BodyTemplate, referenced never inlined. A player chassis supplies anatomy only, never floor shape — stated as a negative. New rules **H-C6**, **H-H5**; H-M2 amended. **◇H15** registered as a new gap: no document owns the player chassis source. |
| **0.11.0** | §13 invariant notation adopted as the set-wide standard. Anatomical depth per enemy tier now references **E** rather than T·F. Open items marked and indexed; ◈H2 (coverage weights summing to 110) flagged in the SIM Register as a defect blocking the anatomy sweep branch. Document set grows to eight. |
| **0.10.0** | **Document created.** Damage & Health system merged from two independent reports. Resolves the three items reassigned by W§5.6a: injury persistence (§9.3), the injury→stat-modifier→effective-field pathway (§6.1), and the crushed-field lockout risk (§10.2). Adds the anatomical body-template model, 14-type archetype routing, three-tier severity with sum-of-squares combination, the renewable-currency recovery rule, four named brakes, tiered enemy anatomy derived from the capability ladder, and the wound-vs-integrity render separation (now V·4.8). Currency vocabulary integrated — Marks / Scrap / Flux / `[Imprint]`; ◈H1 closed; H-C3 bound to the internal name `Location Grounding`; ◇H11–◇H14 opened. Filename convention standardised. |
