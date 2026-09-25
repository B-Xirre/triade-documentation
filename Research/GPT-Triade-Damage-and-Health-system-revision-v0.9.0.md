# Triade Damage and Health System

The attached design set explicitly leaves damage and health as a dedicated follow-on workstream, so the right goal is not to bolt on a second combat game, but to complete the missing layer in a way that respects the locked invariants already present in Triade. In particular, HP must remain the primary victory condition; structural damage must continue to function as setup rather than a parallel kill race; conditions should still resolve through the two channels the combat rules already support — zero-sum dot influences and temporary stat modifiers affecting effective fields — and the system must preserve the guaranteed minimum AP floor, avoid new lockout loops, honour the sum-preserving floor philosophy, and stay inside the readability budget of the current UI model. The proposal below is built on those constraints. fileciteturn0file1 fileciteturn0file2 fileciteturn0file0 fileciteturn0file4 fileciteturn0file5

## Locked constraints that the health layer must preserve

Triade already commits to several properties that a health system cannot violate. The most important are these: combat is an exchange-control game rather than a pure damage race; HP depletion is still the primary win condition; structural damage works by degrading integrity into deeper, longer-lasting Openings; injuries and buffs already have a sanctioned route into the game through temporary stat modifiers that reshape effective fields; armour, shields, and body posture already alter displacement and mitigation before HP loss is applied; and temporary state is expected to clear at the run boundary. The implication is decisive: anatomy should modify how damage lands, how the combat loop behaves, and how the character’s effective field package is deformed, but it should *not* replace HP, replace integrity, or add a dozen new always-visible resources. fileciteturn0file1 fileciteturn0file2 fileciteturn0file0 fileciteturn0file5

From that, the cleanest fitted design is a **dual-layer health model**:

```text
Global layer:
- HP remains the main kill condition
- existing armour/shield/integrity rules stay in place

Local layer:
- hits also write to an anatomical wound ledger
- wounds emit:
  - temporary stat modifiers
  - CDM vectors
  - ongoing HP loss or AP / movement taxes
  - local functional disablement
```

This keeps the number of top-level systems small while giving anatomy real teeth. It also aligns with the project’s general preference for derived, data-driven state over extra hand-authored subsystems, and with the itemisation document’s demand that behavioural effects route through the same underlying mechanics instead of sitting beside them. fileciteturn0file2 fileciteturn0file0

The one new safety rule that the health layer should explicitly add is a **Trauma Safety Clamp** for effective fields. The world document flags an unresolved risk that crushed fields could create lockout, especially on Mind-based recovery tools. To prevent injury from becoming an irreversible downward spiral, this proposal adds:

```text
Φ_eff_x_after_injury >= max(Φ_safe_x, 0.5 * Φ_base_x)
```

`Φ_safe_x` is a per-corner emergency lower bound tuned so that one basic action from each corner family always remains reachable and the existing minimum AP floor still matters. This is the named brake the deferred workstream needs. It solves the exact lockout risk identified in the world design without touching baseline floors or the conserved modification budget. fileciteturn0file5 fileciteturn0file2

## Anatomical model bound to Triade stats and combat flow

The anatomy should be modelled as a **hierarchical body graph** rather than as many independent HP bars. The graph supports hit distribution, tissue routing, functional disablement, and treatment targeting, while still collapsing to a readable set of conditions for the player. Each node has one dominant bone, one or more major muscle groups, optional contained organs, and one or more function tags that link the wound to existing derived statistics and region play. This is the best fit with Triade’s stat grouping model, where Momentum governs force and precise action, Form governs stability and mitigation, and Mind governs control and leverage. fileciteturn0file2 fileciteturn0file0

### Proposed body graph and stat linkage

The table below uses the requested anatomy, but maps each part to the *already locked* stat and combat vocabulary rather than inventing new standalone attributes.

