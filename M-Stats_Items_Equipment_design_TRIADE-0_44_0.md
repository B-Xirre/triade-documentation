# Roguelike RPG — Design Plan: Character Stats, Itemisation & Equipment

**Version 0.44.0** — 27 September 2026. Restructured around the Triade, which turned out to be upstream of all three subsystems.

**Document set:** this is one of **ten**.

| Ref | Document | Filename |
| --- | --- | --- |
| **T** | Core Mechanic | `T-Core_Mechanic_design_TRIADE-0_44_0.md` |
| **M** | **Stats, Items, Equipment** — *this document* | `M-Stats_Items_Equipment_design_TRIADE-0_44_0.md` |
| **L** | Lexicon | `L-Lexicon_design_TRIADE-0_44_0.md` |
| **V** | Visual Design | `V-Visual_design_TRIADE-0_44_0.md` |
| **K** | Combat Design | `K-Combat_design_TRIADE-0_44_0.md` |
| **W** | World, Maps & Dungeons | `W-World_Generation_design_TRIADE-0_44_0.md` |
| **H** | Damage & Health | `H-Damage_Health_design_TRIADE-0_44_0.md` |
| **E** | Enemies & Bestiary | `E-Enemies_design_TRIADE-0_44_0.md` |
| **G** | Tile Pipeline | `G-Tile_Pipeline_design_TRIADE-0_44_0.md` |
| **P** | **Content Pipeline & Data Model** | `P-Content_Pipeline_design_TRIADE-0_44_0.md` |

**Companion document:** `T-Core_Mechanic_design_TRIADE-0_44_0.md` owns the state model, credit economy, class model, enemy model and trace system. This document owns stats, itemisation, equipment, the data foundations and the agentic development track.

**Deliberately out of scope:** final numbers. Numbers are the output of this process, not an input.

---

## Part 0 — Design Constitution

| # | Decision | Status |
| --- | --- | --- |
| 0.1 | **Time model** | **Locked; restated 0.34.0.** One authoritative `world_tick`. Out of combat, authored tick costs; in combat, **AP is a rate, not a pool** — `duration = cost × (60 / rate)`, band 2–6, base 4. **Timing is derived, never stored as a Speed stat.** Formerly: AP-based with expenditure driven by stats, skills, equipment and the Triade. Speed is not a stat — it is derived from Dexterity-type stats and current Momentum. |
| 0.2 | **The Triade** | **Locked.** Momentum / Form / Mind as a zero-sum barycentric position; Instinct / Pressure / Discipline as derived regions; a three-layer credit economy. See companion document. |
| 0.3 | **Determinism** | **Locked.** Runs fully reproducible from a seed, with named RNG streams. Non-negotiable prerequisite for agentic development. |
| 0.4 | **Floor invariant** | **Locked.** Floor shape is class-alone at run start. Total floor budget 0.45; per-corner cap 0.25. |
| 0.5 | **Modification budget** | **Locked.** Any floor modification is sum-preserving and respects the per-corner cap after modification. Threshold reductions are per-region, never global. Permanent items may reshape floors; worn items may alter threshold or dwell; consumables may alter dwell only. |
| 0.6 | **Build expression** | **Locked.** Class supplies floor shape and part of the region vocabulary; weapon type supplies the rest. Capability is generic progression; vocabulary is class- and weapon-specific. |
| 0.7 | **Run length and death model** | **Locked 0.14.0.** Structure was already in W·5.4/5.5; what was open was duration, acquisition count and the death ledger. See Part 9. |
| 0.8 | **Meta-progression** | **Partially answered.** Temper converts into permanent floor reshaping at town triggers. Remaining question is whether anything else persists. |
| 0.9 | **Numeric philosophy** | **Locked 0.14.0.** **9× career**, derived per storey from locked geometry. Not per run — power compounds across bands. See Part 9. |
| 0.10 | **Readability budget** | **Open.** How many numbers may appear on one tooltip. Caps affix count, which caps affix pool design. Tighter than usual here, because the Triade already consumes screen attention. |

**Gate 0 exit criteria:** 0.7, 0.9 and 0.10 answered; three reference fantasies written that the systems must be able to produce.

**Gate 0 status at 0.14.0: passed on three of four.** 0.7 and 0.9 are locked in Part 9; the three reference fantasies are written there and are the prose form of K·15's existing reference builds, so fantasy and fixture are one object (**◈M10**). **0.10 remains open** and has moved to the prototype track with `◇V6` — it is a legibility measurement, not a sweep, and it does not gate the harness.

**0.9 is an itemisation number and nothing more.** T-C3 conserves `Σ Φ_base`, so the Triade layer supplies shape and never magnitude. Stated because "target power multiple" reads as though it spans the design; it spans item power, vocabulary breadth and `[Skill Level]`, and two of those three are breadth.

---

## Part 1 — Character stats

Stats no longer feed combat maths directly. They feed the Triade, and the Triade modulates combat maths at evaluation time.

### 1.1 Taxonomy

- **Primary attributes** — few (3–6), chosen at build time, define identity. They influence the Triade; they are not consumed by combat maths.
- **Derived stats** — computed from primaries and gear, modulated by Triade state; these are what combat maths reads.
- **Resources** — pooled and spendable: **HP only**. *AP left this category at 0.34.0 — it is an action-time **rate**, not a resource, and nothing about it is spent, banked or carried (**K-C11**).* Note the credit layers are *not* stats; they belong to the Triade.
- **Meta stats** — affect systems outside combat (loot quality, shop prices, detection).
- **Hidden/technical** — threat, poise, i-frames.

Anything that fits no bucket is cut.

### 1.2 The three influence channels

Primaries reach the Triade through three distinct channels. Every stat must do something in at least one channel that no other stat does.

| Channel | What it governs | Example feeders |
| --- | --- | --- |
| **Pull strength** | how far one action moves the position dot | Strength → Form pull; Dexterity → Momentum pull; Intelligence → Mind pull |
| **Floor extent** | resilience and stability of the reachable region | Constitution, Willpower |
| **Decay resistance** | how fast state drifts back toward home | a Discipline/Wisdom-type stat |

**Floor shape is rendered from stat-fields (Triade A4).** Stats group by corner; each group fuels a field; the three fields (conserved sum) render the floor via the corner-single / region-dual rule, with two renders — Floor (staying, balance-rewarding) and Reach (depth, specialisation-rewarding). Class sets the baseline; stats sculpt the shape within the conserved budget; the per-corner cap holds after rendering. See Triade A4 for the full mechanism, including the [Reach Cost] skill characteristic.

**Test:** for every pair of stats, a player must be able to state the difference in one sentence. If they cannot, merge them. This applies *within* a corner group especially — three stats per corner must map to three distinct verbs, or it is one stat in three costumes (Triade A4.1).

### 1.3 The stat contract

```
id, display_name, bucket, type, default, min, max, soft_cap, hard_cap,
stacking, rounding, display_format,
triade_channel[], consumed_by[], produced_by[]
```

`consumed_by` is the honesty check: a stat read by nothing is dead weight; a stat read by everything is a mandatory tax.

### 1.4 Common currency

Define one scalar everything converts into — **eHP** for defensive stats, **eDPS** for offensive, **TTK/TTL ratio** as the combined health metric.

**Triade amendment:** a stat's value is now *state-dependent*. Price stats as an expectation integrated over the trajectory distribution across the fixture set, not at a single reference point. This makes the sim harness a prerequisite for stat balance, not a nice-to-have.

### 1.5 Curves and interaction matrix

Choose a response curve per derived stat — linear, diminishing `x/(x+k)`, or threshold. Build an N×N matrix marking every stat pair as additive, multiplicative or orthogonal. Every multiplicative pair is a potential exponential exploit; target a small named set of intended multiplier chains and nothing else.

**AP rate coupling** [restated 0.34.0, **K-C12**]. **No Triade corner contributes an additive or multiplicative term to AP rate.** Momentum gives Readiness rank, Mind gives effective cost, Form gives the minimum floor — a clamp, not a contribution. Only authored effects such as Haste/Slow move `current_AP_rate`, inside 2–6. *The former pool rule read "at most one corner may modify the AP pool.

### 1.6 Anti-pattern sweep

Record a ruling on each: dump stats, mandatory taxes, stats that only matter in the last 10% of a run, stats invisible moment-to-moment, pairs the player cannot distinguish, anything requiring a wiki to evaluate.

### 1.7 Formalise and simulate

Emit `stats.schema.json` and `stats.data.json`. Run reference builds × reference encounters × 10k seeds and produce the stat-value table.

**Gate 1:** stat schema frozen; every stat has a state-integrated currency conversion; interaction matrix has no unintended multiplier chains; every stat is distinguishable from every other in one sentence.

---

## Part 2 — Itemisation

### 2.1 Taxonomy

Two orthogonal axes kept separate in data: **category** (weapon / armour / **shield** / trinket / consumable / currency / tome) and **slot**.

**`shield` is a category in its own right, not a sub-type of either parent** [LOCKED 0.16.0]. Its component set is the union of weapon and armour — martial profile *and* defence signature *and* its own integrity track — drawn from **one pooled budget** (M-C4, 2A.11). Filing it under `weapon` or `armour` would leave a linter unable to state which components a shield requires without encoding the exception in code, which violates *content is data, never code* (Part 4 item 1).

**Trade-off named.** Seven values instead of six, and `slot / occupancy` already marks the off-hand — so the seventh looks redundant from the slot side. It is not: slot says *where it equips*, category says *which components are required*. Collapsing them re-merges two of P·1.3's three classifications that must never merge.

Per-category **base types** carry an intrinsic signature not expressible as a stat. For weapons this is the `weapon_triade` block defined in the companion document: archetype, pull vectors, magnitude, volatility, recovery, vocabulary, efficiency.

### 2.2 What rarity means

**Locked: rarity is mechanical demand, not magnitude.**

- **Corner items** — push toward a single corner, forgiving, generic vocabulary. Common, early, always usable.
- **Region items** — demand a narrow part of the triangle, reward it heavily. Rare, deep.

This self-balances. A region weapon is a jackpot for a class whose floor shape reaches that region cheaply and a curiosity for one that does not — loot variance without stat inflation.

Item level still governs roll magnitude. A separate `unique` flag owns rule-breaking behaviour.

### 2.3 Affix system

```
affix: {
  id, group (prefix|suffix|implicit),
  tags[], applies_to[], tier, ilvl_req, weight,
  value_range, value_curve,
  exclusivity_group,
  triade_effect?      // pull, dwell, efficiency, or per-region threshold
}
```

Rules: a **tag budget** per item so rolled items read as themed; **exclusivity groups** to prevent stacked near-duplicates; and a **behavioural affix quota**.

The quota problem is now solved structurally: any affix carrying a `triade_effect` is inherently behavioural rather than numeric, because it changes how the item moves the dot rather than how large a number is.

**Stat-bonus affixes are *also* behavioural — through the field layer (Triade A4.2a).** A worn stat bonus (e.g. +2 Dexterity) feeds the character's *effective* fields, reshaping the floor and unlocking skill levels the baseline floor denies. So even a plain "+2 Dexterity" affix changes *what the character can do*, not just a number — it is a floor-shaping, behavioural modifier. Two consequences for pricing: a stat bonus must be priced by its *field/skill-unlock* impact (simulation delta, 2.5), not by the raw stat points; and because effective fields are clamped, the same bonus is worth far more to a build below the relevant cap than one already near it — delivering per-build loot variance (2.7) for free.

**Threshold-reducing affixes are restricted to high tiers and uniques.** They partially bypass the commitment cost that makes regions meaningful. Per-region only — a global reduction is strictly better with no tradeoff and becomes mandatory gear.

### 2.4 Generation pipeline

Explicit, seeded, ordered. This is the artefact agents implement and test against.

```
1. select base type       (weighted by source loot table)
2. assign item level      (from depth/source, with variance; saturates for [Incursion] sources — W-C18)
3. roll rarity            (curve by depth, pity counter applied)
4. determine affix count  (from rarity)
5. select affixes         (weight × tag coherence × applies_to × exclusivity)
6. roll values            (tier range × ilvl scaling × quality roll)
7. post-conditions        (clamp, dedupe, budget check)
8. name & flavour         (derived from base + dominant tags)
9. validate               (power budget, readability budget, schema)
```

### 2.5 Item power budget

**M-H3.** `item_power = Σ (affix_value × affix_currency_weight)`, with an allowed band per rarity and item level. Anything outside the band is a build failure, not a balance opinion.

**Triade effects cannot be priced by formula** — they are non-linear and context-dependent. Price them by **simulation delta**: the measured eDPS/eHP change from swapping the affix across the fixture set. This is the delta-signature machinery from the trace system, so it requires no separate infrastructure, but it does require the sim harness to exist before the affix pool grows.

### 2.6 Uniques

Hand-authored, never generated. Each needs a design contract: the rule it breaks, the build it enables, the drawback, the encounter where it feels best. Cap the count — every unique is permanent balance surface.

Threshold-reducing and reach-granting items live here by default.

### 2.7 Loot tables and drop curves

Sources → weighted tables referencing categories and ilvl offsets. Required additions:

- **Pity counters** per slot, so no run is unarmed at depth.
- **Shape-aware drop pools** — required by the modification system, since permanent reshaping can otherwise strand a character with incompatible drops.
- **Smart-loot dial** (0–100%), biasing drops toward the current build. This is now more load-bearing than in a conventional roguelike, because off-class weapons carry a clumsiness penalty. Set it deliberately; it trades discovery against frustration.

### 2.7a Progression attributes on items — *new at 0.12.0*

Two progression systems in **W** attach to the item data model. Both are **authored by mission placement only** and both are protected from the economy, because both are keys and the economy's job is to consume things.

| Attribute | Function | Home |
| --- | --- | --- |
| **`[Secret]`** | Marks an item as a storey-gate key. Picking it up writes to W's **run-scoped key register**; the gate reads the register, never the inventory. An item may be a Secret *and* an ordinary thing — a signet, a shard, a tool | W§5.8a |
| **`[Relic]`** | Marks an item as carried out of a Location to unlock **access** elsewhere. Secured by reaching town, lost on collapse | W§5.9 |

