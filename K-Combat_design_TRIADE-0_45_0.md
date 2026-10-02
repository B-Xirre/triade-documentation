# Combat Design

**Version 0.45.0** — 2 October 2026. Turn structure, action economy, resolution, reactions, and the player-facing exchange loop.

**Document set:** this is one of **ten**.

| Ref | Document | Filename |
| --- | --- | --- |
| **T** | Core Mechanic | `T-Core_Mechanic_design_TRIADE-0_45_0.md` |
| **M** | Stats, Items, Equipment | `M-Stats_Items_Equipment_design_TRIADE-0_45_0.md` |
| **L** | Lexicon | `L-Lexicon_design_TRIADE-0_45_0.md` |
| **V** | Visual Design | `V-Visual_design_TRIADE-0_45_0.md` |
| **K** | **Combat Design** — *this document* | `K-Combat_design_TRIADE-0_45_0.md` |
| **W** | World, Maps & Dungeons | `W-World_Generation_design_TRIADE-0_45_0.md` |
| **H** | Damage & Health | `H-Damage_Health_design_TRIADE-0_45_0.md` |
| **E** | Enemies & Bestiary | `E-Enemies_design_TRIADE-0_45_0.md` |
| **G** | Tile Pipeline | `G-Tile_Pipeline_design_TRIADE-0_45_0.md` |
| **P** | **Content Pipeline & Data Model** | `P-Content_Pipeline_design_TRIADE-0_45_0.md` |
| — | *Open Items Index* | `B-Open_Items_Index_TRIADE-0_45_0.md` |
| — | *SIM Numbers Register* | `Y-SIM_Numbers_Register_TRIADE-0_45_0.md` |
| — | *Validation Rules Index* | `R-Validation_Rules_Index_TRIADE-0_45_0.md` |

**Scope boundary.** The Triade doc owns the state model, regions, credit economy and skill anchors. This document owns everything that turns those into turn-by-turn play: time, AP, resolution order, reactions, the battlefield, and encounter rhythm.

---

## Part 1 — Design thesis

Triade combat is an **exchange-control game**, not a damage race with a stance minigame attached. Damage is the eventual consequence of manipulating your own bearing, the opponent's bearing, temporary vulnerabilities, positional commitment, equipment integrity, and the timing economy of Edge and Grit.

The recurring player question is: *do I stabilise, create an Opening, traverse to read it, or commit to the finishing exchange?*

```
Displace or provoke  →  [Opening]  →  Read at the right time  →  Edge
     →  Claim the Opening  →  [Advantage against X]
     →  Advantage action succeeds  →  Grit + target [Back-foot]
```

**Design target:** traversing this chain must out-perform repeating the largest available attack — *without* making ordinary attacks useless.

**How that tension resolves — the enemy capability ladder.** Ordinary attacks and the loop are not competing for the same job:

| Tier | Correct tool |
| --- | --- |
| **Trash** | ordinary attacks suffice; no loop needed or rewarded |
| **Standard** | ordinary attacks plus positional care |
| **Elite / Commander** | the full exchange chain is the reliable route |

This prevents the failure mode where every kill demands a five-step causal chain and trash fights become tedious. Against Elites, ordinary attacks remain the raw material the loop consumes — they generate the pressure that forces movement and strip integrity.

**The four locked constraints that give the thesis friction** (from the Triade doc, restated because combat design must respect them):

- **Traversal requirement (C.4)** — create and read happen in *different regions*; the dot occupies one at a time. The loop cannot be run from a single stance.
- **Exposure** — distance from home arms enemy Advantage actions. Commitment is what makes you vulnerable.
- **Ejection (A4.7)** — firing above your staying floor throws you out of the region.
- **Position-dependent checks (C.6)** — success scales on position.

---

## Part 2 — Win condition

**Primary: HP depletion.** Ordinary and expected.

**Secondary: the Finisher** — a decisive termination of the exchange chain, available only under earned conditions.

This fills a real gap: the exchange chain currently *terminates* in [Back-foot], a state that makes the next exchange easier but resolves nothing. The Finisher gives the chain a terminal payoff.

**The Finisher threshold is also the gate on anatomical lethality (H·9.4).** A vital-organ hit is lethal *only* when the target is already below that threshold or is Downed; otherwise it converts to a Critical wound plus a deep [Opening]. This keeps HP primary as this Part requires, and stops anatomy becoming a silent instant-kill lottery running beside the win condition.

**Conditions, built only from locked machinery** — the target is:

- **Fractured** or **Broken Guard** (integrity, 2A.6), **and**
- **[Back-footed against you]** (C.3a)

Both are earned through the loop; neither is a new resource. This finally gives the Structural damage track a decisive purpose *without* becoming the parallel kill-race explicitly rejected in 2A.11.