| Node archetype | Included structure | Main muscle groups | Contained organs | Base coverage share | Dominant function tags | Primary stat links | Typical failure feel |
|---|---|---|---|---:|---|---|---|
| **Head** | Skull | jaw, neck stabilisers | brain, eyes, ears, teeth | 8% | cognition, perception, speech | Intellect, Will, Spirit | read failure, daze, sensory loss |
| **Shoulder** ×2 | scapula, collar-bone | deltoid, trapezius, rotator cuff | — | 8% | weapon control, guard posture | Strength, Finesse, Poise | off-hand/main-hand instability |
| **Sternum** | sternum | pectorals | — | 6% | breath bracing, chest structure | Frame, Constitution | guard-shaken, breath tax |
| **Rib cage** | ribs | intercostals, upper core | lungs, heart, liver | 16% | respiration, circulation, posture | Constitution, Spirit, Frame | punctured breath, vital strain |
| **Spine** | vertebral column | erector spinae, deep core | — | 8% | posture, pivot, brace | Frame, Poise, Constitution | stance collapse, severe AP tax |
| **Hip / pelvis** | hip-bone | gluteals, hip flexors, lower core | — | 10% | locomotion, stance stability | Frame, Poise, Stamina | movement collapse |
| **Upper arm** ×2 | humerus | biceps, triceps | — | 10% | striking force | Strength, Finesse | weakened attacks |
| **Forearm** ×2 | radius-dominant forearm model | flexors, extensors, pronation-supination chain | — | 8% | precision, grip setup | Finesse, Strength | bad accuracy, poor conversions |
| **Hand** ×2 | hand, fingers | finger flexors/extensors, intrinsic hand | — | 6% | grip, manipulation | Finesse | dropped guard, item-use penalty |
| **Thigh** ×2 | femur | quadriceps, hamstrings, adductors | — | 12% | drive, charge, base movement | Strength, Stamina, Poise | charge failure, stumble risk |
| **Knee** ×2 | kneecap | patellar chain | — | 4% | directional change | Poise, Finesse | pivot tax, collapse under pressure |
| **Shin** ×2 | tibia | calves, tibialis/peroneals | — | 8% | footing, recovery | Poise, Stamina | poor home-well recovery |
| **Foot** ×2 | foot | plantar/intrinsic foot | — | 6% | footing, stance acquisition | Poise, Finesse | slip, weak anchoring |

The coverage shares are *neutral-stance defaults* for a standing humanoid with no shield interception. They are not hard hit chances. They are multiplied at runtime by attack height profile, angle, zone context, cover, shield position, and current exposure. That preserves the existing distinction between battlefield abstraction, body posture, shield use, and damage resolution. fileciteturn0file1 fileciteturn0file0

For implementation, each archetype should be instanced into a per-actor body graph:

```json
body_node: {
  "id": "rib_cage",
  "side": "centre",
  "parent": "torso",
  "bone": "rib_cage",
  "muscle_groups": ["intercostals", "upper_core"],
  "contained_organs": ["lungs", "heart", "liver"],
  "coverage_weight": 0.16,
  "armour_slot": "torso",
  "function_tags": ["respiration", "circulation", "posture"],
  "stat_links": [
    {"stat": "Constitution", "weight": 0.45},
    {"stat": "Spirit", "weight": 0.20},
    {"stat": "Frame", "weight": 0.35}
  ],
  "capacity_class": "vital_core",
  "thresholds": {"minor": 0.20, "major": 0.45, "critical": 0.70},
  "safety_clamped": true
}
```

This schema is intentionally parallel to the rest of Triade’s data-first architecture: ids, tags, thresholds, stat links, and effect emitters instead of bespoke logic. fileciteturn0file0 fileciteturn0file2

## Damage distribution model and anatomical damage tables

Because Triade already has a locked type pipeline — type share, mitigation, active guard, HP loss, structural integrity and status hooks — anatomy should enter **after** the existing mitigation stack and **before** conditions fully resolve. In other words: shield, Form mitigation, armour groups, and type exceptions still do their job first; the body system then decides what the residual hit actually did to flesh, bone, tendons, or organs. That preserves the current combat order and keeps armour meaningful. fileciteturn0file1

### Proposed resolution sequence

```text
1. Select impacted body node
2. Apply existing defensive ordering
   - shield / active defence
   - Form mitigation
   - armour group mitigation
   - type exception
3. Produce residual damage
4. Route residual damage into:
   - muscle trauma
   - bone trauma
   - tendon / nerve trauma
   - organ trauma
5. Accumulate local trauma on the node
6. Derive:
   - HP loss
   - wound grade
   - emitted conditions
   - local functional penalties
   - opening / exposure modifiers
```