**Why these need rules rather than conventions.** Putting an attribute on `ItemDef` puts it inside the generation pipeline, and this pipeline runs at volume — the power-budget validator alone sweeps 100k generated items. Two failure modes follow directly, and they are the same shape as the one H-C3 already solves for currencies:

| ID | Severity | Rule |
| --- | --- | --- |
| **M-C6** | Critical | `[Secret]` and `[Relic]` are authored by mission-graph placement only. No affix, loot table or generation pipeline may set either |
| **M-C7** | Critical | No `[Secret]`-flagged item is salvageable, rerollable, sellable or discardable. **Binds the internal attribute**, so a player-facing rename cannot evade the check |
| **M-H5** | High | No single interaction delivers more than ~20% of a band's total log-power gain unless it is an authored unique with a named drawback *(§9.6; T-H1 in the power layer)* |
| **M-C8** | Critical | The same protection applies to `[Relic]` items |

Without M-C6 the affix generator can mint a key to no gate, or a duplicate key to a real one. Without M-C7 and M-C8 the salvage and reroll sinks (§2.8) will consume a mission key with no warning, and shape-aware drop pools would offer it as a candidate.

### 2.8 Economy

Sources, sinks, conversion. Salvage and reroll currencies are the pressure valve that makes bad drops non-frustrating; design them alongside the drop curve.

Note that **Temper is already a parallel economy** with its own sink (training and tomes at town triggers). Check the two economies do not compete for the same decision — if both fund the same upgrades, one is redundant.

**Material currencies.** *Provisional, 0.10.0.*

| Currency | Function | Register |
| --- | --- | --- |
| **Marks** | Ordinary town money; goods, services, treatment | neutral — or steel, reading it as a smith's maker's mark |
| **Scrap** | Salvage from dismantling | steel |
| **Flux** | Affix reroll / reforge material | steel — the smelting agent that strips impurities and lets a bond take |

**Reserved word:** *Flux* is a currency and **never** a field quantity. The doc set uses `Φ` and "field" for field magnitudes; *flux* must not be used for field flow.

**Progress currencies are not valid sinks here.** Temper and `Location Grounding`/`[Imprint]` may not price crafting or treatment. H·8.1 makes this a hard rule for recovery: charging against a progress currency lets a spend retroactively erase banked achievement. The same logic applies to crafting — hence Scrap and Flux, which are renewable.

**Open (◇H13):** whether Scrap converts to Flux, or they are independent sinks. Independence permits Scrap-rich / Flux-poor states, which is either useful friction or pure annoyance.

**Gate 2:** affix library at minimum viable size with tags and tiers; generation pipeline seeded and implemented; power-budget validator green on 100k generated items; drop simulation shows target acquisition cadence; corner/region item ratio produces the intended rarity feel.

---

## Part 2A — Materiel: item layers, damage, and integrity

This Part covers the *physical* layer of equipment — what a weapon does on contact and what armour does about it. It is designed to run **through** the Triade, not alongside it: three bridges (2A.6–2A.8) connect it to the Opening loop, the Dot Framework and the credit economy, so materiel is not a parallel stack.

### 2A.1 The five item layers

Every equippable item is defined by five layers. Identity lives in the base object; expression in behaviour; tuning in affixes.

| Layer | Function | Triade integration |
| --- | --- | --- |
| **Chassis** | slot, family, handedness, weight class, reach class, base **martial profile** | sets demand profile and vocabulary anchor |
| **Construction** | material, rigidity, coverage, brittleness | governs typed defence and Structural response |
| **Behaviour** | pull vectors, volatility, recovery, region affinity, vocabulary | talks to dot motion, dwell, clumsiness |
| **Affixes** | bounded stat and typed-modifier layer | shifts effective fields without rewriting identity |
| **Inscription** | rare rule-bending effect | uniques and relics only; narrowly scoped |

**Chassis survives customisation.** An item must remain recognisably itself after affixing — the affix layer tunes, it does not rewrite the chassis.

### 2A.2 Demand classes

Demand expresses **what commitment an item or skill asks of the player**. It is not one axis but **a three-step positional tier plus two orthogonal flags** — the original five-item list bundled together things that are not the same kind of property.

**The positional tier** (a single axis; for skills this is *derived* from the angular window, Triade A3.7):

| Tier | Readable meaning | Rarity feel |
| --- | --- | --- |
| **Broad** | works from home position or a shallow lean; low clumsiness risk | common |
| **Focused** | rewards one corner or a light off-hand pairing | uncommon |
| **Exacting** | wants a region or a tight positional window | rare |

**The two flags** (orthogonal — either may be combined with any tier):

| Flag | Meaning |
| --- | --- |
| **Doctrinal** | wants a *repeatable behaviour loop* or discipline of use — pays off under sustained, patterned use, not casual use. A temporal demand, not a positional one. |
| **Transgressive** | *breaks a rule*, at a sharp cost or a narrowing of the build. The marker for rule-breaks generally — additive pips, threshold-reducing affixes, uniques. |

So a skill may be **Exacting + Doctrinal**: a tight positional window *and* a demand for repeated, disciplined use. The old flat list could not express that.

**Doctrinal is not an access restriction.** It governs *how* a thing must be used, never *who* may use it. Access exclusivity lives in the skill-type and vocabulary systems (Triade A4.7, A4.8): **Specialised** skills exist only for peaked builds, and class/sub-class vocabularies own their exclusive lists. A Doctrinal skill may be universally available; an exclusive skill may be trivially easy to use.

### 2A.3 Damage taxonomy

Fourteen types in five groups. **Types carry identity, narration and status hooks; groups carry mitigation.**

| Group | Types | Resolution path |
| --- | --- | --- |
| **Physical** | Slash, Impact, Pierce | typed defence |
| **Volatile** | Explosive, Fire, Lightning, Cold | typed defence |
| **Corruptive** | Corrosive, Poison | typed defence + degradation |
| **Structural** | **Shatter**, **Tear** | **integrity** — not typed defence |
| **Occult** | Chaos, Divine, Psychic | typed defence + ward |

**Anatomical extension (H·6.2).** Bone integrity and flesh integrity are the per-node anatomical form of this same resolution path: Shatter → fracture, Tear → open wound. This is why the anatomical damage model adds no parallel resolution system — it reuses the integrity path one layer inward, past armour into tissue.

**M-C2 · Structural is a group because it takes a different resolution path**, not merely because it feels different — it checks *integrity*, bypassing typed mitigation. This is also why armour-breaking *spells* sit naturally beside armour-breaking weapons: both are Structural, neither is mislabelled as poison-family.

The two Structural types invert each other:

- **Shatter** attacks rigid construction — plate, scale, brittle wards. Cracks what cannot flex.
- **Tear** attacks flexible construction — cloth, leather, layered textiles — **and unarmoured flesh**. Rends what cannot resist.

So no construction family is immune to the whole group, and a Structural build is never dead weight against an unarmoured target.

### 2A.4 Mitigation: groups plus sharp exceptions

**Armour carries five group resistances plus two or three type-specific exceptions.** The exceptions are where character lives — they must be *sharp and few*, because a long list of qualifiers means nothing stands out and typed defence becomes noise.

The metric that matters is the **matchup surface**: the number of weapon-type × armour-family pairs that resolve non-generically. Target is roughly **twenty across all armour** — learnable by a player, and few enough that each can carry distinct Dictionary narration.

| Construction family | Group baseline | Sharp exceptions |
| --- | --- | --- |
| **Cloth / vestment** | weak Physical, strong Occult | Psychic ++, Slash −−, **Tear −−** |
| **Padded / gambeson** | moderate Physical | Impact ++, Fire −− |
| **Leather / hide** | moderate Physical, some Corruptive | Slash +, Impact −−, **Tear −−** |
| **Mail / scale** | strong Physical | Slash ++, Pierce −−, Lightning −− |
| **Lamellar / brigandine** | balanced Physical | Corrosive −−, Shatter − *(delayed failure)* |
| **Plate** | very strong Physical | Slash +++, **Tear +++**, Lightning −−, **Shatter −−** |
| **Warded plate** | strong Physical + Occult | Divine ++, Chaos ++, Shatter − |

The organising principle is **rigid discontinuity**, not weight: rigid layered constructions absorb enormous immediate force but lose reliability abruptly once cracked; flexible constructions are weaker raw but degrade gracefully. Shatter therefore *pressures* heavy armour rather than invalidating it — and Tear does the reverse to light armour.

**Extended inward as [Tissue Layer] (H·5.1).** The `skin → muscle → bone → organ` stack obeys the identical principle: rigid layers (bone, skull) absorb large force then fail abruptly; flexible layers (skin, muscle) degrade gracefully. Armour and anatomy therefore share one physical logic rather than having two, and the Shatter/Tear inversion means the same thing at both scales.

### 2A.4a Target-node coverage and layer interception [AUTHORED 0.38.0]

A Technique targets an actor or body node; it never names an equipment slot as its target. After H's coverage cascade resolves the impacted node, M derives the covering equipment from that node, each item's authored coverage relation and current functional state.

The physical order is one chain:

```text
resolved target node
→ eligible shield interception
→ functional covering equipment
→ construction, typed defence and integrity
→ H-owned tissue layers
```

Every layer contributes to one deterministic trace with incoming, absorbed or transferred, residual and integrity change by damage type. A payload route reads that trace; it does not rerun mitigation. `Unarmoured` is derived only when no functional covering item intercepts the resolved node. It is never a persisted condition, and no armour class grants universal immunity to a Payload module: coverage, construction, typed defence, integrity, gaps, shield state and the Payload's authored route decide the outcome.

#### `[Ward]` — the Occult mitigation channel [LOCKED 0.13.0]

Occult damage resolves through **typed defence plus `[Ward]`**. Ward was named here from 0.9.0 and defined nowhere until now.

**A ward is a state track, not a pool** — `Intact → Scored → Broken`, modelled on 2A.6's integrity, encounter-scoped, no hidden bookkeeping. It is not a seventh tracked number.

| | |
| --- | --- |
| **Covers** | Occult-to-Mind effects — cognition and focus attacks. Not physical damage |
| **Sourced by** | Warded plate and vestments (above); `[Divine]` faculties |
| **Trade-off named** | A state track cannot express partial absorption, so a ward blunts **kind**, not quantity. This is deliberate and matches how Structural damage works. It is inconsistent with genre precedent, where wards are hit-point-like — flagged because it is the decision most likely to be contested |

**Ward scars are a separate layer.** A broken ward is encounter-scoped; the scar it leaves is persistent, and only H·8.2's town rite clears it. See H·8.2a.

### 2A.5 Status hooks

Every damage type carries a hook. This is where types earn their keep even though mitigation is group-level.

| Type | Primary hook | Secondary |
| --- | --- | --- |
| Slash | Bleed / Lacerated | wider openings on exposed targets |
| Impact | Staggered / Guard-shaken | push, posture loss |
| Pierce | Punctured / Pinned | gap exploitation, anti-guard |
| Explosive | Blasted / Scattered | area stagger, cover break |
| Fire | Ignited | panic, burn-through on organic gear |
| Lightning | Shocked | interrupt, conductivity punish |
| **Chaos** | Warped | +cognition, +focus, **+corruption** |
| **Psychic** | Dazed / Focus-broken | +cognition, +focus, **+displacement** — sustained `[CDM]` on the dot |
| **Divine** | Purged / Consecrated | **+ward**; purges corruption and displacement |
| Cold | Chilled / Brittle | slow; eases follow-up Shatter |
| Corrosive | Eroded Armour | ongoing protection loss |
| Poison | Envenomed | delayed damage, suppression |
| **Shatter** | **Cracked Armour** | integrity loss; later hits overperform |
| **Tear** | **Rent / Opened** | flexible-layer failure; bleeding on flesh |
| Chaos | Warped | unstable routing, ward scramble |
| Divine | Purged / Consecrated | anti-chaos amplification |
| Psychic | Dazed / Focus-broken | cast and stance disruption |

Impact remains the source of stagger and force; Structural owns integrity. The two are complementary, not redundant — Impact starts the problem, Structural makes protection materially unreliable.

### 2A.6 Integrity states — and Bridge 1 to the Opening loop

Armour erosion runs on a **visible state track**, encounter-scoped, with no hidden durability bookkeeping:

**Stable → Cracked → Fractured**, plus **Broken Guard** for shields and rigid off-hand defence.

**`Broken Guard` replaces `Fractured` for shields; it is not a fourth state** [AUTHORED 0.23.0]. A shield profile runs **Stable → Cracked → Broken Guard**; body armour retains **Stable → Cracked → Fractured**. *Reason inline:* K·2 gates the Finisher on *Fractured/Broken Guard* — the two are alternative terminals, not a sequence. A four-state shield path would drive a shield through `Fractured`, and nothing in the corpus says a broken shield opens a **body** Finisher. **Trade-off named:** shields lose the intermediate severity body armour has, so shield attrition is coarser by one step. That is the price of not overloading the Finisher gate.

**Render separation (V·4.8, Requirement 8).** Integrity renders on the equipment **mesh and material**; anatomical wounds render as **skeletal deformation** on the body rig. The two must never share a render target — a player has to be able to distinguish *"his cuirass is Fractured"* (deeper Openings, Finisher gate open) from *"his arm is broken"* (degraded Reach, lost function), because those imply completely different play. Blood decals on equipment surfaces are forbidden: they read as integrity damage.

**Bridge 1 — integrity states feed the Opening layer.** This is what makes Structural damage native rather than a parallel race:

- Openings created against a **Cracked** or **Fractured** target are **deeper** (larger `opening_delta`).
- Openings on a **Fractured** target **decay more slowly** — a compromised guard stays compromised, widening the read window.
- **Broken Guard** suppresses the target's *Discipline* Opening-creation — they cannot counter-punch their way out.

