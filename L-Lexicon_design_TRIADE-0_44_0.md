# Project Lexicon

**Version 0.44.0** — 27 September 2026. The controlled vocabulary for the roguelike RPG design. Every term that has been *locked* in the design documents is indexed here with a short definition and its home reference.

**Conventions.**

- `[Bracketed]` terms are in-fiction game states, tags, or named quantities the player or systems reference directly.
- Unbracketed terms are design-model concepts (the machinery behind the fiction).
- **Ref** points to the authoritative section: **T** = Core Mechanic, **M** = Stats/Items/Equipment, **V** = Visual Design, **K** = Combat Design, **W** = World Generation, **H** = Damage & Health, **E** = Enemies & Bestiary, **G** = Tile Pipeline, **P** = Content Pipeline & Data Model. Section numbers follow.
- **Status: locked** unless marked *provisional* (agreed in principle, exact value/name still tunable) or *deferred* (named but not yet designed).

This document is maintained alongside the other nine design documents and three derived indexes. When a term is locked, added, or renamed, it is updated here in the same pass.

**Document set — ten documents, plus three derived indexes. Naming standardised at 0.10.0; Enemies extracted at 0.11.0; Tile Pipeline added at 0.12.0; Content Pipeline added at 0.15.0:**

| Ref | Document | Filename |
| --- | --- | --- |
| **T** | Core Mechanic | `T-Core_Mechanic_design_TRIADE-0_44_0.md` |
| **M** | Stats, Items, Equipment | `M-Stats_Items_Equipment_design_TRIADE-0_44_0.md` |
| **L** | Lexicon *(this document)* | `L-Lexicon_design_TRIADE-0_44_0.md` |
| **V** | Visual Design | `V-Visual_design_TRIADE-0_44_0.md` |
| **K** | Combat Design | `K-Combat_design_TRIADE-0_44_0.md` |
| **W** | World, Maps & Dungeons | `W-World_Generation_design_TRIADE-0_44_0.md` |
| **H** | Damage & Health | `H-Damage_Health_design_TRIADE-0_44_0.md` |
| **E** | Enemies & Bestiary | `E-Enemies_design_TRIADE-0_44_0.md` |
| **G** | Tile Pipeline | `G-Tile_Pipeline_design_TRIADE-0_44_0.md` |
| **P** | **Content Pipeline & Data Model** | `P-Content_Pipeline_design_TRIADE-0_44_0.md` |
| — | *Open Items Index* | `B-Open_Items_Index_TRIADE-0_44_0.md` |
| — | *SIM Numbers Register* | `Y-SIM_Numbers_Register_TRIADE-0_44_0.md` |
| — | *Validation Rules Index* | `R-Validation_Rules_Index_TRIADE-0_44_0.md` |

---

## 0. Glyph index [LOCKED 0.18.0 · extended 0.18.1]

### 0.1 Identifier glyphs

Six ID namespaces shared one token space — five separated at 0.18.0, non-goals at 0.18.1. `H3` was a goal, a live open item **and** a non-goal; `G4` was a W goal *and* a G open item; `P1` was an M phase *and* a P open item. **The glyph is part of the ID.** An unglyphed `Xn` that is not a section reference is a defect, not shorthand.

| Glyph | U+ | Namespace | Form | Example | Home |
| --- | --- | --- | --- | --- | --- |
| **◇** | 25C7 | Open item, live | `◇Xn` | `◇P7` | Open Items Index §3 |
| **◈** | 25C8 | Open item, closed | `◈Xn` | `◈T6` | Open Items Index §5 |
| **◉** | 25C9 | Goal | `◉Xn-<home>` | `◉G4-W§2` | W§2, H§3; listed in ROADMAP |
| **⦻** | 29BB | Non-goal | `⦻Xn` | `⦻W1`, `⦻H4` | W§2, H§3 |
| **⇥** | 21E5 | Sequencing phase | `X⇥n` | `M⇥1` | M·6 |
| **⌬** | 232C | Skill level | `⌬Ln` | `⌬L3` | T·A3.7 |

**Sections carry no glyph** — `K·17`, `P·10.3`, `W§5.4`. A bare `Xn` in running prose is therefore a section, and everything else must be glyphed.

**◉ and ⦻ carry the document letter** because goals and non-goals are per-document and renumber independently. W and H both start at 1. `⦻H3` (no second kill race), `◉H3-H§3` (no region rendered mute) and `◇H3` (concussion granularity) are three different statements that were one token until 0.18.1.

**Disambiguate the container before the contents.** Headings lost their document letter first (`## Part P4` → `## Part 4`); only then was a surviving bare `Xn` provably an identifier.

### 0.2 Notation

Symbols in use across the set. **Not identifiers** — none of these may be repurposed as one.

| Symbol | U+ | Sense |
| --- | --- | --- |
| **·** | 00B7 | Document–section separator: `M·2A.9`, `T·A4.2` |
| **§** | 00A7 | Section, where the reference is to the section itself: `W§16.1` |
| **—** | 2014 | Em dash. Definition and aside separator; also the *not applicable* cell |
| **–** | 2013 | En dash. Numeric ranges only: `120–180 min`, `⌬L1–⌬L3` |
| **→** | 2192 | Transformation or pipeline stage: `definition → roll → instance` |
| **↔** | 2194 | Bidirectional dependency |
| **⇒** | 21D2 | Logical implication, in rule statements |
| **Φ** | 03A6 | Field quantity. `Φ_eff` is the post-injury effective field |
| **Σ** | 03A3 | Conserved sum. `ΣF` is the barycentric floor total |
| **× ÷ ± ≤ ≥ ≠ ≈ ≫** | — | Arithmetic and comparison, in their ordinary senses |
| **∪ ∈ ⊃ ⊕** | — | Set union, membership, superset, exclusive-or |
| **🟢** | 1F7E2 | Manifest status: current |
| **✓ ✗** | 2713 / 2717 | Present / absent in a capability or coverage table |
| **~~strike~~** | — | A closed or dissolved item retained for provenance. Pairs with `◈` |
| **─ │ ├ └** | 25xx | Box drawing, in fenced diagrams only |

**`—` in a table cell means *not applicable*, never *unknown*.** An unknown is `[OPEN]`, `[SIM]` or `[GAP]`, and the distinction is load-bearing: an undeclared gap reads as complete coverage.

---

## 1. Core mechanics

| Term | Definition | Ref |
| --- | --- | --- |
| **Triade** | The core combat and progression mechanic: a zero-sum triangle of three stances (Momentum / Form / Mind) plus a three-layer credit economy. Upstream of stats, items and equipment. | T · A |
| **Position** / **dot** | A single barycentric point `P = (m, f, i)`, `m+f+i = 1`, representing a combatant's current stance. One dot per combatant. Its location is its *bearing*; its movement is the Dot Framework. | T · A.1 |
| **Momentum** (corner) | Triade corner: tempo, physical action *now*. Primary credit generator. Feeds AP cost of physical actions. *Never used to mean motion — see [Dot Dynamics].* | T · A.1 |
| **Form** (corner) | Triade corner: structure and defence. The stabiliser. Feeds damage mitigation and defensive conversion. | T · A.1 |
| **Mind** (corner) | Triade corner: control and leverage. Primary credit consumer. Gates and scales mind skills. | T · A.1 |
| **Floors** | Per-corner hard minimums forming a smaller reachable inner triangle. Class-set at run start. Total budget `ΣF ≤ 0.45`; per-corner cap `F ≤ 0.25`. | T · A.2 |
| **Floor budget** | The 0.45 cap on the sum of the three floors. Load-bearing: keeps the reachable triangle from collapsing. | T · A.2 |
| **Per-corner cap** | The 0.25 ceiling on any single floor. Guarantees no region is ever *fully* locked out — only made harder to reach. | T · A.2 |
| **Region threshold `T`** | The value (locked at **0.35**) two corners must both reach for their shared region to be active. Above the centroid (1/3), below the floor-limited maximum. | T · A.3 |
| **Home position** | The centroid of a class's reachable region; where the dot rests. Shifts toward the highest floor. Origin for commitment cost, exposure, and the home-well. | T · D |
| **Commitment cost** | Geometric distance from home to a region — how far a class must lean (and how exposed it becomes) to use that region's actions. Computed, not authored. | T · D |
| **Dot Framework** | The umbrella system governing how the dot *moves*: the home-well, the influence pipeline, and the rules turning summed influences into movement. | T · A2 |
| **[Dot Dynamics]** | The dot's *momentum-of-motion* — carried velocity that makes it overshoot and coast. Opt-in per source (`dynamics` field), not a global rule. *Provisional on level-2 dot discussion.* | T · A2.2 |
| **Home-well** | Potential well centred on home position; the dot is always gently pulled toward it. Replaces "decay" as a special case. Decay-resistance = well depth; floors = well walls. | T · A2.2 |
| **Influence** | The unit of dot movement: a zero-sum vector from an action, condition, or extrinsic source, applied as a force or an impulse. One schema for all sources. | T · A2.4 |
| **Force / impulse** | The two influence modes. *Force* = sustained push while active (terrain, conditions). *Impulse* = one-shot jump (most actions). | T · A2.2 |
| **Zero-sum vector rule** | Every dot vector must satisfy `dm+df+di = 0` (tangent to the simplex). Gaining one corner must cost the others. Linter-enforced. | T · A2.4 |
| **[ADM]** active dot motion | Influence origin: the character's own skills, actions, movement. Usually impulses. | T · A2.1 |
| **[CDM]** condition dot motion | Influence origin: conditions on the character. Usually forces. Absorbs the former "condition layer." | T · A2.1 |
| **[EDM]** extrinsic dot motion | Influence origin: enemy actions/skills and environment. Usually forces. | T · A2.1 |
| **Grid** | The discretised coordinate system over the reachable triangle: 12 spokes × 3 rings + Composure = 37 addresses. Universal; class floors clip which cells are reachable. | T · A3.1 |
| **Spoke** | One of 12 radial divisions, anchored to a boundary landmark (3 corners at vertices, 3 regions at edge-midpoints, 6 transitions at quarter-points) — geometry-locked, not fixed-angle. | T · A3.1 |
| **Ring** | One of 3 concentric depth bands; nested scaled triangle outlines whose vertices sit on the spokes, so they deform to the floor. Numbered 1 (near Composure) → 3 (near the wall). | T · A3.1 |
| **Cell / address** | A grid position, written `Sector/Ring` (e.g. `FoDi/2`, `In/3`). Backend label, machine-readable — not what the player sees. | T · A3.2 |
| **Landmark vs transition cell** | Landmark columns (corners, regions) are *destinations* where meaning hangs; the 6 transition columns (`MoIn` etc.) are *transits* passed through between landmarks. | T · A3.3 |
| **[Dot Interpreter]** | Read-only system that renders dot state to the player across two channels: ambient (posture/sound → felt state) and log (prose → resolved events). Narrates stance/trajectory/affordance/events, never numbers. | T · A3.4 |
| **Ambient channel** | Wordless, continuous: character posture, animation, sound cues carry stance, trajectory and exposure. No radar chart shown — the body is the state display. | T · A3.4 |
| **Log channel** | Past-tense prose narrating resolved events, under the "narrate what a player needs to explain their situation" policy, with cause-narration for non-player-caused changes. | T · A3.4 |
| **Dictionary** | Structured fragment data the Interpreter composes log lines from (a grammar, not a phrasebook). Four parts: general grammar / lore vocabulary / mechanics-to-story / tone profiles. Never invents mechanical claims. Agent-generable (Lexicographer). | T · A3.4a |
| **Tone profiles** | Dictionary selector in two layers: **base** (campaign register) + **momentary** (live, driven by fight state — grim near death, heroic on a clutch reversal), composed. Hysteresis: shifts only on earned turning points, no whipsaw. | T · A3.4a |
| **Narrator** | *Optional, future:* a read-aloud engine voicing the log. Afforded for free by the clean-prose log; also an accessibility feature. No redesign needed to support. | T · A3.4a |
| **Legibility stack** | Three non-overlapping surfaces: ambient (feel the state), log+Dictionary (read what happened), UI inspection + skill bar (inspect specifics / see affordances). | T · A3.4b |
| **UI requirements** | **Eight** locked requirements (Visual Design ◇V4). Governing principle: convey *proximity and consequence, never coordinates*. *Requirement 8 added at 0.10.0.* | V · 4 |
| **Two failure modes rule** | The most important **skill bar** rule: *wrong direction* (angular, unavailable) must look different from *under-committed* (radial, weak). Otherwise the player cannot tell whether to change stance or push deeper. *Scoped to V·4.1 — it does not constrain the posture display.* | V · 4.1 |
| **Continuous potency ramp** | Radial falloff must render as a smooth ramp, never discrete steps — stepped rendering re-introduces cliffs perceptually even though the maths is smooth. | V · 4.1 |
| **Directional hint** | An angularly-unavailable skill must indicate *which way to lean*. Turns "why can't I use this" into "lean that way" — teaches the system through play. | V · 4.1 |
| **Barycentric-as-blend-weights** | The dot's `(m, f, i)` *is* a three-way animation blend vector, so posture needs only three extreme poses plus neutral — no pose-authoring explosion. The reason posture-as-display is cheap. | V · 1 |
| **Headless sim core** | The simulation is an engine-independent library with a CLI for agents/sweeps and a thin API for the game. Mandated by the validation tooling; painful to retrofit. | V · 3 |
| **Two-positional-systems problem** | *Resolved (K4):* a sparse zone graph. The physical layer provides only target access, movement cost, circumstantial Advantage and `[EDM]` influences. | V · 6 · K4 |
| **Composure** | The central undivided polygon — the neutral zone where only generic actions apply. Base size parametric from Stats + Class; limited, guarded dynamic resizing permitted (no oscillation). | T · A3.6 |
| **Charge** | *Retired as a tracked value.* Survives only as a derived readout of aggregate credit state, used in metrics (e.g. `recovery rate from low charge`). | T · A.4 |