This lets the health system “plug into” the current combat design instead of rewriting it. It also cleanly separates **armour integrity** from **anatomical trauma**: a Fractured cuirass is not the same as fractured ribs, and an intact harness with a punctured lung is a meaningful state. The docs already make the same distinction for shields versus body armour; the anatomy layer should keep that discipline. fileciteturn0file1 fileciteturn0file0 fileciteturn0file4

### Proposed hit distribution formula

```text
node_weight =
  base_coverage
  × attack_height_bias
  × attack_arc_bias
  × target_pose_modifier
  × exposure_modifier
  × cover_modifier
  × shield_intercept_modifier

local_trauma[layer] =
  residual_damage
  × routing_share[type][node_class][layer]
  × vulnerability_modifier[node][type]

hp_loss =
  residual_damage
  × hp_transfer[node]
  × vital_multiplier[contained_organ_state]
```

The important design choice here is that *anatomy modifies transfer and fallout, not the core victory rule*. HP remains the top-layer bar; anatomy decides whether the hit mainly became bleeding, fracture, disruption, vital strain, or a clean flesh wound. That stays faithful to the combat document’s “HP primary, setup systems secondary” discipline. fileciteturn0file1

### Proposed tissue routing by damage type

This routing table is the practical bridge between the existing fourteen-type taxonomy and the requested anatomical structure.

| Damage type | Primary routing | Secondary routing | Best anatomical targets | Default emitted family |
|---|---|---|---|---|
| **Slash** | muscle / skin 55% | tendon / nerve 20%, bone 15%, organ 10% | forearm, hand, shoulder, face, exposed torso | Bleeding, Lacerated |
| **Impact** | bone 50% | muscle 25%, organ shock 15%, tendon 10% | skull, sternum, ribs, spine, pelvis, knees | Bruised, Staggered, Fracture |
| **Pierce** | organ 55% when present | muscle 20%, tendon 15%, bone 10% | eyes, rib cage, sternum, abdomen equivalent within torso, hands, feet | Punctured, Pinned |
| **Explosive** | mixed scatter 30/25/20 | armour integrity 15%, tendon 10% | exposed limbs, torso clusters | Blasted, Multi-wound |
| **Fire** | soft tissue 45% | organ stress 20%, pain 15%, armour/gear 10%, nerve 10% | muscles, lungs by inhalation, hands, face | Ignited, Burned |
| **Lightning** | nerve 35% | muscle 25%, organ 20%, pain 10%, ward/gear 10% | head, spine, arms, chest | Shocked, Spasm |
| **Cold** | pain / tissue stiffening 25% | bone 20%, nerve 20%, muscle 25%, armour brittling 10% | hands, feet, ribs, joints | Chilled, Brittle |
| **Corrosive** | armour / gear 35% | flesh 30%, organ 20%, bone 15% | torso armour, face, hands | Eroded, Chemical burn |
| **Poison** | bloodstream / organ 45% | muscle 20%, blood loss synergy 20%, nerve 15% | pierce wounds, lungs, liver | Envenomed |
| **Shatter** | bone / shield / armour integrity 70% | organ shock 10%, muscle 20% | skull, sternum, ribs, spine, pelvis, long bones | Cracked, Broken |
| **Tear** | muscle / fascia 50% | tendon 25%, organ 15%, bone 10% | cloth-leather gaps, limbs, unarmoured flesh | Rent, Opened |
| **Chaos** | occult ward / cognition 30% | organ stress 20%, flesh 20%, focus 30% | head, spine, chest | Warped |
| **Divine** | ward / corruption purge 35% | organ stress 25%, pain / suppression 20%, flesh 20% | chest, head, corrupted targets | Purged, Consecrated |
| **Psychic** | cognition / nerve 60% | focus disruption 20%, organ shock 10%, muscle 10% | skull, eyes, ears, spine | Dazed, Focus-broken |

The routing shares are **starter balance values** for simulation, not locked final numbers. That is consistent with the rest of the documents, which repeatedly reserve quantitative tuning for the sim harness rather than trying to settle it by argument. fileciteturn0file0 fileciteturn0file1