The causal chain runs entirely through locked machinery:

```
crack their armour → Openings on them are deeper and last longer
                  → deeper Openings are easier to read (C.6)
                  → more successful reads → more Edge → more Loop Grit
```

So a mace fighter is not racing an armour bar; they are **manufacturing better Openings for their Instinct game**. This also gives Pressure a *physical* expression it previously lacked — you can force a guard materially, not only positionally.

### 2A.7 Bridge 2 — armour and dot displacement

Armour's core relationship to the Triade is **positional**, and the four weight classes engage the Dot Framework (Triade A2.2) through four *different* existing mechanisms — one per component of the A2.2 model, plus the class that engages none.

| Weight class | Mechanism | Identity |
| --- | --- | --- |
| **Heavy** (plate, mail) | dampens incoming **[EDM]** force | *immovable* — holds stance under pressure; slow to correct once moved |
| **Light** (leather, padded) | strengthens the **home-well** pull | *recoverer* — displaced easily, snaps back fast |
| **Medium** (brigandine, standard shield) | adds a second, shallower well at the **barycentre** | *all-rounder* — sits nearer equal thirds, so every region stays reachable; deep corner excursions are resisted |
| **Cloth** | neither, but **zero encumbrance** | *striker* — widest reachable envelope, leans deepest, no protection |

**`Medium` added 0.24.0; its mechanism corrected 0.25.0.** The class pulls the dot toward the **barycentre** — the geometric centre of the triangle — by adding a **second, shallower well** alongside the class home-well. The two attractors compete: the dot rests nearer equal thirds than the class alone would put it.

**This is not a stronger home-well.** T·A2.2 places the home position at *the centroid of the class's reachable region, shifted toward whichever corner carries the class's weight* — **off-centre, and different per class.** Light strengthens the pull to *that* point. Medium pulls to the *geometric* centre. Different attractors, no overlap.

**A second well, not a shifted home.** Home position feeds **commitment cost** (T·A4), **class-anchor fit** and **clumsiness** — three systems computed from geometry. Moving home would silently re-tune all three; adding a competing well leaves them untouched.

> **Trade-off named: breadth bought with depth.** Every region stays reachable, and no region is reachable as deeply. **The limit on corner reach is a resistance, not a cap** — Medium makes leaning deep expensive, never impossible, so it does not collide with `[Attunement]` or the effective corner floors, which are their own mechanism.

**Superseded at 0.25.0.** Medium was first authored as damping **[Dot Dynamics]**. That mechanism was *dynamic* where 2A.7 is explicitly *positional*, and it produced a situational class — `[Dot Dynamics]` being opt-in, restricted by K·17 to particular heavy or unstable actions — which contradicted the word *balanced* this document had used for the Standard shield since 0.9.0. **The identity already written was the signal the derivation was wrong.**

**[Dot Dynamics] is engaged by no armour class, deliberately.** Of the A2.2 model — (B) forces, (D) home-well, (C) carried velocity — armour engages (B) and (D) and now a second (D)-type attractor. (C) is left to actions, where K·17 puts it. Recorded so a later pass reads this as a decision rather than an oversight.

**Armour provides the channel; stats provide the magnitude.** Light armour grants recovery as a *mechanism*; how strong it is scales with Poise (Form-application) or Finesse (Momentum-application). A nimble character in leather recovers far faster than a clumsy one in the same leather — so light armour is a build-dependent choice, not a universal one.

This interlocks with Bridge 1: armour resists displacement → fewer Openings created on you → enemies must **crack your armour first** to move you.

### 2A.8 Bridge 3 — materiel and the credit economy, via status hooks

Damage types do **not** map to credits directly (that would be arbitrary — why would slash grant Edge?). They connect **through their status hooks**, which already carry mechanical meaning:

| Status class | Feeds |
| --- | --- |
| creates or deepens Openings (Stagger, Cracked Armour, Rent) | the **loop** → Loop Grit |
| absorbed punishment (a block that holds, armour resisting a crack) | **Endure Grit** |
| stacking or chaining (Bleed accumulating, combo continuation) | **Flow Grit** |

Designing a new damage type therefore *implies* its credit relationship via the hook it is given. No new primitives, no arbitrary mapping.

### 2A.9 Pips: weapon footprint and skill redistribution

A weapon's damage footprint is expressed in **pips** (e.g. `1h-Sword`: `Slash ++, Pierce +`). The footprint is not a static label — it is the **input to a per-action computation**, so one weapon supports several styles of play.

**Handedness sets the ordinary base pip budget** [LOCKED 0.17.0]. An ordinary **one-handed weapon carries 3 base pips**; an ordinary **two-handed weapon carries 4**. Handedness fixes only the *total*; the martial profile decides how that total is distributed across damage types.

**Reason inline:** the two-hander gives up the off-hand — a shield, a second weapon, or the free hand a `[Mudra]` requires — and the fourth pip is what that sacrifice buys. A one-hander carrying four pips would make the trade pay nothing, which is precisely the dominance 2A.11 rejects for shields.

**Trade-off named.** Fixing the total by handedness costs the design a chassis-by-chassis power dial: a one-handed weapon can no longer be made stronger by carrying more pips, only by carrying *better-placed* ones. That is deliberate — distribution is the expressive axis, magnitude is not.

**Shields are governed by the pooled shield budget** (M-C4, 2A.11), never by this one, and are never evidence for the ordinary weapon norm.

**Redistribution is the default mechanism, and it is zero-sum.** A skill *moves* pips toward its **redistribution target** rather than adding them:

```
Fervour Thrust (redistribution_target: Pierce) on a 1h-Sword
  base:  Slash ++, Pierce +                    (3 pips)
  final: Slash 0,  Pierce +++                  (3 pips)
```

The same family in two-handed form carries one more pip and distributes it per chassis:

```
2h-Sword
  base:  Slash ++, Impact +, Pierce +          (4 pips)
```

Total pips are conserved. This makes **weapon–skill fit** a real relationship at zero authoring cost: the same skill is superb on an estoc (already pierce-shaped), clean on a sword (flexible), and poor or unavailable on a mace. It is also the pip-level echo of the design's zero-sum spine, so skills can never become a power-creep vector.

**Additive pips (skill adds to the total) are reserved for Transgressive/Inscription-tier effects** — a genuine rule-break with weight, like uniques that break geometry rules.

**[Skill Level] scales redistribution, not magnitude.** ⌬L1 shifts one pip, ⌬L3 shifts three. Deeper skill levels are *sharper focusing*, not bigger numbers — mastery as precision, and the ladder stays non-inflationary.

**A footprint is ordered, and the order is martial priority** [AUTHORED 0.31.0]. The record is a list — `{ type, pips }[]` (2A.10a) — and that list is read **signature first, concession last**. The order is not authoring convenience: it states which type the weapon would give up if it had to give one up.

*Reason inline.* Something has to break a tie when a rule selects "the highest type", and the alternatives were worse. A fixed taxonomy order would be arbitrary and unarguable. Rolling for it would make footprint a property of the *copy* rather than of the weapon, contradicting 2A.10's object-boundary rule, forcing per-instance state P has no model for, and leaving a player unable to know whether a weapon reaches `requires Pierce ≥ 2` until after equipping it. Ordering is already in the data; this makes it mean something.

**Trade-off named.** List order becomes semantic, so reordering an authoring row silently changes behaviour. That is a real hazard and it is accepted deliberately: the alternative was a new field on every weapon to express something the list already encodes positionally.

**Status hooks follow the final footprint**, not the weapon's base. Fervour Thrust applies Punctured, not Bleed — so skills change *which statuses you apply*, another behavioural lever.

#### Handedness qualifiers on weapon types

**A weapon family that legally exists in both forms carries an explicit handedness qualifier** — `1h-Sword` / `2h-Sword`, `1h-Mace` / `2h-Mace`, `1h-Axe` / `2h-Axe`, `1h-Hammer` / `2h-Hammer`. This is a **weapon-type identity qualifier**: it is not a slot name, not an occupancy count and not a delivery hook, all three of which remain separate quantities. Families that are inherently one-handed or inherently two-handed need no redundant qualifier unless ambiguity exists.

Machine-facing IDs stay lowercase snake_case and keep the family grouped, so a sort puts variants together: `weapon.sword_1h`, `weapon.sword_2h`, `weapon.mace_1h`, `weapon.mace_2h`.

**The two-handed total is fixed; its distribution is not.** A future `2h-Mace` or `2h-Axe` carries four base pips, and where the fourth pip lands is authored per chassis. It is never inferred from the one-handed profile.

| ID | Severity | Rule |
| --- | --- | --- |
| **M-C1** | Critical | Ordinary base weapon footprints obey the handedness budget — `1h` = **3** base pips, `2h` = **4**. Skill redistribution moves pips zero-sum and conserves that base total. Transgressive/Inscription effects are the explicit exception; shields are governed by **M-C4**, not by this rule |

*Source-row note.* **M-C1 has been carried in the Validation Rules Index, and in K's *enforced here, owned elsewhere* table, since 0.11.0 with no ID-bearing row in this document.* The row above is that source. The 0.17.0 sweep that added it found **M-C2** and **W-C4** in the same condition. **◇P7**'s count was seventeen; the audit found **twenty**, and this row closes one, leaving **nineteen** — see P·Part 8.

### 2A.10 Weapon requirements and conversion penalty

Whether a skill can be used with a given weapon is a **per-skill property**, not a global rule — because some techniques are genuinely weapon-bound and others are merely ill-suited:

```
weapon_requirement: { type | group, min_pips } | null   // null = universal
conversion_penalty: 1.0 | 0.5 | ...                      // efficiency when converting
redistribution:     { target_type, pips_moved }          // scales with [Skill Level]
sources:            [ main_hand | off_hand | faculty | environment | ... ]
```

For an ordinary skill `sources` is a single hand. For a **[Combo-Action]** it lists every contributing source, and the requirement check reads *those sources* rather than assuming a weapon footprint.

**A `[Combo-Action]` declares exactly two delivery hooks — never one, never three.** [LOCKED 0.13.0, rule **T-C13**]

A **delivery hook** is a channel an action issues through: `main_hand`, `off_hand`, or `voice`. **Hook count and hand occupancy are different quantities** — a two-handed weapon occupies both hands but presents **one** hook, which is why E.3 has two-handers declare point demand rather than a segment.

| Legal | Hooks |
| --- | --- |
| Two weapons (dual-wield) | main + off |
| Weapon + shield | main + off |
| Weapon + `[Arcana]` | hand + voice |
| Weapon + `[Mudra]` | hand + free hand |
| `[Arcana]` + `[Mudra]` | voice + hand |
| `[Mudra]` + `[Mudra]` | main + off |

**`[Arcana]` + `[Arcana]` is impossible** — one voice, one hook. It falls out of the model rather than needing a rule, and is stated because it will otherwise be asked.

**Why exactly two, and not more.** Part H rejects all three corners touching the AP **rate** because *"the interaction matrix acquires a multiplicative chain."* A three-source requirement check and three-way footprint interaction is the same failure in the materiel layer. `wand + [Arcana] + [Mudra]` is therefore illegal, and the cap is what keeps 2A.10's requirement check readable.

*Worked example, corrected at 0.13.0:* a **staff** is two-handed and physical — attacks and blocks — so its only combo is `staff + [Arcana]`. A **wand** is one-handed, freeing the off-hand, so it supports `wand + [Arcana]` **or** `wand + [Mudra]`. A two-handed paladin can cast Arcana and never a Mudra: the trade-off is the point, and the previous *staff + cantrip* example quietly violated it.

- **Requires** — the skill declares a minimum footprint in its **redistribution target** (`Pierce ≥ 1`). A weapon lacking it cannot use the skill at all; it is greyed out. Use where the fiction demands it: you cannot thrust with a hammer head.
- **Permits with penalty** — the skill converts from whatever the weapon has, at a **loss** (conversion inefficiency, never a flat damage cut, so it flows through the same pip mechanism and scales naturally with spare pips).

Requirements are stated at **type** level by default, with **group** available as a filter where a skill should cover a whole family cheaply.

**The requirement checks the weapon's *base* footprint**, before redistribution — otherwise the check is circular.

**The object-boundary rule.** Footprint is a property *of the weapon*, so:

- **Affixes count** — a crafted or forged Pierce affix genuinely makes the weapon capable of piercing, and *can* unlock a skill otherwise unavailable to that chassis. Cross-type affixes on mismatched weapons should be **extremely rare but not impossible** in crafting: such an item is a key that opens a whole skill family on a chassis that should not have it — memorable, build-defining loot.
- **External buffs do not** — a potion or blessing is not part of the weapon. It resolves as **additive bonus damage at resolution**, never touching footprint or requirements. A blessed character with a mace still cannot thrust.

Footprint gates *access*; bonuses modify *outcome*.

Group-boundary control falls out of this without a special rule: Skills targeting Shatter or Tear simply declare `requires Shatter ≥ 1`, so Structural stays the province of weapons actually built for it.

**M-C3 · Two-vector loadouts do not pool footprints.** A skill draws from the hand it is used with. The exception is explicit: a skill may declare itself a **[Combo-Action]**, drawing on **more than one source at once**.

*Downstream (H·11.2):* this rule is why the Standard-tier enemy body template splits into two limb nodes rather than one — breaking one arm must be mechanically distinguishable from breaking the other, and a [Combo-Action] requires both sources intact.

The sources need not be two weapons. A [Combo-Action] may combine:

- two equipped items — dual-wield, or sword-and-shield (bash into follow-up),
- an item plus a capability — staff + cantrip (a low-level gesture spell),
- an item plus an environmental feature — and other exotic pairings.

The mechanic is therefore **source-agnostic**: a [Combo-Action] declares its contributing sources, and its requirement check (2A.10) reads *those sources*, not a weapon footprint by default. This keeps cases like staff+cantrip from needing a special rule.

