# Visual Design

**Version 0.45.0** — 2 October 2026. The presentation layer: how the Triade's state is rendered, what the UI must convey, and the graphical/technical model that supports it.

**Document set:** this is one of **ten**.

| Ref | Document | Filename |
| --- | --- | --- |
| **T** | Core Mechanic | `T-Core_Mechanic_design_TRIADE-0_45_0.md` |
| **M** | Stats, Items, Equipment | `M-Stats_Items_Equipment_design_TRIADE-0_45_0.md` |
| **L** | Lexicon | `L-Lexicon_design_TRIADE-0_45_0.md` |
| **V** | **Visual Design** — *this document* | `V-Visual_design_TRIADE-0_45_0.md` |
| **K** | Combat Design | `K-Combat_design_TRIADE-0_45_0.md` |
| **W** | World, Maps & Dungeons | `W-World_Generation_design_TRIADE-0_45_0.md` |
| **H** | Damage & Health | `H-Damage_Health_design_TRIADE-0_45_0.md` |
| **E** | Enemies & Bestiary | `E-Enemies_design_TRIADE-0_45_0.md` |
| **G** | Tile Pipeline | `G-Tile_Pipeline_design_TRIADE-0_45_0.md` |
| **P** | **Content Pipeline & Data Model** | `P-Content_Pipeline_design_TRIADE-0_45_0.md` |