**Sector names (clockwise, backend):** `Mo · MoIn · In · MiIn · Mi · MiDi · Di · FoDi · Fo · FoPr · Pr · MoPr`. Landmarks: Mo/Fo/Mi (corners), In/Pr/Di (regions). Compounds are `[preceding][following]` in wheel order. Full address adds a ring, e.g. `FoDi/2`; Composure carries no ring.

---

## 2. The economy

*Renamed at 0.10.0 from "The credit economy" — now covers both the combat credit layers and the material currencies.*

### 2.1 Credit layers

| Term | Definition | Ref |
| --- | --- | --- |
| **Credit economy** | The three-layer resource system (Edge / Grit / Temper) fed by two source channels ([Action], [Context]). Internal keys `l1/l2/l3`. | T · B |
| **Edge** (⌬L1) | Fleeting, moment-scale credit. Spent inside the exchange to exploit an Opening. Cap 0–3. Steel-family name (the cutting edge). | T · B.2 |
| **Grit** (⌬L2) | Encounter-scale credit. Spent on boosts and Special actions. Cap ~0–10. The banked-toughness layer. | T · B.2 |
| **Temper** (⌬L3) | Run-scale credit. Held until a trigger (e.g. town); spent on permanent floor reshaping. [Context]-sourced only. Steel-family name (heat-treatment that reshapes). | T · B.2 · G.4 |
| **[Action]** (source) | Event-based credit channel: fires on outcomes attributable to a choice (hits, parries, crits). Rewards skill; sets the ceiling. | T · B.1 |
| **[Context]** (source) | Rate-based credit channel: accrues per round from the situation (outnumbered, above tier, threat). Rewards exposure; sets the floor. Unfarmable. Sole feeder of Temper. | T · B.1 |
| **The cascade** | Unspent credit converts downward only (Edge → Grit → Temper), at a loss. No upward conversion. Solves hoarding and gives Temper a skill-correlated surplus. | T · B.3 |
| **Loop Grit** | Grit from a completed Opening→read→Edge→successful-exploit chain. The backbone Grit source. | T · C.5 |
| **Flow Grit** | Minor Grit trickle from combos/crits (Pressure-leaning). Must stay small. | T · C.5 |
| **Endure Grit** | Minor Grit trickle from bracing / punishment survived (Discipline-leaning). Must stay small. | T · C.5 |

### 2.2 Material currencies

*Added at 0.10.0. All **provisional**. Owned by the Economy/World workstream.*

| Term | Definition | Register | Ref |
| --- | --- | --- | --- |
| **Marks** | Ordinary town money. The general renewable currency. Prices consumables, services and treatment. | Neutral — or steel, reading it as a smith's maker's mark | W · 5 · H · 8 |
| **Scrap** | Salvage material yielded by dismantling items. | Steel | M |
| **Flux** | Affix reroll / reforge material. **Reserved word: Flux is a currency and never a field quantity** — see §11 ◇H11. | Steel — the smelting agent that strips impurities and lets a bond take | M · 2.3 |
| **[Imprint]** | Per-Location pool serving as both progression track and spendable medium, for descent unlock and Stratum lock. Qualified by place: *Black Stair Imprint*. Player-facing name for `Location Grounding`. | Geological — strata contain imprints | W · 5.1 |
| **Location Grounding** | *Unbracketed at 0.10.0 — design-model name only.* The internal system name for the pool the player sees as `[Imprint]`. Linter rules bind this name, so a player-facing rename cannot evade them. | — | W · 5.1 · H · 13 |

**Currency separation.** Different sources, horizons and purchases; no overlap:

| Currency | Source | Horizon | Buys |
| --- | --- | --- | --- |
| Edge / Grit | Combat | moment / encounter | Exploits, boosts, Special actions |
| **Temper** | [Context] | within-run, spent at town | Floor reshaping — *who you are* |
| **[Imprint]** | Location runs | across runs, per Location | Descent and Stratum locks — *where you can go* |
| **Marks** | Loot, sale | renewable | Goods, services, **treatment** |
| **Scrap / Flux** | Dismantling | renewable | Crafting and reforging |

**Progress-currency protection (H·8.1).** Recovery, healing and treatment may **never** be denominated in `Location Grounding`/`[Imprint]` or Temper. Charging recovery against a progress currency lets injury retroactively erase banked achievement. Linter-enforced as H-C3.

---

## 3. Regions and the loop

| Term | Definition | Ref |
| --- | --- | --- |
| **Regions** | The three inner areas at the triangle's edge midpoints (Instinct / Pressure / Discipline). *Derived, not tracked* — being "in" a region is a readout of position. Identical coordinates for every character. | T · A.3 · C |
| **Instinct** (region) | Momentum↔Mind. Verb: **read**. Perceives an Opening and converts it into Edge. The shared converter every loop routes through. | T · C.1 |
| **Pressure** (region) | Momentum↔Form. Verb: **force**. Displaces the opponent's dot directly, creating an Opening. The proactive setup. | T · C.1 |
| **Discipline** (region) | Mind↔Form. Verb: **resist**. Holds own dot against disruption; counters, provoking the opponent to overextend. The reactive setup. | T · C.1 |
| **The loop** | The offensive backbone: create → read → exploit (spend Edge → [Advantage]) → convert (Advantage action → Grit). No step self-funds. | T · C.3 |
| **Traversal requirement** | Because create and read live in different regions and the dot can occupy only one, mixed play out-generates single-region play by geometry, not bonus. | T · C.4 |
| **Position-dependent checks** | Locked invariant: action success scales on Triade position. The read check scales on Instinct-proximity, Opening depth, Opening age, and channel stat. | T · C.6 |

---

## 4. Relational states

*Directional states — edges in the combat graph — that hold between two combatants. Scoped **against/for X** (a specific combatant) or **All**.*

| Term | Definition | Ref |
| --- | --- | --- |
| **[Opening]** | A vulnerable state on a combatant's dot. Decays as the dot drifts home. Readable/exploitable only per its scope. | T · C.2 |
| **[Opening for X]** | Opening created by X's *direct action* (Pressure/Discipline). Private — only X may read/exploit it. No handoff. | T · C.2 |
| **[Opening for All]** | Opening from an *environmental/board condition* (irrespective of who set it up) or an enemy self-overextending. Public — any opponent may read it. | T · C.2 |
| **[Advantage]** | A favourable footing the holder has over a target, unlocking Advantage-gated actions. Earned via the loop (one-shot) or by circumstance (maintained). | T · C.3a |
| **[Advantage against X / All]** | Scoped instance of Advantage — over one target or over all. | T · C.3a |
| **[Back-foot]** | A penalised state (AP up, success down) the holder suffers against a target. Relational, non-stacking per attacker; cleared by a successful action against that attacker. `[for All]` version penalises against all tier-2 opponents until balance regained. | T · C.3a · F.0 |
| **Exchange chain** | The causal order of a winning exchange: *their Opening → my Advantage → their Back-foot.* | T · C.3a |
| **Advantage maintenance** | The expiry condition every Advantage carries: loop-earned = one-shot; circumstantial = persists only while the circumstance holds. | T · C.3a |

---

## 5. Actions and vocabulary

| Term | Definition | Ref |
| --- | --- | --- |
| **Action contract** | The single data interface between any action and the Triade: position delta, region effect, check, credit, requirements, AP. | T · H |
| **Region action** | An action whose payload operates on a Triade state (create/read/exploit/resist), not primarily on HP. | T · C.1–C.3 |
| **Vocabulary** | The set of region-gated actions available to a character — supplied by class and weapon. What *grows* over a run; the geometry does not. | T · C.7 · D |
| **[Advantage] action** | An action gated on holding [Advantage against] a target. Success scales on the actor's distance from home (exposure). | T · C.3a · F.0 |
| **[Signature Action]** | A boss-tier skill a [Commander] unlocks by banking Grit from a successful Advantage action. Gated behind the player's own exposure. | E · F.0 |
| **Generic actions** | Baseline actions available from any position (no region membership required). What a dot near the dead centre can still do. **The absolute floor beneath the Trauma Safety Clamp** — a clamped character is never actionless. | T · A.3 · H · 10.2 |
| **Skill Anchor** | A skill's ideal position, authored in grid coordinates (`MoIn/2`); effects scale with distance from it, resolved on continuous position. | T · A3.7 |
| **Angular window** | The *availability* axis of an anchor: a **hard cutoff** — lean the wrong way and the skill is unavailable. Tightens with [Skill Level]. | T · A3.7 |
| **Radial falloff** | The *potency* axis of an anchor: a smooth curve with **no cutoff** — wrong depth is weak, never impossible. | T · A3.7 |
| **Anchor decomposition** | Wrong direction means **no**; insufficient depth means **weak**. A single 2D distance would conflate the two. | T · A3.7 |
| **Kit spread** | A build axis: tightly-clustered anchors are positionally efficient but predictable; spread anchors force traversal, which feeds the Grit engine (C.4). | T · A3.7 |
| **Posture telegraph** | Because enemies have positions and anchors, an enemy's *stance* reveals which skills it can currently use — a read layer emergent from anchors + the ambient channel. **Also the channel carrying enemy wound state** (H·12.2). | T · A3.7 · H · 12.2 |
| **Skill builder spec** | The nine-step authoring procedure and the automatable validation rules (reachability, demand-consistency, ladder monotonicity, pip conservation, redundancy, coverage, class-fit). | T · A3.8 |
| **AP** (action points) | In-combat action currency. At most one corner may modify the *pool*; others modify cost. A minimum AP floor is always guaranteed — **the second named brake against the injury spiral** (H·10.1). | T · H · K·3.3 |