[Combo-Actions] are the **payoff of a multi-source loadout** — the reason to surrender a two-hander's concentrated footprint is access to a vocabulary no single source can perform. Commitment buys focus; breadth buys techniques.

*Terminology note:* a **[Combo-Action]** is a *single action drawing on multiple sources*. This is distinct from a **combo** in the Flow Grit sense (2A.8, Triade B), which is a *sequence of actions over time*. One is width, the other is length.

### 2A.10a `[Faculty]` — the non-item source

A `faculty` is what a `sources` entry names when the source is not an item. It covers **everything a body or a mind does without equipment** — not only magic. Before 0.13.0 the corpus had no unarmed model at all: E·F.1 gives Equipment cardinality `0–2`, so a Trash-tier enemy with no equipment had no vocabulary source and could not act, and 2A.6's *"Disarm risk"* left a disarmed player in the same state. Both fall here.

```
faculty {
  id, display_name
  family          : arcana | mudra | psyche | somatic
  source_mode     : independent | bound_node
  base_footprint  : { type: enum14, pips: int }[]     // required for independent; empty for bound_node
  hook_contract   : voice | fingers | brain | bound_node
  gate_nodes      : [ ref(BodyNodeArchetype) ]        // reads H's function_denial
  pull_signature  : (dm,df,di) | null                 // primitive direction; zero-sum
}
```

Origin is deliberately absent from the immutable Faculty definition. Whether an actor possesses a Faculty, why it possesses it and whether it is currently usable belong to the actor × Faculty entitlement and runtime gates under `◇P12`; they must not be copied into the definition and allowed to drift. Technique authorization is likewise a normalized relation, not a delimited field on this record.

**A faculty carries its own base footprint**, exactly as a weapon chassis does, and 2A.9's zero-sum redistribution applies unchanged. K·5.1 already anticipated this — its materiel line reads *"hand or capability, weapon requirement, pip redistribution, damage scalar, status hook."* The alternative, deriving the footprint from stat fields, would make casting power scale with build a **second** time on top of the stat → field → floor → skill-level chain that already does exactly that. Two scaling paths for one thing.

#### The four families and their hooks [ADOPTED 0.41.0, ◈P11-A/B]

| Family | Execution hook | Gate nodes | Denied by |
| --- | --- | --- | --- |
| **`[Arcana]`** — verbal | **voice** | functional vocal apparatus | speech/incantation denial (H·7.2) |
| **`[Mudra]`** — gesture | **fingers** | selected hand's fingers | one-hand: that hand occupied or denied; two-hand: either of two distinct hands occupied or denied |
| **`[Psyche]`** — unspoken | **Brain** | Brain | Brain function denial |
| **`[Somatic]`** — natural-node control | **bound node; no independent hook** | binding source node | node state and binding prerequisites |

A one-hand Mudra requires functional fingers on one selected unoccupied hand. A two-hand Mudra is one Faculty entitlement using two distinct finger hooks; both selected hands must be functional and unoccupied. It is not two Faculties. Arcana + Arcana remains invalid because there is one voice hook; Psyche + Psyche is invalid because the actor has one Brain hook.

**Somatic is authorization, not a fourth physical source.** `[Innate]` remains retired: the lineage-owned node profile states what the body can physically do. Somatic states which deliberate natural-node Techniques the actor may learn and use. It carries no independent footprint, contributes no delivery hook and cannot satisfy a physical requirement; the active bound node supplies all three. A Somatic Technique therefore uses `innate_node` as its source and Somatic as its required Faculty.

**Faculty lifecycle is explicit.** `conferred` means automatically possessed by an explicit grant; `unlocked` means eligible for acquisition; `acquired` is a persisted character-state fact created through a valid acquisition route. `possessed` is derived as conferred or acquired and is not authored separately. A Lineage grant explicitly chooses `conferred` or `unlocked`; deliberate natural actions such as Bite, Punch and Kick may therefore arrive as conferred Somatic control. Multiple authoritative sources fold to one base-Faculty entitlement, with conferred possession dominating unlocked-only eligibility. An acquired Faculty normally survives loss of its unlock source unless that source explicitly declares a leased or revocable contract. Runtime readiness is not another Faculty lifecycle value: `known`, `selectable` and `executable` derive at Technique-candidate grain from possession, hooks/nodes, activation, position/floor, carrier, target route, costs and cooldowns. Any Faculty-level readiness is a generated aggregate only.

**The gates reuse anatomy.** H's `function_denial` remains the mechanism; the Faculty contract names which function it reads. There is no anti-magic subsystem: counterplay against a caster is anatomical, and the player learns it from the same wound table that governs everything else.

**`[Psyche]` pays for having no external component with its Brain gate.** Counterplay is still anatomical and therefore high-risk, but no second spine hook is inferred.

**`[Innate]` is no longer a faculty. It is part of the lineage** [AUTHORED 0.32.0, T·A4.8a]. A lineage authors an unarmed footprint **per node** — a dwarf's hands, a wolf's front legs and teeth — and the profile is live exactly while the node is. What was a slot table maintained here, plus a `gate_nodes` pointer into H's `function_denial`, is now an attachment: nothing to gate, nothing to derive, nothing to keep in step.

**Why it moved.** The slot model and the node model said the same thing twice. A serpent has no punch because its template has no upper-limb group — already true, and the slot table restated it. Attaching the profile to the node deletes the restatement, and **dissolves `◈E10`**: bite was a deferred fourth slot, and there are no slots.

**One injury may still deny both a natural action and `[Arcana]`**, but for two different reasons. Bite reads its selected source node; Arcana reads vocal function. A particular BodyTemplate may realise those functions through overlapping anatomy without making teeth the universal Arcana hook.

#### Faculty profiles, compositions and actor pull [ADOPTED 0.41.0, ◈P11-C/D/F]

Independent base Faculties carry three damage-footprint pips. Zero-pip types are absent:

| Faculty | Damage footprint | Actor pull signature |
| --- | --- | --- |
| Arcana | Divine 2, Psychic 1 | Discipline `(-2,+1,+1)` |
| Mudra | Chaos 2, Divine 1 | Pressure `(+1,+1,-2)` |
| Psyche | Psychic 2, Chaos 1 | Instinct `(+1,-2,+1)` |
| Somatic | none; read the bound node | none; read the Technique/node route |

Composite profiles are explicit unordered authorization records, never the result of a universal arithmetic rule and never separate Faculty entitlements:

| Profile | Damage footprint | Required hooks | Actor pull signature |
| --- | --- | --- | --- |
| Arcana && Mudra | Chaos 2, Divine 3 | voice + one selected finger hook | Form `(-1,+2,-1)` |
| Mudra && Mudra | Chaos 3, Divine 2 | two distinct selected finger hooks | Pressure `(+1,+1,-2)` |
| Psyche && Mudra | Chaos 3, Psychic 2 | Brain + one selected finger hook | Momentum `(+2,-1,-1)` |
| Arcana && Psyche | Divine 2, Psychic 3 | voice + Brain | Mind `(-1,-1,+2)` |

Every composite has five pips, no damage type above three, and only damage types present in its inputs. Arcana && Arcana and Psyche && Psyche are invalid. Arcana && Mudra requires the two possessed base Faculties; Mudra && Mudra requires one possessed Mudra Faculty plus two functional, unoccupied hands, each supplying a distinct functional finger hook. A pull signature is a primitive zero-sum direction: the Technique owns magnitude, and its actor `position_delta_q` must be zero-sum and positive-collinear with that signature. The signature never stacks as an additional runtime delta and does not constrain target displacement or environmental motion.

**Four families, still no `[Innate]` Faculty.** `[Arcana]`, `[Mudra]` and `[Psyche]` remain independent learned or granted sources. `[Somatic]` is the bound-node authorization family and adds no source of its own. `[Innate]` was never that shape — it is what a body **is**, not what it knows.

#### Innate magnitude — per node, never per body [ADOPTED 0.37.0, ◈M14]

**The constraint is at the node, because a body total never resolves.** **M-C3** forbids two-vector loadouts from pooling footprints, so the sum across a creature's nodes is not the magnitude of anything it does. A per-body budget would constrain a quantity that never appears in play — and would make anatomy a liability, normalising a dragon's jaws, tail, four legs and two wings down to a human's four pips.

**T·A4.8a's four-pip illustrations are a reference for ordinary weapon-capable bodies, not a universal ceiling.** Human `1+1+1+1`, Dwarf `2+2`, Wolf `1+1+2` all total four; that is the authoring norm for a body that also carries weapons, and it does not bind an anatomy whose natural sources *replace* held weapons.

| Grade | Base innate pips | What it describes |
| --- | ---: | --- |
| **Incidental** | 1 | an ordinary hand, foot, wing buffet, secondary limb |
| **Dedicated** | 2 | a claw, combat-adapted limb, heavy tail, strong fist |
| **Apex** | 3 | monster-defining jaws, stinger, beak, horn |

**The grade vocabulary persists and is load-bearing.** These are the canonical names for base innate magnitude at one node: Incidental = 1, Dedicated = 2, Apex = 3. They are not skill levels, enemy tiers or permission to add pips. Validation reads the integer and checks the exact name/value mapping under **M-C12**; the existing two-hook and Transgressive/Inscription exceptions remain the only route above Apex.

**Three is the ordinary single-node ceiling.** Four is reserved for a source committing **two delivery hooks** — the two-hander's bargain, one layer inward — or for an explicit Transgressive/Inscription exception.

**Ordinary striking equipment draws a 2-pip pool at its node**: 1 offensive pip and 1 local defensive pip, as a shield does (**M-C9**). Its offence composes with the node's innate footprint and **the ordinary offensive composite saturates at 3**:

| | |
| --- | --- |
| Human hand `1` + conditioning to `2` + glove `1` | **3** |
| Dwarf hand `2` + glove `1` | **3** |
| Apex jaws `3` | **3** — equipment may still add defence, type access or affixes, never ordinary magnitude |

**Holding a weapon suppresses innate and striking-equipment offence at that hand** (2A.10a). Local equipment *defence* remains.

**An ordinary physical `[Combo-Action]` draws at most `3 + 2 = 5`** — three from its primary source, two from its supporting one. That is the dual-wield envelope exactly: a one-hander at 3 with an off-hand at 2 under **M-C11**. Bite-and-tail therefore lands where sword-and-dagger already sits, and a sixth available pip stays relevant to independent source use without collapsing into one action. *This bounds ordinary physical combination only; faculty and exotic multi-channel magnitudes are not constrained here.*

#### Unarmed builds are layered, not granted [ADOPTED 0.37.0, ◈M14]

Viability comes from four separate layers, so no humanoid is handed a weapon-equivalent body by default:

1. **Lineage anatomy** sets the starting node footprint (T·A4.8a).
2. **Permanent martial conditioning** may promote selected nodes — **under H-C8, and only on the Permanent tier**. It is a permanent transformation of the base profile, never a skill adding pips.
3. **Striking equipment** contributes offence, local defence, integrity and affixes.
4. **Skills** redistribute zero-sum and supply vocabulary, tempo, status, movement and combination effects.

**A bare standard humanoid may reach 3 pips at a node through Permanent conditioning alone** [RULED 0.37.0]. Equipment independence is therefore a real build and not a flavour — the Brawler reaches parity with a gloved hand by conditioning instead, and pays for it in the affixes and defence the glove would have carried.

**This is the first consumer of H-C8.** That rule authorised the Permanent tier to alter an innate profile at 0.32.0 and nothing had used the channel; conditioning is what it was holding open. It also keeps 2A.9 intact — no skill adds pips, and the ladder stays non-inflationary.

#### How a hand resolves [AUTHORED 0.32.0]

**A hand is one source, never two.** It resolves as its **weapon**, or — when empty — as **innate plus whatever offensive profile its worn equipment carries**. Never both: a sword in the fist does not also punch.

| Hand | Resolves as |
| --- | --- |
| Holding a weapon | the weapon's footprint. Innate and glove offence at that hand **do not apply** |
| Empty | lineage innate at that node **+** offensive profile of equipment worn there |

**An empty hand is a real second source.** A one-handed sword in the main hand and a gloved fist in the off hand is a legal two-vector loadout on the same terms as sword-and-dagger or sword-and-shield: two hooks, `main_hand` and `off_hand`, and **M-C3** still forbids the two footprints from pooling.

**Three things carry offensive pips, and the third is the new one.**

| Source | Budget | Authority |
| --- | --- | --- |
| **Weapon** | handedness — `1h` 3, `2h` 4 | **M-C1** |
| **Shield** | a 2-pip pool, split with defence | **M-C9**. *Not armour* — `shield` is the seventh `category` in its own right, component set the union of both parents (§2.1, locked 0.16.0), so no statement about armour reaches it |
| **Striking armour** — gloves, boots | pooled with defence, as a shield is | 0.32.0 |

**All other worn equipment carries defence only.** A cuirass, a helm, a cloak: no offensive pip, ever. Stated as a negative because the general case — *every* armour piece budgeted like a shield — is the obvious generalisation, and it is **rejected**. Only equipment that can plausibly strike may strike.

**Unarmed can rival armed at a hand, and that is the intent.** Innate plus a striking glove is additive, so a lineage with a strong unarmed profile can match a weapon on pips while paying none of a weapon's costs — no integrity track, nothing to disarm, no loot to find. The martial artist, the brawler and the pugilist are **design space the corpus deliberately keeps open**, and a rule declaring weapons superior would close it for the sake of an arithmetic tidiness nobody asked for.

What differentiates them is authored elsewhere and will be authored further: a weapon carries an **affix layer** (2A.1) with no unarmed equivalent unless the gloves themselves are enchanted, and weapon vocabulary and skill design will shape the rest as it lands. **Magnitudes are settled — `◈M14`, closed 0.37.0**: per node, ordinary ceiling 3, striking equipment a 2-pip pool (**M-C12**, **M-C13**).

### 2A.11 The shield — armour and weapon

The shield breaks the weapon/armour division deliberately. It is three things:

- **Armour** — construction family, defence signature, and its own integrity track (Broken Guard, 2A.6).
- **Weapon** — a damage footprint in pips, drawn from the offensive share of its pool (below). A buckler spends both pips there (`Impact +, Slash +`), a standard shield one (`Impact +`), **a tower none**. *A tower shield carries no damage footprint at all* — it bashes through vocabulary and Opening-creation, not through pips, and that is what "mobile cover that can also bash" means once the budget is real. `Impact ++` stood here from 0.16.0 with no derivation and overspent every pool this section authorises.
- **The only *active* piece of armour** — and this explains the other two. Body armour is a standing property: it protects whatever you are doing. A shield is *a position you hold* — aimed, raised, angled. That is precisely why it is **the only armour that carries skills**: skills are things you *do*, and the shield is the only defensive item you actively operate.

**Its defence scales with lean.** Where body armour engages Bridge 2 passively (plate dampens [EDM] whatever your stance), a shield engages it **actively**: its defensive contribution scales with how far the dot leans toward **Form**. Held in a defensive stance it is superb; leaning hard aggressive it is largely weight on the arm.

This sits directly on the locked two-vector geometry (Triade E.3): sword-and-shield pulls toward Momentum *and* Form and the player chooses which to lean on turn by turn — and that choice now has a direct consequence, since leaning sword-ward lowers what the shield is doing for you.

**The shield is the only equipment that natively supports both Opening-creation paths** — Discipline (parry, brace, counter → provoked overextension) *and* Pressure (bash, shove → direct displacement). Every other item does one or neither. That is the shield's mechanical identity in one line, and it is why sword-and-board feels complete: you can manufacture Openings reactively or proactively with the same piece of gear.

**Data model — one record, not two.** A shield is a single object carrying both sets of fields:

```
shield_item: {
  chassis,                    // buckler / standard / tower
  construction_family,        // armour side
  defence_signature{},        // group resistances + sharp exceptions
  integrity,                  // OWN track, separate from body armour
  damage_footprint{},         // weapon side — pips
  pull_vectors[],             // defensive_converter archetype
  vocabulary[],               // Discipline- and Pressure-heavy; unique among armour
  lean_scaling                // defensive contribution vs Form-ward lean
}
```

Shield integrity is tracked **separately from body armour** — an intact harness with a broken shield is a normal and meaningful state.

**M-C4 · The shield budget — a single pool split between the two natures.** A shield must **not** receive a full weapon pip budget *and* a full armour defence budget independently. That would make a one-hand-plus-shield loadout strictly dominate a two-hander: a complete weapon in the main hand, a second weapon's worth of pips in the offhand, and full armour value from the same slot. Instead, one pooled budget is **split** between offensive pips and defensive value (defence signature + integrity).

This is not an artificial constraint — it is what the shield sub-families already are:

| Sub-family | Budget split | Weight class (Bridge 2) | Identity |
| --- | --- | --- | --- |
| **Buckler** | pip-heavy, low defence | light — home-well pull | an offhand *weapon* that also parries |
| **Standard** | balanced | medium — **barycentre well** (2A.7) | the canonical two-vector loadout |
| **Tower** | defence-heavy, low pips | heavy — [EDM] damping | mobile cover that can also bash |

Buckler-versus-tower is therefore a *position on a budget line* rather than three hand-tuned items — consistent with how every other spectrum in this design is handled.

#### The pool has a size, a unit, and an authored split [RESTATED 0.29.0]

`◈M12` asked two questions in order — how the pool is represented, and what defensive value is denominated in. Both are answered here, and at 0.29.0 the split position is **authored rather than measured**, which retires `S-M05`.

**Every shield draws a 2-pip pool.** Sub-family is a position on that pool, not a different size of it.

| Sub-family | Offence | Defence | Damage footprint | Defence signature |
| --- | ---: | ---: | --- | --- |
| **Buckler** | **2** | 0 | `Impact +, Slash +` | — |
| **Standard** | **1** | 1 | `Impact +` | `Physical +` |
| **Tower** | **0** | **2** | — | `Physical +, Volatile +` |

*Reason inline.* 2A.9 fixes `1h` at 3 and `2h` at 4, and the two-hander keeps its four. A shield adds two, so sword-and-board totals **five** against a two-hander's four — and that is not dominance, because **M-C3** forbids two-vector loadouts from pooling footprints. The largest footprint any single action can draw is **4** for the two-hander and **3** for any split loadout; only a `[Combo-Action]` reaches both sources. **Commitment buys focus, breadth buys techniques** — the extra pip is breadth, and it never lands in one blow.

**Trade-off named.** The tower gives up its damage footprint entirely. That is the price of two defence pips, and it makes the sub-families genuinely different objects rather than three points on a damage dial.

**Both natures are denominated in pips.** A budget "split between offensive pips and defensive value" is only one budget if a unit of each is the same size. One **defence pip** buys one step of 2A.4 signature notation — the `+` in `Physical +`.

**State the negative: Structural is not purchasable.** 2A.3 routes Shatter and Tear through **integrity**, not typed defence (**M-C2**), so a defence pip cannot buy resistance to them. The buyable groups are **Physical, Volatile, Corruptive and Occult** — four of five, with Occult additionally passing through `[Ward]`. A tower shield resists a mace by *having an integrity track*, never by spending a pip against Shatter. This is 2A.4's rigid discontinuity holding at the shield scale.

#### The off-hand transform [AUTHORED 0.29.0]

**A one-handed weapon equipped in the off hand loses one pip, removed from its highest damage type.** A `Slash ++, Pierce +` sword becomes `Slash +, Pierce +`.

*Reason inline.* This is what stops `1h + 1h` from being six pips, and it does it by **cost rather than prohibition** — no off-hand legality gate, no second authored form per weapon, no new handedness value. Every one-handed weapon is off-hand capable; the off hand is simply worse. That also authors the *offhand-capable* phrase which had stood in the agent workflow art since 0.12.0 owning nothing.

**It strips shape, not just magnitude.** The pip comes off the *highest* type, so the off-hand form loses precisely the concentration a martial identity is built on. Because **2A.10's requirement check reads the base footprint**, and this transform applies to that base, an off-hand weapon can **fail a requirement it passes in the main hand** — `requires Slash ≥ 2` is live in the main hand and greyed out in the off hand. The cost is expressed in access, which 2A.9 calls the expressive axis, rather than in a damage number.

**The tie resolves by priority** [AUTHORED 0.31.0]. A `1 / 1 / 1` footprint has no single highest type. Where two or more types tie for highest, the pip comes off **the one declared last** — the concession slot (2A.9). The author chooses the sacrifice by where they place it, and the result is derived rather than stored, so an off-hand form stays computable from the weapon record alone.

**This generalises past M-C11.** The tie is a property of the *selector*, not of this rule: a four-pip `2 / 2` two-hander ties for highest just as a `1 / 1 / 1` one-hander does, and any future rule reading "the highest type" inherits the same resolution instead of inventing its own. `◈M13` closed on that basis rather than on the narrow case that raised it.

| ID | Severity | Rule |
| --- | --- | --- |
| **M-C9** | Critical | Every shield draws a **2-pip pool**, split by sub-family — buckler **2/0**, standard **1/1**, tower **0/2** — where `offensive pips + defence pips = 2`. A shield never draws a second budget |
| **M-C10** | Critical | Offence and defence in a shield pool share the **same pip unit** — one defence pip is one 2A.4 signature step in a group that resolves through **typed defence**. Structural is not purchasable (**M-C2**); body-armour signatures are unbudgeted and are never evidence for a shield's |
| **M-C11** | Critical | A one-handed weapon equipped in the **off hand** has its **base** footprint reduced by one pip, taken from its highest damage type — **where types tie for highest, from the one declared last** (2A.9 martial priority) — before 2A.10's requirement check. Two-handers and shields are unaffected |
| **M-C12** | Critical | Innate magnitude is constrained **per node, never per body** — **M-C3** bars pooling, so a body total never resolves. Canonical base grades are **Incidental = 1**, **Dedicated = 2**, **Apex = 3**. Ordinary single-node ceiling is Apex; **4** requires a source committing two delivery hooks or an explicit Transgressive/Inscription exception |
| **M-C13** | Critical | Ordinary striking equipment draws a **2-pip pool** at its node — 1 offence, 1 local defence — and the ordinary offensive composite of innate plus equipment **saturates at 3**. Holding a weapon suppresses both at that hand |
| **M-C14** | Critical | An ordinary physical `[Combo-Action]` draws at most **3 from its primary source and 2 from its supporting source**. Innate promotion is **Permanent-tier only (H-C8)**; no skill adds pips |
| **M-C15** | Critical | Equipment interception is derived from the resolved target node, authored coverage and current item state. `Unarmoured` is derived, never persisted; no armour class grants universal Payload immunity |
| **M-C16** | Critical | Somatic authorizes deliberate natural-node Techniques but contributes no independent footprint or hook. The active bound node is the `innate_node` source. Faculty lifecycle persists entitlement/acquisition facts only; `known`, `selectable` and `executable` are derived at Technique-candidate grain and never authored as independent truth |
| **M-C17** | Critical | Base Faculty profiles are exact: Arcana = Divine 2 + Psychic 1 with voice; Mudra = Chaos 2 + Divine 1 with selected finger hooks; Psyche = Psychic 2 + Chaos 1 with Brain; Somatic carries no Faculty footprint or pull and reads its bound node |
| **M-C18** | Critical | Composite Faculty profiles are explicit unordered authorization records, never entitlements, with two distinct hooks and their authored five-pip footprint and primitive pull signature. No universal composition arithmetic exists; Arcana + Arcana and Psyche + Psyche are invalid, while Mudra + Mudra requires one possessed Mudra Faculty and two functional, unoccupied hands with distinct functional finger hooks |

---

## Part 3 — Equipment

### 3.1 Slot architecture

For each slot, complete the sentence *"This slot exists so the player can decide ___."* A slot that cannot complete it is merged or cut.

**The offhand slot has a locked identity:** one-hand-plus-offhand demands a *segment* of the triangle rather than a point, which makes it the control loadout against the two-hander's commitment loadout. That is a structural choice, not a damage-versus-defence trade, and the slot architecture should be built around it.

### 3.2 Aggregation pipeline

Order of operations from equipped items to final derived stats. This is a balance document, not an implementation detail.

```
class base (floor shape, home position)
+ permanent modifications      (sum-preserving; cap checked after)
+ worn threshold / dwell modifiers
→ reachable region and region access computed
+ flat additions (primaries)
→ recompute channel contributions (pull, floor extent, decay resistance)
+ flat additions (derived)
× additive-percent bucket (summed, applied once)
× multiplicative bucket (each applied separately)
→ Triade state modulation at evaluation time
→ conditional / situational layer
→ clamps and soft caps
→ final
```

Rounding rule and clamp position are specified once, globally. Ambiguity here is where late-project balance bugs live.

### 3.3 Synergy layer

Choose **one** primary mechanism: sets, tag thresholds, slot pairs, or sockets. Two mechanisms competing for the same design space produce mush.

Given the Triade, tag thresholds are the natural fit — "5+ Pressure-tagged pieces equipped" reads directly against a system the player already understands.

### 3.4 Modification and upgrade

Governed by the permanence rules in Constitution 0.5. Each mechanism must answer: what resource it consumes, what decision it forces, and whether it can be undone.

Permanent reshaping requires **mandatory preview** of the resulting floor shape before commit, and **reversal at steep cost**. Irreversibility is only fair when fully informed.

### 3.5 Swap rules

Mid-combat swapping, swap cost, locked or cursed items. A pacing lever, not a convenience setting. Note that swapping changes clumsiness and region vocabulary immediately, so swap cost interacts directly with the credit economy.

### 3.6 Comparison and UI data contract

*Visual encoding requirements live in `V-Visual_design_TRIADE-0_44_0.md` (V·4.7). This section defines the **data contract** — what the model must expose for the UI to render.*

Write the tooltip spec now, because it defines what the data model must expose:

- current versus candidate delta
- which stats are build-relevant
- why an affix is greyed out
- breakpoint proximity
- **weapon demand versus reachable envelope** — *within reach* / *at the edge of your reach* / *beyond you*
- **clumsiness penalty** if any
- **region vocabulary gained and lost** on swap

The last three are not optional. Without them the player cannot evaluate a drop at all, and the trace system deliberately does not help here — traces tell designers whether an item is distinct, not players whether it is for them.

**Gate 3:** slot list with justifications; aggregation pipeline documented and unit-tested with golden cases; tooltip data contract signed off; a naive player can evaluate an unfamiliar weapon from its tooltip alone.

---

## Part 4 — Foundations

Prerequisites for the agentic track. Building agents before these exist produces plausible content that silently breaks the game.

1. **Content is data, never code.** JSON/YAML under version control, one file per domain.
2. **JSON Schemas for every content type.** The schema is the contract an agent writes against.
3. **Deterministic seeded RNG with named streams** (`loot`, `affix`, `combat`, `layout`).
4. **Headless simulation CLI** with machine-readable output.
5. **Trace instrumentation with per-delta attribution** — built in from day one, not retrofitted.
6. **Golden and snapshot balance tests.** Committed baselines; any shift flags for review.
7. **Content linter.** Unique ids, tag budgets and cardinality rules, exclusivity groups, power-budget bands, floor-budget and per-corner caps, threshold legality, name collisions, orphaned references, readability budget.
8. **Reference builds, classes, weapons and encounters.** A frozen fixture set. Everything is measured against these.

---

## Part 5 — Agentic development

### 5.1 Operating principles

1. **Agents propose data; code decides truth.** No agent owns a balance formula. They own parameters, validated by the formula.
2. **Every generator is paired with a verifier.** A generator grading its own work grades generously.
3. **Mechanics and flavour are separate agents.** Combined, the model bends numbers to fit a good name.
4. **Human gates at intent level, not per item.** Review the brief and a sampled batch, not 400 swords.
5. **All output reproducible.** Log prompt version, model, seed and input schema hash with every generated record.
6. **Small, typed, testable outputs.** One call → one schema-valid record → automatic validation → accept/reject/repair.