### Proposed anatomical damage table

The next table is the operational core. It gives each requested node a default role in damage transfer, status production, and field deformation.

| Node | Capacity class | hp_transfer | systemic weight | Most dangerous types | Minor threshold effect | Major threshold effect | Critical threshold effect |
|---|---|---:|---:|---|---|---|---|
| **Head** | vital_core | 1.40 | 1.75 | Impact, Pierce, Psychic, Lightning | Dazed, -Intellect/-Will | Concussed, sensory penalties, weak read checks | Brain trauma, severe Mind loss, huge read/focus penalty |
| **Shoulder** | lever_core | 0.85 | 0.60 | Slash, Tear, Impact | weapon AP +1 for affected hand actions | Dislocated / cracked shoulder, block penalty | arm nearly disabled, shield or two-hand use compromised |
| **Sternum** | vital_core | 1.10 | 1.10 | Impact, Pierce, Shatter | breath tax, Guard-shaken | chest pain, reduced Form mitigation | chest collapse / cardiac shock risk |
| **Rib cage** | vital_core | 1.25 | 1.50 | Pierce, Impact, Fire, Shatter | winded, shallow bleed | punctured lung or liver shock | respiratory crisis, very high systemic strain |
| **Spine** | vital_core | 1.20 | 1.70 | Impact, Pierce, Lightning | posture penalty, Pivot tax | spine trauma, severe Poise loss | collapse, locomotion and guard failure |
| **Hip / pelvis** | heavy_core | 1.00 | 1.20 | Impact, Shatter, Pierce | step tax, movement penalty | pelvic instability, heavy locomotion loss | near-immobility, fall risk |
| **Upper arm** | limb_major | 0.75 | 0.50 | Slash, Tear, Impact | -Strength or -Finesse on that side | fracture or deep tear, attack_scalar penalty | main-hand or off-hand heavily impaired |
| **Forearm** | limb_major | 0.70 | 0.45 | Slash, Tear, Pierce, Impact | precision loss, parry loss | cracked radius / tendon damage | grip conversion greatly reduced |
| **Hand / fingers** | limb_fine | 0.55 | 0.35 | Slash, Pierce, Cold | grip slip, item-use tax | broken fingers, inaccurate use-item / reload | disarm risk, very poor manipulation |
| **Thigh / femur** | limb_major | 0.85 | 0.65 | Impact, Pierce, Tear, Shatter | movement tax, charge penalty | femur trauma, severe speed and stance penalties | collapse, cannot drive deep safely |
| **Knee / kneecap** | hinge | 0.65 | 0.50 | Impact, Pierce, Cold | Pivot +1 AP | joint instability, Poise loss | leg buckling, frequent falls |
| **Shin / tibia** | limb_major | 0.75 | 0.55 | Impact, Shatter, Cold | stance recovery weaker | tibia fracture, home-well recovery loss | leg nearly unusable |
| **Foot** | limb_fine | 0.60 | 0.45 | Impact, Pierce, Cold, Corrosive | footing loss, zone-move tax | crushed foot, major locomotion penalty | cannot hold angles cleanly |

The `hp_transfer` value states how efficiently residual damage becomes global HP loss through that node. The `systemic weight` states how much the node contributes to derived crisis states such as blood loss, breath debt, or neurotrauma. This avoids turning every body part into a separate defeat bar while still making head, chest, spine, and pelvis meaningfully more frightening than fingers. fileciteturn0file1 fileciteturn0file2

## Temporary and persistent effects tied to fields, posture, and anatomy

The combat rules already limit conditions to two supported channels: zero-sum influences and temporary stat modifiers affecting effective fields. The health system should keep that rule absolutely intact. Detailed wounds exist in the ledger, but what they *do* to play is always expressed through one or more of the following: stat penalties, AP / movement taxes, ongoing HP loss, local disablement, or a CDM vector that shifts posture. That keeps the wound layer legible and mechanically native. fileciteturn0file1 fileciteturn0file2

### Proposed wound effect schema