---

## 6. Conditions and dot influences

*In-fiction states that act as [CDM] or [EDM] influences — they push the dot via zero-sum vectors. See §9C for injury-specific conditions.*

| Term | Definition | Ref |
| --- | --- | --- |
| **Condition** | Any in-fiction state applying a dot influence (force/impulse). Character-scoped conditions are [CDM]; external ones are [EDM]. **`[Wound]` is a Condition subtype anchored to a `[Body Location]`.** | T · A2.1 · H · 7.1 |
| **[Blinded]** | Eye wound: accuracy and read penalty; Instinct read potency crush. *Designed at 0.10.0 — no longer merely illustrative.* | H · 7.2 |
| **[Poisoned] / [Stunned] / [Fed] / [Thirsty]** | Example [CDM] conditions on a character. *Illustrative — not yet individually designed.* | T · A2.1 |
| **[Rain] / [Muddy Terrain]** | Example [EDM] environmental conditions. *Illustrative.* | T · A2.1 |
| **[Wet] / [Cold] / [Braced]** | Example conditions cited for *level-2 non-linear interaction*. *Deferred to level 2.* | T · A2.5 |

---

## 7. Enemies

| Term | Definition | Ref |
| --- | --- | --- |
| **Capability ladder** *(the word is now undivided — the `sources` slot yielded it at 0.13.0)* | Four enemy tiers defined by which loop stages they possess, not by stat size: Trash → Standard → Elite → Commander. **Also determines anatomical depth** (H·11). *Home reference moved to **E** at 0.11.0.* | E · F.0 · H · 11 |
| **Trash** | Tier 1: has a position, can be exploited, cannot manipulate the player. *No wound ledger.* | E · F.0 · H · 11.1 |
| **Standard** | Tier 2: + creates Openings on the player, applying [Back-foot]. No credit economy. *Five-node body template.* | E · F.0 · H · 11.2 |
| **[Elite]** | Tier 3 role tag: + reads player Openings → one-shot [Advantage] action. *Full body template.* | E · F.0 · F.1 |
| **[Commander]** | Tier 4 role tag: + banks Grit from successful Advantage actions → [Signature Action]. *Full template plus signature-linked nodes.* | E · F.0 · F.1 · H · 11.3 |
| **Enemy Tag** | One of the six typed tag classes composing an enemy — chassis, physique, behaviour, equipment, faculty, role — each with a cardinality rule. **Never called a *category***: that word is the item classification (M·2.1). *Renamed from the F.1 column header "Category" at 0.16.0.* | E · F.1 |
| **Tag composition** | Enemies built from typed **Enemy Tags** (chassis / physique / behaviour / equipment / **faculty** / role) with cardinality rules; chassis-plus-modifiers then renormalise. *`faculty` added at 0.13.0 at cardinality ≥1 (rule **E-C6**) and missing from this row until 0.16.0 — an enemy with zero equipment still acts.* | E · F.1 |
| **`[Band-End Portal]`** | The authored traversal edge out of a dungeon at band completion. Sibling to `[Vertical Portal]`; both are **authored, never generated**. Leaving through one is what locks bands A and B — there is no partial lock. | W · 5.4 |
| **Band C exemption** | Band C alone may carry **one interior exit between storeys**, and requires save-and-resume. Narrow by construction: band C only, between storeys, never mid-storey. Any widening re-opens W·5.4's mutual exclusivity. | W · 5.4a |
| **Storey pacing unit** | The storey, not the Delve level, is the unit growth and acquisitions are measured against. 18 per career — `S-W01` levels × `W·5.8` `N`. | M · 9.1 |
| **Career power multiple** | **×9** effective damage from run start to career end, compounding across bands. **Not** a per-run figure. Derived per storey (`9^(1/18)` = 1.130). Never touches the conserved baseline floor (T-C3). | M · 9.2 |
| **`faculty`** | An acquired or conferred vocabulary authorization. Independent families may also be non-item action sources with their own footprint and hook; `[Somatic]` is authorization-only and uses a bound natural node as the source. Four families since 0.40.0: `[Arcana]`, `[Mudra]`, `[Psyche]`, `[Somatic]`. *Renamed from `capability` at 0.13.0 to return that word undivided to the capability ladder.* | M · 2A.10a · T · A3.8 |
| **`[Attunement]`** | Player-facing name for the **Mind effective corner floor** as it gates and scales faculties — the same naming pattern as `[Imprint]` for Location Grounding. Not a new quantity and **not a resource**: Mind's locked consumption verb is *"threshold — gates access"*. Affine render (T-C11); bounded below by the Trauma Safety Clamp, so injury suppresses casting and can never zero it. | T · A.1 · A4.2a |
| **`[Innate]`** | **Not a faculty since 0.32.0.** The unarmed footprint a lineage authors **per body node** (T·A4.8a) — a dwarf's hands, a wolf's teeth. Live while the node is; denied by the node's own state, never by a gate. | T · A4.8a |
| **Incidental** | Canonical base innate magnitude grade **1** at one body node: an ordinary or secondary natural source. Not a skill level or enemy tier. | M · 2A.10a · M-C12 |
| **Dedicated** | Canonical base innate magnitude grade **2** at one body node: a combat-adapted natural source. Not a skill level or enemy tier. | M · 2A.10a · M-C12 |
| **Apex** | Canonical base innate magnitude grade **3** at one body node and the ordinary single-node ceiling. Exceeding it requires M-C12's explicit exception. | M · 2A.10a · M-C12 |
| **`[Arcana]`** | Faculty family for **verbal** casting. Hook: voice; gate: functional vocal apparatus. `[Arcana]` + `[Arcana]` is impossible — one voice, one hook. | M · 2A.10a · H · 7.2a |
| **`[Mudra]`** | Faculty family for **gesture** casting. Hook: fingers on a selected unoccupied hand. A two-hand Mudra requires two distinct functional finger hooks and both hands unoccupied; it remains one Faculty entitlement. | M · 2A.10a · H · 7.2a |
| **`[Psyche]`** | Faculty family for **unspoken** casting. Hook and anatomical gate: **Brain only**. `[Psyche]` + `[Psyche]` is impossible — one Brain, one hook. | M · 2A.10a · H · 7.2a |
| **`[Somatic]`** | Faculty family authorizing deliberate natural-node Techniques. It contributes no independent footprint or delivery hook; an active lineage-bound node is the action source. Anatomy supplies capacity, Somatic supplies acquired control. | M · 2A.10a · T · A3.8a · P · 2.3a |
| **Faculty lifecycle** | `conferred` = automatically possessed by an explicit grant or build instruction; `unlocked` = eligible for acquisition; `acquired` = a persisted character-state fact. `possessed` derives from conferred or acquired and is not authored separately. Acquisition normally survives loss of its unlock source unless an explicit leased/revocable contract says otherwise. Runtime readiness is not a Faculty lifecycle state. | M · 2A.10a · P · 2.3a · 2.3c |
| **Faculty profile** | An immutable base or explicit composite Faculty source contract: normalized members, execution hooks, Occult damage footprint, primitive actor-pull signature and Technique authorizations. A composite is an authorization profile, never a separately acquired entitlement, and does not own Technique behaviour. | M · 2A.10a · P · 2.3b · 2.3c |
| **Faculty pull signature** | A primitive zero-sum direction constraining a Technique's actor `position_delta_q`. The Technique owns magnitude and applies the only runtime delta; the Faculty signature never stacks and never governs target or environmental motion. | T · A3.8c · M · 2A.10a |
| **Technique readiness** | Three derived predicates: `known` = vocabulary and authorization hold; `selectable` = at least one complete actor-side candidate may initiate; `executable` = one fully contextual candidate passes every gate and may commit costs and resolve. None is persisted. Unqualified *available* is player-facing prose, not an engine predicate. | P · 2.3d · T · A3.8d · K · 5.1a |
| **Execution candidate** | One exact authorization/grant/source/support/provision/carrier/target route. Alternative complete candidates combine existentially; every dependency inside one candidate combines conjunctively. Failure is local to candidates declaring that dependency. | P · 2.3d · T · A3.8d |
| **Target-route contract** | The Technique-authored selection origin and shape, reach/range source, visibility requirement and delivery route. Direct and area routes apply different authored gates; source category alone never implies LOS or its bypass. | T · A3.8d · K · 5.1a |
| **Resolution participant** | Umbrella for four non-interchangeable roles: the command's **selected target**, a delivery **route contact**, a compatible **effect recipient**, or a Named Reaction's **reaction product**. Executability validates the selected target/origin and route; later milestones discover current contacts and recipients. | P · 2.3e · T · A3.8e · K · 5.2 |
| **Plannable Action** | A Technique-authorized scheduled or triggered commitment that binds an exact candidate and autonomous `world_tick` node. At the due tick it attempts a fresh executable verdict independently of the owner's later actor-timeline position; it is not stored AP, an extra turn, or permission to retarget. | P · 2.3e · T · A3.8e · K · 3.7 |
| **Plan acquisition mode** | How a Plannable Action obtains what it will attempt: `first_eligible` takes the first deterministic eligible participant, `bound_identity` watches one perceived identity with no default retarget, and `fixed_spatial` binds an origin/path/area and discovers recipients at resolution. Acquisition never replaces Technique target-route validation. | P · 2.3e · T · A3.8e · K · 3.7 |
| **Delivery hook** | The channel an action issues through — `main_hand`, `off_hand` or `voice`. **Distinct from hand occupancy**: a two-hander occupies two hands and presents one hook. A `[Combo-Action]` declares exactly two (T-C13). | M · 2A.10 |
| **`[Ward]`** | The Occult mitigation channel, covering cognition and focus attacks. A **state track** — `Intact → Scored → Broken` — modelled on integrity, not a pool. Blunts kind, not quantity. | M · 2A.4 |
| **Occult load** | Cumulative exposure to corruption and displacement, accruing **whether or not the state is purged in combat**. Converts past threshold to ward scars, which only the town rite clears. Makes in-combat purge tactically complete and strategically partial. | H · 8.2a |
| **Divine purge** | One action, two faces: it removes a state from an ally and converts that same state into damage against a bearer. **Consumes what it converts** (H-H6) — a conversion, never a generator. | H · 6.2b |
| **Martial profile** | An item chassis's base damage and defence characteristics. *Renamed from "damage/defence signature" at 0.13.0, freeing* signature *for `[Signature Action]`.* | M · 2A.1 |
| **Trace Signature** | The per-actor trace fingerprint used by the redundancy gate. *Qualified at 0.13.0 for the same reason.* | T · I.2 |
| **`aim_weight` / `AIM_CEILING`** | The bias an aimed action applies to the coverage cascade, and its ceiling below 1.0. *Named `focus` at 0.13.0 and renamed within the same version — **focus** was already Mind-side vocabulary.* | H · 6.2a |
| **Aimed mode** | A Technique-declared optional action mode with maximum granularity `coarse` or `targeted`. It pays an action-time surcharge and reweights H's existing coverage cascade; it never selects a node, invents anatomy or guarantees carrier/Payload delivery. Enemy access is an acting-tier permission in E. | T · A3.8b · K · 3.4 · H · 6.2a · E · F.0a |
| **[Chassis]** | The single tag naming an actor's **body template** (H·5.3) and, **for enemies only**, its base floor shape. Exactly one per actor — **players included**. **The same object as the Lineage** (T·A4.8a), not a separate record. A player chassis never declares a floor shape: that renders from stat fields. *Distinct from the item-layer sense at M·2A.1.* | E · F.1 · H · 5.3 · T · A4.8a |
| **Lineage** | What an actor is born as, and the same record as `[Chassis]`: body template, available sizes with one flagged **typical**, and a 9-stat **offset that sums to zero**, measured at typical. A stat lens of the same kind as class. *`[Race]` was rejected — it collides with the* damage race */* kill race *sense.* | T · A4.8a |
| **Typical** | The one size a lineage flags as its ordinary member — Small for a Rat, Large for a Troll. The lineage's stat offset is measured here, and the typical size carries **no** physique pairs. *Never called "standard": that is enemy Tier 2 and the shield sub-family.* | T · A4.8a · E · F.1 |
| **Size ladder** | `Small → Average → Large → Giant`. A lineage offers a **subset**; a size it does not offer is `null`, which is not zero. **A position on the lineage's own ladder, never a world-scale measure.** | E · F.1 |
| **Physique** | Enemy Tag for size/mass, biasing Form and Pressure (e.g. `[Average size]`). The ladder is `Small → Average → Large → Giant`, a per-lineage subset with one `typical` (E·F.1). | E · F.1 |
| **Behaviour** | Enemy Tag(s) driving AI policy (e.g. [Compulsive], [Simpleminded], **[Wounded]**). The tag set *is* the behaviour policy — learnable and transferable. | E · F.1 · F.2 |
| **Equipment** (enemy) | Enemy Tag supplying region vocabulary; shares the player weapon record (e.g. [Pike] = a polearm). | E · F.1 |
| **Role** | Enemy Tag setting the capability tier ([Elite], [Commander]). Absence = Standard/Trash. | E · F.1 |

---

## 8. Character build & progression

| Term | Definition | Ref |
| --- | --- | --- |
| **Class** | Two data structures: a floor shape (class-alone at run start) and a region vocabulary. Also a *stat lens*: a zero-sum starting **offset** + a growth-cost **gradient**. | T · D · A4.8 |
| **Influence channels** | The three ways stats reach the Triade: **pull strength**, **floor extent**, **decay resistance**. Every stat must be distinct in at least one. | M · 1.2 |
| **Stat group** | The three stats attached to one Triade corner, structured capacity/application/resilience. Momentum {Strength, Finesse, Stamina}, Mind {Intellect, Will, Spirit}, Form {Frame, Poise, Constitution}. Nine total (superset; scalable to six). | T · A4.1 |
| **Capacity / application / resilience** | The role structure of each stat group — *what you have / how you direct it / how you withstand its domain*. **Also the derivation rule for wound→stat mapping** (H·5.2): bone→capacity, tendon/nerve→application, organ/bleed→resilience. | T · A4.1 · H · 5.2 |
| **Render emphasis** | One field per corner, but the two renders read the stats differently: Reach emphasises capacity+application (striker), Floor emphasises resilience (controller). **Consequence at 0.10.0:** bone-breaking counters strikers, bleeding counters controllers (H·5.2). | T · A4.1 · A4.4 |
| **Field (Φ)** | A per-corner-group strength that renders the floor (not a force on the dot). Quasi-static — a live read of current stats. Two states: baseline and effective. | T · A4.2 |
| **Baseline field** | Fields from stats at creation + progression + rare permanent changes. Conserved (`Σ Φ_base` constant) — the invariant. No permanent power creep. | T · A4.2 |
| **Effective field** | Baseline + temporary stat modifiers (injuries, poisons, potions, food, blessings, **surfaces**). Clamped to per-corner caps **and to the Trauma Safety Clamp**; not conserved. Snaps back to baseline when modifiers clear. | T · A4.2 · H · 10.2 |
| **Field conservation** | The *baseline* field strengths sum to a constant; raising one lowers the others. Effective may break the sum temporarily but is clamped. | T · A4.2 |
| **Temporary stat modifier** | A reversible change to a stat from a condition/consumable/worn item, shifting effective fields → re-rendering the floor. **Clears at the run boundary** (◈W2f, Steward-locked 28 July 2026), in addition to duration/heal conditions — whichever comes first. | T · A4.2a · W · 5.6a |
| **Effective-field sources** | Three permanence tiers: permanent (progression → baseline), worn (equipment → effective, reverts on unequip, persists across runs), temporary (consumables/conditions → effective, clears at run boundary). **Wounds split by channel** — see §9C. | T · A4.2a · H · 9.3 |
| **Floor-shaping gear** | Stat-bearing equipment lifts effective fields, so it unlocks skill levels the baseline floor denies — inherently behavioural, not a stat-stick. | T · A4.2a · M · 2.3 |
| **Modifier-as-safer-route** | A positive modifier can raise effective floor/reach to meet a deep skill's [Level Requirement] from a *safer* dot position — trading a resource for the exposure positioning would otherwise cost. Grants a ceiling, not mastery. | T · A4.2a |
| **Region co-authorship** | Each region floor is rendered from *both* its parent fields (In ← Momentum+Mind, etc.). | T · A4.3 |
| **Region Floor render** | Staying power: super-additive (`≈2·Φa·Φb`), rewards *balanced* parents. Drives the controller. | T · A4.4 |
| **Corner-floor render affinity** | The **corner**-floor render must be **affine** in its field, or `ΣF_rendered` drifts across a career rather than a run. The **sector**-floor render is deliberately super-additive. Two renders, two opposite requirements, on purpose. Rule **T-C11**. | T · A4.4 |
| **Region Reach render** | Depth of access: peak-driven (`f(max Φ)`), rewards a *specialised* parent. Drives the striker. **The render the Trauma Safety Clamp protects** (H·10.2). | T · A4.4 · H · 10.2 |
| **Striker / controller / master** | Three region-occupancy profiles from the reach-vs-staying gap. | T · A4.4 · A4.7 |
| **[Reach Cost]** | Skill Characteristic: the region depth at which a skill becomes accessible at all. **Input to the `Φ_safe_x` derivation.** | T · A4.7 · H · 10.2 |
| **Skill type** | *Specialised* (peak-gated) or *Shareable* (available at depth, tiered by [Skill Level]). | T · A4.7 |
| **[Skill Level]** | For shareable skills, a ladder of additive, qualitative tiers, each carrying a [Level Requirement]. | T · A4.7 |
| **[Level Requirement]** | A sector-floor threshold a given skill level demands. **Input to the `Φ_safe_x` derivation.** | T · A4.7 · H · 10.2 |
| **Usable level (skill)** | Derived: **reach** sets the level you can *momentarily* fire; **staying floor** sets the level you can *hold*. | T · A4.7 |
| **Mastery (skill)** | Raising staying floor until it meets reach, so the deep version no longer ejects you. A training/Temper sink. | T · A4.7 |
| **Field breathing** | *Resolved:* quasi-static — baseline (conserved) + effective (clamped). | T · A4.2 · A4.6 |
| **Starting offset** | The class's ± stat mask, applied at creation. **Must sum to zero** — class sets shape, never size. | T · A4.8 |
| **Growth gradient** | Per-stat growth costs: mains cheaper, off-stats costly-but-reachable. Governs the *path*, never the total. | T · A4.8 |
| **Path/destination principle** | Zero-sum governs stat/field *totals*; the growth economy governs the *path*. | T · A4.8 |
| **Sub-class** | Zero-sum on stats; rewarded by (A) a sharper offset → deeper reach, and (C) exclusive Specialised vocabulary + higher [Skill Level] ceilings. No stat-total deviation. | T · A4.8 |
| **Multi-class** | Summed offsets (→ toward neutral, often partially cancelling) + unioned gradients (→ thinner growth → shallower reach). Versatile-but-shallow, emergent from the fixed budget, no authored penalty. | T · A4.8 |
| **Reach vs dwell** | *Reach* = can you enter a depth. *Dwell/staying* = how long you hold it. | T · G.1 · A4.4 |
| **Modification budget** | Rule for floor-reshaping items: sum-preserving (holds ΣF = 0.45), per-corner cap respected, threshold reductions per-region only. | T · G.2 · M · 0.5 |
| **Permanence tiers** | What an item may alter by how long it lasts: permanent → floor shape; worn → threshold/dwell; temporary → dwell only. | T · G.3 |
| **`_q`** | A persisted fractional value at `FIXED_POINT_SCALE = 12 000`, so `1.0 = 12 000_q`. Signed 64-bit; round-to-nearest, ties away from zero. **Governs persisted fractional simulation state only** — `world_tick`, tick durations, AP rates and `u8` channels are ordinary integers. | P · 3 |
| **`world_tick`** | The **sole** persistent active-adventure timestamp — a monotonically increasing integer. Every schedule, effect, propagation, exposure and threshold is expressed against it. A transient processing cursor may exist internally but **must not persist or diverge**, and **`sim_tick` is not a competing field or clock**. | K · 3 |
| **AP rate** | An actor's action-time rate, `2–6 AP / 60 ticks`, base **4**. `action_duration_ticks = effective_AP_cost × (60 / current_AP_rate)`. **AP is not a resource** — nothing is spent, banked or carried. | K · 3.4 |
| **Tactical Timeline** | The player-facing projection of the `world_tick` queue. **Not a second clock**, and the 60-tick band is a cadence and refresh boundary rather than an AP grant. | K · 3.1 |
| **Airborne Volume** | Gas, smoke or vapour held as a **sparse volume carrier**, propagating along permeable volume edges. Addressed independently of any face, so it **never contends with face state** — a face may be wet while the volume above it burns. | W · 11 |
| **Intent Marker** | A committed and **perceived** enemy action shown on the Tactical Timeline — actor, prepared action, target, span, resolve tick, interruptibility, visible branches. Supplements posture; never reveals unseen enemies or uncommitted choices. | K · 3.5 |
| **Ghost Track** | The preview produced by running the **authoritative** resolver against a temporary state copy. Forecasts are **Solid**, **Conditional** or **Unknown**; it never reveals a future roll or hidden state. | K · 3.5 |
| **Armed Intercept Node** | The timeline position created by Watch or Riposte. Fires only on temporal crossing **and** valid trigger **and** spatial eligibility, evaluated **at the intercept tick**. Widens *when* a reaction may fire, never its cost or payout. | K · 8.1a |
| **[Modification Ceiling]** | Depth-granted latitude governing how far from class baseline the floor shape may be reshaped within a run. Never grants floor budget; `ΣF` stays conserved. Answers T·K.6. Reverts toward baseline on collapse. *Provisional.* | W · 5.6 |
| **[Territory Vocabulary]** | Techniques taught by a Location, anchored in that region and learnable only by a character whose floor shape reaches it (T·A3.8 anchor reachability). Pool grows with `[Imprint]`; slot count fixed. *Provisional.* | W · 5.6 |
| **[Technique Slot]** | One of a fixed number `N` of per-run slots into which learned [Territory Vocabulary] is loaded. Depth buys choice, never power. *Provisional.* | W · 5.6 |
| **Handedness** | The chassis property fixing a weapon's **ordinary base pip budget**: one-handed = **3** base pips, two-handed = **4**. Fixes the total only; distribution across damage types is authored per chassis. Shields are excluded — they use the pooled shield budget. Weapon families existing in both forms carry an explicit `1h-` / `2h-` type qualifier (`1h-Sword`, `2h-Sword`); machine IDs use `_1h` / `_2h`. A type qualifier, never a slot, occupancy count or delivery hook. *Locked 0.17.0, rule M-C1.* | M · 2A.9 |
| **Shield budget** | A shield draws pips *and* defensive value from **one pooled budget**, never two full ones. **Two base pips, always** — split by sub-family: buckler 2/0, standard 1/1, tower 0/2 (**M-C9**). | M · 2A.11 |
| **Defence pip** | The unit defensive value is denominated in — one step of 2A.4 signature notation, the `+` in `Slash +`. The **same** unit as an offensive pip, which is what makes the shield budget one pool (**M-C10**). Buys only in groups resolving through **typed defence** — **Structural is not purchasable** (M-C2). Body-armour signatures are not denominated in it, because they are unbudgeted. | M · 2A.11 |
| **Split position** | Where a shield sits on its 2-pip budget line. **Authored, not measured** — buckler 2/0, standard 1/1, tower 0/2 (M-C9). `S-M05` struck at 0.29.0. | M · 2A.11 |
| **Off-hand form** | A one-handed weapon as it behaves in the off hand: base footprint minus one pip, taken from its highest damage type (**M-C11**); ties resolve to the last-declared type. Not a separate item and not a handedness value — the same weapon, transformed by the slot. | M · 2A.11 |
| **Martial priority** | The order of a footprint's `{ type, pips }` list, read **signature first, concession last** (M·2A.9). Load-bearing, not authoring convenience: it names the type a weapon gives up when a rule selects *the highest* and two tie. | M · 2A.9 |
| **Tile class** | A tile's kind, in **G**. Deliberately *not* `category`, which is the locked item classification (M·2.1, P·1.3) — the tile column read `Category` until 0.16.0 and was renamed to clear the collision. The word `class` carries no mechanical weight here and needs none. | G · 2 |
| **Weapon Smith** | Agent authoring weapons. Hard gates: pip budget (the weapon analogue of class sum-to-zero), zero-sum pull vectors, granted-vocabulary anchor reachability, structural legality, loadout shape. | M · 5.3 |
| **Armourer** | Agent authoring armour. Hard gates: per-family exception budget, **global** matchup-surface budget, Bridge-2 weight-class consistency, integrity coherence (rigid discontinuity), stat-effect caps. | M · 5.4 |
| **Shield Smith** | Agent authoring shields. Exists because the shield budget is a rule *neither* parent agent owns. Clears both parent suites plus lean-scaling and dual-path vocabulary; audited for loadout dominance. | M · 5.4a |
| **Class Smith** | Agent that proposes class/sub-class offset+gradient. Hard gate: offset sums to zero. Quality: build-trace redundancy (EMD) vs existing classes. Agent writes only the 9-number core; render→floor→skills→trace is deterministic. | T · A4.9 · M·5.2 |
| **Portfolio constraint** | A validation budget held across the *whole content set* rather than per item — e.g. the ~20 matchup-surface target. | M · 5.4 |

---

## 9. Itemisation & equipment

| Term | Definition | Ref |
| --- | --- | --- |
| **`category`** | **The item classification — what a thing *is*.** Seven values: `weapon`, `armour`, **`shield`**, `trinket`, `consumable`, `currency`, `tome`. Determines which typed components a record must carry, so a linter can state completeness from data alone. **One of P·1.3's three classifications that must never merge** — `category` is *what it is*, `slot / occupancy` is *where it equips*, `delivery_hook` is *the channel an action issues through*. *Locked in M·2.1 since 0.9.0 and never propagated here until 0.16.0.* | M · 2.1 · P · 1.3 |
| **`shield`** *(category)* | The dual-nature category. Component set is the **union** of weapon and armour — martial profile, defence signature, own integrity track — drawn from **one pooled budget** (M-C4). It is not a sub-type of either parent: filing it under one would make its required components unstateable in data. *Added at 0.16.0; P·1.2 had listed it as a peer since 0.15.0 while P·1.3's enum omitted it.* | M · 2A.11 · P · 1.3 |
| **`remedy_type`** | The remedy classification — `consumable`, `tool`, `surgery`, `rest`, `service`, `rite`. **Never `category`**: a remedy is an item, carrying `scarcity_tier` and `affix_slots`, so it already holds a `category`. The two enums overlapped on `consumable` and diverged on five values, which is what hid the collision from 0.10.0 to 0.16.0. | H · 8.4 |
| **weapon_triade** | A weapon's signature block: archetype, pull vectors, magnitude, volatility, recovery, vocabulary, efficiency. | T · E.5 · M · 2.1 |
| **Archetype** | A weapon's identity template (e.g. `heavy_builder`, `fast_sustainer`). Hand-authored; no agent may add one. | T · E.5 |
| **Affinity / vocabulary / efficiency** | The three weapon-to-region relationships, which *need not align* — divergence makes a "technical" weapon. | T · E.1 |
| **Corner weapon / region weapon** | Corner = single-corner push, forgiving, common. Region = demands a narrow region, rewards it, rare. *This is what rarity means.* | T · E.2 · M · 2.2 |
| **Weapon demand** | Derived stat: the deepest region a weapon's vocabulary needs, shown against the character's reach. | T · E.4 · M · 3.6 |
| **Clumsiness** | Penalty (AP + recovery) scaling with distance from home to a weapon's demand. **Capped, so off-class drops stay usable — the fourth named brake against the injury spiral** (H·10.1). Wound-induced weapon-handling penalties route through it. | T · E.4 · H · 10.1 |
| **Affix** | A modular item modifier; `triade_effect` affixes (pull/dwell/efficiency/threshold) are inherently behavioural. Rerolled with **Flux**. | M · 2.3 |
| **Item power budget** | Allowed power band per rarity/ilvl. Triade effects priced by *simulation delta*, not formula. | M · 2.5 |
| **Threshold-reducing affix** | Lowers region threshold `T` for one region; restricted to uniques/high tiers; per-region only. | M · 2.3 · T · E.5 |

---

## 9A. Materiel: damage, armour and pips

| Term | Definition | Ref |
| --- | --- | --- |
| **Five item layers** | Chassis / Construction / Behaviour / Affixes / Inscription. | M · 2A.1 |
| **Demand tier** | Three-step *positional* axis: Broad → Focused → Exacting. For skills, **derived** from the angular window. | M · 2A.2 · T · A3.7 |
| **Doctrinal** | Orthogonal flag: wants a *repeatable behaviour loop*. A **temporal** demand, not positional — and **not** an access restriction. | M · 2A.2 |
| **Transgressive** | Orthogonal flag: *breaks a rule* at a sharp cost. The general marker for rule-breaks. | M · 2A.2 |
| **Access scope** | Universal / class-exclusive / sub-class-exclusive — **derived** from vocabulary membership, display-only. | T · A3.8 · A4.7 · A4.8 |
| **Damage groups** | Physical / Volatile / Corruptive / **Structural** / Occult. **Types carry identity, narration and status hooks; groups carry mitigation.** | M · 2A.3 |
| **Structural** | Damage group (Shatter, Tear) that checks **integrity**, not typed defence. **Extended at 0.10.0:** bone and flesh integrity are the per-node anatomical form of the same path (H·6.2). | M · 2A.3 · H · 6.2 |
| **Shatter / Tear** | Inverted Structural pair: Shatter cracks *rigid* construction; Tear rends *flexible* construction and unarmoured flesh. Anatomically: Shatter→fracture, Tear→open wound. | M · 2A.3 · H · 6.2 |
| **Sharp exceptions** | Armour carries five group resistances + 2–3 type-specific exceptions. Target **matchup surface ≈ 20**. | M · 2A.4 |
| **Rigid discontinuity** | The organising principle of armour integrity — not weight. Rigid layers absorb huge force then fail abruptly; flexible layers degrade gracefully. **Extended inward as [Tissue Layer]** (H·5.1). | M · 2A.4 · H · 5.1 |
| **Integrity states** | Visible, encounter-scoped track: **Stable → Cracked → Fractured**, plus **Broken Guard** for shields. **Renders on equipment mesh/material only — never shares a channel with wounds** (V·4.8). | M · 2A.6 · V · 4.8 |
| **Bridge 1** | Integrity feeds the Opening loop: Cracked/Fractured → *deeper* Openings; Fractured → *slower decay*; Broken Guard → suppresses target's Discipline Opening-creation. | M · 2A.6 · T · C.2 |
| **Bridge 2** | Armour and dot displacement: **heavy** dampens [EDM]; **light** strengthens the home-well pull; **cloth** zero encumbrance. | M · 2A.7 · T · A2.2 |
| **Bridge 3** | Materiel reaches the credit economy *through status hooks*, never by direct type→credit mapping. | M · 2A.8 |
| **Pips** | A weapon's damage footprint — an *input to per-action computation*, not a static label. | M · 2A.9 |
| **Redistribution** | Default skill mechanism: a skill *moves* pips toward its **redistribution target**, zero-sum. Additive pips reserved for Transgressive/Inscription tier. | M · 2A.9 |
| **Redistribution target** | The damage type a skill moves pips toward. Field `redistribution_target`. **Named `focus` until 0.33.0**, which collided with the locked Mind-side sense — `+focus`, `Focus-broken`, the Will/focus tax. `damage_focus` was rejected: qualifying a reserved word does not legalise a second meaning. | M · 2A.9 |
| **Weapon requirement** | Per-skill property: **requires** (min pips in the **redistribution target**) or **permits with penalty**. Checks the weapon's **base** footprint. | M · 2A.10 |
| **Object-boundary rule** | Footprint is a property *of the weapon*: **affixes count**, **external buffs do not**. | M · 2A.10 |
| **No pip pooling** | Two-vector loadouts do **not** pool footprints — a skill draws from the hand used. Exception: a **[Combo-Action]**. **Reason the Standard enemy template splits limbs** (H·11.2). | M · 2A.10 · H · 11.2 |
| **[Combo-Action]** | A *single action drawing on multiple sources* — two items, item + capability, item + environment. **Source-agnostic**. Denied by hand and finger wounds (H·7.2). | M · 2A.10 |
| **Shield duality** | Armour + weapon + **the only *active* armour** — which is why it is the only armour carrying skills. One record, own integrity track. | M · 2A.11 |
| **Lean scaling (shield)** | A shield's defensive contribution scales with Form-ward lean. | M · 2A.11 |
| **Dual Opening paths (shield)** | The shield is the only equipment natively supporting *both* Opening-creation verbs — Discipline (counter) and Pressure (bash/shove). | M · 2A.11 |

---

## 9B. Combat: time, resolution and reactions

| Term | Definition | Ref |
| --- | --- | --- |
| **Exchange-control thesis** | Combat is manipulation of bearing, vulnerability and integrity; damage is the *consequence*. | K · 1 |
| **Finisher** | Secondary win condition: a scaled execute gated on the target being **Fractured/Broken Guard** *and* **[Back-footed against you]**. **Also the gate on vital-hit lethality** (H·9.4). | K · 2 · H · 9.4 |
| **Readiness** | Turn order = `intrinsic + relational`. | K · 3.2 |
| **Ordinality (readiness)** | Readiness sorts, never multiplies — the relational term **cannot snowball** and needs no cap. | K · 3.1 |
| **Three tempo levers** | One per corner, none compounding: **Momentum** = act earlier; **Mind** = action cost; **Form** = AP floor and [Back-foot] resistance (*you cannot be denied*). | K · 3.3 |
| **AP-as-elapsed-time** | `action_duration_ticks = effective_AP_cost × (60 / current_AP_rate)` — **restated 0.34.0; `base_AP_pool` retired with the pool itself (K-C11)**. Makes the action economy and the Dot Framework mathematically compatible. **The clock injury `hp_tick` runs on `world_tick`.** | K · 3.5 · H · 7.3 |
| **Zone graph** | The physical battlefield: 2–4 named zones per room with simple adjacency. Range in zone hops. **Never used for anatomy** — see `[Body Location]`. | K · 4 |
| **Position snapshot** | Resolution step 3: availability and potency read the position captured *before* the action resolves. | K · 5.2 |
| **Technique archetype** | The physical/action contract of a skill: anchor, timing, check, spatial and source requirements, zero-sum redistribution, ordinary effects and aim capability. It owns no Payload condition identity. | T · A3.8b |
| **Payload module** | An authorised condition or linked secondary-damage contract with a carrier type, target-layer route, scaling inputs and resistance/stacking policy. Adds no footprint pips, satisfies no source requirement and never enters redistribution. | T · A3.8b |
| **Source instance** | One usable Technique source resolved from an authorised binding and one active realised delivery node. Equivalent limbs remain distinct instances even when grouped in presentation. | T · A3.8a |
| **Derived skill rendition** | Deterministic composition of a Technique archetype, authorised source binding/instance and zero or one ordinary Payload module. Identity retains all three references. | T · A3.8b |
| **Carrier contract** | Immutable step-7 declaration of source revision, delivery node/hooks, redistributed footprint, Payload, carrier type and required target-layer route. | K · 5.2a |
| **Delivery proof** | The one-time step-9 test that the contracted carrier reached the contracted route in step 8's immutable layer trace. Unrelated damage cannot substitute. | K · 5.2a · H · 6.1a |
| **Layer trace** | Immutable ordered evidence for the resolved node's shield, covering-equipment and tissue-layer chain, including typed incoming, transfer/residual and integrity/trauma deltas. It is output, never a second resolver. | H · 6.1a |
| **Margin resolution** | One seeded roll → a margin → four outcomes. A critical is *evidence of a favourable exchange*, not a second lottery. | K · 6.1 |
| **Glancing rule** | Global: glancing produces the effect at reduced magnitude and **never awards credit**. | K · 6.2 |
| **Read timing window** | `read_value = depth × clarity_from_age × alignment × channel_stat`. | K · 6.3 |
| **[Pivot]** | A paid lateral traversal action anchored in a **transition sector**. Passive drift is always homeward. Taxed by knee wounds (H·6.3). | K · 7.4 |
| **Compound command** | Edge → Advantage → Advantage action remains three engine transitions but **one player command**. | K · 7.5 |
| **[Watch]** | An explicit reaction action: small AP cost plus a **Momentum-loss impulse**, geometrically settling the actor into Discipline. One per round. | K · 8.1 |
| **Watch two-branch rule** | Enemy **attacks** → counter. Enemy **declines** → modest drift toward Instinct. Both branches pay. | K · 8.2 |
| **Counter-as-traversal** | Di→In is *gain Momentum, shed Form, hold Mind* — a Momentum-building counter launches the counter-fighter from guard toward the reading position. | K · 8.2 |
| **[Provoke]** | A Watch variant that deliberately raises the actor's **exposure** to become the attractive target. | K · 8.3 |
| **[Riposte]** | The **⌬L3 rung of the Watch ladder**, not a separate mechanic. Its rarity is structural. | K · 8.4 |
| **Edge tokens** | Edge is 1–3 tokens, each tagged to its source Opening and target — making the no-handoff rule **structurally impossible** to violate. | K · 9.1 |
| **Cooldowns** | Authored rare-and-dramatic limiters with explicit check and start identities. A base Technique cooldown gates its derived renditions; rendition, Faculty and provider cooldowns have separate scopes and do not propagate without an explicit shared key. | K · 5.1 · K-H4 |
| **Encounter phases** | Probe → Exchange → Break. | K · 13 |
| **TTK benchmark** | If the fastest clear ignores Instinct and Edge entirely, time-to-kill is too short or burst too cheap. **Also the gate on whether wounds are too harsh** (H·14). | K · 13 · H · 14 |

---

## 9C. Damage, health and injury

*New at 0.10.0. All terms **provisional**. Home reference **H**.*

| Term | Definition | Ref |
| --- | --- | --- |
| **[Wound]** | A locational, persistent injury held on a body node; a `Condition` subtype surviving beyond the encounter and healed only by treatment. Distinct from HP loss. | H · 7.1 |
| **[Body Location]** | A node in the skeletal/muscular/organ graph carrying coverage, tissue layers, function tags and stat links. **Never called *region* or *zone*** — both are locked to other meanings. | H · 5.1 |
| **[Tissue Layer]** | The `skin → muscle → bone → organ` stack. Rigid layers fracture (Shatter); flexible layers tear (Tear). Extends rigid discontinuity inward past armour. | H · 5.1 |
| **[Wound Severity]** | Three-tier ordinal — Minor / Major / Critical — derived from a continuous per-node trauma accumulator. | H · 6.4 |
| **[Hobbled]** | Leg or foot wound state: Momentum field down, zone-move cost up, readiness down. | H · 7.2 |
| **[Deafened]** | Ear wound: readiness down, telegraph clarity reduced. | H · 7.2 |
| **[Wounded]** | Behaviour tag shifting AI policy toward defence or disengagement. Standard tier and above; Trash has no wound ledger and no tag. | H · 11.4 |
| **Body template** | An instantiable body-graph definition. Non-humanoid bodies and tiered-enemy bodies are new templates, not schema changes. **Referenced by `[Chassis]`, never inlined** (H-C6). | H · 5.3 |
| **Coverage weight** | Per-node **relative** weight biasing hit selection. **Per-pair**: a `×2` archetype's listed weight is the pair total, split at instantiation. Normalised to 1.0 per template (H-M2); not a percentage and not required to sum to 100. | H · 5.4 |
| **`hp_transfer`** | Per-node efficiency converting residual damage into global HP loss. Makes vitals lethal *through* HP — the legal route — rather than by a gated instant kill. | H · 6.3 |
| **`systemic_weight`** | Per-node contribution to derived crisis states. | H · 6.3 |
| **Derived crisis states** | `blood_loss_rate`, `breath_debt`, `neurotrauma`, `systemic_strain` — aggregated from active wound families, never stored. The layer that collapses many nodes into four readable things. | H · 7.4 |
| **Systemic strain** | Sum-of-squares aggregate over active wounds weighted by `systemic_weight`. **Super-linear in severity, sub-linear in count** — the structural guard against death-by-a-thousand-grazes. | H · 7.5 |
| **Trauma Safety Clamp** | Two-term lower bound on injury-driven effective-field loss, guaranteeing every held region stays mechanically reachable. Applies to the **sum of all sources**, including surfaces. Resolves W§5.6a's crushed-field lockout. | H · 10.2 |
| **`Φ_safe_x`** | The computed per-corner floor at which the Reach render still meets the lowest [Reach Cost]/[Level Requirement] in the character's vocabulary. **Derived per-build, never authored** — a tuned constant would silently desynchronise from region thresholds. | H · 10.2 |
| **Four named brakes** | The injury-spiral guards required by T·I.5: Trauma Safety Clamp · AP minimum floor · free Minor-scoped field dressing · Clumsiness cap. | H · 10.1 |
| **Vital-hit backstop** | A vital-organ hit is lethal *only* when the target is already below the Finisher threshold or Downed; otherwise it converts to a Critical wound plus a deep [Opening]. | H · 9.4 |
| **Downed** | Scene state at HP 0 or on a Critical head/spine wound. Not death — creates a rescue-or-finish window. | H · 9.4 |
| **Channel-split persistence** | Across a run boundary, wound **field modifiers clear** (◈W2f) while **[CDM], HP caps and function loss persist** until treated. Preserves `ΣF_rendered == ΣF_baseline` at run start and bounds the crushed-field risk to a single run. | H · 9.3 |
| **Progress-currency protection** | Recovery may never be priced in `Location Grounding`/`[Imprint]` or Temper. Linter-enforced (H-C3), bound to the internal name. | H · 8.1 |

---

## 9D. World, maps and dungeons

*New section at 0.10.0. These terms were locked in W§21 at 0.9.0 but never propagated into the Lexicon.*

| Term | Definition | Ref |
| --- | --- | --- |
| **[Delve level]** | One generated dungeon level; depth index within a Location. | W · 5.1 |
| **Territory** | The formal geographic world record. Each Territory declares **one** Triade axis and owns a content package, a palette and a lore scope; **many Territories may declare the same axis**, which is why geographic identity is not Triade identity and why `region` could not carry both. Machine identifier `territory_id`. | W · 5 |
| **Territory capitalisation** | **Territory** and **Territories** are capitalised in design prose whenever they denote the formal record or one of its instances — including *a Territory declares*, *many Territories*, *per-Territory*, *new Territory* — and in compounds: **Territory package**, **Territory schema**, **Territory identity**, **Territory cluster**, **launch Territories**, **[Territory Vocabulary]**. Machine identifiers stay lowercase snake_case: `territory_id`, `ref_territories`, `scope_kind: territory`. Lowercase *territory* is reserved for ordinary non-model geography and for preserved historical quotation. | L · 9D |
| **[Deck]** | *provisional, 0.12.0.* A stacked traversable sheet within one combat room; shares the room's 2–4 zone overlay. `tz` is the deck index. A zone may not span decks (W-C19). **Replaces the rejected `[Walk Surface]`**, which shadowed the locked meaning of *surface*. | W · 5.8 |
| **Deck tile** | The human-readable name of a `TileArchetype` contributing supporting or traversable geometry to a `[Deck]` (G·2). **Named `Surface` until 0.33.0**, which shadowed the reserved environmental sense. | G · 2 |
| **`deck`** | The machine-readable member of `structural_roles` naming that contribution. The canonical representation as of 0.33.0 (TD-CR-03); a `tile_class` of `deck_tile` is not. | G · 2 |
| **[Storey]** | *provisional, 0.12.0.* One generated bundle within a `[Delve level]`; own zone overlays, joined by `[Vertical Portal]`. `N` derived from Stratum band — 1 / 2 / 3 — and fixed. **Never called a floor.** | W · 5.8 |
| **[Vertical Portal]** | *provisional, 0.12.0.* An explicit authored traversal edge between decks or storeys, carrying movement cost and a landing-clearance mask. Never inferred from coordinate overlap. | W · 5.8 |
| **[Secret]** | *provisional, 0.12.0.* **A run-scoped `Discovery`** — a gate condition on a storey transition. Three monotonic resolution verbs: *operated*, *picked up*, *destroyed*. An attribute on the item record (M · 2.7a); held in the run-scoped key register, never in inventory. | W · 5.8a |
| **[Switch]** | *provisional, 0.12.0.* The latching state-change object class — the *operated* resolution. Irreversible, non-cover, indestructible on mandatory paths. **Not called a lever**: *lever* is reserved to K-C8's tempo sense. | W · 5.8a |
| **run-scoped key register** | *Unbracketed, provisional 0.12.0.* The non-droppable, capacity-free store holding resolved `[Secret]`s for the current run. Clears at the run boundary (◈W2f). Decoupling it from inventory closes every loss path at once and unblocks storeys from the undesigned `[Inventory]` system. | W · 5.8a |
| **[Relic]** | *provisional, 0.12.0.* **The physical, collectible form of a `[Progression Key]`**, inheriting its semantics and adding: item form, the resolution verb *collected*, a pending carried state, loss and same-Location re-placement on collapse, commitment by reaching town, and `[Incursion]` gating. An item carried out of a Location by the verb *collected*. Unlocks **access only** — never Grounding, `[Modification Ceiling]`, floor budget or stats (W-C15). Lost on collapse, re-placed same-Location at its authored band, secured by reaching town. | W · 5.9 |
| **[Incursion]** | *provisional, 0.12.0.* A dungeon belonging to no Location, gated by a `[Relic]`. Unrestricted depth, no progression, item level saturating at the best Location-obtainable tier. | W · 5.9 |
| **Progression placement** | *Unbracketed, provisional 0.12.0; amended 0.33.0.* W§13 Stage 5a — the dungeon-scope reservation pass that reserves every **`[Progression Site]`** before tiling. It reserves *sites*, not only objects: a persistent `Discovery` need not be an object, and a site need not host one. | W · 13 |
| **[Progression Site]** | *provisional, 0.12.0; narrowed 0.33.0.* **A protected spatial reservation or physical realisation** used by progression placement. It may host or realise a `[Secret]`, a `[Progression Key]`, a descent unlock, a boss obligation, a teaching event or another declared progression output. **It is neither the logical discovery nor the authored effect, and it need not be an object.** *It claimed to be the general class of progression objects until 0.33.0; that class is `Discovery`.* | W · 13 |
| **Discovery** | *Unbracketed, 0.33.0.* The semantic class of mission-authored discoveries participating in progression. **Not necessarily hidden, physical or spatial** — the two classes are distinguished by persistence and effect, never by visibility. Two members: `[Secret]` and `[Progression Key]`. | W · 10.0a |
| **[Progression Key]** | *0.33.0.* A **persistent** `Discovery`. After its defined commit condition it writes an **idempotent** persistent progression fact unlocking authored access. Placement alone unlocks nothing. `[Relic]` is its physical carried form; other forms — tome, clue, sigil, witnessed event, mapped route — remain **deferred placeholders, not locked**. | W · 10.0a |
| **[Inventory]** | *deferred, 0.12.0.* **Named, not designed.** No document owns the container model (◇M9). Recorded so the gap is visible rather than assumed filled. | — |
| **[Stratum]** (pl. **[Strata]**) | A band of 10 Delve levels, bounded by an escalating boss at 3, 9 and 10. | W · 5.1 |
| **[Instinct Wilds]** / **[Pressure Marches]** / **[Discipline Holds]** | The launch Territories, one declaring each Triade axis. Nothing in schema encodes the number three. | W · 4.1 |
| **[World Steward]** | Human-only owner of world grammar, Territory schema, axis taxonomy and surface vocabulary. Mirrors the Triade Steward rule. | W · 17.1 |
| **Tile substrate** | The fine authoring/visual/nav grid that bakes into zone properties; never seen by the simulation core. | W · 9 |
| **Zone extraction** | Deterministic segmentation collapsing tiles into a 2–4 zone combat overlay. The bridge between tile world and Triade combat. | W · 12 |
| **[Generator Version]** | Append-only tag paired with a seed; old generators retained so old seeds reproduce byte-identically. | W · 7.3 |
| **Surface channel** | One of the bounded integer environmental state channels on a tile or object face. **Emits temporary stat modifiers on effective fields** — so it participates in the Trauma Safety Clamp sum. | W · 11.1 · H · 10.2 |
| **Named reaction** | Player-facing result of a channel combination; fixed lookup, never emergent. | W · 11.2 |
| **Delta over seed** | Persistence pattern storing `(seed, version)` plus mutation deltas, never full maps. | W · 18.1 |
| **Semantic placement** | Rule-based furnishing by room-type grammar, path-guarded. | W · 10.2 |
| **Collapse** | Failure at a boss, or death in the unprotected span, reverting to the last purchased checkpoint. Costs Delve access, unspent `[Imprint]`, and the [Modification Ceiling] earned within the collapsed Stratum. | W · 5.5 |

---

## 10. Validation, traces & agentic development

| Term | Definition | Ref |
| --- | --- | --- |
| **Trace** | The per-action record of a combat. The behavioural fingerprint everything is validated against. | T · I.1 |
| **Signature** | A trace aggregated across the fixture set into a fixed-length vector. | T · I.2 |
| **Residency histogram** | 36-cell discretisation of the simplex. Compared with Earth Mover's Distance. **Also the live check that the Trauma Safety Clamp is working** — residency must stay non-zero in every region under injury. | T · I.2 · H · 14 |
| **Redundancy gate** | A candidate must exceed a trace-distance threshold from existing entities or is auto-rejected. | T · I.4 · M · 5.3 |
| **Coverage map** | 2D projection of signatures showing clusters and voids; voids become machine-specified content briefs. | T · I.4 |
| **Expressive Range Analysis (ERA)** | Sampling a generator over metric pairs and feeding the *voids* to agents as briefs. Core loop under run-structure, not advanced tuning. | W · 16.5 |
| **Named brake requirement** | T·I.5: every reinforcing loop must carry a named brake. *Injured → weaker → more injured* is such a loop; H·10.1 supplies four. | T · I.5 · H · 10.1 |
| **Reference builds / encounters / fixtures** | The frozen set everything is measured against. | M · 4 |
| **Agent roster** | The named agents (Schema Steward, Triade Steward, Weapon Smith, Affix Librarian, Bestiary Composer, Location Smith, Dungeon Smith, Tile Smith, Furnisher, Surface Smith, Zone Auditor, Map Proofing Auditor, Balance Auditor, etc.). | M · 5.2 · W · 17.1 |
| **Triade Steward** | Human-only owner of the action contract schema, archetype library and region geometry. No agent may alter these. | M · 5.2 |
| **Severity scheme** | The set-wide validation grading — **Critical** (locked invariant; blocks merge), **High** (design goal; overridable with recorded justification), **Medium** (quality; warn). IDs take the form `{DOC}-{C\|H\|M}{n}`. Unified at 0.11.0 from three incompatible schemes. | Validation Rules Index |
| **`[OPEN]`** | Marker on any unresolved design question. Every occurrence is mirrored in the Open Items Index, which is generated from these markers. | Open Items Index |
| **`[SIM]`** | Marker on any provisional numeric value pending the simulation harness. Every occurrence is mirrored in the SIM Numbers Register with its basis, gate and failure path. | SIM Numbers Register |
| **`[GAP]`** | Marker for a concern **no document owns** — a missing system rather than an open question within one. Currently: the economy and audio. | Open Items Index |
| **Derived index** | A document generated from markers in the design set rather than authored. Editing the index instead of the source is a defect. Three exist: Open Items, SIM Numbers, Validation Rules. | — |

---

### 10A. Intake vocabulary [LOCKED 0.20.0 · extended 0.21.0]

| Term | Definition | Home |
| --- | --- | --- |
| **Intake record** | A tracked working document in `Documentation\` recording what an outside stream — technical implementation, third-party report, reconciliation — proposed, and what became of each item. A subtype of the reconciliation record, on the same lifecycle: it retires to `Research\` only when every item is disposed | Design-stream instructions |
| **Disposition** | The per-item outcome in an intake record. Exactly one of five values, and `authored` names a receiving document and section (**P-H5**) | Design-stream instructions |
| **`authored`** | Written into a design document, with the ID minted **there**. The index derives an ID; it never issues one | — |
| **`enforced-elsewhere`** | The rule already exists under another ID. Cite it; do not mint a duplicate | — |
| **`backlog`** | Accepted but not implemented now. Enters as a `◇` open item in a **named** home document, so it stays visible to every sweep. *Not* `deferred` — that word is taken twice, by L·11 and by the Open Items Index's blocking category | — |
| **`struck`** | Rejected or superseded, with the reason written in the record | — |
| **`unresolved`** | Home, ruling or reconciliation still unsettled. Blocks retirement. An `AUTHORED DESIGN DECISION` parked here stays non-authoritative while the stream keeps implementing against it | — |
| **`FINDING`** | Intake item **type**: a defect, gap or consequence observed while implementing. A proposal, nothing more | Technical-stream instructions |
| **`AUTHORED DESIGN DECISION`** | Intake item **type**: the technical stream resolved a design question because implementation could not proceed without it. A **working decision** — legal to implement against, non-authoritative until disposed `authored` (**P-C10**) | Technical-stream instructions |
| **Authored-but-not-yet-centralised** | How a technical document must label an `AUTHORED DESIGN DECISION` before centralisation. Never *rule*, never *locked* | **P-C10** |
| **Counter-patch** | A tracked record issued by the **central process** requesting a change to the technical-stream instructions, which the central process may not edit directly. The mirror of an intake record | Design-stream instructions |

**Why this vocabulary is locked.** `L-M1` and `L-M2` were accepted during a technical implementation stream and left for "a centralised process" that did not exist. They lived in a document with no design authority for eight versions while the index carried IDs for them. `backlog` is the state that had no name.

---

### 9A1. Weight classes [LOCKED 0.24.0 · mechanism corrected 0.25.0]

Four. Locked in M·2A.7.

| Class | Engages | Identity |
| --- | --- | --- |
| **Heavy** | damps incoming **[EDM]** force | *immovable* |
| **Medium** | adds a second, shallower well at the **barycentre** | *all-rounder* — every region reachable, none reachable deeply |
| **Light** | strengthens the **home-well** pull toward the class's own centroid | *recoverer* |
| **Cloth** | none, but zero encumbrance | *striker* |

**The home-well and the barycentre are different points.** Home is the centroid of the class's *reachable region*, shifted toward the class's dominant corner (T·A4). The barycentre is the geometric centre. Light pulls to the first, Medium to the second.

**`[Dot Dynamics]` is engaged by no armour class**, deliberately — it stays with actions (K·17).

**`medium` was a value in use before it was a class.** M·2A.11 assigned it to the Standard shield while 2A.7 defined only three classes — an undefined value in use from 0.9.0 until `◈M11` closed at 0.24.0.

---

## 11. Deferred / provisional terms

| Term | State | Ref |
| --- | --- | --- |
| **[Dot Dynamics]** as common inertia | Provisional — opt-in only until the level-2 dot discussion settles. | T · A2.2 |
| **Non-linear influence interaction** | Deferred to level-2 dot discussion. | T · A2.5 |
| **Grid–math interaction** | *Resolved:* scaling reads continuous position; gating may read cells; grid is the authoring/display language. Skill Anchors earn the exception. Latched cell effects rejected. | T · A3.5 · A3.7 |
| **[Dot Interpreter] functions** | *Resolved:* two-channel (ambient + log), Dictionary-composed, UI-inspection stack. Remaining is content (writing the Dictionary) and UI-inspection detail. | T · A3.4 |
| **Stat count & names** | *Resolved:* nine stats, three per corner (capacity/application/resilience). Superset; scalable to six later. | T · A4.1 |
| **Dynamic Composure** | Base parametric sizing locked; the pressure-driven shrink is opt-in and later. | T · A3.6 · K13 |
| **[Back-foot] / [Advantage] as readouts** | Open fork: keep as first-class relational states, or re-derive from net dot-influence. | K · 10 |
| **Position persistence out of combat** | Open: reset / decay-to-home / persist-until-rest. A primary pacing lever. | K · 1 |
| **Level 2 dot enhancement** | The second complexity level of the dot mechanic, not yet shared. | — |
| **◈W2f propagation** | The run-boundary clear must be written into T·A4.2a, not held only in W. **Outstanding.** | W · 19 |
| **◇H11 — Flux reserved word** | Declare *Flux* a currency only, never a field quantity, before it surfaces in field discussion. | H · 17 |
| **◇H12 — Marks / landmark proximity** | *Landmark* is locked twice and `[Pressure Marches]` is a Territory name. Substring and near-rhyme, not homonym — judged acceptable, recorded so it is not rediscovered. | H · 17 |
| **◇H13 — Scrap ↔ Flux conversion** | Independent sinks or convertible? Does dismantling yield both? | H · 17 |
| **◇H14 — town screen currency load** | Marks, Scrap, Flux, Temper and `[Imprint]` are all spendable at town — five simultaneous resources against M·0.10's readability budget. | H · 17 |
| **Prosthetic / regrow / rite economy** | Named but not designed. `converts_to_scar` ships `false`; the economy hanging off it is a separate workstream. | ⦻H4 |
| **Infection / disease** | Deferred. Additive layer, not a prerequisite. | ⦻H5 |
| **Slot count `N`** for [Territory Vocabulary] | Fixed constant, not a progression track. Value pending sim. | W · 19 |

---

## 12. Maintenance rules [AUTHORED 0.20.0]

The two rules that keep this document true. **Both were indexed from 0.11.0 and authored nowhere** — stated only in `Z-Design_Stream_Project_Instructions_TRIADE-0_44_0.md`, which holds no design authority and therefore cannot originate a rule. That is why a Lexicon check could return clean while `category` sat locked and unlisted for seven versions.

| ID | Severity | Rule |
| --- | --- | --- |
| **L-M1** | Medium | Every locked term in any document appears in this Lexicon, entered in the **same pass** as the lock. A term locked without an entry poisons every subsequent grep against it |
| **L-M2** | Medium | No term shadows a locked term from another domain. Check by grep against the whole set **before** proposing, not after |

**Both are checks, not habits.** The obligation to run them lives in `Z-Design_Stream_Project_Instructions_TRIADE-0_44_0.md` as working practice and carries no ID there; the rule lives here and is enforced by the linter. Conflating the two is what produced eight versions of apparent authorship.

---

## Changelog

| Version | Change |
| --- | --- |
| **0.44.0** | **P12-C vocabulary locked.** Resolution participant distinguishes selected target, route contact, effect recipient and reaction product. Plannable Action and its three acquisition modes enter as autonomous due-node terms, not AP reserve or target fallback. |
| **0.43.0** | **P12-B vocabulary locked.** Faculty lifecycle ends at possession; Technique readiness distinguishes `known`, `selectable` and `executable`. Execution candidate and target-route contract enter as locked terms, including existential alternatives and conjunctive within-candidate requirements. |
| **0.42.0** | Faculty lifecycle distinguishes authoritative acquisition from derived possession and availability. Composite Faculty profiles are authorization profiles rather than separate entitlements; acquisition normally survives unlock-source loss unless explicitly leased or revocable. |
| **0.41.0** | Faculty hooks corrected to voice, selected fingers, Brain and selected bound node. Faculty lifecycle now records explicit Lineage confer-or-unlock modes; Faculty profile and Faculty pull signature enter as locked terms. |
| **0.40.0** | `[Somatic]` and Faculty lifecycle entered. `faculty` now separates authorization from physical source; cooldowns gain explicit base, rendition, Faculty and provider scopes. |
| **0.39.0** | **Aimed mode** entered: Technique-owned eligibility, K-owned surcharge timing, H-owned placement and E-owned acting-tier access. |
| **0.38.0** | **Territory** and **Territory capitalisation** authored in §9D. `[Region Vocabulary]` → `[Territory Vocabulary]`, its Triade anchor preserved. 6 renames. **Session A vocabulary:** Technique archetype, Payload module, Source instance, Derived skill rendition, Carrier contract, Delivery proof and Layer trace. |
| **0.33.0** | **`Deck tile` and `deck` entered** beside `[Deck]` (L-M1), separating world topology, tile structure and environmental state into three namespaces that had been sharing one word. **`Redistribution target` entered**; `Redistribution` and `Weapon requirement` repointed off `focus`. `damage_focus` rejected — qualification does not legalise a second meaning. **`Discovery` and `[Progression Key]` entered; `[Secret]`, `[Relic]` and `[Progression Site]` retyped** (L-M1). `[Relic]` becomes the physical carried **form** of a `[Progression Key]`, keeping every §5.9 rule. **`[Progression Site]` narrowed** — it claimed to be the general class of progression objects; that class is `Discovery`, and a site is a spatial reservation or realisation that need not be an object. **Corrective pass.** `Progression placement` amended — it reserves **sites**, not only objects, since a persistent `Discovery` need not be one. |
| **0.32.0** | **`[Innate]` re-entered as lineage-owned**, not a faculty; `faculty` narrowed to three learned-or-granted families (L-M1). |
| **0.31.0** | **Two entries added — `Martial priority` and `Tile class`** (rule L-M1). `tile class` had been in use in G since the 0.16.0 rename off `Category` with no Lexicon entry — the `category` failure, repeated and now closed. |
| **0.30.0** | **`Physique` entry repaired** — it cited `[Medium size]`, struck at 0.27.0, for three versions. The rename reached E and stopped there. |
| **0.29.0** | **`Off-hand form` added**; `Shield budget`, `Defence pip` and `Split position` amended to the authored 2-pip split (L-M1). |
| **0.28.0** | **Two entries added — `Defence pip` and `Split position`** (rule L-M1); `Shield budget` amended to carry its size. Both new terms checked against the whole set for collisions (L-M2) before naming. |
| **0.27.0** | **Lineage**, **Typical** and **Size ladder** locked; `[Chassis]` amended to state it is the same record as the lineage. *Typical*, never *standard* — that word is enemy Tier 2 and the shield sub-family. Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | §9A1 corrected, with the home-well/barycentre distinction stated — they are different points. Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | **§9A1 Weight classes locked** — four classes, one per component of the A2.2 model. Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | **§10A extended** — `unresolved`, `FINDING`, `AUTHORED DESIGN DECISION`, *authored-but-not-yet-centralised*, *counter-patch*. Five terms, entered in the same pass as the lock. The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | **§12 Maintenance rules authored** — `L-M1` and `L-M2` finally live in the document they govern, after eight versions indexed and authored nowhere. **§10A Intake vocabulary locked** — six terms including `backlog`, the state that had no name. Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | **§0 rebuilt as the Glyph index** — six identifier glyphs and a fifteen-row notation table covering every non-ASCII symbol in the set. States that `—` in a table cell means *not applicable*, never *unknown*. Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | **§0 Identifier glyphs added [LOCKED 0.18.0]** — five locked terms entered in the same pass, per L-M1. Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **37 glyphed identifiers in this document.** |
| **0.17.0** | **One entry added — `Handedness`** (rule L-M1), under Materiel beside *Shield budget*. It is a locked mechanical quantity as of M·2A.9: one-handed = 3 base pips, two-handed = 4, fixing the total and not the distribution, with shields excluded to the pooled shield budget. The `1h-` / `2h-` type qualifier is recorded with it, and its negative stated — **not a slot, not an occupancy count, not a delivery hook**, the three quantities M and P keep separate. **L-M2 run before naming:** `handedness` already appeared once in the corpus, in M·2.x's chassis-layer row, in exactly this sense — an extension, not a collision. `1h-` and `2h-` returned no prior use anywhere in the set. |
| **0.16.0** | **Four entries added, three of them overdue.** **`category`** — locked in M·2.1 since 0.9.0 and never propagated here, so every L-M2 grep for the word had been returning a false negative; the `[Location Grounding]` failure in a second form. **`shield`** as its seventh value. **`remedy_type`**, the H·8.4 rename that resolves a collision with it. **Enemy Tag**, the E·F.1 rename that resolves a third sense. *Tag composition* corrected — `faculty` had been missing since 0.13.0. **Nine stale `T · F.n` refs repointed to `E · F.n`**: the capability ladder moved to E at 0.11.0 and only the ladder's own row recorded it. Ref-letter convention list gained **E, G, P**; document counts and the footer corrected. |
| **0.12.0** | **Vertical vocabulary added** — `[Deck]`, `[Storey]`, `[Vertical Portal]`. *Floor* confirmed reserved to its Triade barycentric sense (103 uses in T, 39 in W, none geometric) and struck from geometry naming; `[Walk Surface]` and `[Dungeon Floor]` rejected as collisions. Progression vocabulary added — `[Secret]`, `[Switch]`, `[Relic]`, `[Incursion]`, `[Progression Site]`, run-scoped key register, progression placement. *Lever* confirmed reserved to K-C8's tempo sense; `[Switch]` adopted instead. `[Inventory]` recorded as **deferred — named, not designed**. Document set grows to **nine** with the Tile Pipeline (**G**). |
| **0.14.0** | Four entries — `[Band-End Portal]`, the band C exemption, the storey pacing unit, and the career power multiple. `portal` becomes a **category**: two kinds, both authored traversal edges, both always qualified. `C1/C2/C3` was proposed for structural complexity and **rejected** — 81 bare tokens already in the corpus and every document carries `X-C1`/`C2`/`C3` rule IDs; `N` is already locked in W·5.8 and needed no synonym. |
| **0.13.0** *(Stage 1)* | Thirteen entries added — `faculty`, `[Attunement]`, `[Innate]`, `[Arcana]`, `[Mudra]`, `[Psyche]`, delivery hook, `[Ward]`, occult load, Divine purge, martial profile, Trace Signature, `aim_weight`. Three L-M2 resolutions recorded: `capability` returned undivided to the ladder; `signature` freed for `[Signature Action]` by renaming its two other senses; `focus` freed for the Mind side by renaming the Stage 0 aim term. |
| **0.13.0** | **Stage 0 terms.** `[Chassis]` amended — universal across players and enemies, names the body template, enemy-only floor shape. New entries: **Corner-floor render affinity** (rule T-C11), **Coverage weight** (relative, per-pair), **Aim / focus**. **Body template** amended to record that it is referenced by chassis, never inlined. ◈W2d struck from the deferred list — closed in W and stated in T. |
| **0.11.0** | **Enemies extracted to `E`** — the capability ladder, tag composition and behaviour-as-AI move from T·Part F to their own document; `F.n` numbering retained so cross-references stay valid. Document set grows to **eight**, plus three derived indexes. `[OPEN]`, `[SIM]` and `[GAP]` markers standardised across all documents. Validation severity scheme unified onto Critical/High/Medium with `{DOC}-{C&#124;H&#124;M}{n}` IDs, extending H's notation set-wide. Two Lexicon propagation rules added (L-M1, L-M2). Nine stale open questions cleared from T and M. |
| **0.10.0** | **Damage & Health document created** (`H-Damage_Health_design_TRIADE-0_44_0.md`) — new section 9C. **World terms propagated** from W§21 — new section 9D. Filename convention standardised to `TRIADE-[System] design-[Version]`; document set grows to seven. §2 renamed "The credit economy" → "The economy" and extended with **Marks / Scrap / Flux / [Imprint]**. `[Location Grounding]` **unbracketed** to design-model status, resolving ◈W5 and ◈W6. UI requirements 7 → 8. Two failure modes rule re-scoped to V·4.1 (skill bar), clarifying it does not constrain the posture display. |
| **0.9.0** | Combat Design document created. New section 9B. Adds: Finisher win condition, relational readiness, three symmetric tempo levers, AP-as-elapsed-time, zone graph, glancing rule, Pivot, and the Watch/Riposte reaction system. |
| **0.8.0** | UI requirements moved to the new Visual Design doc; A3.4c is now a pointer. Document-set note added. |
| **0.7.x** | Skill Anchors (A3.7–A3.8); demand tier split from Doctrinal/Transgressive flags; UI requirements; Weapon/Armour/Shield Smith agent specs; shield budget. |
| **0.6.x** | Materiel system: damage taxonomy with Structural group, integrity states, the three bridges, pips and redistribution, shield duality. |
| **0.5.x** | Dot Framework, grid + Dot Interpreter, stat-groups and field-rendered floor, skill level model, class system, Dictionary and tone. |

---

*End of Lexicon 0.44.0. Maintained alongside the Core Mechanic, Stats/Items/Equipment, Visual, Combat, World Generation, Damage & Health, Enemies, Tile Pipeline and Content Pipeline documents.*