### 5.2 Agent roster

| Agent | Owns | Verified by |
| --- | --- | --- |
| **Schema Steward** | schemas, migrations, id registry | CI, human |
| **Triade Steward** | action contract schema, archetype library, region definitions | **human only — no agent may add archetypes or alter region geometry** |
| **Stat Architect** | stat records, channel parameters, curve params | Sim Runner + Balance Auditor |
| **Weapon Smith** | weapon records: chassis, construction, pip footprint, pull vectors, archetype, vocabulary, clumsiness | Linter (pip budget, zero-sum pulls, anchor reachability, structural legality — all hard) + trace divergence gate + Trajectory Auditor |
| **Shield Smith** | shield records (dual-nature). Owns the **shield budget** — the pooled offence/defence split that neither parent agent owns | Linter (shield budget, sub-family fit, both parent suites, lean-scaling, dual-path vocabulary — all hard) + Balance Auditor (loadout dominance) |
| **Armourer** | armour and trinket records: construction family, group resistances + sharp exceptions, integrity profile, weight class, stat effects | Linter (exception budget, **global** matchup surface, Bridge-2 consistency, integrity coherence — all hard) + Balance Auditor (slot-fit Pareto) |
| **Affix Librarian** | affix pool, tiers, tags, weights | Linter + power-budget check |
| **Bestiary Composer** | enemy tag compositions | Linter (cardinality) + Trajectory Auditor |
| **Class Smith** | class/sub-class stat offsets + growth gradients | Linter (offset sums to zero — hard) + Trajectory Auditor (build-trace redundancy, brief-fit) |
| **Skill Smith** | skill records: anchors, angular windows, falloffs, level ladders, pip redistribution | Linter (reachability, demand-consistency, ladder monotonicity, pip conservation — all hard) + Trajectory Auditor (anchor redundancy, coverage) |
| **Routine & Effects Designer** | non-numeric affixes, unique effects, behaviour policies | human + integration tests |
| **Loot Curator** | drop tables, weights, pity and shape-awareness params | Sim Runner |
| **Namer/Flavourist** | names, descriptions, tone (sees behaviour, not raw numbers) | style linter + human sample |
| **Lexicographer** | Dictionary fragments (verbs, clauses, lore vocabulary, per-skill/enemy narration) | style linter + human sample; hard rule: fragments describe resolved events, never decide them |
| **Trajectory Auditor** | trace analysis — coverage, dominance, spirals, redundancy | deterministic metrics |
| **Balance Auditor** | adversarial critique | human |
| **Sim Runner** | executes sweeps, summarises, diffs against baselines | self-verifying |
| **Exploit Hunter** | searches for degenerate multiplier chains and credit loops | Sim Runner reproduction |
| **Integrator** | branch, apply, test, open PR | CI + human merge |

**M-C5 · Class and sub-class starting offsets sum to zero.** The Class Smith's output is gated on it as a hard linter check (above). The concept is T's — class is a starting *offset* on the barycentric position, not a stat grant (T·4.8) — but the constraint is enforced here, on the record M owns.

Every agent gets a written charter: mandate, inputs, outputs, hard constraints, forbidden actions, escalation triggers.

### 5.3 Workflow — weapon creation

```
[human] Brief: archetype, target region, tier, tag theme
   │
   ├─ Schema Steward: confirm schema version, reserve id block
   │
   ├─ Weapon Smith → candidates (mechanics only, placeholder names)
   │      authors: chassis, construction, pip footprint, pull vectors,
   │               archetype/volatility/recovery, vocabulary, clumsiness curve
   │
   ├─ Linter — HARD GATES (arithmetic, instant)  [auto-reject → repair, max 3 attempts]
   │      • PIP BUDGET: total pips within the band for tier/rarity
   │      • ZERO-SUM PULL: every pull vector sums to zero (A2.4)
   │      • ANCHOR REACHABILITY: every skill in the granted vocabulary has an
   │        anchor the weapon's own pull can actually reach
   │      • DEMAND CONSISTENCY: demand tier derived, not authored
   │      • STRUCTURAL LEGALITY: Shatter/Tear pips require a chassis that
   │        plausibly carries them
   │      • LOADOUT SHAPE: offhand-capable weapons declare segment demand,
   │        two-handers declare point demand (E.3)
   │
   ├─ Sim Runner: TTK/TTL sweep + trace capture, 10k seeds
   │
   ├─ TRACE DIVERGENCE GATE
   │      within-type distance check AND across-type check
   │      below threshold → auto-reject as redundant, regardless of numbers
   │
   ├─ Trajectory Auditor: coverage, region residency, spiral index,
   │                      credit-economy shape
   │
   ├─ Signature coherence (advisory):
   │      • does the pip spread match the declared archetype?
   │      • affinity / vocabulary / efficiency alignment (E.1) — is this a
   │        *pure* weapon or a *technical* one? Flag unintended divergence.
   │
   ├─ Balance Auditor: outliers, dominance analysis, "is this interesting?"
   │
   ├─ Exploit Hunter: combine with top-20 affix sets, flag outliers
   │
   ├─ [HUMAN GATE] accept / revise brief / reject
   │
   ├─ Namer/Flavourist
   │
   └─ Integrator: PR with records, sim report, audit findings, regression diff
```

**Repair loop rule:** three failed validations escalate to a human. Repeated failure usually means the brief or schema is wrong, not the output.

**The pip budget is the weapon equivalent of the class offset's sum-to-zero rule** — a hard arithmetic gate that makes weapons safely agent-generable. An agent may propose freely; anything outside the band is auto-rejected before a human or the sim sees it.

### 5.4 Workflow — armour creation

```
[human] Brief: slot, construction family, weight class, defensive role
   │
   ├─ Armourer → candidate record
   │      authors: construction family, group resistances, sharp exceptions,
   │               integrity profile, weight class, stat effects, encumbrance
   │
   ├─ Linter — HARD GATES:
   │      • M-H1 EXCEPTION BUDGET: at most 2–3 sharp exceptions per family (2A.4)
   │      • MATCHUP SURFACE (GLOBAL): total non-generic weapon-type × armour-family
   │        pairs across ALL armour stays near the ~20 target
   │      • M-H4 BRIDGE-2 CONSISTENCY: the displacement mechanism matches the weight
   │        class — heavy → [EDM] damping, light → home-well pull,
   │        cloth → zero encumbrance. No mixing.
   │      • INTEGRITY COHERENCE: rigid construction → low Shatter resistance,
   │        high Tear resistance; flexible → the inverse (rigid discontinuity, 2A.4)
   │      • STAT EFFECTS: feed effective fields; per-corner cap respected after
   │        rendering (Triade A4.2)
   │
   ├─ Sim Runner: eHP sweep + trace capture (defensive currency, not eDPS)
   │
   ├─ Trajectory Auditor:
   │      • does the piece change the wearer's dot behaviour as its weight class
   │        promises? (heavy should visibly reduce displacement in trace)
   │      • integrity → Opening interaction: does Bridge 1 fire as expected?
   │
   ├─ Balance Auditor: SLOT-FIT — does this give its slot a decision, or is it
   │                   strictly dominated? Pareto analysis across the slot.
   │
   ├─ [HUMAN GATE] → Namer/Flavourist → Integrator
```

**M-H2 · The matchup surface is a *portfolio* constraint, not a per-item one.** Most validation is per-record; this one is global. The Armourer must know how much exception budget remains across the whole armour set before proposing new ones — otherwise each piece looks locally fine while the set collectively drifts past what a player can learn. Treat remaining surface budget as an input to the brief.

### 5.4a Workflow — shields (Shield Smith)

Shields get a dedicated agent, and the reason is specific: **they need a budget rule that neither parent agent owns.** The Weapon Smith owns pip budget; the Armourer owns defence budget; *neither* owns the tradeoff between them. That orphaned rule — the shield budget (2A.11) — is the Shield Smith's defining mandate.

```
[human] Brief: sub-family (buckler / standard / tower), defensive role, vocabulary theme
   │
   ├─ Shield Smith → single record (weapon fields + armour fields)
   │
   ├─ Linter — HARD GATES:
   │      • SHIELD BUDGET: pips + defensive value drawn from ONE pooled budget.
   │        A shield may not hold a full weapon budget and a full armour budget.
   │      • BUDGET/SUB-FAMILY FIT: the split must match the declared sub-family
   │        (buckler pip-heavy → tower defence-heavy) and its weight class
   │      • ALL WEAPON HARD GATES (zero-sum pulls, anchor reachability, …)
   │      • ALL ARMOUR HARD GATES (integrity coherence, Bridge-2 consistency, …)
   │      • LEAN-SCALING CURVE: defensive contribution must scale with Form-ward
   │        lean (2A.11) — a flat curve is rejected
   │      • DUAL-PATH VOCABULARY: must support BOTH Opening-creation verbs
   │        (Discipline counter AND Pressure displacement). Supporting only one
   │        is rejected — that is not a shield.
   │
   ├─ Sim Runner: eDPS *and* eHP sweep — a shield is scored on both currencies
   │
   ├─ Trajectory Auditor: trace divergence vs existing shields; does the
   │                      budget split read as its sub-family in play?
   │
   ├─ Balance Auditor: LOADOUT DOMINANCE — does one-hand+this-shield dominate
   │                   an equivalent two-hander? The check the shield budget exists to protect.
   │
   └─ [HUMAN GATE] → Namer/Flavourist → Integrator
```

Shield integrity is validated on its own track, independent of body armour. **Loadout dominance is the audit that matters most** — it is the failure the shield budget exists to prevent, so it is checked explicitly rather than assumed.

### 5.5 Workflow — affix batch

```
[human] Brief: tag theme, tier, count, applies_to filter
  → Affix Librarian: N candidates
  → Similarity check against existing pool (semantic + numeric distance)
  → Power-budget conversion; triade_effect affixes priced by simulation delta
  → Exclusivity, tag-budget and threshold-legality validation
  → Sim: 5k generated items using the new pool; item-power distribution
         inside band, tag coherence not degraded
  → Auditor: "does this batch add decisions or just entries?"
  → [HUMAN GATE] → Namer → Integrator
```

### 5.6 Workflow — bestiary composition

```
[human] Brief: chassis, tier, encounter role
  → Bestiary Composer: tag sets respecting cardinality rules
  → Linter: cardinality, contradictory pairs, floor renormalisation legality
  → Sim: enemy trace capture against reference builds
  → Trajectory Auditor: enemy-trace clustering — flag if too close to existing
  → Encounter validator: tag diversity within groups
  → [HUMAN GATE] → Namer → Integrator
```

`chassis × role` is validated exhaustively; the modifier space is sampled. Renormalisation guarantees no combination is structurally illegal.

### 5.6a Workflow — skill creation

Skills are strongly agent-suited: the record is typed, most validation is arithmetic, and quality is trace-measurable. The Skill Smith proposes the record; everything downstream is deterministic.

```
[human] Brief: region/verb, anchor neighbourhood, demand class, class or weapon family
   │
   ├─ Skill Smith → skill record (anchor, angular window, falloff, level ladder,
   │                              sources, weapon requirement, pip redistribution)
   │
   ├─ Linter (hard gates, instant):
   │     • anchor reachable inside the owning class's floor-clipped grid
   │     • demand_tier == value derived from angular_window (flags exempt)
   │     • access_scope matches vocabulary membership
   │     • ladder monotonic (additive + qualitative; windows tighten)
   │     • pip redistribution zero-sum (unless Transgressive/Inscription)
   │
   ├─ Sim: fire the skill across reference builds × encounters × seeds
   │
   ├─ Trajectory Auditor:
   │     • anchor redundancy vs existing skills (EMD-style)
   │     • anchor coverage — does this fill a void or crowd a cluster?
   │     • class-anchor fit — positional workload it adds to its owner
   │
   ├─ Balance Auditor: is ⌬L3 worth its precision demand? is the skill dominated?
   │
   ├─ [HUMAN GATE] accept / revise brief / reject
   │
   ├─ Lexicographer: Dictionary fragments per level per outcome
   │
   └─ Integrator: PR with record, sim report, coverage delta
```

**The coverage map is the brief generator.** Projecting all skill anchors onto the grid shows clusters (redundant design space) and voids (unused regions) — and a void is a machine-specified brief: *"a skill anchored near `FoDi/2`, Focused demand."* That closes the loop from validation back into generation, exactly as the weapon coverage map does.

### 5.7 Workflow — rebalance

```
Trigger: telemetry or playtest flags an outlier
  → Sim Runner reproduces from seeds   [not reproducible → stop; it's feel, not maths]
  → Balance Auditor proposes ≤3 minimal parameter changes with predicted effects
  → Sim Runner evaluates each against the full regression fixture set
  → Identity-drift check: did any signature move significantly?
  → [HUMAN GATE] pick one
  → Integrator applies; baselines updated with justification in the commit
```

### 5.8 Bulk content

Batch generate → validate → **sample-review 10%** → accept or reject the batch wholesale. Never review bulk content item by item; the review budget belongs at the brief and the sampling.

### 5.9 Forbidden to agents

- Changing schemas outside the Schema Steward workflow
- Altering region geometry, membership thresholds, floor budgets or caps
- Modifying balance formulas, the aggregation order, or RNG stream definitions
- Updating golden baselines
- Authoring uniques, reach-granting items, or new archetypes
- Inventing stats, tags or behaviour policies outside the frozen taxonomy

### 5.10 Instrumentation

Log per artefact: agent id, charter version, model, prompt hash, input schema hash, seed, validation results, human verdict. Auditable provenance, and eventually the data to tell which briefs produce good content.

---

## Part 6 — Sequencing