```json
wound_effect: {
  "id": "punctured_lung_major",
  "family": "respiratory",
  "source_nodes": ["rib_cage", "sternum"],
  "grade": "major",
  "stat_mods": [
    {"stat": "Constitution", "delta": -2},
    {"stat": "Spirit", "delta": -1}
  ],
  "cdm_vector": {"m": -0.10, "f": 0.15, "i": -0.05},
  "hp_dot_per_round": 3,
  "ap_tax": 1,
  "movement_tax": 0,
  "opening_mod": {"against_self": +0.10},
  "persistence": "run_until_treated",
  "visibility_priority": 90,
  "cure_tags": ["seal", "restoration", "surgery"]
}
```

That schema intentionally mirrors existing design language: modifiers are data, vectors are zero-sum, thresholds are explicit, and persistence is a data field rather than hidden logic. fileciteturn0file2 fileciteturn0file0

### Proposed temporary and persistent effects table

| Effect family | Typical anatomical sources | Temporary effects | Persistent effects if untreated | Channel output |
|---|---|---|---|---|
| **Pain** | any major hit, especially shoulder, ribs, limbs | small AP tax, slight push toward Form | chronic AP tax within run | CDM + small mixed stat penalty |
| **Bleeding / Opened** | slash / tear to shoulder, forearm, hand, thigh, torso | HP loss per round, easier follow-up damage | turns into blood-loss state within run | hp_dot + opening_mod |
| **Bruised / Guard-shaken** | impact to sternum, ribs, shoulders, thighs | reduced guard efficiency, short Stagger | usually clears after encounter | short-duration stat mod |
| **Fracture** | shatter / impact to skull, arm, ribs, pelvis, femur, tibia | large local function penalty | severe run-persistent disablement until splinted / treated | heavy stat mod + AP / move tax |
| **Dislocation** | shoulder, knee, hip | local range / block / pivot loss | unstable joint, reinjury risk | stat mod + vulnerability tag |
| **Concussed** | skull, face, lightning / psychic to head | poor read checks, Dazed, weaker Mind floor | long within-run cognitive penalty | Intellect / Will / Spirit loss + CDM |
| **Blinded** | eyes, corrosive / pierce / slash to head | accuracy and read penalty, proximity reliance | one eye can persist as partial perception loss | strong perception-linked penalties |
| **Deafened** | ears, explosive / impact / psychic head trauma | reduced telegraph clarity, slower reaction reads | mild persistent reaction penalty | reaction / read tax |
| **Jaw / teeth trauma** | face impact or slash | speech / incantation difficulty, pain | reduced vocal / occult skill use within run | Will / focus tax |
| **Respiratory trauma** | ribs, sternum, lungs | AP tax, cannot sustain deep commitments well | recurring breath debt until sealed / rested | Constitution / Spirit loss + hp_dot |
| **Cardiac trauma** | heart via sternum / rib pierce or critical chest impact | huge systemic strain spike, panic | near-fatal until advanced treatment | hp spike + severe stat drop |
| **Liver trauma** | low rib cage pierce / blunt trauma | delayed HP loss, weakness | strong within-run attrition | delayed hp_dot + Stamina loss |
| **Spinal trauma** | spine, lightning, heavy impact | Pivot, Move, Guard, and Watch all worsen | severe locomotion and posture instability | Frame / Poise / Constitution loss + CDM |
| **Pelvic instability** | hip-bone, heavy impact / shatter | zone movement, charge, and stance acquisition degrade | near-run-ending mobility problem | move tax + Poise / Frame loss |
| **Burned / Ignited** | exposed flesh, hands, face, lungs by fire | ongoing HP loss, panic, grip penalty | scarred pain until run end | hp_dot + Finesse loss |
| **Shocked / Spasm** | head, spine, arms, chest | interrupts, action unreliability | lingering tremor | Finesse / Will loss + short CDM |
| **Chilled / Brittle** | hands, feet, ribs, joints | weaker recovery, more fracture-prone follow-ups | clears with warmth / time | Poise / Finesse loss |
| **Envenomed** | pierce wounds, chest, liver | delayed HP loss, suppression | long attrition until cleansed | hp_dot + Stamina / Spirit loss |
| **Eroded tissue / armour** | corrosive hits | armour efficacy loss, exposed flesh risk | deep tissue pain until treated | armour mod + pain |
| **Warped / Focus-broken** | psychic / chaos to head and spine | read failure, stance disruption | lingering mental instability | Mind group penalties + CDM |