**Scope boundary.** The Core Mechanic doc owns *what information must be conveyed and why* (the Interpreter's mandate, its channels, the Dictionary). This document owns *how it is rendered* — encoding requirements, the graphical model, and tooling. Where the two touch, the Core Mechanic doc holds the design rationale and points here for the visual spec.

---

## Part 1 — The governing constraint

Everything in this document follows from one locked decision: **posture is the primary state display.** No radar chart is shown to the player; the character's body *is* the state readout (T · A3.4).

That sounds expensive. It is not, because of a coincidence worth stating plainly:

> **Barycentric coordinates are animation blend weights.**

The dot's position is `P = (m, f, i)` where `m + f + i = 1`. That is exactly the form of a three-way blend weight vector. So the entire posture system reduces to:

- author **three extreme poses** (full Momentum, full Form, full Mind) plus neutral,
- feed the dot position directly into a blend node,
- **sector** determines blend *direction*, **ring depth** determines blend *magnitude*.

There is no pose-authoring explosion — no 12 sectors × 3 rings × N weapons matrix. Interpolation does the work, and every mainstream engine consumes this natively (Unity Blend Trees, Godot `BlendSpace2D`, Unreal BlendSpace). The most demanding visual requirement in the design is therefore nearly free.

**Consequence:** this is a strong argument for a **rigged, skeletal** character representation over anything sprite-based. *Reinforced at 0.10.0* — wound rendering (V·4.8) depends on the same rig, and would be prohibitively expensive without it.

---

## Part 2 — Graphical model

**Recommendation: stylised low-poly 3D, fixed-angle tactical camera, 2D UI overlay.**

3D specifically because of what the design already locks in:

| Locked requirement | Why 3D serves it |
| --- | --- |
| Posture as state display (T · A3.4) | blend trees consume barycentric coordinates directly |
| Heavy equipment variety (weapons, shields, armour families) | bone sockets make attachment trivial; sprites need every combination pre-rendered |
| Integrity states — Cracked / Fractured / Broken Guard (M · 2A.6) | material swaps and decals; cheap in 3D, expensive in 2D |
| Enemy posture telegraphing capability (T · A3.7) | silhouette reading benefits from a rotatable camera |
| **Wound state as skeletal deformation (H · 12.3)** | *added 0.10.0* — limb-local pose offsets on the existing rig, orthogonal to material-based integrity |

One rig serves many characters — swap meshes and materials, keep the skeleton. Stylised/low-poly keeps art cost sane and ages better than attempted realism.

**Camera: fixed-angle isometric/dimetric. Continuous rotation is not part of the base design** [AMENDED 0.12.0]. Permitted: bounded zoom, pan, authored cutaway transitions, and optional discrete 90° viewpoints only where every environment and actor asset has matching variants. Rejected: free continuous rotation, perspective-dependent puzzle geometry, routes discoverable only by rotating, and camera pitch changes during combat. A fixed camera turns render ordering, tile projection, cover silhouettes and vertical readability into **proofable** properties (V·4.9).

**This amendment is conditional and the condition is not yet discharged.** Rotation was wanted for one stated reason — *posture reading depends on silhouette* — and posture is the primary state display (T·A3.4: the character's body **is** the state display), gated at S-V01 under 0.5 s. Striking rotation therefore has a prerequisite, not a consequence: **the fixed viewing angle must be shown to preserve posture legibility before this amendment is treated as settled.** Until that test passes, the amendment is provisional. **[OPEN]** ◇V6 · ◇V7.

**2.5D binds the environment and the camera. It does not bind character rendering** [NEW 0.12.0]. The environment is authored as layered sprites or scene tiles under a fixed projection; characters remain low-poly 3D under an orthographic camera. This is the only configuration that preserves all five justifications in the table above — in particular the wound pose-offset library (H·12.3, V·4.8), which gained a dependency at 0.10.0 that a pure-2D pipeline would have to re-solve, and which V-H3 requires to render on targets disjoint from integrity.

| Variant | Environment | Characters | Assessment |
| --- | --- | --- | --- |
| A — pure 2D skeletal | sprite/tile layers | 2D skeletons, paper-doll equipment | Leanest runtime; highest equipment-authoring burden; wound pose offsets must be re-solved |
| **B — hybrid 2.5D** *(adopted)* | sprite/tile layers | low-poly 3D under orthographic camera | Preserves all five locked 3D dependencies; depth integration requires discipline |
| C — pre-rendered 3D | baked sprite atlases | baked directional actors | Strong cohesion; animation and equipment combinatorics expensive |

**Fallback if 3D is out of scope:** 2D skeletal animation (Spine, DragonBones) — the same blend logic applies and it is cheaper to produce. The cost is that equipment variety becomes painful fast, and equipment variety is central to this design.

---

## Part 3 — Technical architecture

**Headless simulation core, thin presentation layer.** This is not optional: the main plan (Part 4) already mandates a headless simulation CLI with 10k-seed sweeps, deterministic seeding, golden tests and trace instrumentation. Every validator, trace tool and agent workflow depends on it.

```
sim core (engine-independent library)
 ├── headless CLI → agent pipeline, sweeps, golden tests
 └── thin API → game engine (presentation only)
```

Get this boundary right early; it is painful to retrofit.

**Language staging:**

- **Prototype** in TypeScript or Python while rules are still moving — native JSON, trivial agent/LLM integration, fast iteration.
- **Port** to Rust or C# once rules stabilise and sweep performance bites.

Do not optimise while the design is this fluid.

**Engine:** **Godot 4** if solo or a very small team — free, no licensing questions, excellent tilemaps, fast iteration, and its 3D is more than adequate for stylised tactical. **Unity** if animation tooling is the priority, since its blend-tree and state-machine ecosystem remains the strongest. For this project's shape, Godot is the lean.

---

## Part 4 — UI requirements

*Moved here from T · A3.4c. The Core Mechanic doc retains the design rationale and points here.*

**Governing principle: the UI conveys *proximity and consequence*, never coordinates.** A player must be able to act correctly without ever seeing a sector name, ring number or field value.

### 4.1 Skill bar — four pieces of information per skill

| Information | Source | Encoding requirement |
| --- | --- | --- |
| **Positional eligibility** | angular window — *hard cutoff* (T · A3.7) | binary positional gate: inside vs outside the authored window (desaturated / greyed) |
| **Potency** | radial falloff — *continuous* (T · A3.7) | **continuous ramp** — fill height, opacity or glow intensity |
| **Current level** | build vs [Level Requirement] (T · A4.7) | discrete level indicator (pips or numeral) |
| **Ejection risk** | reach-vs-staying gap (T · A4.7) | distinct edge/border treatment — "you will be thrown out after this" |

**V-H1 · Requirement 1 — the two failure modes must look different.** *Wrong direction* (unavailable, angular) and *under-committed* (weak but usable, radial) must be visually distinct. If both render as "dimmed," the player cannot tell whether to **change stance** or **push deeper** — which discards the entire value of the anchor decomposition. This is the single most important UI rule in the system.

**P12-B boundary (0.43.0).** This table explains the positional gate only. Overall action readiness now derives as `known`, `selectable` and `executable` with typed failed-gate reasons (P·2.3d); it may also fail on source, hook, floor, carrier, target, cost or cooldown. Intake A4 owns how those causes are presented and must not collapse them into this one positional binary.

**P12-C boundary (0.44.0).** A Plannable Action creates a visible Intent Marker carrying its scheduled/triggered window, bound identity or fixed area where perception permits, and visible conditional branches. This reuses K's Tactical Timeline surface; it does not settle intake A4's icon, colour, tooltip or failure-explanation design. Hidden identity and future recipients remain hidden.

> **Scope clarification (0.10.0).** Requirement 1 governs the **skill bar**. It does not constrain the character posture display, which is why the wound overlay in V·4.8 does not collide with it. The constraint that *does* apply to posture is Requirement 5's anchor-neighbourhood distinctness.

**V-H2 · Requirement 2 — potency must render as a continuous ramp, not discrete steps.** The radial falloff is smooth by design specifically to avoid cliffs and boundary-camping. Rendering it as three or four stepped states re-introduces the cliff *perceptually* even though the maths is smooth, and players will optimise against the visual steps.

**Requirement 3 — directional hint on angular unavailability.** When a skill is greyed out for being at the wrong angle, the button must indicate **which way to lean** (an arrow, a tilt, an edge glow toward the needed sector). Without this, angular cutoff is opaque. With it, "why can't I use this?" becomes "lean that way," which teaches the system through play rather than through a wiki.

**Requirement 4 — no coordinates.** Proximity is shown by the ramp and the hint. Sector names, ring numbers and field values never appear on the skill bar.

### 4.2 Character display (ambient)

Posture and animation carry **stance, trajectory and exposure** (T · A3.4). **No radar chart is shown.** Being inside **Composure** should read as a distinct, legible neutral/settled posture — the player must be able to tell "I am committed to nothing right now."

*As of 0.10.0 this is a **four**-channel display; the fourth is wound state. See V·4.8.*

### 4.3 Enemy display

**Requirement 5 — enemy posture must telegraph capability.** Enemies carry positions and anchors, so their stance reveals which skills they can currently use (T · A3.7). Enemy posture changes must be readable at a glance and distinct enough between anchor neighbourhoods that a player can learn "that lean means the bash is coming." This is the payoff that makes players watch the enemy rather than their own UI, so it is a requirement rather than a polish item.

**Extension (0.10.0) — wound state rides this same channel.** A wound crushes an enemy's effective field, which crushes its Reach, which *genuinely changes which skills it can currently use* — which Requirement 5 already mandates displaying. Enemy wound legibility therefore needs **no new UI surface**; it is the existing telegraph correctly reflecting a degraded field (H · 12.2). No wound icons appear on enemies at any tier.

**Consequence for anatomy depth.** Telegraph legibility only matters for enemies whose skill access the player benefits from predicting, which is Standard upward. This is one of the reasons enemy anatomical depth is tiered by the capability ladder (H · 11).

### 4.4 Integrity states

**Requirement 6 — Cracked / Fractured / Broken Guard need distinct visual states** on both player and enemies (M · 2A.6). Since integrity feeds the Opening layer (Bridge 1), a player must be able to see that a target's armour is compromised in order to understand why their Openings are landing deeper. Shield integrity displays **separately** from body armour (M · 2A.11).

*As of 0.10.0 this is a three-way separation — shield, body armour, and flesh. See V·4.8.*

### 4.5 Relational states

**Requirement 7 — relational states must show *against whom*.** [Back-foot], [Advantage] and [Opening] are directional edges in the combat graph (T · C.3a), not flags on a character. A single "back-footed" icon would be actively misleading when a player is back-footed against one enemy and clean against another. Inspection must convey the relation, and the ambient/UI layer must make the *relevant* relation legible during an exchange.

**Note (0.10.0):** wounds are **self-scoped, not directional**, so they display on the character itself and must not be rendered in a way that suggests a relational edge.

### 4.6 Inspection (hover)

Full state list on demand: buffs, debuffs, conditions, relational states with their targets, integrity state, and current skill availability reasons. This is where precision lives, so that the ambient and skill-bar layers can stay uncluttered.

**Extended at 0.10.0.** Inspection is also the **only** surface carrying the full anatomical wound ledger — per-node grades, tissue-layer state, treatment tags and exact stat effects (H · 12.1). The ambient and HUD layers never show per-node detail.

### 4.7 Tooltips and item comparison

The tooltip data contract (M · 3.6) must expose: current-vs-candidate delta; which stats are build-relevant; why an affix is greyed out; breakpoint proximity; **weapon demand versus reachable envelope** (*within reach* / *at the edge of your reach* / *beyond you*); **clumsiness penalty** if any; and **region vocabulary gained and lost** on swap.

The last three are not optional — without them a player cannot evaluate a drop at all, and the trace system deliberately does not help here (traces tell designers whether an item is distinct, not players whether it is for them).

**Open (M · 0.10):** the readability budget — how many numbers may appear on one tooltip. Tighter than usual, because the Triade already consumes screen attention. *Pressure increased at 0.10.0:* five resources are now spendable at town — Marks, Scrap, Flux, Temper and `[Imprint]` (◇H14).

### 4.8 Wound rendering — *new at 0.10.0*

**The fourth surface becomes the Tactical Timeline** [ADOPTED 0.35.0, CR-11]. It is the existing activation-timeline surface **expanded**, not a fifth always-on surface — the display budget was argued once and does not get re-argued by addition. **Posture remains the world-space capability telegraph**; Intent Markers and the Ghost Track supplement it and never replace it, and both are bound by FOW: they may expose **committed and perceived** facts only (**W-H17**, **K-H3**).

**Requirement 7a — unspent enemy Edge shows on the activation timeline.** [NEW 0.13.0 — carries ◈E1]

Enemy Edge renders as **0–3 pips on the enemy portrait in the activation sequence** (K·3.1), using the same representation as player Edge — *"one to three tokens, not a number"* (K·9.1). Symmetry is the justification: enemies and characters are one system, so the credit they hold should read the same way on both sides.

It supports Requirement 5 rather than competing with it. Posture tells the player which skills an Elite *can* reach; Edge tells them it has already read an Opening and is holding the conversion. Together they make a charging Commander legible before its wind-up (K·10.3).

**Two negatives, both worth their space:**

- Enemy Edge is **not** a condition and does **not** count against K12's four-item visible-condition cap. That cap governs conditions; credits are a separate channel.
- The activation timeline is a **fourth surface**, alongside T·A3.4b's ambient / log / inspection stack. It is admitted deliberately and narrowly: a bounded 0–3 integer on an element already on screen. It is not a licence to promote other state to always-on display.

**V-H3 · Requirement 8 — wound state and integrity state must not share a render target.**

Both read to a player as "that thing is damaged," but they imply completely different play. Armour integrity means *deeper Openings and the Finisher gate opening* (Bridge 1). A wound means *degraded Reach and lost function* (H · 10.2). Confusing them breaks the Bridge 1 read, which is load-bearing for the whole exchange loop.

The separation is structural, not a matter of art discipline, because ◇V2's one-rig architecture already provides two independent targets:

| State | Render target | Channel |
| --- | --- | --- |
| Armour integrity | equipment **mesh + material** | material swap, decals |
| Shield integrity | shield mesh, **displayed separately** (V·4.4) | material swap |
| **Wounds** | **body rig — skeletal deformation** | limb-local pose offsets |

Armour is a mesh that swaps; a wound is the skeleton underneath moving differently.

**Blood decals on equipment surfaces are forbidden** — they read as integrity damage. Bleed cues must be motion or trail, never a surface decal.

#### The fourth posture channel

V·4.2's display already carries three things. Wounds make four. Safe encoding:

| Channel | Physical aspect |
| --- | --- |
| stance | whole-body blend direction (`(m,f,i)` blend tree, ◇V1) |
| trajectory | motion and velocity of the blend |
| exposure | commitment depth |
| **wounds** | **limb-local, static, asymmetric deformation** |

Limb-local and static is orthogonal to whole-body and dynamic. A dragging leg does not read as a Momentum lean, because the lean is a torso and weight-distribution signal.

#### Ambient wound vocabulary

Limping · arm guarding · laboured breathing · concussed sway · favoured side · blood trails (motion, not decal).

#### The gate

**Requirement 8 ships only if it passes the existing readability test.** Per ◇V6, carrying T · J.9:

> *Prototype the state display before finalising the maths. If the state cannot be read in under half a second, simplify the maths — not the UI.*

**A wounded enemy's anchor neighbourhood must still read in under half a second.** The risk here is not a rule violation but signal-to-noise: overlay noise degrading Requirement 5's anchor-neighbourhood distinctness. If the test fails, the locked instruction is to **simplify the wound model**, not to add UI — falling back to HUD-only wound display (H · 12.1) with no posture overlay.

### 4.9 Render proof suite — *new at 0.12.0*

A fixed camera makes render correctness checkable. These are **Critical**, and they are a separate suite from the gameplay proofs.

**The firewall is the point.** W-C4 requires that the same seed and `generator_version` reproduce an identical proof digest, and W-C7 forbids floating point in any decision affecting that digest. Screen space is camera- and float-derived. Therefore:

| Suite | Runs on | Feeds the proof digest? | Failure behaviour |
| --- | --- | --- | --- |
| **Gameplay proofs** (W§16) | The integer logical model | **Yes** | Repair → reseed → reject |
| **Render proofs** (below) | The baked render package | **Never** (W-C10) | Fails the **build**, not the seed |

A readability constraint that must influence generation is expressed as an **integer footprint rule in lattice space** — for example, an upper deck may not cover more than *K* of the lower deck's path-critical cells (S-V04) — never as a screen-space test inside the generation loop.

| ID | Rule |
| --- | --- |
| **V-C1** | Every walkable cell has a valid rendered surface; every exposed elevation edge has a facade or an intentional void treatment |
| **V-C2** | No active actor, posture telegraph or Commander wind-up is fully occluded in any cutaway state |
| **V-C3** | Y-sort ordering is stable across tile boundaries; screen-space selection resolves to exactly one intended target |
| **V-C4** | Every destruction state has matching art, collision and navigation |

**Cutaway policy.** When an upper structure obscures a relevant lower one: fade or hide the occluder, preserve edge outlines so room shape stays legible, never hide combatants, telegraphs, portals or mission-critical interactables, and restore occluders with hysteresis to prevent flicker. Visibility is driven by room and zone membership, not by raw sprite overlap.

---

## Part 5 — Tooling

| Tool | Purpose |
| --- | --- |
| **Blender** | rigs, the three extreme poses, low-poly assets, **wound pose-offset library** (V·4.8). One shared humanoid rig, then variations. |
| **Tiled** | room templates, if the procedural assembler uses hand-authored pieces |
| **JSON Schema + validator** | the linter rules are already specified across all design docs — make them real CI checks from day one |
| **Trace/coverage visualiser** | the anchor coverage map (T · A3.8) and residency histograms (T · I.2) are genuine design instruments; a simple web view (D3/Observable) beats reading numbers |
| **Orthographic batch renderer** | *new at 0.12.0* — deterministic atlas bake under the locked projection (**G**·3) |
| **Render proof harness** | *new at 0.12.0* — Y-sort, cutaway, occlusion and screen-space selection test scenes for V·4.9. **[GAP]** this is not grep-able CI; it needs a headless render harness nobody has costed |

---

## Part 6 — Open issues

**The two-positional-systems problem — RESOLVED (Combat Design K4).** Locked as a **sparse zone graph**: 2–4 named zones per room with simple adjacency, range measured in zone hops, no square or hex grid. The physical layer provides only target access, movement cost, circumstantial Advantage and [EDM] influences. The Triade dot remains the principal "where am I?" system.

**Prototype the state display before finalising the maths** (T · J.9). If the state cannot be read in under half a second, simplify the maths — not the UI. *At 0.10.0 this test also gates Requirement 8 (V·4.8).*

### Live items

*Standardised at 0.11.0. Mirrored in `B-Open_Items_Index_TRIADE-0_45_0.md`.*

| # | Question | Marker | Blocking |
| --- | --- | --- | --- |
| **◇V1** | **Body template variation.** Non-humanoid body templates (H·5.3) need rigs that are not the shared humanoid. Scope and count depend on the bestiary (**E**·◇E5) | **[OPEN]** | Content / E |
| **◇V2** | **Wound overlay read time.** Requirement 8 (V·4.8) ships only if a wounded enemy's anchor neighbourhood still reads in under half a second. Untested | **[OPEN]** [SIM] | Prototype |
| **◇V3** | **Tooltip readability budget** (M·0.10) — how many numbers may appear at once. Five resources are now spendable at town | **[OPEN]** [SIM] | UI |
| **◇V4** | **Audio channel undesigned.** T·A3.4 specifies the ambient channel as posture **and sound cues**; the Interpreter is a two-channel system. Half of one channel has no design document | **[OPEN]** | **Gap — no owner** |
| **◇V6** | **Posture legibility at a fixed angle.** ◇V2's camera amendment strikes continuous rotation, which existed to serve silhouette reading. The amendment is **provisional until a fixed-angle posture test passes** at S-V01's half-second bar | **[OPEN]** [SIM] | **Blocks the ◇V2 amendment** |
| **◇V7** | **Render proof harness cost.** V·4.9's four Critical proofs need camera, atlas, actors and cutaway state. Not costed | **[OPEN]** | **Gap — no owner** |
| **◇V5** | **Accessibility.** When the primary state display is a silhouette, colourblind and low-vision support is a design constraint, not a finishing pass. Currently one passing mention (the Narrator, T·A3.4a) | **[OPEN]** | **Gap — no owner** |

---

**Tarot presentation handoff [ADOPTED 0.45.0].** P·2.3f–i requires generated descriptions of operative expressions: changed values, added characteristics, costs, prerequisites, contribution/suppression and incompatibility reasons. Technique and Support Cards require distinct visual templates; inherent endpoints remain visibly cardless. C1-F is next for template hierarchy, discovery, accessibility and preview; no concrete template or discovery mechanic is adopted here. Installation/build state and runtime readiness must be shown separately.

## Changelog

| Version | Change |
| --- | --- |
| **0.45.0** | Tarot operative-description and mandatory visual-template handoff added; C1-F remains pending. |
| **0.44.0** | **P12-C presentation boundary recorded.** Plannable Actions reuse visible Intent Markers without exposing hidden identities or future recipients; exact UI treatment and failed-gate explanation remain intake A4 work. |
| **0.43.0** | **P12-B boundary recorded.** §4.1's former Availability row is narrowed to positional eligibility. Overall `known`/`selectable`/`executable` and failed-gate presentation remains intake A4 work; no new UI surface is silently adopted. |
| **0.42.0** | Version alignment only. P12-A gains no presentation surface; P12-B/C and intake A4 still own availability explanation and UI/legibility work. |
| **0.41.0** | Version alignment only. P11's Faculty profile and availability distinctions gain no presentation surface here; intake A4 remains the UI/legibility pass. |
| **0.40.0** | Version alignment only. Faculty lifecycle and derived availability gain no presentation surface here; intake A4 remains the UI/legibility pass. |
| **0.39.0** | Version alignment only. A2 settles mechanics and enemy access; aimed-mode UI/legibility remains intake A4 and no V surface is inferred here. |
| **0.35.0** | **§4.8's fourth surface becomes the Tactical Timeline** — expanded, not a fifth surface added. Posture remains the world-space capability telegraph; Intent Markers and the Ghost Track supplement it under FOW. |
| **0.27.0** | Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | **Three ID-bearing statements authored** — `V-H1` and `V-H2` on §4.1's Requirements 1 and 2, `V-H3` on §4.8's Requirement 8. Nine subsection headings deletterd. Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | Six `Part V<n>` headings become `Part <n>`. Closing line corrected — it read *0.17.0*. Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **28 glyphed identifiers in this document.** |
| **0.17.0** | No content change. **Closing line corrected — it had read *"End of Visual Design 0.10.0"* through seven subsequent releases**, and its *maintained alongside* list still named six documents when the set has held ten since 0.15.0. This is the identical defect K corrected at 0.16.0; the sweep that caught it there did not extend to V. A footer is not covered by any rule in the Validation Rules Index, which is why it can rot silently across seven versions — noted rather than fixed with a rule, because a rule per footer is not worth its row. |
| **0.13.0** | **Requirement 7a added** — unspent enemy Edge renders as 0–3 pips on the enemy portrait in the activation sequence, matching the player's token representation (K·9.1), carrying ◈E1. Two negatives stated: it is not a condition and does not count against K12's cap, and the timeline is admitted as a fourth surface deliberately and narrowly. |
| **0.12.0** | **◇V2 amended:** fixed-angle isometric/dimetric camera, continuous rotation struck — **provisional until the ◇V6 posture test passes**, since rotation existed to serve silhouette reading. 2.5D bound to environment and camera only; characters remain low-poly 3D under an orthographic camera (variant B), preserving all five locked 3D dependencies including V·4.8's wound pose offsets. **V·4.9 added** — four Critical render proofs and the render/gameplay digest firewall (W-C10). Two open items registered (◇V6, ◇V7); ◇V7 is an unowned gap. |
| **0.11.0** | **◇V6 restructured** into a marked open-items table. Two previously-unrecorded gaps registered: the **audio channel is undesigned** despite T·A3.4 specifying the ambient channel as posture *and sound cues*, and **accessibility has no owner** despite the primary state display being a silhouette. Document set grows to eight. |
| **0.10.0** | **Requirement 8 added (V·4.8)** — wound rendering must not share a render target with integrity; wounds render as skeletal deformation, integrity as mesh/material. Character display recognised as a four-channel display. V·4.3 extended: enemy wound state rides the existing posture telegraph, no new surface. V·4.6 extended: inspection is the sole carrier of the anatomical ledger. Requirement 1 re-scoped explicitly to the skill bar. Document set grows to seven; filename convention standardised. |
| **0.9.0** | *(entry omitted at the time — recorded retrospectively)* Document set grew to five with the addition of the Combat Design document; cross-references updated to cite **K**. |
| **0.8.0** | Document created. UI requirements moved here from T · A3.4c (now a pointer). Added the graphical model (◇V2), technical architecture (◇V3), tooling (◇V5), and the two-positional-systems open issue (◇V6). Tooltip requirements consolidated from main plan 3.6. |

---

*End of Visual Design 0.45.0. Maintained alongside the Core Mechanic, Stats/Items/Equipment, Lexicon, Combat, World Generation, Damage & Health, Enemies, Tile Pipeline and Content Pipeline documents.*