| Phase | Focus | Exit criteria |
| --- | --- | --- |
| **M⇥0** | Design Constitution | 0.7, 0.9, 0.10 answered; reference fantasies written |
| **M⇥0.5** | **Triade structure** — state machine, action contract, region geometry, floor model, one proof action per region, trace instrumentation | **Gate T** |
| **M⇥1** | Stat model, channels, schema, sim harness | Gate 1 |
| **M⇥2** | Foundations (Part 4) | Seeds, linter, golden tests, fixtures, attribution |
| **M⇥3** | Item pipeline, minimum affix pool, class and weapon vocabularies — hand-authored | Gate 2 on a small pool |
| **M⇥4** | Equipment layer, aggregation, tooltips, modification system | Gate 3 |
| **M⇥5** | Agents on the narrowest domain first — affix names, then affix numbers | One workflow end-to-end with human gate |
| **M⇥6** | Scale agents to weapons, equipment, bestiary, loot tables | Content velocity up without regression drift |
| **M⇥7** | Telemetry-driven rebalance loop | Rebalance closes automatically from flag to PR |

Agents enter at M⇥5 deliberately. Their value is proportional to validator quality, and the validators are M⇥2–M⇥4.

---

## Part 7 — Risks

| Risk | Mitigation |
| --- | --- |
| **Complexity, not balance, is now the primary risk.** Position, three credit layers, regions, floors, tags | Regions are derived not tracked; credit caps are small integers; total tracked state is six numbers. Prototype readability at J.9 before finalising maths. If the state cannot be read in half a second, simplify the maths |
| Agent content is plausible but flat | Interest is not machine-checkable. Trace divergence clears duplicates; the human gate stays permanently on briefs and sampled batches |
| Power-budget validation becomes the design | The budget is a floor and ceiling, not a target. Reserve a deliberate quota of intentional outliers |
| Triade effects mispriced | Simulation-delta pricing only. Never a flat coefficient |
| Weapon redundancy hidden by type clustering | Divergence evaluated within type as well as across it |
| Modification dissolves class identity | Sum-preservation, per-corner cap after modification, and the build-trace divergence check against class baselines |
| Off-class drops feel worthless | Clumsiness penalty capped; smart-loot dial tuned deliberately; shape-aware pools |
| Multiplier chains discovered late | Exploit Hunter runs on every batch, not at milestones |
| Sim says balanced, players say unfun | Sim gates arithmetic. Playtest gates feel. Neither substitutes for the other |
| Content volume outpaces review | Sampling protocol with batch accept/reject |

---

## Part 8 — Open questions

*Standardised at 0.11.0. Every live item carries **[OPEN]**; provisional numbers carry **[SIM]**. Mirrored in `B-Open_Items_Index_TRIADE-0_44_0.md`.*

**Removed as resolved:** *Position persistence out of combat* was a duplicate of T·1 and is answered by K17 — decay toward home over two or three exploration turns.

| # | Question | Marker | Blocking |
| --- | --- | --- | --- |
| **◇M9** | **`[Inventory]` is undesigned.** M defines what items *are* and never what holds them — no carry capacity, no slot count, no drop or discard mechanics, no quest-item class. Salvage, reroll, remedy items and now `[Secret]`/`[Relic]` all assume a container specified nowhere. W§5.8a routes around it with the run-scoped key register, which is why storeys are not blocked; the gap remains | **[OPEN]** [GAP] | **No owner** |
| ~~**◈M11**~~ | **CLOSED 0.24.0.** `medium` is a weight class this document defines: 2A.7 gains a fourth row. *Mechanism corrected at 0.25.0* — a second well at the barycentre, replacing the [Dot Dynamics] damping first authored | **CLOSED** | — |
| ~~**◈M12**~~ | **CLOSED 0.28.0, restated 0.29.0.** Both questions answered in 2A.11 — a flat **2-pip** pool with an authored split (**M-C9**) and one shared pip unit (**M-C10**). The rating unit was never missing; it was the weapon unit all along. `S-M05` struck at 0.29.0 — the split is authored, not measured | — | — |
| ~~**◈M13**~~ | **CLOSED 0.31.0.** Ties resolve to the **last-declared** type — footprint order is martial priority, signature first, concession last (2A.9). Generalises to any *highest type* selector, including a `2/2` two-hander | — | — |
| ~~**◈M14**~~ | **CLOSED 0.37.0.** Magnitude is constrained **per node** — a body total never resolves under M-C3. Grades 1/2/3, ordinary ceiling 3, striking equipment a 2-pip pool saturating the composite at 3, `[Combo-Action]` at 3+2, and **a bare humanoid may reach 3 by Permanent conditioning alone** (H-C8). *My per-body budget proposal was withdrawn: it constrained a quantity that never appears in play* | — | — |
| ~~◈M1~~ | **CLOSED 0.14.0** — Part 9. Structure was already in W·5.4/5.5; duration, acquisitions and the death ledger are now locked. *Superseded text:* Run length and death model (0.7) — governs item acquisition count per run. Interacts with W's Stratum run structure (1→3, 4→9, 10). **Reclassified 0.13.0: this is a choice, not a measurement.** A sweep can test whether a chosen model survives contact; it cannot produce the target. Gate 0 requires it *before* M⇥1 builds the harness, so classifying it as harness-blocked was a deadlock on paper only | **[OPEN]** | **Design — gates the harness** |
| ~~◈M2~~ | **CLOSED 0.14.0** — Part 9.2. **×9 career**, derived per storey from locked geometry. *Superseded text:* Target power multiple (0.9) — the single number that sets affix tiering. **Reclassified 0.13.0, same reason as ◈M1**: ×N start-to-end is chosen and then validated, never measured into existence | **[OPEN]** | **Design — gates the harness** |
| **◇M3** | **Readability budget** (0.10) — tooltip number cap, tighter than usual given Triade screen cost. *Pressure increased at 0.10.0: five resources are now spendable at town (◇H14).* **Moved to the prototype track at 0.13.0** — this is a legibility measurement in the same family as S-V01 and S-V04, answered by a recognition test rather than a sweep, and it should run in the same session as ◇V6 | **[OPEN]** [SIM] | **Prototype *(with ◇V6)*** |
| **◈M10** | **Reference fixture set — fantasies written 0.14.0 (Part 9.5), builds still unowned.** The three fantasies are the prose form of K·15's builds, so fantasy and fixture are one object. Encounters, weapons and classes remain unspecified, and Gate T's T-H2/T-H4 measure against them. *Original:* The reference fixture set is unowned. Part 4 item 8 requires *"reference builds, classes, weapons and encounters — a frozen fixture set"*, and Gate T's **T-H2** and **T-H4** both measure against it. K·15 already names three builds — **Pressure striker**, **Discipline controller**, **Instinct technical** — but no document owns the set, and nothing tracked it until now. Encounters, weapons and classes remain unspecified | **[OPEN]** [GAP] | **No owner** |
| **◇M4** | **Smart-loot dial value** — interacts with clumsiness; discovery versus frustration | **[OPEN]** [SIM] | Balance |
| **◇M5** | **Synergy mechanism** (3.3) — tag thresholds recommended, but pick one and commit | **[OPEN]** | Design |
| **◇M6** | **Temper versus item economy overlap** (2.8) — confirm they fund different decisions. *Widened at 0.10.0: seven currencies now exist across four documents; no single owner* | **[OPEN]** | Economy |
| **◇M7** | **Scrap ↔ Flux conversion** — independent sinks or convertible? Does dismantling yield both? *(raised as ◇H13)* | **[OPEN]** | Economy |
| **◇M8** | **Remedy items belong here, not in H.** H·8.2's remedy table is item content sitting in a rules document; the set's pattern is that K owns combat rules while M owns weapons. Move when M is next opened | **[OPEN]** | Housekeeping |

Triade-internal open questions are listed in Part K of the Core Mechanic document. All open items across all eight documents are collated in the Open Items Index.

---

## Part 9 — The run contract [LOCKED 0.14.0]

*Answers Constitution 0.7 and 0.9, closing **◈M1** and **◈M2**. Structure was never open — W·5.4 made each band a run unit and W·5.5 specified collapse. What was open was duration, acquisition count, the death ledger and the power multiple.*

### 9.1 The storey is the pacing unit

Not the Delve level. Both are locked, and the storey count falls out of them:

| Band | Delve levels *(S-W01)* | `N` *(W·5.8)* | **Storeys** | Duration |
| --- | ---: | ---: | ---: | --- |
| **A** 1→3 | 3 | 1 | **3** | 30–45 min |
| **B** 4→9 | 6 | 2 | **12** | 60–90 min |
| **C** 10 | 1 | 3 | **3** | **75–110 min** *(was 120–180)* |
| | | | **18** | |

**Band C's target was reduced at 0.14.0.** Bands A and B agree exactly at 10–15 minutes per Delve level. The old 120–180 figure asked 8–18× that for a single level, which no comparator supports and which contradicts W·5.8's own lock that `N` **partitions** the space budget rather than multiplying it. 75–110 keeps band C a summit — roughly 3× the per-level pace, justified by three storeys and a terminal boss — without leaving the genre band where every comparator's *whole run* lives.

*Both independent Gate 0 studies derived this contradiction separately, with the same arithmetic and the same citation.*

### 9.2 Power — 9× career, derived per storey

**The multiple is a career quantity, not a per-run one.** Gear persists through the town return, so bands compound.

Uniform growth per storey over the locked 18:

| Band | Storeys | Multiple |
| --- | ---: | ---: |
| A | 3 | ×1.44 |
| B | 12 | ×4.33 |
| C | 3 | ×1.44 |
| **Career** | **18** | **×9.0** |

**Band C equals band A because both are three storeys.** That is the point: it removes the terminal-band anomaly at its root rather than patching around it.

| Quantity | Value | Basis |
| --- | --- | --- |
| Career effective damage | **×9** | precedent — inside the 8–15× comparator band; Slay the Spire's Corrupt Heart implies ≈10× required damage-per-turn |
| Career effective survivability | **×3** | precedent — survivability universally grows slower than output |
| Peak single-action burst | **≤ ×30** | precedent, tightened — H's Finisher threshold already makes a burst spike a kill mechanic |
| Per-storey growth | **×1.130** | **derived** — `9^(1/18)` |

**This is derived, not swept.** Per the register's own principle a number falling out of locked geometry is not a `[SIM]` value. `S-M02` records the career target; the per-band split is arithmetic, not a second guess.

### 9.3 Acquisitions — two major per storey

| Band | Storeys | Major acquisitions |
| --- | ---: | ---: |
| A | 3 | **6** |
| B | 12 | **24** |
| C | 3 | **6** |
| **Career** | **18** | **36** |

Precedent puts full-run acquisitions in the low tens; the best-documented comparator dataset gives ~24–25 cards plus ~15–21 relics per winning run. Band B at 24 sits on that figure.

**The consequence is the reason this number exists.** With 9× over 36 acquisitions, average per-pick value is:

```
g = 9^(1/36) = 1.063   ->  6.3% per acquisition, CONSTANT across the career
```

**Uniform per-pick value is what makes loot legible** — an item is worth the same wherever it drops, so a player learns one sense of "good" instead of three. It also disciplines the affix pool: at two major acquisitions per storey nothing small is ever perceptible, which argues against a large pool of micro-affixes. `S-M01`.

### 9.4 Death — what death costs is what was carried

W·5.5 as amended at 0.14.0. **Purchased access is never lost;** collapse takes unspent Grounding, the Stratum's `[Modification Ceiling]`, the temporary build, and an unsecured `[Relic]`. Wounds may persist, priced in renewable currencies only (H·8.1).

**No mid-run revive.** Stated as a negative: bounded 30–110 minute bands do not need one, and `[Relic]`-lost-on-collapse already carries the push-or-bank tension a revive would blunt.

**Band C alone may be left through one interior exit** (W·5.4a). Bands A and B have no partial lock.

### 9.5 The three reference fantasies

**Not invented — derived.** K·15 already names three reference builds, and Gate T's `T-H2` and `T-H4` measure against them. Writing unrelated fantasies would fork the fixture set, so these are the prose form of those builds and they *are* **◈M10**'s content.

**Fantasy 1 — The Striker** *(Pressure)*. *I commit, and commitment is visible.* I lean deep into Pressure and my floor shape says so before I act. Elites read me as overcommitted and convert against me — that is the price. I pay it because from that position my vocabulary opens actions nothing else reaches, and a Finisher lands before the exchange becomes a grind. I win by making fights short and accepting I cannot afford to be wrong twice.
*Exercises:* deep single-corner residency · Advantage conversion against the player · Finisher gating · burst headroom · `[Back-foot]` recovery.

**Fantasy 2 — The Controller** *(Discipline)*. *I never take the fight I was offered.* I sit near home and the sector-floor render's super-additivity pays me for balance. I spend AP on Watch and Pivot rather than damage, and take the Riposte when it comes. A Commander charging its Signature is my failure condition, so I play tight and it never charges. I win slowly, and the enemy never gets the exchange it wanted.
*Exercises:* balanced-parent sector floors · Watch/Riposte ladder · zone graph and Pivot economy · relational readiness · Signature throttling.

**Fantasy 3 — The Technical** *(Instinct)*. *I read the body, not the health bar.* I aim, and aim degrades gracefully when I am out of position, so my positioning **is** my accuracy. I break the arm that holds the weapon and the jaw that speaks the spell. My damage numbers are unimpressive and my opponents stop working. I win by removing capability rather than hit points.
*Exercises:* `aim_weight` and `AIM_CEILING` · coverage cascade and per-pair weights · `function_denial` · faculty gates `[Arcana]`/`[Mudra]`/`[Psyche]` · wound severity tiers.

**Why these three.** They partition the triangle, map one-to-one onto the existing fixture builds, and between them exercise every subsystem locked through 0.14.0. **Fantasy 3 carries extra weight deliberately** — it is the only one that fails if Stage 1's anatomical gating does not hold, making it the fixture that validates the newest architecture.

### 9.6 Power attribution — instrument in logs

Effective run power decomposes multiplicatively, so instrument it additively:

```
ln P_effective = ln P_gear + ln P_synergy + ln P_vocabulary + ln P_execution
```

This lets the harness attribute an outlier run to raw item magnitude, one interaction, unusual vocabulary breadth or execution efficiency — rather than reporting only that a run was strong. It plugs directly into T·I.1's trace instrumentation and is a **Stage 2c harness requirement**, not an optional analysis.

**No single interaction may deliver more than ~20% of a band's total log-power gain** unless it is an authored unique with a named drawback — the T-H1 named-brake requirement expressed in the power layer. Rule **M-H5**.

### 9.7 Enemy scaling follows the curve

```
E(x) = P(x) x (0.92 + 0.18x)
```

Expected encounters begin at ~92% of reference-build power and end at ~110%. **This is an encounter budget, not a health multiplier** — it covers durability, action quality, behaviour tags, spatial pressure and resource denial. Scaling enemy health alone would lengthen combat without testing the Triade.

**This is what stops cleared bands trivialising on replay**, which a 9× career multiple would otherwise guarantee. It lands on **W** (Stratum scaling) and **E** (tier mix), and neither document currently states it — registered as **◇W17**/**◇E11**.

---

---

## Changelog

| Version | Change |
| --- | --- |
| **0.44.0** | Version alignment only. P12-C binds exact candidates and milestone timing without changing equipment occupancy, Faculty footprints, source composition or the two-hook Combo ceiling. |
| **0.43.0** | **P12-B readiness terminology aligned.** Faculty lifecycle stops at possession. `known`, `selectable` and `executable` derive at Technique-candidate grain; any Faculty-level readiness remains a generated aggregate. Mudra && Mudra continues to require both functional, unoccupied hands with distinct functional finger hooks inside one candidate (**M-C16**, **M-C18**). |
| **0.42.0** | **P12-A entitlement boundary adopted.** Composite Faculty profiles are authorization profiles, never separate entitlements. `possessed` derives from conferred/acquired; acquisition normally survives unlock-source loss. Mudra && Mudra requires one possessed Mudra plus two functional, unoccupied hands with distinct functional finger hooks (**M-C18 amended**). |
| **0.41.0** | **`◈P11` Faculty semantics adopted.** Four immutable Faculty identities, corrected execution hooks, exact three-pip base profiles, four explicit five-pip composites and primitive actor-pull signatures are authored (**M-C17**, **M-C18**). Definition origin is removed; actor entitlement provenance remains with `◇P12`. Lineage may explicitly confer or unlock Somatic. |
| **0.40.0** | **Somatic Faculty authored.** The family is authorization for deliberate natural-node Techniques, with `source_mode = bound_node`, no independent footprint and no hook (**M-C16**). Faculty lifecycle distinguishes conferred, unlocked and acquired; availability remains derived. `[Innate]` stays lineage-owned physical capacity rather than returning as a Faculty. |
| **0.39.0** | Version alignment only. A2 leaves M's target-layer and equipment-interception ownership unchanged; armour does not rewrite anatomical probability merely by covering a node. |
| **0.38.0** | **Session A target-layer boundary.** §2A.4a derives shield/equipment interception from the resolved body node and current coverage state; `Unarmoured` is derived and universal armour immunity is barred (**M-C15**). |
| **0.37.0** | **`◈M14` closed — magnitude is per node, never per body.** M-C3 bars pooling, so a body total never resolves; grades 1/2/3 with an ordinary single-node ceiling of **3** and 4 reserved for a source committing two delivery hooks (**M-C12**). Striking equipment is a **2-pip pool** whose composite with innate saturates at 3 (**M-C13**). `[Combo-Action]` draws **3 + 2** — the dual-wield envelope exactly (**M-C14**). **A bare humanoid may reach 3 by Permanent conditioning alone**, the first consumer of **H-C8**. |
| **0.32.0** | **The faculty record loses `innate`; three families remain.** The slot table and its `gate_nodes` pointer are deleted — an attachment replaced a pointer maintained by hand. **How a hand resolves** authored: a hand is its weapon, or innate plus striking equipment when empty, never both. Offence-bearing sources enumerated — weapon, shield *(not armour)*, and gloves/boots; all other worn equipment is defence-only, with the general case **rejected**. `◇M14` registered for magnitudes. |
| **0.31.0** | **`◈M13` closed — footprint order is martial priority.** 2A.9 authors the list as *signature first, concession last*; **M-C11** now removes from the last-declared type where types tie for highest. The resolution belongs to the **selector**, so a `2/2` two-hander inherits it. Randomising the drop was rejected: it would make footprint a property of the copy, contradicting 2A.10's object-boundary rule, and would leave skill access unknowable until equipped. |
| **0.29.0** | **Shield budget restated and the off-hand transform authored.** Every shield draws **2 pips**, split buckler 2/0, standard 1/1, tower 0/2 — the split is authored, so `S-M05` is struck. **M-C10** gains the Structural exclusion; **M-C11** takes one pip off a one-handed weapon in the off hand, from its highest type, before 2A.10's requirement check. 2A.3's Occult row moved back inside its table. `◇M13` registered for the tie. |
| **0.28.0** | **`◈M12` closed — the shield pool is sized and both natures share a unit.** 2A.11 authors **M-C9** (buckler 1, standard 2, tower 2 base pips) and **M-C10** (one defence pip = one 2A.4 signature step). The second pip is paid for by 2A.6's coarser attrition and `Broken Guard`. `Impact ++` re-derived to `Impact +` — it was an undated illustration that overspent every pool. |
| **0.27.0** | Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | **◇M12 registered** — M-C4 requires one pooled shield budget and 2A.11 names a defence signature, but **no rating unit or budget scale exists**. Representation and unit are M's; the magnitude is a later `[SIM]`. M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | **Medium's mechanism corrected** — a second, shallower well at the **barycentre**, replacing the [Dot Dynamics] damping authored at 0.24.0. *All-rounder: every region reachable, none reachable deeply.* A **second well, not a shifted home** — home position feeds commitment cost, class-anchor fit and clumsiness, and moving it would silently re-tune all three. Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | **2A.7 gains a fourth weight class — `Medium`, damping [Dot Dynamics]** [AUTHORED 0.24.0]. Derived, not chosen: A2.2's model is B + D with C localised, Heavy held (B), Light held (D), Cloth none, and **(C) was the one component no class engaged**. **◈M11 closed.** 2A.11's Standard shield now has a defined mechanism. Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | **`Broken Guard` replaces `Fractured` for shields** [AUTHORED 0.23.0] — 2A.6 now states `Stable → Cracked → Broken Guard` for shield and rigid off-hand profiles, body armour keeping the three-state path. First `AUTHORED DESIGN DECISION` centralised from the technical stream. **◇M11 registered**: `medium` is not a weight class 2A.7 defines. M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | **Three ID-bearing statements authored** — `M-C3` at 2A.10, `M-C5` restated below the 5.2 roster so it leads its line, `M-H4` on the 5.4 Bridge-2 gate. None needed writing; all three were stated and untagged. Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | **Five ID-bearing statements authored** — `M-C2` (2A.3), `M-C4` (2A.11), `M-H1` (5.4), `M-H2` (5.4), `M-H3` (2.5). `M-C3`, `M-H4` have no statement to tag and `M-C5`'s source is `T · 4.8`; all three stay in ◇P7. Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | Its sequencing phases become **M⇥0**–**M⇥7**, including `M⇥0.5`. They had collided with **P**'s open items ◇P1–◇P9, and lines 986 and 1118 carried both senses in one sentence. Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **57 glyphed identifiers in this document.** |
| **0.17.0** | **Handedness fixes the ordinary base pip budget** (§2A.9) — one-handed = **3** base pips, two-handed = **4**. Handedness fixes the total only; distribution stays authored per chassis. The worked example is rewritten: the one-handed sword that had carried `Slash ++, Impact +, Pierce +` since the first draft was a **four-pip one-hander**, and it was the sole evidence for a norm P·10.3 had already flagged as unverified. It becomes a **`2h-Sword`**; the one-handed form is `Slash ++, Pierce +`. **Trade-off named:** a one-hander can no longer be strengthened by carrying more pips, only better-placed ones — distribution is the expressive axis, magnitude is not. **Handedness qualifiers locked** — families legally existing in both forms use `1h-` / `2h-` type labels (`weapon.sword_1h` / `weapon.sword_2h` for machine IDs); a type qualifier, never a slot, occupancy count or delivery hook. **`M-C1` gained its source row here**, stating the budget and its conservation. It had been carried in the Validation Rules Index and in K's *enforced elsewhere* table since 0.11.0 with **no ID-bearing row in this document** — the ◇P7 defect, one instance of which is now closed. The same sweep found `M-C2` and `W-C4` in that condition and absent from ◇P7's list. |
| **0.16.0** | **`shield` locked as the seventh `category` value** (§2.1) — dual-nature, component set = weapon ∪ armour, one pooled budget (M-C4). It is not a sub-type of either parent: filing it under one leaves a linter unable to state its required components from data, which violates Part 4 item 1. **Trade-off named:** a seventh value that looks redundant against `slot / occupancy`, kept because slot says *where* and category says *which components*. The change was prompted by an equipment-authoring question, and the sweep it triggered found that **`category` had never been entered in the Lexicon** despite being locked here since 0.9.0 — so every prior L-M2 grep against that word returned a false negative. |
| **0.14.0** | **Gate 0 closed on three of four.** **Part 9 added** — the run contract. **0.7 locked**: the storey is the pacing unit (18 across the career, from S-W01 × W·5.8), band C reduced from 120–180 to **75–110 min**, two major acquisitions per storey (36 career), and a death ledger in which **purchased access is never lost**. **0.9 locked at ×9 career**, derived per storey rather than swept, from which a **constant 6.3% per-acquisition value** falls out — the property that makes loot legible. Three reference fantasies written as the prose form of K·15's reference builds, giving **◈M10** its content. New rule **M-H5** (no interaction exceeds ~20% of a band's log-power gain). Enemy scaling `E(x) = P(x)(0.92+0.18x)` registered against W and E as **◇W17**/**◇E11**. ◈M1 and ◈M2 closed. |
| **0.13.0** *(Gate 0 prep)* | **◈M1 and ◈M2 reclassified** from *Balance (needs the sim harness)* to **Design — gates the harness**. Gate 0 requires 0.7 and 0.9 answered before M⇥1 builds the harness, while the index had them waiting on it: a deadlock that existed only in the classification. Both are choices validated afterwards, not measurements. **◇M3 moved to the prototype track** with ◇V6 — a legibility test, not a sweep. **◈M10 registered**: the reference fixture set is a Part 4 foundation that Gate T measures against, partially specified in K·15, and owned by no document. |
| **0.13.0** | **§2A.10a added — `[Faculty]`, the non-item source.** Closes the hole where `capability` was a `sources` value with no record, no agent and no linter for three versions. Four families: `[Innate]` (slotted, derived from the body template), `[Arcana]` (voice), `[Mudra]` (free hand), `[Psyche]` (head and spine). A faculty carries its own base footprint, parallel to a weapon chassis; 2A.9 redistribution applies unchanged. **The corpus had no unarmed model** — E·F.1's Equipment cardinality `0–2` left Trash enemies unable to act and 2A.6's disarm left players the same; both now resolve here. **§2A.10 narrowed**: a `[Combo-Action]` declares **exactly two** delivery hooks (T-C13), hook count distinguished from hand occupancy, and the *staff + cantrip* worked example corrected — it violated the free-hand rule it was used to illustrate. **`[Ward]` defined** in §2A.4 as a state track after being named and undefined since 0.9.0. **Occult triad remodelled** in §2A.5 — Chaos `+corruption`, Psychic `+displacement` as `[CDM]` rather than decision control (K·10.2 rejected compulsion), Divine as the two-way purge. Chassis layer's *base damage/defence signature* renamed **base martial profile**, freeing *signature* for `[Signature Action]`. |
| **0.12.0** | **§2.7a added** — `[Secret]` and `[Relic]` as item attributes authored by mission placement only, with three Critical rules (M-C6, M-C7, M-C8) protecting them from the affix generator and from the salvage/reroll sinks. Item-level assignment noted as saturating for `[Incursion]` sources (W-C18), preventing an unbounded-depth mode from producing out-of-band items. **◇M9 registered as an unowned gap** — no document owns `[Inventory]`. Document set grows to nine. |
| **0.11.0** | **Part 8 rewritten** with `[OPEN]`/`[SIM]` markers and blocking categories; one stale duplicate removed (position persistence, resolved by K17). Two items added: remedy content belongs in M rather than H (◇M8), and Scrap↔Flux conversion (◇M7). Document set grows to eight with the Enemies extraction. |
| **0.10.0** | Document set grows to seven with **H — Damage & Health**; filename convention standardised. **2.8:** material currencies — **Marks / Scrap / Flux** — with *Flux* declared a reserved word (currency, never a field quantity) and progress currencies barred from crafting and treatment sinks. **2A.3:** Structural group extended to anatomy — bone and flesh integrity are the per-node form of the same path. **2A.4:** rigid discontinuity extended inward as `[Tissue Layer]`. **2A.6:** integrity render separated from wound render (V·4.8). **2A.10:** no-pip-pooling identified as the reason the Standard enemy template splits limbs. |
| **0.9.0** | Restructured around the Triade; materiel Part 2A. |
| **0.8.0** | UI requirements moved to the new `V-Visual_design_TRIADE-0_44_0.md`; A3.4c is now a pointer. Document-set note added. |
| **0.7.x** | Skill Anchors (A3.7–A3.8) resolving the grid–math question; demand tier split from Doctrinal/Transgressive flags; UI requirements; Weapon/Armour/Shield Smith agent specs; shield budget. |
| **0.6.x** | Materiel system: damage taxonomy with Structural group, integrity states, the three bridges, pips and redistribution, shield duality. |
| **0.5.x** | Dot Framework, grid + Dot Interpreter, stat-groups and field-rendered floor, skill level model, class system, Dictionary and tone. |