A few design rules are worth making explicit.

First, **visible conditions should stay capped**. The combat and visual documents are clear that the main view should not carry a dozen small icons. The wound ledger may contain many entries, but the combat HUD should only surface the four most tactically relevant families by priority, while full anatomical inspection lives on hover or panel. This preserves the legibility stack already defined for Triade. fileciteturn0file1 fileciteturn0file4

Second, **persistent does not mean permanent by default**. The clean MVP recommendation is:

- minor effects: encounter-scoped unless escalated;
- major effects: persist through the current run until treated;
- critical effects: persist through the current run and may demand town-grade treatment;
- all unresolved temporary-tier modifiers clear at the run boundary, matching the rule already adopted for temporary effective-field changes.

That uses the world document’s recommended boundary, keeps health management meaningful inside a run, and avoids introducing a third permanent-economy sink before the rest of the progression model has stabilised. fileciteturn0file5 fileciteturn0file2

## Mitigation means, treatment items, and recovery data model

Triade’s item rules already distinguish permanent, worn, and temporary layers, and they explicitly warn against temporary tools that bypass the commitment economy by granting direct reach. That means mitigation items should, by default, do one of four things: stop worsening, suppress a condition family, restore a limited amount of HP, or improve *dwell / recovery / resilience* rather than granting free peak access. Put differently: medical tools should make you safer, steadier, or less compromised; they should not be cheap tickets to deep skills. fileciteturn0file0 fileciteturn0file2

### Proposed mitigation asset schema

```json
mitigation_asset: {
  "id": "field_splint",
  "category": "consumable",
  "usage_phase": ["combat", "interlude"],
  "target_scope": "single_node",
  "targets": ["upper_arm", "forearm", "thigh", "knee", "shin"],
  "cure_tags": ["fracture", "dislocation"],
  "stabilises": ["major", "critical"],
  "hp_restore": 0,
  "stat_mods": [{"stat": "Poise", "delta": +1}],
  "dwell_bonus": 0.10,
  "cdm_countervector": {"m": 0.05, "f": -0.05, "i": 0.00},
  "duration": "until_run_end_or_replaced",
  "side_effects": ["finesse_minor_down"],
  "stack_group": "splint"
}
```

This keeps treatment assets inside the same data philosophy as the rest of the design: tags, targets, cure routes, duration, and trade-offs are explicit. fileciteturn0file0

### Proposed mitigation and treatment table