**Form: a scaled execute, not an instant kill.** Available below an HP threshold rather than at any HP. This keeps HP meaningful (so the primary win condition doesn't become vestigial against Elites) while making the loop the *efficient* route to a kill. Threshold to be set in simulation.

*Precedent:* Octopath's Break and Sekiro's posture both work because stripping the defensive resource is a **different job** from dealing HP damage, and the payoff is decisive. Our integrity system already has that shape; the Finisher supplies the payoff.

---

## Part 3 — Time, initiative and AP

### 3.1 Round structure

Combat runs on the **Tactical Timeline** — a player-facing projection of the authoritative `world_tick` queue, not a second clock [ADOPTED 0.34.0, CR-11]. **The one-activation-per-round rule is retired.** A 60-tick band is a **cadence and refresh boundary, not an AP grant**, and it no longer contains one uninterrupted activation per actor. Actions may cross a boundary because time is continuous. Combat pauses whenever player input is required; planning does not advance `world_tick`. Readiness is recalculated at round boundaries only, and the next round's order displayed — recalculating mid-round would make the initiative display churn during an activation.

**Readiness is ordinal, not magnitudinal — and the reason changed at 0.34.0.** It was justified by the one-activation cap, which is now retired. The replacement is stronger: **Readiness is never converted into ticks or into rate.** It orders initial decision nodes and breaks same-tick ties among actors and reactions; it never alters `due_tick`, action duration, AP rate or the number of decision nodes. **Its effect saturates at first position among otherwise simultaneous eligible nodes**, so it cannot manufacture action frequency and cannot snowball. It is snapshotted at combat start and recomputed at each 60-tick boundary — a change mid-band lands in the next snapshot. Advance, Delay, Haste and Slow manipulate timeline state directly and are **not** disguised Readiness effects. Formerly readiness determines *sort order* only. There is no "more than first." This is load-bearing: it means the relational term below **cannot snowball**, because its output saturates at the top of the queue. No cap is required.

### 3.2 Readiness — intrinsic plus relational

```
readiness = intrinsic + relational

intrinsic  = base + Finesse + Momentum lean + weapon recovery + conditions
relational = Σ([Back-foot] you hold) − Σ([Back-foot] held against you)
```

**Why relational.** Every other combat state in this design is a directional edge in the combat graph ([Opening], [Advantage], [Back-foot]). Initiative being computed in a vacuum was the one inconsistency. And in an exchange-control game, *having the initiative* is definitionally relational — it means the opponent is responding to you.

**Consequence worth having:** turn order becomes a **readout of who is winning the exchange**. A player landing the loop sees themselves rise in the order. The exchange thesis made visible with no new display.

**Only [Back-foot] contributes** — not [Opening] or [Advantage]. Back-foot is the state that specifically means *compromised in the exchange*; the others are opportunities, not tempo positions. Including them would make the term noisy.

**Momentum stays intrinsic** alongside the relational term. Intrinsic speed (you are fast) and relational initiative (you are winning) are different things; keeping both means a fast character who is losing still acts reasonably early.

**Brakes on the reinforcing loop** (required by I.5):

- [Back-foot] **self-clears** on a successful action against its imposer (C.3a) — the compromised party's own success breaks the cycle.
- Readiness is **ordinal**, so the effect saturates.
- **Form's tempo lever** (K·3.3) structurally resists tempo-starvation.

**Outnumbered case.** The relational sum naturally goes negative when outnumbered — correct and thematic. The design already compensates: **[Context] credit accrues from being outnumbered** (B.1). Tempo lost, run-scale resource gained. These were designed independently and balance.

### 3.3 The three tempo levers — one per corner

Each corner has exactly **one** tempo relationship. None compounds with itself.

| Corner | Lever | Reads as |
| --- | --- | --- |
| **Momentum** | readiness → act **earlier** in the round | *when* you act |
| **Mind** | effective AP cost — and therefore action **duration** | *how much* you do in a given span |
| **Form** | the **minimum AP-rate floor**; resists [Back-foot]'s AP tax. A floor is a clamp, **not a rate contribution** | *you cannot be slowed past a point* |

*Form's AP-**rate** floor is also the second of four named brakes against the injury spiral (H·10.1) — wound AP taxes cannot reduce a turn to nothing.*

**Why symmetric.** Previously Momentum held two tempo levers (readiness *and* physical cost discount), Mind held one, Form held none — Momentum was strictly the better tempo corner for reasons unrelated to playstyle. Tempo is *generically* useful (more actions means more of everything) while Form's mitigation and Mind's control are *situationally* useful, so an asymmetry here distorts stance choice globally.

**Form's lever is the tempo-starvation brake.** A Form-leaning character retains their activation even while losing the exchange — which is what makes the relational readiness model safe, and what the §K7 Recenter/Guard tools exist to guarantee.

**Locked from Part H, restated at 0.34.0 as rate coupling (K-C12):** **no corner contributes an additive or multiplicative term to AP *rate*.** Form's floor is a clamp, not a contribution, and only authored effects such as Haste/Slow move `current_AP_rate` within 2–6. *The former wording permitted one corner to modify a pool that no longer exists.* All three levers above modify cost, order or floor.

### 3.4 AP as action-time rate

**AP is no longer a resource. It is a rate** [ADOPTED 0.34.0, CR-11]. It remains the authored action-cost unit, but nothing is spent, banked or replenished:

```
action_duration_ticks = effective_AP_cost × (60 / current_AP_rate)
```

| | |
| --- | --- |
| Base rate | **4 AP / 60 ticks** |
| Legal band | **2–6 AP / 60 ticks** |
| Effective cost | an integer, **rounded once** and clamped to **at least 1** |
| Tick granularity | every legal rate divides 60 exactly — 30, 20, 15, 12, 10 ticks per AP — so **no action needs a fractional tick** |

**Aimed mode is an action-cost transform, not a second action.** When a Technique permits it and the actor selects it, a non-negative aim surcharge enters `effective_AP_cost` before the single rounding/clamp and before commit. The exact surcharge curve by requested granularity and combat context is [SIM: **S-K09**]; until that gate settles, no content may assume a zero-cost called shot. A committed surcharge is not refunded when the hit lands on a different node.

**"Unused AP is lost" is retired and replaced by something stronger: there is no AP balance to bank, lose or carry.** The old rule existed to stop a player pre-loading a whole create→read→convert chain; a rate cannot be pre-loaded at all, so the exploit is closed by construction rather than by prohibition.

### 3.5 Timeline nodes and milestones [ADOPTED 0.35.0, CR-11]

**Every time-bearing action defines `commit_tick`, zero or more `milestone_nodes`, `resolve_tick`, and optionally `recovery_tick`.** The default effect lands at **resolution**; start, launch, travel, channel, pulse and recovery effects must be **explicitly authored** — nothing is implied by an action merely having duration.

| Action shape | Milestones |
| --- | --- |
| Movement | timestamped **cell-arrival** milestones |
| Projectile | launch and impact **separated** |
| Channelled | several pulse nodes |
| Thrown bomb | releases or impacts at its authored milestone — **it does not implicitly occupy the release cell at action start** |

**Environmental events evaluate the actor's authoritative position and state at their exact tick.** So mid-action movement is neither ignored nor resolved as teleportation — the two failure modes a duration model invites, named because both look reasonable from inside the code.

**Intent Markers show committed, perceived enemy action** — acting enemy, prepared action, target cell or path or area, intent span and resolve tick, interruptibility, visible conditional branches. They **supplement** posture, animation and world-space telegraphs rather than replacing them; V·4.8's posture stays the world-space capability telegraph.

**A normal enemy cannot silently change a committed intent.** Invalid targets take the action's authored failure behaviour, and only a **Reactive** enemy may use an explicitly *displayed* conditional branch. **Unseen enemies, undiscovered traps, concealed information and uncommitted AI choices are never revealed** — and AI evaluates from its own perceived state, so the player-facing timeline grants bots nothing (**W-H17**).

**The Ghost Track previews by running the authoritative resolver against a temporary state copy** — not a parallel estimator, which would drift from the real one. Forecast is classified as **Solid** (deterministic from committed and perceived state), **Conditional** (dependent on a roll, reaction window, Reactive intent or conditional geometry), or **Unknown** (prevented by FOW, concealment or an uncommitted decision).

**It never reveals a future random result or hidden state.** Where exact resolution is unknowable it previews **branches or ranges**, and it forecasts over a bounded horizon — normally the next decision or the visible round window, with multi-round zoom for slow hazards rather than simulation of the dormant world.

### 3.4a Former AP pool — retired

```
Base AP:        4
Minimum AP:     2      (guaranteed floor — a bad stance never means a skipped turn)
Normal maximum: 6
```

```
effective_cost = base_cost
               × stance_cost_modifier
               × clumsiness_modifier
               × Back-foot_modifier
               × condition_modifier
```

Rounded once, clamped to at least 1 AP.

**Stance modifiers read lean *relative to home*, not absolute coordinate.** `mental modifier reads: i − Hi`. This prevents naturally Mind-oriented classes from receiving a permanent, effortless discount they did not earn — consistent with how exposure already works.

**[Back-foot]** normally adds 1 AP to actions against the relevant attacker plus a modest check penalty. It does **not** stack against the same attacker.

**No carryover.** Unused AP is lost. Generous carryover would let a player pre-load an entire create→read→convert loop into one activation and skip the traversal that defines the game. *(Divinity: Original Sin 2's 2-AP carryover is widely reported by players as producing "pooling rather than planning" — the failure to avoid.)*

### 3.5 AP as elapsed time

Variable action costs create a bug: sustained CDM/EDM forces would integrate a different number of times depending on whether an actor took one expensive action or three cheap ones. **Action economy and the Dot Framework would be quietly incompatible.**

Resolve by treating AP as elapsed combat time:

```
dt = effective_AP_cost × (60 / current_AP_rate)   // ticks; there is no pool
```

After an action: apply its impulse at full strength → integrate active CDM, EDM and home-well forces × `dt` → clamp to the legal floor-well.

**Passing** commits an authored recovery interval on the timeline — there is no remaining AP to consume — letting the home-well and active forces resolve over that time. One influence pipeline, mathematically compatible with the action economy.

---

## Part 4 — Physical battlefield

**Locked: a sparse zone graph. No square or hex grid.**

Each room contains two to four named zones connected by simple adjacency.

**Two to four, with no exception** [CONFIRMED 0.12.0]. W's `complex_room` flag exempts an authored room from the **2-zone floor only, never the 4-zone ceiling** (W§12, position A2). K's substrate is therefore uniform: no room anywhere in the game presents more than four zones. What an authored set-piece gains is zone *identity*, not zone *quantity* — four named zones with authored meaning beat six generic ones in a fight whose core skill is posture-reading.

**Vertical rooms consume the same budget.** A room with two `[Deck]`s spends two of its zones on deck separation, because a zone cannot span decks — the zone record carries a scalar `elevation_band` (W-C19). Decks are joined by a `[Vertical Portal]`, which supplies an **adjacency edge and a movement cost**, never a zone of its own. A stair landing belongs to whichever deck's zone it sits on; if it carries tactical meaning it is a chokepoint, and chokepoint seeding already handles it.

```
Raised Gallery ── Broken Walkway
      │                 │
  Courtyard ────── Muddy Gate
```

```
Zone
- adjacent_zones[]
- elevation
- cover
- capacity
- environmental influences[]
- advantage_rules[]
```

Actions specify range as **zero, one or two zone transitions** — never metres or tiles.

**The physical layer provides exactly four things:** target access; movement cost (usually 1–2 AP); circumstantial [Advantage] (high ground, flank, surprise, cover breach); and [EDM] influences (mud, wind, unstable footing).

**It does not have** independent facing, opportunity-attack geometry, precise line tracing, or fine movement points in the initial implementation.

**Cover is evaluated, not stored** [ADOPTED 0.33.0, TD-CR-05]. W retired the authored `zone_contribution: {"cover": "+half"}` because it kept a **mutable spatial consequence as an immutable object bonus** — a table granted half cover upright, shoved aside or in pieces.

| Owns | What |
| --- | --- |
| **W** | Object geometry, transform, occupied volume, enabled affordance slots, collision and occlusion state, and the deterministic **spatial query** |
| **K** | **When** cover is evaluated, and how the returned facts affect attack resolution |

**A cover slot is a position, not a promise.** It marks where an actor may stand to benefit; cover applies at resolution **only if the attack line intersects the object's currently active geometry without being fully blocked**. A pushed, toppled, opened, broken or destroyed object invalidates affected cover and line-of-fire results **immediately**.

**K consumes a world-query result and never inspects the tile grid.** This is the same boundary §4 already draws — zones are the combat substrate, and reading cells directly would build a second positional combat system beside the sparse one.

**Zone cover values may persist as generation metrics or cached opportunities. They are never authoritative per-attack bonuses.**

**Incidental complete obstruction is a line-of-fire result, not cover** — solid geometry blocks an attack whether or not a cover affordance was ever authored on it.

**Why abstract.** This resolves the two-positional-systems problem (Visual Design ◇V6). The Triade position remains the principal *"where am I?"* system; physical zones answer only *"what can I reach, and what environmental leverage exists here?"*

No mainstream tactical game runs two full-resolution spatial systems simultaneously; the invariable solution is **one rich plus one abstract** (Darkest Dungeon's 4-rank lanes, Fabula Ultima's zones). Because the stance triangle is already a demanding continuous space, the battlefield must be coarse.

---

## Part 5 — Action resolution

### 5.1 The combat action record

The locked action contract (Part H) remains the stable Triade interface. Combat-specific systems **wrap** it rather than adding fields to it.

```
combat_action
├─ identity        — id, tags, display data
├─ timing          — base AP cost, recovery, wind-up, cooldown?
├─ anchor          — sector/ring, angular window by level, radial falloff
├─ spatial         — range in zone hops, target pattern, movement before/after
├─ source/materiel — hand or faculty, weapon requirement, pip redistribution,
│                    damage scalar, status hook
├─ triade          — the existing locked action contract
└─ AI/presentation — utility tags, telegraph class, Dictionary keys
```

**On cooldowns.** Every other limiter in this design is *structural* (ejection, zero-sum budgets, exposure, ordinality). Cooldowns are *authored*. They do something structural limits cannot — bound repetition of **one specific** skill while leaving the rest of the kit free — so they are legitimate. But they should be the **exception**, reserved for skills whose identity is "rare and dramatic," not the default limiter. Otherwise they become the answer to every balance problem and the structural pressures stop working.

**Cooldown scope is explicit and asymmetric** [AUTHORED 0.40.0]. A cooldown names both the identities an action checks and the identities it starts. A base Technique cooldown blocks every rendition derived from that Technique. A rendition may add and start its own cooldown without starting the base cooldown, so Poisonous Rend can cool down while plain Rend remains available; the reverse is not true while Rend's base cooldown is active. Faculty-wide cooldowns are exceptional shared locks and block every Technique authorized through that Faculty. Provider cooldowns gate production or application only: a regenerating venom gland cannot create a new provision, but it does not erase an already applied coating or block plain Rend.

No propagation is inferred between siblings, from a provider to an existing provision, or from a rendition back to its base. Any action that starts more than its own declared cooldown identity lists every additional shared key explicitly.

The proving cases are normative:

- Rend on cooldown → Rend and Poisonous Rend are not selectable.
- Poisonous Rend on cooldown → plain Rend may remain selectable.
- Venom gland regenerating → no new gland venom may be applied; an existing weapon coating may remain usable; plain Rend remains unaffected.
- A Faculty-wide Arcana vocal-recovery lock started by Resonant Chorus blocks every Arcana-only or composite Technique that requires Arcana without changing entitlement.
- A composite Technique owns its own Technique cooldown; unrelated cooldowns on Techniques authorized by either member Faculty do not block it.
- A transferred provision belongs to the recipient and owns its remaining uses/expiry; provider loss or provider cooldown prevents replenishment, not consumption of the existing provision.

### 5.1a Selection and target-route validity [AUTHORED 0.43.0, ◈P12-B]

Combat consumes three derived predicates from the authoritative Technique resolver. `known` is vocabulary membership, `selectable` is at least one complete actor-side initiation candidate, and `executable` is one fully contextual candidate. Only `executable` permits costs to commit or effects to resolve. UI and AI may inspect the earlier predicates and their failed-gate reasons, but neither may convert them into execution permission.

Target validation dispatches by the Technique-authored selection and delivery contract, not by the broad source category. A direct actor-targeted weapon attack validates selected-weapon reach, actor perception, actor line of sight and direct-route geometry. A direct projectile additionally validates its projectile path. A direct Psyche attack validates Technique reach, perception and actor line of sight unless an explicit mental-link or non-visual-lock route replaces those requirements.

Area actions validate their origin, pattern, propagation and geometry rather than perception or line of sight to every affected actor. A Sword Whirlwind may use selected-weapon reach as its actor-centred radius and strike occupants of eligible surrounding cells without selecting them individually. A flask or bomb selects a destination under its authored destination-visibility rule, then validates throw range, ballistic route and landing cell before resolving affected cells. An unseen occupant may be hit without being exposed to the actor or AI before resolution. Walls, closed doors, elevation and other blocking geometry still apply under the authored propagation contract.

Multiple source candidates are alternative complete routes. The resolver may keep Punch selectable when one eligible hand survives, but it may not satisfy a two-hand route with one hand: `Mudra && Mudra` requires both functional, unoccupied hands and their distinct finger hooks in the same candidate. The candidate is selected before costs commit.

The verdict reports every currently failed gate without triggering side effects. P12-C's deterministic evaluation and commit order are specified in §5.2 and K·3.7.

### 5.2 Fixed resolution order

**Pre-commit is pure.** Run the complete P·2.3e resolver against one immutable snapshot, choose one exact candidate, and require `executable`. AP is a rate and is never reserved or spent. Successful commitment atomically records the candidate and command; captures pre-commit position, current usable skill level and radial-potency inputs; computes effective cost and duration; reserves actual spendables and exclusive dependencies; and creates the action, milestones, timeline nodes, Intent Marker and audit digest. Any write failure rolls the transaction back.

Post-commit resolution is ordered by consuming milestone:

1. Resolve authored movement-before and preparation milestones
2. Revalidate the exact source, hooks, occupancy, target route and other gates consumed at release
3. Consume release-milestone costs and start the cooldown identities declared for successful execution commitment
4. Resolve the action check
5. Redistribute weapon pips
6. Freeze the exact carrier contract
7. Resolve active defence, primary damage, mitigation and integrity; emit the immutable layer trace
8. Evaluate delivery proof from that trace; consume any delivery-proof cost
9. Apply compatible Payload modules, conditions and per-recipient effects
10. Create or consume relational states
11. Apply actor and target dot impulses and integrate sustained forces over elapsed `world_tick`
12. Emit environmental contacts and Named Reaction requests to W's deterministic same-tick batch
13. Commit atomic geometry changes and traceable child events in stable order
14. Award Edge or Grit; update affordances, posture, log and victory state; release or expire reservations

The pre-commit snapshot is an anti-exploit. Availability and potency use the position captured *before* the action resolves, so an action cannot move itself into its own ideal anchor and retroactively benefit. Actions may carry explicit `movement_before` (a charge) — an authored exception reflected in effective cost and risk.

Do not rerun the whole readiness resolver at every milestone. Revalidate only the live state consumed there: source/hook/occupancy at release, route contacts in transit, landing and affected set at impact, compatibility/resistance/reactions at effect, and release/expiry at recovery. The bound Technique, level, aim, Faculty profile, source, rendition, provision, carrier and selected target/origin never silently change. Outcomes are `resolved`, `resolved_no_effect`, `route_failed`, `interrupted`, `cancelled`, or explicitly authored `superseded`.

A reservation is not consumption. Every spendable declares `commit`, `release`, `contact`, `delivery_proof` or `effect` as its consumption milestone. A gameplay failure does not roll back milestones already reached. Unreached reservations release; no universal refund exists.

**Why steps 10 and 11 can be ordered this way:** Opening depth is **derived**, not stored (K·6.2). Relational states are created before impulses because depth is recomputed from current state whenever read. *Do not "optimise" depth into a stored value — it silently breaks this ordering.*

### 5.2a Carrier contract before damage; delivery proof from the trace

The **carrier contract** is fixed at the end of step 6. It names the exact source revision, delivery node and hook or hooks, post-redistribution footprint, authorised Payload module, carrier type and required target-layer route. Step 7 consumes this immutable contract; later results cannot replace its source or add carrier types.

The **delivery proof** is evaluated once at step 8 from step 7's immutable layer trace. It answers only whether the contracted carrier reached the contracted layer by the contracted route — for example, positive Pierce transfer into viable tissue for inoculation, or positive Corrosive damage at an armour layer for corrosion. Merely listing the carrier type in the base footprint is insufficient, while unrelated damage cannot substitute for it.

Payload magnitude may consume the proved carrier entry and other explicitly authorised trace outputs, then target susceptibility/resistance, exactly once. It cannot feed back into primary mitigation or anatomical routing, independently reapply attacker/target inputs already represented by the trace, or alter the carrier contract that admitted it.

A secondary payload is legal only as an explicitly authored child of the original action. It keeps the original carrier contract, delivery proof and traceable parent event; it cannot prove itself as a new carrier, spawn another secondary payload in the same action, or feed its resolved result back into its own magnitude. Aim remains orthogonal: H·6.2a samples the target node from the reweighted full distribution, after which the same step-8 layer chain supplies delivery proof. Landing on a non-selected node is still a successful hit on that sampled node; it is not a miss, a reroll or a refund.

---

## Part 6 — Checks, outcomes and the Opening model

### 6.1 One-roll margin resolution

**Do not** roll separately for hit, critical, status, penetration and Opening creation. One seeded roll produces a resolution margin.

```
resolution_score = base competence + channel stat + anchor potency
                 + relevant position bonus + Opening/Advantage factors
                 − target defence − Back-foot and condition penalties
                 + narrow seeded variance

margin = resolution_score − difficulty
```

| Margin | Outcome |
| --- | --- |
| Clearly negative | Failure |
| Slightly negative / near zero | **Glancing** |
| Positive | Success |
| Strongly positive | Critical success |

A critical is therefore **evidence of a strongly favourable exchange**, not a second independent lottery. The random band stays narrow enough that positioning and preparation usually dominate. UI shows a qualitative forecast (*secure / contested / desperate*) plus the consequence of failure.

### 6.2 The glancing band — one global rule

> **Glancing produces the action's effect at reduced magnitude, and never awards credit.**

| Action type | Glancing result |
| --- | --- |
| **Create** | shallow Opening, no credit |
| **Read** | no Edge; the Opening **survives** (you failed to capitalise, but did not consume it) |
| **Advantage action** | damage at reduced potency; **no Loop Grit, no [Back-foot]** |

**The action contract needs no fourth credit field.** Three fields (`credit_on_success` / `failure` / `crit`) stay, with the global rule that glancing pays none of them. Credit is always what is withheld — which keeps the **anti-self-funding rule** perfectly sharp.

**Why a shallow Opening is the right form.** Opening depth is already a *derived, continuous* value, so a glancing create needs no new machinery — it simply produces low depth. And it self-limits: `read_value` scales on depth, so a shallow Opening is genuinely hard to read. A glancing hit gives you something you *might* convert if well-positioned and well-timed, and often cannot. That is exactly what a partial success should feel like. *(A "bonus to next attack" was rejected: it would be a parallel mini-system with its own lifetime, scope and display, for something the Opening object already models.)*

### 6.3 Opening representation

```
Opening
- id, target, creator or public source
- scope: for_x | for_all
- opening_vector
- created_at
- integrity_modifier, status_modifier
```

Depth is **derived**, never stored:

```
depth = displacement away from home along opening_vector
      + integrity bonus
      + status-hook bonus
```

No independently ticking health bar — an Opening naturally weakens as the target's dot moves home. `created_at` is required because reading has a **timing curve**:

```
read_value = opening_depth × clarity_from_age × actor_instinct_alignment × channel_stat
```

`clarity_from_age` rises rapidly from creation; depth falls as the opponent recovers. Their product creates an **intermediate optimal reading window** — Edge is a reward for *timing*, not for pressing the highlighted button immediately.

### 6.4 Anchor resolution

Angular alignment is a **hard availability gate**; radial is a smooth curve with a non-zero minimum:

```
available when angular_distance ≤ angular_window[level]

potency = minimum_potency
        + (1 − minimum_potency) × exp(−(radial_error / falloff_width)²)
```

This produces exactly the distinction Visual Design ◇V4 requires: **wrong direction = unavailable; right direction, wrong depth = usable at reduced potency.**

---

## Part 7 — The player-facing exchange loop

### 7.1 Pressure — proactive creation

Displaces the target's dot or breaks its guard: shove away from home; deepen an existing Opening; apply Staggered / Guard-shaken / Pinned; pressure armour integrity; force zone movement.

**Creates an Opening, generates no Loop Grit.**

### 7.2 Discipline — reactive creation

Two families, and **a Discipline action must never both create an Opening and award Endure Grit.** The player chooses to stabilise *or* counter.

**Brace** — reduce incoming displacement; suppress home-well disruption; small Endure Grit when real punishment is absorbed.

**Watch / Counter** — the reaction system (Part 8).

### 7.3 Instinct — read

Attempts to read an Opening. Success generates a **tagged Edge token**. Critical success may generate two, or preserve one after the exploit, subject to cap.

**No Opening means no read action.** The UI must not allow "searching empty air" to generate resources.

### 7.4 Pivot — deliberate traversal

**Passive drift never crosses regions.** The home-well pulls toward *home*, so drifting from Pressure lands you nearer Composure, not in Instinct. Lateral movement between regions must be **paid for**.

**Pivot** is an action anchored in a **transition sector** (`MoIn`, `MiIn`, `MiDi`, `FoDi`, `FoPr`, `MoPr`), producing a strong lateral ADM impulse between adjacent regions. High AP cost, **no credit generation**, and elevated exposure during transit.

Two payoffs:

- **Transition sectors become mechanically load-bearing.** They were defined as "transits, not destinations" (A3.3) and were legal anchor positions with no distinct role. Pivot is what they are *for*.
- **Kit spread (A3.7) gains teeth.** A build with spread anchors *needs* pivots; a clustered build does not. The "spread kit generates more economy but is harder to pilot" tradeoff now carries a concrete cost.

A basic Pivot belongs in the generic toolkit (K·7.7) — inefficient for everyone — with better versions as traversal-specialist vocabulary.

### 7.5 Exploit without a button tax

The mechanical model remains **Edge → Advantage → Advantage action**, but the player should not press a contentless "Exploit" button.

When a valid Edge token exists, selecting an Advantage-gated action presents a **compound command**: spend tagged Edge → create one-shot Advantage → execute the action. Engine and trace preserve both state transitions; the player performs one meaningful command.

### 7.6 Advantage action

A successful Advantage action consumes the loop-earned Advantage, performs its effect, awards **Loop Grit**, and puts the target **[Back-foot against the actor]**.

**Success scales on the *target's* distance from home** (F.0) — their overcommitment arms you.

**It is NOT reduced by the actor's own exposure.** *(Considered and rejected.)* The loop *requires* deep positioning — Instinct is a region, reads happen there, Advantage actions are region-gated. If going deep both armed enemies against you *and* degraded your own conversion, commitment would be punished twice for doing what the design demands. **Exposure alone is the commitment cost.** This makes conversion the *climax* of commitment rather than a retreat; ejection (A4.7) is what pulls you out afterwards.

### 7.7 Generic actions

Every character needs a neutral toolkit usable from Composure or an unfavourable position.

| Action | Purpose |
| --- | --- |
| **Basic attack** | reliable low-demand HP pressure; also the best integrity-stripper |
| **Move** | change physical zone |
| **Recenter** | strong ADM impulse toward home |
| **Guard** | reduce incoming damage and displacement |
| **Pivot** (basic) | paid lateral traversal between adjacent regions |
| **Observe** | inspect enemy state; no hidden mechanical bonus |
| **Use item** | activate a consumable or tool |
| **Pass** | commit a recovery interval and let the home-well act across it |

Generic actions are **intentionally inefficient at completing the loop, but never unusable.** Recenter and Guard are especially important: being pushed out of a build's preferred region must *change the player's problem*, not eliminate their turn.

---

## Part 8 — Reactions: Watch and Riposte

Discipline is one of only **two** Opening-creation paths, so its reaction system is offensive infrastructure, not a defensive perk. If enemies could simply decline to engage a counter-stanced character, that entire creation route would die — the shipped failure in Battle Brothers' Riposte (the AI avoids attacking riposte units, so the stance "builds up fatigue very fast for nothing").

### 8.1 Watch — an action, not a reserve

**Watch is an explicit action**, not held-back AP — **and 0.34.0 makes that argument unanswerable**: with AP as a rate there is no balance to hold back, so automatic reserve is not merely undesirable but unrepresentable. The counter and decline branches, Provoke and the Riposte ladder are unchanged by the timing rewrite. Automatic reserve was rejected: "I happened to have AP left" is not a decision.

As an action it is **visible** (a committed posture, per the XCOM Overwatch pattern rather than invisible auto-fire), carries a **tunable cost**, can be **anchored** in the Di sector, and can carry a **[Skill Level] ladder**.

**Cost: a small AP cost plus a Momentum-loss impulse** (an ordinary zero-sum ADM vector).

Three properties follow from the geometry:

- **The cost *is* the commitment.** Losing Momentum means gaining Form and Mind — a vector pointing at **Discipline**, since Di is the Mind↔Form midpoint. Watching physically settles you into a guard, and the posture display shows it.
- **It self-limits without a rule.** Repeated watching drifts you further off Momentum, lowering readiness (K·3.3), so you act later and later. A positional limiter, not an authored cap.
- **It differentiates archetypes for free.** A Momentum striker pays heavily — each watch drags them off their identity *and* their tempo. A Discipline build is already there, and floors stop further drift, so **the counter-fighter watches cheaply because they have already paid the commitment.**

**Mind's tempo lever is what funds it.** Mind reduces action costs, so a Mind-heavy character can Watch *and* still act meaningfully. Reaction capacity is not a separate grant bolted onto Mind — it is the same lever expressing itself off-turn. Momentum owns *when*, Mind owns *how much* (extending to *outside the turn*), Form owns *guarantee*.

**Budget: one reaction per round**, regained at the start of your turn (5e / Pathfinder 2e consensus).

### 3.6 Environmental nodes, manipulation and same-tick priority [ADOPTED 0.36.0, CR-11]

**Environmental events occupy the same timeline as actors.** Propagation, emission, dissipation, expiry, explosions and structural transitions appear as nodes on the Tactical Timeline and resolve in **one deterministic due-event order** with actor actions — not on a parallel schedule that happens to interleave.

**Timeline manipulation moves nodes; it never rewrites the past.** Advance and Delay shift a *pending* node's position within authored bounds. **A committed action already in progress is never resized** — Haste and Slow change the rate for actions committed *afterwards* (**K-C12**), and no effect retroactively alters a resolution that has passed.

**Same-tick priority is fully ordered**, because a tie that resolves differently on two machines is a determinism failure:

| Order | Resolves |
| ---: | --- |
| 1 | **Immediate** events authored to resolve inline at their own milestone |
| 2 | **Environmental** due events, as a deterministic batch against a pre-application snapshot (**W-C34**) |
| 3 | **Triggered reaction plans** whose trigger holds and whose authored response delay makes them due now |
| 4 | **Scheduled Plannable Action** resolution nodes due at this tick |
| 5 | **Ordinary actor** actions, ordered by **Readiness rank**, which breaks ties and never grants frequency (**K-H2**) |
| 6 | Stable tiebreak on generated identity where all of the above tie |

**Readiness is the tiebreak, not the clock.** It decides *who goes first among simultaneous eligible nodes* and contributes nothing to when those nodes occur.

### 3.7 Plannable Actions and autonomous due nodes [ADOPTED 0.44.0, ◈P12-C]

A Technique is plannable only when its action contract says so. Arming is a paid, visible commitment: it evaluates current actor-side gates, binds one exact candidate, pays setup costs, reserves declared sources, hooks and resources, and creates a plan timeline node plus Intent Marker. It does not assert that a future target route will remain executable.

The plan declares `scheduled` or `triggered` activation, its `world_tick` window, scheduled tick or trigger and response delay, acquisition mode, setup and activation costs, reaction budget, maximum activations, reservations, visibility, expiry and cancellation. The default reactive window lasts until the owner's next activation; a scheduled plan normally stays within the visible round. Multi-round plans require explicit authorship.

The plan node is autonomous. A scheduled plan attempts at its recorded tick; a triggered plan records its attempt tick as `trigger_tick + response_delay`. Lead-up, release, impact and recovery milestones are fixed from that node. The attempt occurs independently of the owner's later position on the actor progress bar, Readiness, AP rate or opportunity to act. Haste and Slow do not move it; only an explicit Advance or Delay effect directed at the plan node may do so.

At activation the exact bound candidate receives a fresh `executable` verdict. Its acquisition mode determines what is attempted:

- `first_eligible` — standard Overwatch takes the first participant satisfying the authored trigger, area and deterministic simultaneous order;
- `bound_identity` — targeted Overwatch watches one perceived opponent, ignores all others, and cancels without retargeting if that opponent or its route is invalid at activation;
- `fixed_spatial` — a planned throw, area technique or hazard binds an origin, path or area and discovers recipients only at resolution.

Acquisition never replaces ordinary route validity. A hidden opponent cannot be identity-bound, and current perception or an authored non-visual lock remains required when the attempt activates. `retarget_policy = none` is the default. An aimed planned action stays aimed and does not downgrade unless a visible authored conditional branch explicitly permits it.

If the due attempt fails, the default result is `cancelled_failed`: release unreached reservations, retain setup and already consumed costs/cooldowns, and do not retarget, substitute a source, retry, reschedule or wait for the owner. Planned-action setup cooldown begins at arming; the execution Technique cooldown begins only when activation successfully commits. Watch's own stance cooldown, if Watch is authored as a Technique, begins at arming.

### 8.1a Armed Intercept Nodes [ADOPTED 0.35.0, CR-11]

**Watch and Riposte create an Armed Intercept Node** at the actor's resulting timeline position. A hostile Intent Span crosses it when:

```
hostile_action_start_tick < intercept_tick <= hostile_action_resolve_tick
```

**Temporal crossing is necessary and not sufficient.** The reaction fires only on:

```
temporal_crossing AND valid_trigger_type AND spatial_eligibility
```

**Spatial eligibility is evaluated at the exact intercept tick** — perception and LOS, weapon range or melee reach, facing or firing arc where applicable, relative XY, Z-deck and elevation, and intervening walls, doors, geometry and furniture. Evaluating it at commit time instead would let a watcher counter through a door that closed while the blow was travelling.

**The economy below is unchanged, and that is the point of stating it here.** Watch remains a **paid, visible action** with its Momentum commitment; the base trigger is **an attack against the watcher**; **Provoke** and the **Riposte ladder** stand; a valid crossing resolves the **counter** branch and an untriggered contract resolves the smaller **decline** branch on expiry. Broader trigger masks require **specifically authored Watch variants** — the node model widens *when* a reaction can fire, never *what* it costs or *what* it pays out.

**And the rate model makes §8.1's argument unanswerable**: there is no AP balance to hold back, so automatic reserve is unrepresentable rather than merely rejected.

### 8.2 The two branches — the Watch is never wasted

**Trigger: an attack against you.** Enemy overextension was considered and rejected as a trigger — overextension is *already* disadvantageous (it arms every Advantage action), and adding a second consequence would double-punish one state.

| Branch | Character | Effect |
| --- | --- | --- |
| **Enemy attacks → counter fires** | explosive, turning-point | **partial negation** of the incoming attack, private [Opening for X] on the attacker, **strong Momentum-ward impulse** |
| **Enemy declines** | patient, incremental | **modest drift toward Instinct** |

**Both branches pay.** This — not the trigger — is what solves the anti-decline problem, and it needs no new state on the enemy.

**Partial negation, not full.** Full negation would make attacking a watcher strictly bad, collapsing the enemy's decision in the wrong direction. Partial keeps the dilemma genuinely hard: the attacker still achieves something.

**Why the counter's impulse is the real engine.** Discipline sits at ≈`(m 0, f 0.5, i 0.5)`; Instinct at ≈`(m 0.5, f 0, i 0.5)`. The path between them is **gain Momentum, shed Form, hold Mind** — so a Momentum-building riposte *physically launches the counter-fighter from their guard toward the reading position*. This solves the counter-fighter's structural problem: they create in Discipline but must read in Instinct, four sectors away, and traversal is never free.

Three consequences:

- **Tempo-neutral when it works.** Watch costs Momentum (lowering readiness); a successful counter rebuilds it. You pay tempo to set the trap and get it back only on success.
- **It reproduces the ejection pattern.** The counter launches you *out of* Discipline, so counters cannot chain. Land one, and you are committed to converting it; re-commit to Watch afterwards. The same spike-and-drop rhythm A4.7 produces for deep skills, arriving without being designed for.
- **The two creation paths get genuinely different economics.** The **Pressure fighter** creates on demand, then *pays* to pivot to Instinct — self-sufficient but expensive. The **counter-fighter** creates *and* traverses in one action, but only when the enemy commits — efficient but hostage to enemy behaviour. Aggressor controls their own tempo; counter-puncher trades control for efficiency.

**Decline-branch magnitude: noticeably smaller than the counter.** Enough to make progress and partially offset the Watch's Momentum cost — roughly reaching `MiDi` territory rather than approaching `In`. It must not fully refund the Momentum cost, or watching becomes free when ignored. If both branches paid similarly, the enemy's decision would stop mattering.

**Visibility is a virtue here, not a liability.** Enemies *should* see a Watch stance. Perfect information (Into the Breach) turns it into a genuine dilemma rather than a gotcha, and the AI evaluating *"attack into the counter, or cede position?"* is exactly the decision the mechanic exists to create.

### 8.3 Provoke — a Watch variant

**Provoke does not compel an attack.** A resistance test was rejected: compulsion fights the utility-based AI (K·10.2), where behaviour emerges from tags and is learnable across species, and it would make the counter-fighter's core strategy a dice roll.

Instead: **Provoke is a Watch that deliberately increases your own exposure.** You bait by genuinely opening up.

§K·10.2's utility model already includes `target_vulnerability`, and exposure already determines what makes a target worth attacking — so Provoke feeds the existing AI calculation natively, with no new test or stat. The risk is real and asymmetric: if they take the bait you counter, but if they *decline*, you have exposed yourself and armed **every other enemy's** Advantage actions for nothing.

| Tool | Effect | Risk |
| --- | --- | --- |
| **Watch** | reaction contract; counter on attack, position on decline | AP + Momentum cost; no recovery |
| **Provoke** | Watch + deliberate exposure to raise attractiveness | exposure arms *all* enemies, not only the baited one |

### 8.4 Riposte — the turning point, not a separate mechanic

**Riposte is the deep end of the Watch ladder, not a once-per-encounter card.**

A per-encounter cap on *counters* was rejected: Discipline is a counter-fighter's entire offensive route, so capping it at one would cap their whole loop at one use per fight — not rare-and-dramatic, simply non-functional.

| Level | Effect |
| --- | --- |
| **⌬L1** | partial negation, shallow Opening, small impulse. Repeatable. |
| **⌬L2** | stronger; held by a good staying floor. |
| **⌬L3 — Riposte** | the turning point: deep Opening, big Momentum launch. |

**The rarity is structural, not authored.** Per A4.7, firing above your staying floor **ejects** you — so only a true master *holds* ⌬L3, and everyone else gets it as a spike-and-drop. The explosive Riposte is naturally rare for most builds because of the staying-floor gate.

**No per-encounter cap.** Skill cooldowns provide any additional pacing needed (K·5.1), and double-gating ⌬L3 behind both the hardest thing in the design *and* a hard cap would make mastery feel unrewarded.

---

## Part 9 — Credit economy in combat

### 9.1 Edge

**Represented as one to three tokens, not a number.** Each token records the Opening and target it came from — which makes the no-handoff rule (C.2) *structurally impossible* to violate rather than merely prohibited.

- Cap: **3 tokens**
- Lost when its source Opening becomes invalid
- Unused Edge cascades to Grit at a poor rate (prototype: **3 expired Edge → 1 Grit**)
- **Target metric: 60–70% Edge conversion** for competent play (B.5)

### 9.2 Grit

**Loop Grit should be ≈70–85% of ordinary Grit generation.** Flow and Endure combined stay secondary — initial target **no more than 15% from either** across the reference fixture set. (This operationalises the trickle-magnitude question from C.5.)

Two recommended universal spends:

```
Recover Bearing — 3 Grit + 1 AP
  • controlled impulse toward home
  • if the actor reaches Composure, clear one target-scoped [Back-foot]
  • grants no credits

Hold the Line — 2 Grit
  • halve the next incoming EDM influence
  • cannot create an Opening or award Endure Grit
```

These provide recovery from negative spirals **without** turning Grit into direct healing or free damage.

Unused Grit cascades into Temper at encounter end (prototype: **5 Grit → 1 Temper**).

### 9.3 Temper

**MVP: no ordinary in-combat spend.** Its purpose remains permanent, sum-preserving development at town triggers.

The single dramatic intervention (a steep run-level cost to survive lethal damage) should be tested **later** as an optional branch — including it now would obscure whether the baseline recovery model works.

---

## Part 10 — Enemy combat model

### 10.1 Credit ownership by tier

| Tier | Economy |
| --- | --- |
| **Trash** | no credits |
| **Standard** | no credits; may create Openings and apply [Back-foot] |
| **Elite** | **Edge only**; reads the player, one-shot Advantage |
| **Commander** | **Edge and Grit**; successful Advantage actions charge a [Signature Action] |
| **All enemies** | **no Temper** |

Preserves qualitative escalation without running three full economies on every enemy.

### 10.2 AI utility model

Behaviour is generated from tags, not per-enemy scripts.

```
utility = objective_value + anchor_potency + loop_progress
        + target_vulnerability + behaviour_tag_bias
        − exposure_risk − AP inefficiency − repetition_penalty
```

| Tag | Bias |
| --- | --- |
| **Compulsive** | heavily discounts exposure risk; prefers Momentum/Pressure |
| **Simpleminded** | removes Instinct reads from consideration |
| **Patient** | prefers delayed reads near optimal Opening age |
| **Guardian** | values Discipline, ally protection, zone denial |
| **Opportunistic** | prioritises public Openings and circumstantial Advantage |

This makes behaviour **learnable across species** (F.2).

### 10.3 Telegraphing

Enemy posture always communicates its current anchor neighbourhood, and therefore its available capabilities (A3.7). Additionally:

- ordinary attacks show target and broad attack family
- Advantage actions receive a clear commitment cue
- Commander [Signature Actions] require a **visible wind-up**
- an enemy may change declared intent only with an explicit **Reactive** trait

A charging Commander exposes: current Grit progress; approximate effect and target; the posture enabling it; and a clear way to disrupt the chain.

**The player's defence against a Commander ultimate is therefore not "deal enough damage."** It is to deny readable Openings, force the Commander away from Instinct, or exploit its own committed posture.

---

## Part 11 — Damage, armour and integrity in combat

### 11.1 Damage pipeline

```
type_share = final_type_pips / total_final_pips

raw_type_damage = weapon_base × action_scalar × anchor_potency
                × outcome_multiplier × type_share

final_type_damage = raw_type_damage × group_mitigation
                  × type_exception × active_guard
```

The full hit is the sum of resolved type components.

**Status hooks read the *final* footprint**, not the weapon's original — a sword used with a Pierce-targeting skill applies **Punctured**, not Bleed (2A.9).

### 11.2 Defensive ordering

1. Active shield or defensive skill
2. Form-based mitigation or conversion
3. Armour group resistance
4. Sharp type exception
5. HP damage
6. Status-hook evaluation

This lets a Form-heavy shield user **actively blunt** an attack before passive armour resolves it.

**Downstream — anatomy (H·6.1).** The anatomical damage model resolves *after* this stack and *before* conditions finalise, inserting between steps 5 and 6. Shield, Form mitigation, armour group and type exception all do their job first; the body system then decides what the **residual** hit did to flesh, bone, tendon or organ. H wraps this contract and adds no fields to it, per K·5.1.

### 11.3 Structural damage

Shatter and Tear use **integrity**, not typed defence. Structural advances Stable → Cracked → Fractured. **It is not an alternative HP victory track.**

| Integrity state | Combat consequence |
| --- | --- |
| **Stable** | normal |
| **Cracked** | Openings against the target are **deeper** |
| **Fractured** | Openings deeper **and decay more slowly** |
| **Broken Guard** | shield's Discipline Opening-creation **suppressed** |

Structural builds therefore **manufacture better exchanges** rather than deleting armour — the central bridge (2A.6) preventing materiel from becoming a separate game. Integrity resets after the encounter; no hidden persistent durability.

---

## Part 12 — Conditions

MVP uses only the **two channels already supported**: a zero-sum CDM/EDM influence, and a temporary stat modifier affecting effective fields.

```
Chilled        — CDM force away from Momentum; temporary Finesse reduction
Cracked Armour — no arbitrary credit grant; increases subsequent Opening depth
Pinned         — CDM force toward Form; physical movement cost increased
```

**Non-linear combinations** (Wet amplifying Cold) stay **disabled** until level-1 is stable (A2.5).

**Legibility cap:** normally no more than **four** tactically relevant visible conditions. Same-family conditions **refresh or escalate** rather than accumulating as near-identical icons.

**Wounds count against this cap (H·7.6).** Injury effects are Conditions, so the four-item ceiling covers them; same-family wounds (multiple bleeds) refresh or escalate into one entry. The full anatomical ledger — per-node grades, tissue state, treatment tags — lives at inspection only (V·4.6), never ambiently.

---

## Part 13 — Encounter rhythm

| Phase | Character |
| --- | --- |
| **Probe** | establish range, posture, environmental leverage. Generic attacks common; Openings shallow; integrity stable |
| **Exchange** | first meaningful Openings. Player traverses between creation and Instinct, generates Edge, converts to Grit. Enemies apply target-specific [Back-foot] |
| **Break** | armour Cracked/Fractured; Grit Specials available; Commanders threaten Signatures. Should resolve before both sides cycle their entire economies repeatedly |

| Encounter | Target duration |
| --- | --- |
| Minor | 2–4 rounds |
| Standard group | 4–7 rounds |
| Elite | 5–9 rounds |
| Commander / boss | 8–12 rounds |

Fixture targets, **not hard turn limits**.

Rooms may use objectives (escape, hold, protect, seize a zone). Circumstantial Advantage connects those objectives to the Triade rather than making them independent minigames.

**TTK caveat:** control and setup mechanics only pay off if time-to-kill is long enough. If enemies die too fast, players will correctly ignore the loop and simply burst. **Benchmark: if the fastest clear ignores Instinct and Edge entirely, TTK is too short or burst is too cheap.**

**Wounded variant (H·14).** The mirror benchmark applies to time-to-*lose*: if injury shortens the player's survival enough that the exchange loop gets skipped under pressure, wounds are too harsh. Both directions collapse the same loop.

---

## Part 14 — Worked exchange

*A maul fighter, four AP, starting near home.*

**Round 1**

- **Driving Blow (3 AP)** — Pressure-aligned. Actor moves toward Pressure; target displaced from home; private [Opening for X] created. **No Edge, no Loop Grit.**
- Remaining 1 AP passed; home-well and active forces partially resolve.

**Round 2**

- **Pivot (2 AP)** — a *paid* lateral traversal from Pressure toward Instinct. Passive drift would only have pulled toward home, not laterally; the traversal must be bought.
- **Read the Fracture (2 AP)** — Opening depth is increased because the enemy's armour is **Cracked**; Instinct alignment favourable; timing inside the clarity window. **Read succeeds → one tagged Edge.**

**Round 3**

- Player selects **Crushing Reversal**, an Advantage-gated action. The compound command spends the tagged Edge → creates one-shot Advantage → executes.
- Success: Impact damage; enemy becomes **[Back-foot against the player]**; player gains **Loop Grit**; the deep action **ejects** the player toward the level their staying floor supports. The [Back-foot] also **raises the player's relational readiness** for the next round.

The player has won the exchange — and must now choose whether to recover, spend Grit to hold position, or begin another traversal.

**That is the intended texture: success changes the next problem rather than ending decision-making.**

---

## Part 15 — MVP scope

- Three reference builds: **Pressure striker**, **Discipline controller**, **Instinct technical**
- Three loadouts: **maul**, **daggers**, **sword and shield**
- Two proof skills per region, plus the generic toolkit
- One **Trash**, one **Standard**, one **Elite**, one **Commander**
- Rooms with two to four abstract zones
- Physical and Structural damage plus a small proof subset of other groups
- Stable / Cracked / Fractured / Broken Guard
- **Linear ADM/CDM/EDM only**
- Full trace attribution
- Production-style posture and skill-bar prototype **before** visual polish

The schema may support the full damage taxonomy from the start; proof *content* stays small.

---

## Part 16 — Validation targets

| Metric | Purpose |
| --- | --- |
| Edge conversion rate | Is Edge a meaningful decision rather than noise? |
| Loop / Flow / Endure Grit share | Is the loop still the economy's backbone? |
| Region residency | Are classes and weapons producing distinct behaviour? |
| Traversal distance | Is mixed-region play occurring naturally? |
| **Pivot frequency** | Is paid traversal happening, or are builds staying clustered? |
| Opening age at read | Does the timing window have a healthy middle? |
| Back-foot duration | Compromised without being locked down? |
| **Turn-order churn per round** | Is relational readiness informative or noisy? *(If order reshuffles more than a slot or two per round on average, add damping.)* |
| **Watch outcome split** | Are both branches (counter / decline) occurring, or does one dominate? |
| Recovery from low credit / poor position | Detect unrecoverable spirals |
| AP starvation rate | Confirm the floor and penalties are fair |
| Integrity transition timing | Structural is setup, not an alternate kill race |
| **Finisher frequency** | Decisive but earned, not routine |
| Commander Signature frequency | Threatening but preventable |
| Damage-type matchup surface | Preserve learnable armour exceptions |
| Posture-recognition time | State readable in under half a second |
| Trace divergence | Reject classes, weapons and enemies that play identically |

### Hard automated checks

*Severities and IDs standardised at 0.11.0. Full suite in `R-Validation_Rules_Index_TRIADE-0_45_0.md`. Rules owned by other documents are cross-referenced, not duplicated.*

| ID | Rule | Severity |
| --- | --- | --- |
| **K-C1** | No action creates an Opening **and** awards the same region's trickle | Critical |
| **K-C2** | No action reads without a valid Opening | Critical |
| **K-C3** | Edge cannot target a different Opening or combatant | Critical |
| **K-C4** | Loop-earned Advantage is one-shot | Critical |
| **K-C5** | `[Back-foot]` does not stack against one attacker | Critical |
| **K-C6** | Glancing outcomes award **no credit of any kind** | Critical |
| **K-C7** | Watch resolves exactly one branch per triggering event | Critical |
| **K-C8** | No corner holds more than one tempo lever | Critical |
| **K-C9** | Position snapshot is taken **before** the action resolves | Critical |
| **K-C10** | Critical | Cover is resolved from a W spatial query against the object's **current** geometry, never from a stored object bonus. K consumes the query result and never reads the tile grid |
| **K-C11** | Critical | `world_tick` is the sole persistent active-adventure timestamp. AP is a **rate**, not a pool — `action_duration_ticks = effective_AP_cost × (60 / current_AP_rate)`, band **2–6**, base **4**. Nothing is spent, banked or carried |
| **K-C12** | Critical | **No Triade corner contributes an additive or multiplicative term to AP rate.** Momentum gives Readiness rank, Mind gives effective cost, Form gives the minimum floor — a clamp, not a contribution. Only authored effects alter `current_AP_rate` |
| **K-H2** | High | Readiness is never converted into ticks or rate; it orders nodes and breaks same-tick ties, saturating at first position |
| **K-C13** | Critical | A time-bearing action declares `commit_tick`, its milestones and `resolve_tick`; effects other than resolution are **explicitly authored**. Environmental events read the actor's authoritative position at their exact tick — mid-action movement is neither ignored nor teleported |
| **K-H3** | High | The Ghost Track runs the **authoritative** resolver against a temporary state copy, classifies forecasts Solid / Conditional / Unknown, and never reveals a future random result or hidden state |
| **K-C14** | Critical | An Armed Intercept Node fires only on `temporal_crossing AND valid_trigger_type AND spatial_eligibility`, with eligibility evaluated **at the intercept tick**. The node model changes when a reaction may fire, never its cost or payout; broader trigger masks require authored Watch variants |
| **K-C15** | Critical | Same-`world_tick` resolution is fully ordered — immediate, environmental batch, triggered reaction plans, scheduled plan nodes, ordinary actors by Readiness, then stable identity. **A committed action or autonomous plan node is never resized by actor-rate changes** |
| **K-C16** | Critical | The carrier contract is fixed after step 6; delivery proof is evaluated once at step 8 from step 7's immutable layer trace against the contracted carrier type and route. Payload resolution cannot feed back into primary resolution, and a secondary payload cannot prove or recursively spawn another carrier |
| **K-C17** | Critical | A selected aimed mode contributes its non-negative surcharge to effective AP cost before commit. On a successful attack H samples the reweighted full distribution; landing elsewhere neither converts the hit to a miss nor refunds cost |
| **K-C18** | Critical | Only `executable` authorizes commitment and resolution. Target-route validity follows the Technique-authored selection shape, visibility and delivery route: direct actor-targeted routes apply their authored reach, perception, LOS and path gates; area routes validate origin, pattern, propagation and geometry without automatically requiring perception or LOS to every affected actor |
| **K-C19** | Critical | Pre-commit evaluation is pure; one exact candidate commits atomically with its snapshot, spendable reservations, action/milestone nodes, Intent Marker and audit digest or not at all. Live state is revalidated only at its consuming milestone; reservations are not consumption, reached milestones do not roll back after gameplay failure, and no silent fallback or universal refund exists |
| **K-C20** | Critical | A Plannable Action creates an autonomous `world_tick` node with an exact candidate and `first_eligible`, `bound_identity` or `fixed_spatial` acquisition. It attempts a fresh executable verdict at its due tick independently of the owner's later actor-timeline position, never silently retargets or retries, and defaults to `cancelled_failed` on invalid resolution requirements |
| **K-H1** | Cooldowns used only for rare, dramatic skills — never as a default limiter | High |
| **K-H4** | A cooldown declares the identities an action checks and starts. Base Technique cooldowns gate all derived renditions; rendition and provider cooldowns do not propagate upward or sideways unless an explicit shared key says so. Faculty-wide cooldowns are exceptional shared locks | High |

**Enforced here, owned elsewhere:**

| ID | Rule | Owner |
| --- | --- | --- |
| T-C1 | All dot vectors sum to zero | T · A2.4 |
| T-C9 | AP cannot fall below the guaranteed floor | T · H |
| T-C10 | All skill anchors reachable by their intended vocabulary owner | T · A3.8 |
| T-C6 | Temporary effects cannot modify baseline floors or global thresholds | T · A4.2a |
| M-C1 | Pip redistribution conserves total pips | M · 2A.9 |
| M-C2 | Structural effects use integrity, not typed mitigation | M · 2A.3 |
| H-C1 | Σ of all effective-field reductions per corner ≥ `max(Φ_safe_x, 0.5 × Φ_base_x)` | H · 10.2 |
| H-C4 | Vital-organ lethality gated on HP below the Finisher threshold, or Downed | H · 9.4 |

*The metrics above (K16 validation targets) are **measurements**, not pass/fail rules; their gates and provisional values live in `Y-SIM_Numbers_Register_TRIADE-0_45_0.md`.*

---

## Part 17 — Decisions on previously open questions

| Question | Resolution |
| --- | --- |
| **AP rate coupling** | **No Triade corner contributes an additive or multiplicative term to AP rate.** Momentum gives Readiness rank, Mind gives effective cost, Form gives the floor — a clamp, not a contribution. Only authored effects such as Haste/Slow change `current_AP_rate`, within **2–6**. Three symmetric tempo levers (K·3.3) |
| **Physical positioning** | Sparse graph of two to four abstract zones |
| **Out-of-combat position** | Decay toward home over two or three exploration turns |
| **Wound decay (H·9.2)** | Minor wounds auto-downgrade one step at the encounter boundary if no active bleed, poison or burn; one free Minor-scoped field dressing per character. Major and Critical persist until treated |
| **Temper intervention** | Excluded from MVP; test later as one expensive dramatic intervention |
| **Enemy economy** | Elite = Edge; Commander = Edge + Grit; neither gets Temper |
| **Back-foot / Advantage representation** | Keep as first-class relational states |
| **Dot Dynamics** | Opt-in on particular heavy or unstable actions only |
| **Dynamic Composure** | Off in MVP |
| **Non-linear conditions** | Off until level-1 combat passes validation |
| **Exploit action** | Separate engine transition, bundled into the selected Advantage action |
| **Randomness** | Narrow seeded margin roll; position and preparation dominate |
| **Trickle magnitude** | Loop 70–85%; Flow and Endure ≤15% each (K·9.2) |
| **Win condition** | HP depletion, plus a Finisher gated on Fractured/Broken Guard + [Back-foot] (K2) |
| **Reaction timing** | Watch as an explicit action; one per round; two-branch resolution (K8) |
| **Final numbers** | Derived from simulation and playtest, not locked in design documents |

---

**Tarot runtime integration [ADOPTED 0.45.0].** P·2.3f–i resolves layout expressions before candidate construction. A Tarot Combo has one exact Combo-Action and two same-depth endpoints, each supplying one distinct hook; nested contributors supply none. Combo transfer is explicit and counted once. Source/target-route/cost/cooldown and planned-action checks remain under P12-C, with no silent substitute, suppressed-Support fallback or topology mutation on temporary failure.

## Changelog

| Version | Change |
| --- | --- |
| **0.45.0** | Tarot runtime integration preserves exact-candidate P12 commitment, two distinct hooks, explicit contribution transfer and no fallback. |
| **0.44.0** | **P12-C timing and commitment adopted.** §5.2 separates pure pre-commit evaluation from atomic commitment and milestone-local live revalidation (**K-C19**). §3.6–3.7 gives triggered and scheduled plans autonomous `world_tick` nodes, three targeting-acquisition modes, exact-candidate/no-retarget semantics and deterministic same-tick priority (**K-C15**, **K-C20**). |
| **0.43.0** | **P12-B targeting and candidate semantics adopted.** §5.1a distinguishes `known`, `selectable` and `executable`, requires Technique-authored direct/area targeting contracts, and preserves information boundaries for unseen area occupants (**K-C18**). Alternative candidates are existential; every dependency within the chosen candidate remains conjunctive. |
| **0.42.0** | Version alignment only. P12-A establishes entitlement persistence but leaves complete runtime availability and cooldown evaluation ordering to P12-B/C. |
| **0.41.0** | **P11 cooldown fixtures adopted.** K·5.1 now states the asymmetric Rend/Poisonous Rend cases, provider-versus-provision survival, the exceptional Faculty-wide lock and independent composite-Technique cooldown. |
| **0.40.0** | **Cooldown scopes authored.** Base Technique, derived-rendition, Faculty-wide and provider cooldowns are distinct declared identities. Base cooldowns gate derived renditions; child and provider cooldowns do not propagate upward or sideways without an explicit shared key (**K-H4**). |
| **0.39.0** | **A2 aimed-mode timing.** The non-negative aim surcharge enters effective AP cost before commit (**S-K09**); a successful hit samples H's reweighted full distribution, and landing elsewhere is neither a miss nor a refund (**K-C17**). |
| **0.38.0** | **Session A correction and centralisation in §5.2a / K-C16.** The carrier **contract** closes after redistribution; delivery **proof** is evaluated once from step 8's immutable layer trace. This preserves armour/tissue routes without a feedback cycle. Payloads cannot alter primary resolution, double-apply represented inputs or recurse. |
| **0.36.0** | **Remaining AP-pool consumers swept.** Pass no longer *consumes remaining AP* — it commits an authored recovery interval; Form's floor is restated as a **rate** floor. 0.34.0 retired the pool and left downstream clauses executing against it. |
| **0.35.0** | **CR-11 combat adoption.** §3.5 authors timeline nodes, action milestones, Intent Markers and the Ghost Track (**K-C13**, **K-H3**); §8.1a authors **Armed Intercept Nodes** (**K-C14**) with the Watch cost, trigger, Provoke and Riposte ladder **unchanged** — the node model widens *when* a reaction fires, never what it costs or pays. |
| **0.33.0** | **`Pierce-focused` → `Pierce-targeting`** — `focus` is locked Mind-side. **Cover is evaluated, not stored** (**K-C10**, TD-CR-05). W owns the spatial query over current geometry; K owns when cover is evaluated and how it affects resolution. A cover slot is a position, not a promise; a toppled object invalidates it immediately. K consumes the query result and never reads the tile grid. **TD-CR-10 boundary confirmed**: W derives the sparse zone graph from resolved geometry and K consumes coarse relations — target access, traversal cost, cover and exposure, eligible high ground — retaining combat-resolution authority and never reading the tile grid. |
| **0.27.0** | Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | 31 subsection headings deletterd. Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | Seventeen `Part K<n>` headings become `Part <n>`; **K** was the only document with sectioned parts and no open items, so every bare `K<n>` is a section reference and stays unglyphed. Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **7 glyphed identifiers in this document.** |
| **0.16.0** | No content change. Closing line corrected — it had read *"End of Combat Design 0.12.0"* through four subsequent releases, and listed six companion documents when there are nine. |
| **0.12.0** | **K4 confirmed against W's `complex_room`.** The flag exempts an authored room from the 2-zone floor only, never the 4-zone ceiling (position A2), so K's substrate stays uniform and K4 needs no amendment. Vertical rooms documented: two `[Deck]`s spend two zones on deck separation, a zone may not span decks (W-C19), and a `[Vertical Portal]` supplies an adjacency edge and movement cost rather than a zone of its own. Document set grows to nine. |
| **0.11.0** | **K16 restructured** — the flat "hard automated checks" bullet list becomes an ID'd severity table (`K-C1`–`K-C9`, `K-H1`), with rules owned by other documents cross-referenced rather than duplicated. Validation metrics separated from pass/fail rules and moved to the SIM Numbers Register. Document set grows to eight. |
| **0.10.0** | Document set grows to seven with **H — Damage & Health**; filename convention standardised. **K·11.2:** anatomy hands off after the defensive stack, between HP damage and status-hook evaluation. **K2:** the Finisher threshold gates anatomical lethality — no silent instant kills. **K12:** four-condition cap confirmed to cover wound families. **K·3.3:** Form's AP floor named as the second injury-spiral brake. **K13:** wounded time-to-lose benchmark added. **K16/K17:** Trauma Safety Clamp and vital-hit gate added to the invariant list; wound decay recorded. |
| **0.9.0** | Document created. Combat thesis, win condition + Finisher, round/AP/initiative model with three symmetric tempo levers and relational readiness, sparse zone battlefield, resolution order, one-roll margin with the glancing rule, Pivot as paid traversal, the Watch/Riposte reaction system, combat credit economy, enemy combat model, encounter rhythm, MVP scope and validation targets. |

---

*End of Combat Design 0.45.0. Maintained alongside the Core Mechanic, Stats/Items/Equipment, Lexicon, Visual Design, World Generation, Damage & Health, Enemies, Tile Pipeline and Content Pipeline documents.*