| Means | Usage window | Best targets | Immediate effect | Persistent benefit | Cost / drawback |
|---|---|---|---|---|---|
| **Bandage roll** | combat or interlude | slash / tear limb wounds, hand, thigh, torso flesh wounds | removes one Bleeding tier | keeps wound from escalating to blood-loss state | small AP cost; no fracture help |
| **Tourniquet** | emergency combat use | severe limb bleed | instantly halts heavy Bleeding | prevents collapse from blood loss | strong Finesse / Poise penalty on that limb |
| **Field splint** | combat or interlude | arm, forearm, thigh, knee, shin fractures | downgrades fracture instability | holds node at “treated major” state for the run | slower actions involving the limb |
| **Sling / shoulder brace** | interlude, sometimes combat | shoulder, collar-bone, scapula | suppresses dislocation penalties | stops reinjury escalation | weakens two-handed actions |
| **Chest seal** | combat or interlude | punctured lung / pierced rib-cage wounds | stops respiratory HP loss spike | keeps punctured lung manageable until town | occupies chest-treatment slot; no bone repair |
| **Burn salve** | combat or interlude | fire / corrosive surface trauma | removes Ignited, lowers pain | reduces future scar severity in run | no help against deep organ burn |
| **Antivenom** | combat or interlude | poison states | halves or clears Envenomed stack | prevents delayed collapse | rare; best on true toxin, wasted on scourges |
| **Neutralising wash** | interlude | corrosive wounds / gear | arrests Eroded progression | protects armour and flesh from further decay | limited charges |
| **Eye rinse / face pack** | combat or interlude | eyes, face, corrosive or particulate hits | downgrades Blinded to Hindered Vision | keeps perception functional | no help for punctured eye |
| **Ear pack / ringing draught** | interlude | ear trauma, explosive shock | reduces Deafened severity | faster reaction recovery | minor mind-fog side effect |
| **Dental wax / jaw cinch** | interlude | teeth / jaw trauma | reduces speech pain | restores basic vocal skill use | no help for skull trauma |
| **Pain draught** | combat or interlude | any major pain family | removes AP tax and some Dazed / panic | makes treatment possible under pressure | temporary; rebound pain after expiry |
| **Breath tonic** | combat or interlude | respiratory and sternum / rib-cage trauma | reduces breath AP tax | adds temporary dwell and home-well recovery | should buff resilience, not deep reach |
| **Stoneblood tonic** | combat or interlude | spine, pelvis, fracture-prone states | boosts Constitution / Frame / Poise side | stronger holding power under injury | sluggishness, weaker Momentum actions |
| **Clarity tincture** | combat or interlude | concussion, psychic, shock states | improves Will / Spirit, reduces Dazed | stabilises reads and reactions | small physical cost; not a full cure |
| **Suture kit** | interlude or town | open lacerations, tears | converts untreated Opened to closed wound | prevents run-long bleed attrition | time-consuming, poor in combat |
| **Bone-set service** | town only | major skeletal injuries | clears persistent fracture/dislocation flags | resets node to healed baseline | gold / Grounding / town access cost |
| **Surgical restoration** | town only | lungs, heart-adjacent, liver, spine, eye trauma | clears critical internal flags if survivable | full run reset of critical vital wounds | expensive, rare, progression-gated |
| **Blessing / ward rite** | town or rare encounter | chaos / psychic / divine trauma | clears Warped / Focus-broken / ward scars | stabilises Mind-side health | tied to occult economy, not generic loot |

Two policy rules matter as much as the item list itself.

The first is **treatment hierarchy**. Bandages and splints stabilise; town services actually reset deep damage. That distinguishes temporary, run-long, and infrastructure-grade recovery cleanly. It also fits the world model, where town already acts as the place for banking, reshaping, and recovery decisions. fileciteturn0file5

The second is **no free reach from medicine**. Recovery tonics should default to resilience-side benefits — Constitution, Spirit, Poise, Stamina, home-well pull, AP-floor protection, bleed suppression — rather than capacity/application-side spikes that effectively bypass the positional economy. The documents are not fully identical on temporary field buffs, but they are consistent on the broader intent: consumables should not trivialise the cost of committed positioning. For health items, the conservative and most Triade-compatible rule is therefore: *mitigation boosts staying power, not peak access*. fileciteturn0file0 fileciteturn0file2

## Coherent health management loop

The full health loop should be simple to state.

A character has one global HP pool, one anatomical wound ledger, existing armour and shield integrity, and a derived crisis state. Hits first resolve through the existing combat pipeline. Residual damage then writes to a body node. That node may emit pain, blood loss, fracture, organ strain, or cognitive disruption. Those outputs are expressed through temporary stat modifiers, zero-sum posture shifts, local AP or movement taxes, and ongoing HP loss. Severe unresolved wounds persist through the run until treated. Temporary states clear at the run boundary. HP is still what kills you; anatomy decides *how* you deteriorate on the way there. fileciteturn0file1 fileciteturn0file2 fileciteturn0file5

### Recommended actor health state

```json
actor_health_state: {
  "hp_current": 73,
  "hp_max": 100,
  "body_nodes": [
    {"id": "rib_cage", "side": "centre", "trauma": 0.58, "grade": "major", "treated": true},
    {"id": "right_forearm", "side": "right", "trauma": 0.31, "grade": "minor", "treated": false}
  ],
  "active_effects": ["punctured_lung_major", "pain_minor"],
  "blood_loss_rate": 0,
  "breath_debt": 2,
  "neurotrauma": 0,
  "systemic_strain": "derived",
  "treatment_slots_used": ["chest_seal"]
}
```

`blood_loss_rate`, `breath_debt`, and `neurotrauma` can be stored or derived; for MVP I would derive them from active wound families to minimise redundant state. That is more in keeping with the project’s general design style. fileciteturn0file2

### Recommended combat loop

In combat, the health system should create interesting decisions without drowning the exchange loop.

- **Pressure and structural play** remain offensive setup tools. Heavy impacts and Shatter improve later reads by cracking armour or compromising body structure.
- **Limb damage** narrows the victim’s tactical vocabulary by taxing weapon control, guard quality, or locomotion rather than simply shaving HP.
- **Head, spine, and chest injuries** are the main route by which anatomy threatens the read/create/exploit rhythm: they damage Mind-side control, breath, posture, reaction quality, and safe commitment.
- **Grit remains positional, not medical**. `Recover Bearing` and `Hold the Line` are still the correct anti-spiral tools; health recovery comes from triage and equipment, not from converting Grit into generic healing. That preserves the economy split already in the combat design. fileciteturn0file1 fileciteturn0file0

### Recommended between-fight loop

Between encounters, health management should become a short triage puzzle, not an inventory spreadsheet.

Each unresolved major or critical node asks one question: stabilise now, suppress and push onward, or retreat to town. Because the world layer already uses town return as a meaningful boundary and temporary-tier modifiers clear at that boundary, unresolved health state naturally participates in the push-your-luck structure: the longer the player stays down in a run, the more likely they are to carry splints, seals, and painkillers instead of flexible utility tools. fileciteturn0file5

The clean default rule set is:

```text
After each encounter:
- minor untreated wounds: auto-downgrade one step if no active bleed / poison / burn
- major untreated wounds: persist
- critical untreated wounds: persist and may worsen if rest is skipped
- one free “field dressing” action per character after combat
```

That free post-fight dressing is the second named brake against injury spirals. The first brake is the Trauma Safety Clamp. The third brake is the already locked AP minimum floor. Together they answer the world document’s warning that “injured → weaker → more injured” must not be left unchecked. fileciteturn0file5 fileciteturn0file2

### Recommended persistence policy

The persistence question is not fully locked in the source set, but the best default for Triade right now is:

**persistent inside the run, reset at town / run boundary unless converted into a rare scar mode.**

That choice has four advantages. It honours the adopted temporary-tier clear rule; it avoids creating a third long-horizon sink on top of Temper and Grounding; it keeps pressure on the current run without making failure compound across entire campaigns; and it lets anatomy matter a great deal tactically without making the meta-progression economy brittle. The world document explicitly identifies the alternative — wounds persisting beyond town — as a source of extra sink competition and compounded punishment. For MVP, the reset model is the cleaner choice. fileciteturn0file5

### Recommended UI and legibility treatment

The visual design should not show twenty-one mini-bars. Triade’s legibility stack already has the right answer: posture and a few high-priority conditions carry the ambient state, inspection shows the detailed truth, and the shield / armour integrity visuals remain separate from bodily trauma. The health layer should therefore render in three bands:

- **Ambient**: limping, arm guarding, laboured breathing, concussed sway, shield damage, blood trails.
- **Combat HUD**: at most four top-priority conditions, such as `Bleeding II`, `Fractured Right Forearm`, `Concussed`, `Punctured Lung`.
- **Inspection panel**: full body graph with node grades, treatment tags, and exact stat effects.

That follows the locked UI principle that the player should read proximity and consequence, never drown in coordinates or hidden detail. fileciteturn0file4 fileciteturn0file1

### Final judgement

The most Triade-native health system is **not** a realistic trauma simulator and **not** a single abstract HP bar. It is a hybrid:

- HP stays primary.
- Armour and shield integrity stay encounter-scoped and tactically central.
- Anatomy adds local wound states that deform the current run through effective-field penalties, zero-sum posture shifts, and selective functional disablement.
- Medicine stabilises and restores *holding power* more often than it grants *peak access*.
- Serious wounds matter within a run, but the default MVP resets them at town / run boundary.
- A named Trauma Safety Clamp prevents injury from deleting the player’s ability to act.

That model is closely bound to the locked systems, uses the same vocabulary the rest of the project already depends on, fits the readability constraints, and directly answers the open damage-and-health workstream the world design calls out. fileciteturn0file5 fileciteturn0file2 fileciteturn0file1 fileciteturn0file0