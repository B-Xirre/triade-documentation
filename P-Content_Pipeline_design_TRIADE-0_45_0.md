# Triade — Content Pipeline & Data Model

**Version:** 0.45.0
**Date:** 2 October 2026
**Status:** Created at 0.15.0 by reconciliation of two independent studies. Architecture settled; operational numbers pending first build.

**Document set:** this is one of **ten**.

| Ref | Document | Filename |
| --- | --- | --- |
| **T** | Core Mechanic | `T-Core_Mechanic_design_TRIADE-0_45_0.md` |
| **M** | Stats, Items, Equipment | `M-Stats_Items_Equipment_design_TRIADE-0_45_0.md` |
| **L** | Lexicon | `L-Lexicon_design_TRIADE-0_45_0.md` |
| **V** | Visual Design | `V-Visual_design_TRIADE-0_45_0.md` |
| **K** | Combat Design | `K-Combat_design_TRIADE-0_45_0.md` |
| **W** | World, Maps & Dungeons | `W-World_Generation_design_TRIADE-0_45_0.md` |
| **H** | Damage & Health | `H-Damage_Health_design_TRIADE-0_45_0.md` |
| **E** | Enemies & Bestiary | `E-Enemies_design_TRIADE-0_45_0.md` |
| **G** | Tile Pipeline | `G-Tile_Pipeline_design_TRIADE-0_45_0.md` |
| **P** | **Content Pipeline & Data Model** — *this document* | `P-Content_Pipeline_design_TRIADE-0_45_0.md` |

**Scope.** **P** owns how content is authored, stored, validated, generated, simulated and attributed. It owns the data model for equipment, affixes, faculties and fixtures; the storage architecture; the trace and signature schema; and the agent pipeline.

It does **not** own what any of those things *mean* — equipment semantics stay in **M**, the Triade state model in **T**, combat resolution in **K**, wounds in **H**, enemies in **E**, tiles in **G**.

**Founding rule, inherited from M·Part 4:** *content is data, never code.* P exists because that rule had no schema behind it.

---

## Part 0 — Why this is a separate document

Five documents consume it:

| Consumer | Depends on |
| --- | --- |
| **M** | The equipment/affix/faculty model; the generation pipeline; the fixture catalogue |
| **T** | Trace instrumentation (I.1), Trace Signature (I.2), the redundancy gate (I.4) |
| **K** | The action-event schema — every combat action is a trace row |
| **H** | Per-delta attribution for wounds, integrity and ward state |
| **E** | Enemy definitions share the schema; bestiary content accumulates here |

E·0's test applies: *"a section consumed by three documents is a subsystem."* This is consumed by five, and at creation it is larger than four existing documents.

**It is data architecture, not game design.** That distinction is the reason it is separable at all — nothing in P decides how the game plays.

---

## Part 1 — The five lifecycle objects

The corpus conflates five things that behave differently. Separating them is the central decision.

```
Equipment definition          hand-authored chassis: maul, dagger, wand, shield
        ↓
Generated roll                item level, rarity policy, affixes, rolled values
        ↓
Owned item instance           mutable: current integrity, ward state, ownership
        ↓
Equipped loadout snapshot     hand occupancy and delivery hooks → legal actions
        ↓
Attributed combat trace       source of every delta, valid after content revision
```

**Why the separation is load-bearing.** A trace points at the exact revision used at the time, so a balance patch creates a *new revision* rather than rewriting history. A designer can compare two revisions under identical seeds. A player's sword may be Fractured while the sword *definition* is untouched.

### 1.1 Five bounded domains

| Domain | Holds | Mutability |
| --- | --- | --- |
| **Definition** | What equipment, affixes, skills, faculties are designed to be | Immutable by revision |
| **Generation** | How a definition becomes a rolled item | Versioned policy |
| **Runtime** | Ownership, current integrity, equipped state | Mutable game state |
| **Fixture** | Frozen builds, loadouts, enemies, encounters | Immutable within a fixture-set version |
| **Trace** | What occurred, and which source caused each delta | Append-only |

### 1.2 No giant nullable table [LOCKED]

M·2A defines five item layers — chassis, construction, behaviour, affixes, inscription — and categories carry different combinations. Weapons, armour, shields, trinkets, consumables, currencies and tomes share a **small core identity record** and attach **typed components**.

**Trade-off named.** Component attachment costs joins on every read. Accepted because the alternative is a table where most columns are null for most rows, and where a linter cannot state which fields are required without encoding category rules in code — violating *content is data, never code*.

### 1.3 Three classifications that must never merge [LOCKED]

| Classification | Meaning |
| --- | --- |
| `category` | What it is — weapon, armour, **shield**, trinket, consumable, currency, tome. `shield` is dual-nature: component set = weapon ∪ armour, one pooled budget (M-C4) |
| `slot / occupancy` | Where it equips, and how many hand units it consumes |
| `delivery_hook` | The channel an action issues through — `main_hand`, `off_hand`, `voice`, `none` |

**Hand occupancy and hook count are different quantities** (M·2A.10). A two-handed maul occupies two hands and presents **one** hook. A one-handed weapon occupies one hand and leaves the other free for `[Mudra]`. Collapsing these into a single `hands` field makes `[Combo-Action]` legality unrepresentable, and rule **T-C13** unenforceable.

---

## Part 2 — Authoring

### 2.1 The layer stack [LOCKED]

| Layer | Representation | Authority |
| --- | --- | --- |
| Human editing | Multi-sheet workbook, deterministic CSV export | Editing façade |
| **Canonical content** | **Deterministically ordered JSON, JSON-Schema validated** | **Source of truth** |
| Operational catalogue | DuckDB tables and views, imported from canonical JSON | Query and validation |
| Large traces | Append-only partitioned Parquet | Analytical fact store |
| Derived analysis | DuckDB tables — signatures, deltas, findings | Rebuildable |
| Game runtime | Compiled content package from approved revisions | Deployment artefact |

**The database is never the source of truth.** `.duckdb` and Parquet files are binary and not meaningfully git-diffable; DuckDB has no row-level `diff` command. The build is **one-directional — text → DuckDB, never the reverse.** If anyone edits the database directly, diffability and reproducibility are both lost.

**Concrete authoring implementation.** The current Stage 2 façade is **Grist**. Grist is not authoritative: deterministic exports compile into canonical JSON, and canonical JSON remains the source of truth. The important rule is not the storage format but that **deterministic exported text feeds the canonical build** — any façade meeting that contract satisfies this layer. Column-level Grist schemas, Reference targets, formula fields and implementation status live in the version-aligned `TRIADE-Content Authoring Technical Specification`.

```
content/
  authoring/   grist/ · csv/*.csv
  canonical/   equipment.data.json · affixes.data.json · faculties.data.json · fixtures.data.json
  schema/      equipment.schema.json · affix.schema.json · faculty.schema.json · fixture.schema.json
```

### 2.2 One scalar per cell [LOCKED]

Tags, damage types, skills, vectors, slots and affixes are **never** comma-separated strings. Every repeatable value gets a child-table row.

Reasons, inline: it prevents spelling drift, it makes referential validation possible at all, and it stops an agent making an opaque edit inside a delimited blob.

### 2.3 Sheet classes

| Class | Editable | Purpose |
| --- | --- | --- |
| Authoring | Yes | Equipment, profiles, links, affixes, fixtures |
| Reference | **Protected** | Enums, stat IDs, damage types, regions, hooks, slots, rule IDs |
| Generated | **Read-only** | Flattened previews, tooltips, validation findings, trace summaries |

Authoring sheets, by row grain: `equipment` · `equipment_text` · `slot_occupancy` · `equipment_tags` · `chassis_profiles` · `construction_profiles` · `damage_profile_entries` · `defence_profile_entries` · `integrity_profiles` · `integrity_states` · `triade_effects` · `vocabulary_links` · `stat_modifiers` · `affixes` · `affix_effects` · `inscriptions` · `generation_policies` · `loot_tables` · `loot_entries` · `faculties` · `faculty_profiles` · `faculty_profile_members` · `faculty_profile_damage_entries` · `faculty_profile_hook_requirements` · `faculty_technique_authorizations` · `build_faculty_instructions` · `actor_faculty_acquisitions` · `lineages` · `lineage_sizes` · `lineage_stat_offsets` · `lineage_physique_pairs` · `lineage_node_profiles` · `lineage_node_profile_entries` · `lineage_enemy_floor_profiles` · `lineage_innate_grants` · `lineage_grant_technique_bindings` · `lineage_binding_source_nodes` · `lineage_binding_payloads` · `lineage_binding_payload_support_nodes` · `fixture_builds` · `fixture_stat_weights` · `fixture_loadouts` · `fixture_encounters` · `fixture_enemies` · `fixture_encounter_members` · `fixture_coverage` · `design_parameters` · `provenance`.

**Forty-eight authoring sheets.** `fixture_enemies` and `fixture_encounter_members` are **new at 0.17.0** and exist because P·10.5–10.6 specify frozen enemy fixtures and multi-enemy compositions that **P-C3** forbids expressing as a delimited cell. Row grains: one frozen enemy-fixture definition, and one encounter × enemy-fixture membership row carrying an integer `quantity` and a stable `sort_order`. **Their column sets are not yet fixed** — the enemy-fixture field list must be reconciled against **E** and **H** before it is locked, and that decision is **[OPEN] [GAP]** under **◇P8**. What is decided here is the normalized relation itself, not its fields. `actor_faculty_entitlements` is an additional generated read-only projection and is therefore not counted as an authoring sheet.

The concrete Grist column schemas, Reference targets, formula fields and implementation progress are maintained in the version-aligned **Content Authoring Technical Specification**. **P owns the logical model; the technical specification owns the current Grist realization.** Where the two disagree, P wins and the technical specification is patched.

### 2.3a Lineage, physique and innate grants [LOCKED 0.40.0, ◈P13]

The actor-side `[Chassis]` is the immutable revisioned `lineages` record; no second actor-chassis identity exists. One lineage references one H-owned `BodyTemplate`, never an inline anatomy and never equipment `chassis_profiles`. `lineage_enemy_floor_profiles` is an optional component because only the enemy realization carries a base floor shape; a player floor renders from stats.

| Relation | Row grain |
| --- | --- |
| `lineages` | one immutable lineage revision and its H-owned body-template reference |
| `lineage_sizes` | one lineage revision × available protected size; exactly one row is `typical` |
| `lineage_stat_offsets` | one lineage revision × protected stat; exactly nine integer rows summing to zero at typical size |
| `lineage_physique_pairs` | one lineage revision × available non-typical size × ordered conserving pair; at most two per size |
| `lineage_node_profiles` | one lineage revision × compatible body-node archetype carrying a natural physical profile |
| `lineage_node_profile_entries` | one node profile × ordered physical damage entry |
| `lineage_enemy_floor_profiles` | zero or one enemy-only base-floor component per lineage revision |
| `lineage_innate_grants` | one stable passive or deliberate innate capability grant under one lineage revision |
| `lineage_grant_technique_bindings` | one deliberate grant × allowed Technique revision |
| `lineage_binding_source_nodes` | one Technique binding × eligible delivery-node archetype |
| `lineage_binding_payloads` | one Technique binding × authorised Payload revision |
| `lineage_binding_payload_support_nodes` | one binding × Payload × producer/support-node archetype |

Absence of a `lineage_sizes` row means the size is unavailable — the design's `null`, never numeric zero. The typical row carries no physique pair. Each physique pair stores a positive integer magnitude plus distinct gain/loss stat references, making its zero sum structural rather than a second authored number.

An innate node profile is physical capacity only. Its ordered entries obey M·2A.10a and **M-C12–M-C14**; it owns no Technique, Payload or mutable availability. A BodyTemplate node must exist before a lineage may profile or bind it.

An innate grant is either `passive` or `deliberate`. A passive grant binds no executable Technique. A deliberate grant references exactly one Faculty and declares `entitlement_mode` as `conferred` or `unlocked`; it may bind several Techniques, but the Faculty owns authorization and Lineage never directly grants a Technique. `conferred` automatically possesses the Faculty because of Lineage; `unlocked` makes it eligible for character-state acquisition. Multiple grants fold to one actor entitlement, with conferred possession dominating unlocked eligibility.

Technique bindings own their source-node rows because Bite, Punch and Kick under one grant use different anatomy. Payload support is narrower still: teeth deliver Bite, while a venom gland supports only the Bite + Poison rendition. A support node is never a source or delivery hook. Transfer is a separate binding — `Apply Venom` uses the gland as its source to create a weapon-bound provision; after transfer the coating is runtime state and later gland loss prevents replenishment rather than erasing the coating.

The Somatic Faculty authorizes conferred, unlocked or acquired control of natural body-node Techniques. It owns vocabulary and acquisition, but no independent footprint or delivery hook; the active bound node supplies both. This is not the retired `[Innate]` slot in another name: anatomy states what the body can do, Somatic states what deliberate use the actor possesses.

Illustrative binding, not fixture content:

```text
venomous_hobgoblin.natural_combat@1 — Somatic; entitlement_mode conferred
  Bite  → source teeth; allows Poison → support venom_gland
  Punch → source hand
  Kick  → source foot

venomous_hobgoblin.venom_production@1 — Somatic; entitlement_mode conferred
  Apply Venom → source venom_gland; allows Poison

Bite + Poison = derived Poisonous Bite rendition
```

`venom_gland → Poison` is not a source row: source rows identify a Technique binding. The gland is a support dependency for direct Bite inoculation and the source of the separate Apply Venom provision action.

### 2.3b Faculty profiles and Technique authorization [LOCKED 0.41.0, ◈P11]

Faculty identity, profile composition, damage entries, execution-hook requirements and Technique authorization are separate normalized grains:

| Relation | Row grain |
| --- | --- |
| `faculties` | one immutable Faculty identity: `faculty.arcana@1`, `faculty.mudra@1`, `faculty.psyche@1`, or `faculty.somatic@1` |
| `faculty_profiles` | one immutable base or explicit composite profile, including its primitive actor pull or null |
| `faculty_profile_members` | one profile × member Faculty occurrence; permits two ordered Mudra occurrences without inventing two entitlements |
| `faculty_profile_damage_entries` | one profile × Occult damage type × authored pips |
| `faculty_profile_hook_requirements` | one profile × execution-hook requirement, including distinct-hand cardinality |
| `faculty_technique_authorizations` | one Faculty profile × authorized Technique revision |

The four base profiles and four composites are exactly those authored in M·2A.10a. Composition is unordered at identity level and explicit in data; no engine formula may synthesize an unregistered profile. The actor-position pull signature constrains the Technique-owned `position_delta_q`; it is never itself applied as another movement.

**Authorized seed vocabulary — examples with stable semantic boundaries.**

| Profile | Authorized Techniques |
| --- | --- |
| Arcana | Vocal Seal · Resonant Chorus · Exhortation · Divine Purge |
| Mudra | Aegis Weave · Decisive Snap · Flowing Seal · Pressure Lock |
| Psyche | Mind Thrust · Kinetic Wave · Cognitive Anchor · Synapse Overload |
| Somatic | Bite · Punch · Kick · Apply Venom |
| Arcana && Mudra | Hex · Sanctified Seal · Unraveling Chants · Consecrated Knot |
| Mudra && Mudra | Entropic Weave · Flicker Step · Refraction Matrix · Entropic Rupture |
| Psyche && Mudra | Neuro-Shatter · Warp Pulse · Thought Bleed · Psychokinetic Blast |
| Arcana && Psyche | Decree of Mind · Aura of Enlightenment · Psionic Whisper · Subjugation Chant |

`Rend` is a weapon Technique and is not in Arcana vocabulary. `Hex` requires Arcana && Mudra. Poisonous Bite and Poisonous Rend are derived renditions, not authorization rows. Names do not authorize unrestricted decision control, universal resistance bypass, stored action-point drain, universal reflection, unrestricted teleportation or undeclared effect categories; each Technique still owns its bounded executable behaviour, numerical effects, progression, presentation, targeting, costs and cooldowns.

The vocabulary fixture asserts **32 authorization rows**, four for each registered profile. It also asserts the negative cases above and exact profile/hook/damage/pull equality. This closes concrete Faculty identity/profile/vocabulary work only.

### 2.3c Faculty entitlement and acquisition [LOCKED 0.42.0, ◇P12-A]

Entitlement attaches only to one of the four immutable base Faculty identities. A composite profile is an execution-authorization profile, never a Faculty identity, entitlement or separately acquired object. Therefore Arcana && Mudra requires possessed Arcana and possessed Mudra; Mudra && Mudra requires one possessed Mudra Faculty plus two functional, unoccupied hands, each resolving a distinct functional finger hook. Repeated profile membership expresses hook cardinality, not duplicate entitlement.

| Relation | Row grain |
| --- | --- |
| `build_faculty_instructions` | one immutable build revision × base Faculty × instruction (`confer`, `unlock`, or `acquire`) plus provenance and any explicit revocation contract |
| `actor_faculty_acquisitions` | one actor × base Faculty acquisition fact with its authoritative acquisition provenance |
| `actor_faculty_entitlements` | generated read-only projection of one actor × base Faculty, folding current Lineage grants, build instructions and actor acquisition facts |

The lifecycle facts remain distinct. `conferred` is possession supplied automatically by an authoritative grant or build instruction. `unlocked` is eligibility to acquire and is not possession. `acquired` is a persisted character-state fact created through a valid acquisition route. `possessed` is derived as `conferred OR acquired`; it is not separately authored. `available` is a later runtime derivation and is never stored in any of these relations.

An acquisition normally survives loss of the source that unlocked it: removing or disabling that source removes current unlock eligibility, not the historical acquired fact. A source may revoke an acquisition only when its authored contract explicitly declares the entitlement leased or revocable and identifies the revocation rule. This prevents equipment, temporary effects or changing prerequisites from silently deleting permanent character progression.

Multiple sources fold deterministically into the generated projection. Conferred possession dominates unlocked-only eligibility; an acquired fact continues to establish possession; provenance remains source-specific even when several rows support the same base Faculty. The projection may explain why the actor possesses or may acquire a Faculty, but it may not cache Technique availability.

P12-A closes entitlement identity and persistence only.

### 2.3d Derived Technique readiness and candidate dependencies [LOCKED 0.43.0, ◈P12-B]

Authoritative engine contracts do not use one unqualified `available` flag. They derive three different predicates, none persisted as independent truth:

| Predicate | Meaning |
| --- | --- |
| `known` | The actor possesses the required base Faculty or Faculties, the profile authorizes the Technique, and any required lineage/capability binding exists |
| `selectable` | At least one complete actor-side candidate route can satisfy its initiation gates before a target-specific verdict is required |
| `executable` | One fully specified candidate — source, rendition, carrier, route and target where required — passes every contextual gate and may commit costs and resolve |

Base Faculty identity owns possession, never executable availability. A Faculty-level readiness value may exist only as a generated UI/diagnostic aggregate answering whether at least one authorized route is currently selectable. It is never canonical state and never authorizes execution by itself.

An execution candidate carries typed dependencies:

```text
authorization  = possessed base Faculties + authorizing profile
grant route    = lineage/capability grant + Technique binding, where required
source route   = selected source instances + required hooks and occupancy
rendition      = support/provider instances + Payload or other rendition inputs
provision      = transferred runtime instances, remaining uses and expiry
carrier        = selected carrier and delivery proof
target route   = authored selection, reach/range, visibility and delivery contract
```

Alternative complete candidates combine existentially; requirements inside one candidate combine conjunctively. Punch may remain selectable through a surviving right-hand candidate when the left hand is denied. `Mudra && Mudra` is one candidate with two required hands: one possessed Mudra Faculty plus **both** functional, unoccupied hands, each resolving a distinct functional finger hook. Failure of either hand invalidates that candidate; it is never reduced to “either hand works.” Execution selects one surviving candidate before costs commit.

Invalidation is dependency-local. A failed source, support node, provider, carrier or target route invalidates only candidates declaring it; shared Faculty identity, body, grant or Payload family does not propagate failure sideways. A source delivers the Technique. A support/provider enables only its declared rendition or provision operation and never replaces the source or becomes a delivery hook.

Valid transfer cuts the live provider dependency unless the provision explicitly requires continuous maintenance. Once Apply Venom transfers a coating, the recipient owns the runtime instance, remaining uses and expiry; later gland denial or provider cooldown prevents replenishment but does not erase the existing coating. Provider provenance remains recorded.

Cooldown propagation follows declared identity. A base Technique cooldown blocks the Technique and every derived rendition. A rendition cooldown blocks only that rendition by default. A provider cooldown blocks new production/application, not an existing transferred provision. A Faculty-wide cooldown is an exceptional shared lock. A composite Technique cooldown blocks that Technique and not unrelated Techniques authorized by either member Faculty.

Target-route validity dispatches through the Technique's authored selection and delivery contract. Conceptually the Technique declares a selection origin and shape, a reach/range source, a visibility requirement and a delivery route; B does not prescribe their technical columns. A source supplies reach/range capability, while the Technique supplies selection shape, visibility and delivery rules.

Direct actor-targeted weapon and projectile routes require their selected reach/range, actor perception, actor line of sight and direct/path geometry. A direct Psyche route likewise requires Technique-authored Psyche reach, actor perception and actor line of sight; Mind position, Psyche membership and Psychic damage imply no targeting bypass. Non-visual individual targeting requires an explicitly authored mental link, lock or replacement route.

Area routes validate their selected origin, pattern, propagation and geometry and do not automatically require perception or line of sight to every affected actor. A self-centred weapon area may strike occupants of valid cells within the weapon-derived radius without selecting them individually. A throwable flask or bomb validates throw range, its authored destination-visibility rule, ballistic route and landing cell, then resolves occupants of the propagated area; “throwable” never implies permission to pass through walls, select an unknown cell or ignore a blocked trajectory.

Temporary injury, occupancy, position, accessible-floor failure, target failure, insufficient costs and cooldowns can change `selectable` or `executable`; they do not remove Technique knowledge, base-Faculty possession, acquisition provenance or permanent authorization. Derived verdicts return every currently failed gate for the evaluated candidate — including distinct reach, perception, line-of-sight, path, ballistic, landing-cell, area-pattern, propagation and non-visual-lock failures — without running later side effects.

### 2.3e Deterministic evaluation, commitment and planned actions [LOCKED 0.44.0, ◈P12-C]

One immutable evaluation snapshot feeds one pure resolver. Evaluation performs no writes, consumes no resource, starts no cooldown, draws no randomness and applies no effect. For every candidate it evaluates these stages in fixed order:

1. **Knowledge and authority** — possessed base Faculties, profile authorization, required lineage/capability grant and binding.
2. **Candidate construction** — exact source instances, hooks and occupancy, support/provider, transferred provision with uses and expiry, rendition/Payload, carrier and delivery route.
3. **Actor initiation** — functional sources and hooks, unoccupied hands where required, Triade angular gate, accessible floor and current skill level, actor state, cooldown identities and cost affordability.
4. **Target route** — target requirement and reference; existence; target domain, capability or environmental state; spatial anchor; perception or non-visual lock; reach/range; line of sight; direct, projectile or ballistic route; landing; pattern, propagation and geometry.
5. **Verdict derivation** — `known`, `selectable`, then `executable`.

Each gate returns `pass`, `fail(reason_code)` or `blocked_by(gate_id)`. The result contains every independent failure and every dependent gate blocked by it, ordered by stage, candidate identity and gate identity. Alternative complete candidates combine by `OR`; requirements inside one candidate combine by `AND`, including the two hands and two distinct finger hooks of `Mudra && Mudra`.

Target domains are explicit: actor, object, `cell_surface`, `environmental_volume`, or `path_or_area`. An object resolves through W-owned `ObjectRuntimeState`; a surface or volume resolves through W-owned environmental state. The Technique must authorize the domain and any required capability or state. T/P own targeting contracts, K owns timing, W owns object/environment semantics, and Named Reactions own transformations.

Four roles prevent target ambiguity:

- **selected target** — the actor's submitted actor, object, cell, volume, path or area;
- **route contact** — a participant encountered during delivery;
- **effect recipient** — a participant to which an effect is applicable at its consuming milestone;
- **reaction product** — a state or participant created by a Named Reaction.

Together they are **resolution participants**. Executability validates the selected target or origin and the authored route; it does not predict every future recipient. Resolution discovers contacts, the affected set and current participants at the relevant milestone. Applicability is local to each recipient. An empty affected set is `resolved_no_effect` unless the Technique explicitly requires at least one recipient. Indirect effects create traceable child events in stable spatial-address, participant-ID and effect-component order; they do not recursively retarget. W resolves non-immediate environmental changes in its deterministic same-tick batch, and geometry changes remain atomic under W-C34.

Before commitment, one exact stable candidate is selected: Technique revision, level and aim, Faculty profile, grant/binding, sources and hooks, rendition/Payload, support/provider or transferred provision, carrier, route, and selected target or origin. UI may aggregate equivalent choices, but submission may not silently replace the hand, weapon, ammunition, provision, plain/Poison rendition, target, cell, level, aim or carrier.

A final full evaluation against one authoritative snapshot must return `executable`. Successful commitment is one atomic transaction: record the exact command and candidate; capture pre-commit Triade position and skill level; compute effective cost and duration from the AP rate without treating AP as a pool; reserve actual spendables and exclusive dependencies; create the action instance, milestones, timeline nodes, Intent Marker and audit digest. Any write failure rolls back the whole transaction. The action identity then stays immutable, but later world success is not guaranteed.

Post-commit validation is milestone-local rather than a rerun of the whole resolver. Source, hook, occupancy, cost and launch gates are checked when consumed; transit checks contacts; impact checks landing and recipients; effect checks applicability, resistance and reactions; recovery releases or expires reservations. Outcomes are `resolved`, `resolved_no_effect`, `route_failed`, `interrupted`, `cancelled`, or an explicitly authored `superseded`. Reservations are not consumption. Costs declare `commit`, `release`, `contact`, `delivery_proof` or `effect` as their consumption milestone; a gameplay failure does not roll back milestones already reached, and no universal refund exists.

Cooldown start follows the identity that actually acts. Ordinary Technique, rendition, composite-profile and exceptional Faculty-lock cooldowns start on successful execution commitment. A provider cooldown starts on actual production or application, while a transferred provision owns its own uses and expiry. A planned setup cooldown starts when the plan arms; the execution Technique cooldown starts when activation commits. If Watch is itself a Technique, its stance cooldown begins at arming.

**Plannable Action** is an authored capability, not a second action economy. Its lifecycle is `known/selectable → plan armed → scheduled/triggered activation → fresh executable verdict → execution commitment/resolution → complete`, with explicit expiry and cancellation branches. Its plan contract declares activation mode (`scheduled` or `triggered`), `world_tick` window, scheduled tick or trigger, targeting-acquisition mode, reservations, setup and activation costs, reaction budget, maximum activations, visibility, expiry and cancellation.

Arming evaluates only authorable and current actor-side gates, atomically pays setup costs, reserves declared sources/hooks/resources, and creates the plan node plus Intent Marker. The exact candidate is bound and gains no silent fallback. The plan node is autonomous: at its scheduled tick, or at `trigger_tick + response_delay`, it attempts the exact bound action independently of the owner's later position on the actor timeline, Readiness, AP rate or opportunity to act. Haste, Slow and owner displacement on the progress bar do not move it; only an explicit Advance or Delay effect aimed at the plan node may do so. Failure at the due tick follows the authored branch and defaults to `cancelled_failed`, releasing unreached reservations without refunding setup or already consumed costs and cooldowns.

Target acquisition is separate from Technique target-route validation:

- `first_eligible` takes the first participant satisfying the declared trigger and deterministic simultaneous-candidate order; it never retrospectively chooses a better target;
- `bound_identity` watches one perceived participant, ignores other eligible participants and does not retarget if that identity becomes invalid, concealed, displaced, interrupted or removed;
- `fixed_spatial` binds an origin, path or area and discovers recipients only at resolution.

The plan contract records domain, trigger, area or relation, optional bound identity, visibility or lock requirement, simultaneous order, maximum acquisitions, retarget policy and invalidation branch. The default is `retarget_policy = none`. Hidden participants cannot be identity-bound, and current visibility or an authored non-visual lock is still revalidated at activation. An aimed plan remains aimed; it never silently downgrades unless an explicit visible conditional branch authorizes that change.

### 2.3f Tarot acquisition and persistence [LOCKED 0.45.0, ◈C1-A/B]

The Tarot layer owns acquisition outcomes, character-owned card identity, installation and build configuration. **Technique remains the sole executable behaviour owner.** Acquiring a Technique through training, a drop, a tome or another authorized channel produces a character-owned **Technique Card**. Conferred Lineage/build Techniques remain cardless and inherent. A card may enhance or combine with an inherent Technique without converting it into a card. **Support Cards** are a separate non-executable Tarot Card type; their detailed acquisition contract remains Session C1-G work.

```text
Acquisition channel
  → character-owned Technique Card
    → acquired Technique access
      → installation and build configuration
        → executable Technique candidate under P12
```

The acquisition transaction validates the channel, resolves an exact Technique revision, creates the persistent card, records acquired access and provenance atomically, or rolls back entirely. Neither orphan acquired access without its card nor a card without its referenced acquisition is valid. An unlearned physical card may be an Inventory input; it is distinct from the persistent character-owned card. Concrete channel rewards, prices and crafting provenance belong to Stage 3 and Stages 5–6, not this generic interface.

Ownership and installation are independent. Uninstallation preserves the card, acquisition provenance and existing expertise/discovery. Cards remain character-scoped while that character persists, including equipment/source loss and run transitions. Death/account inheritance is unresolved Stage 3 work. Repeated acquisition of the same exact Technique revision creates neither another access truth nor automatic expertise; physical duplicates and disposal remain Inventory/Economy decisions. Card and Technique revisions are pinned independently; migration is explicit, never silent.

The card is the primary player-facing mechanical description, generated from authoritative Technique, card, installation and discovery state. It does not duplicate executable mechanics. Every operative effect, cost and prerequisite is disclosed; latent uses may remain undiscovered. C1-F must settle the visual templates and discovery contract in V before architecture closeout. Formal vocabulary is Technique, Tarot Card, Technique Card, Support Card, installed Tarot Card and Tarot layout; Deck and Arcana retain their existing world/Faculty meanings.

**P-C20 · Critical.** Every acquired Technique has an atomically created character-owned Technique Card and exact acquisition provenance; conferred inherent Techniques remain cardless. Uninstallation preserves ownership/access, and revisions never migrate silently. A Support Card authorizes no independent executable Technique.

### 2.3g Tarot layout and vertical contributions [LOCKED 0.45.0, ◈C1-C]

One global authored Tarot topology carries stable column/depth addresses. Local depth extensions preserve the main node rather than replacing it; three complete global layers are not required. `A@1`, `A@2`, `A@3` denote physical addresses, while `D⌬1`, `D⌬2`, `D⌬3` denote intrinsic Technique/card tiers. Slot depth and intrinsic tier are separate. Classes, progression, rewards and other authorized sources unlock existing positions and links; they do not invent coordinates or rewrite topology.

Progression/build determines slot unlock, installation requirements, compatible occupancy and active neighbouring links. Slot progression is `defined → unlocked → installation-eligible → occupied → layout-valid`. Current character/world state determines `known`, `selectable` and `executable` through P12. Temporary failure never uninstalls a card or changes persistent topology.

Support Cards contribute upward to the first receiving Technique above them in the same column; empty intermediate positions are permitted. A receiving Technique ends that contribution path. A contributor cannot contribute downward, horizontally, recursively or to two receivers. A lower-tier Technique Card may contribute **same-Technique resonance** to a higher-tier receiver in its explicitly authored Technique progression. It remains a Technique Card; while bound it cannot execute independently or join a Combo separately. Other Technique Cards cannot provide cross-Technique vertical modification.

Every vertical contributor must have a lower intrinsic tier than its receiver, and the sum of installed contributor tiers must not exceed the receiver's intrinsic tier. This capacity covers both Supports and resonance. A receiver retains its intrinsic tier; contribution never grants floor access or a higher Technique level.

| Column from lower to higher depth | Result |
| --- | --- |
| D⌬1 Support, G⌬2 Support, A⌬3 Technique | Legal: 1 + 2 ≤ 3 |
| D⌬1 Support, G⌬1 Support, A⌬3 Technique | Legal: 1 + 1 ≤ 3 |
| D⌬2 Support, G⌬2 Support, A⌬3 Technique | Illegal: 2 + 2 > 3 |
| D⌬1 Support, G⌬2 Support, A⌬1 Technique | Illegal: contributors are not lower tier |
| D⌬1 Support, G⌬2 Technique, A@3 empty | Legal: D supports G; no empty apex is required |
| D⌬1 Technique, D⌬2 Technique | Legal resonance: increased authorized D⌬2 output; lower D is bound |
| D⌬1 Support, G⌬2 Technique | Legal compatible Support modification; no strength ranking against resonance is presumed |

Same-Technique resonance increases declared existing output values without adding characteristics or effects. Support Cards may modify and/or add explicitly authorized output and characteristics. These builds serve different tactical purposes and neither is universally stronger.

Only one effective contribution of each specific Support identity is accepted per receiver. Different ⌬ variants share that identity: only the highest-tier bound Support contributes, lower variants are suppressed, and equal-tier duplicates contribute once. All installed duplicates still occupy positions and count toward vertical capacity. Suppressed variants never become automatic runtime fallbacks. Distinct Support identities may both contribute if compatible.

**P-C21 · Critical.** Tarot depth and intrinsic tier are separate; vertical contributions are receiver-local, strictly lower-tier and sum to at most the receiver tier. Support and same-Technique resonance remain distinct; bound contributors cannot execute or become Combo endpoints. Duplicate Supports contribute only once at their highest bound tier while all installed contributors consume capacity.

### 2.3h Tarot horizontal links and inherent endpoints [LOCKED 0.45.0, ◈C1-D]

Resolve each column's receiver with its exact contributors before horizontal pairing. This **layout expression** retains receiver identity/tier and exact revisions but is not itself an executable candidate. Its nested contributors provide no additional delivery hooks or endpoints.

Horizontal links join only directly linked positions at the same physical depth. They permit exact Combo authorization; adjacency alone gives no Combo, horizontal potency, action sequence or recursive network traversal. A lower-tier Technique Card may occupy a higher-depth position as a Combo component, but it cannot execute standalone there. It remains a Technique Card, not a Support Card.

```text
A@1: A⌬1 Technique ↔ B@1: B⌬1 Technique
  → A⌬1, B⌬1 and authorized A⌬1+B⌬1 Combo
A@2: A⌬2 Technique; B⌬1 remains at B@1
  → A⌬2 standalone; no cross-depth A⌬2+B⌬1 Combo
A@2: A⌬2 Technique ↔ B@2: B⌬1 Technique
  → authorized A⌬2+B⌬1 Combo; raised B⌬1 has no standalone use
```

```text
Combo authorization
  component A = exact Technique && tier compatibility
  component B = exact Technique && tier compatibility
  result      = exact Combo-Action revision
```

Both Technique identity and tier compatibility are required. The physical link is undirected; an authored Combo may be symmetric or distinguish primary/secondary order. It references an exact Combo-Action, never dynamically merges arbitrary records. Exactly two endpoint expressions supply one distinct delivery hook each; their union must contain exactly two hooks. A two-hook composite cannot take another endpoint. Two Arcana endpoints cannot reuse one voice. Nested Supports/resonance add neither hooks nor components. Construct the exact Combo candidate and evaluate every dependency under P12; a failed component blocks the Combo without silent substitution.

A cardless inherent Technique participates through an **inherent endpoint**, a stable non-card layout position. This is the accepted C1-D4 connection, formerly called an inherent anchor during reconciliation; `anchor` remains reserved to T's Skill Anchor. The endpoint references an already possessed inherent Technique and grants no acquisition, source or hook. It may be empty when no compatible inherent Technique is possessed. The inherent Technique remains independently usable without an endpoint.

Endpoint depth matches the inherent expression's authorized tier; a tier-1 expression cannot be raised to depth 3 merely to reach a Combo. A higher expression must already be authorized by the Technique's progression. An inherent endpoint may receive compatible lower-tier Support Cards and acquired same-Technique resonance Cards under §2.3g, and may join an authorized same-depth Combo under this section. The inherent Technique remains cardless.

**P-C22 · Critical.** A Tarot Combo has exactly two directly linked same-depth endpoint expressions, exact Technique && tier compatibility and one exact Combo-Action revision. Each endpoint resolves one distinct hook; nested contributors supply none. An inherent endpoint references an existing cardless entitlement at matching tier/depth and never grants a Technique or source.

### 2.3i Tarot enhancement contracts [LOCKED 0.45.0, ◈C1-E]

The receiving Technique declares every permitted contribution dimension and variant. Exact contributor identity/revision, receiver identity/revision, receiver tier compatibility, permitted dimensions and layout/capacity requirements combine conjunctively. Resonance additionally requires an explicit same-Technique progression relation; display names and damage types do not establish one. A Support may target one Technique or an authored family whose membership and revisions resolve deterministically.

| Dimension | Same-Technique resonance | Support Card |
| --- | --- | --- |
| Damage, healing, shielding or mitigation output | May increase declared existing values | May modify and/or add explicitly authorized output |
| Effect strength, duration or displacement distance | Only declared existing potency fields | May modify and/or add explicitly authorized effect parameters |
| Range, area dimensions or target count | No default permission | May modify explicitly permitted parameters |
| Costs, execution time or cooldown duration | No default permission | May modify explicitly permitted parameters |
| Payload or other effect characteristics | Preserves existing effect set | May modify and/or add explicitly authorized Payload or effect characteristics |
| Targeting shape, delivery route or planning behaviour | Preserves existing contract | May modify and/or add explicitly authorized targeting, route or planning behaviour |
| Tier, entitlement, source requirements, hooks, footprint or aimed-mode capability | Cannot change | Cannot change |

Support additions select behaviour authorized by the receiving Technique; Technique remains the executable owner. Added routes and planning behaviour carry explicit requirements and inherit P12-C. Ordinary Payload cardinality remains zero or one under T-C16; exceptional multi-Payload authority cannot be inferred from cards. Resonance fields are authored individually, never all numerical fields by default.

```text
receiver at authorized tier
  → select highest-tier effective Support per identity
    → resolve authorized Support variants
      → aggregate same-Technique resonance
        → aggregate numeric Support contributions
          → apply declared bounds and rounding
            → validate the complete expression
```

Every adjustable field declares its stacking operator. The default uses one reference value after variant selection:

```text
final = clamp(reference × (1 + sum(proportional adjustments))
              + sum(flat adjustments))
```

Contributors never repeatedly multiply enhanced results. Integer counts and exclusive variants require suitable declared operators. Installation order cannot affect the result. Resonance scales only the receiver's declared potency fields; a Support-added effect participates only through explicit receiver authorization. Numeric evaluation uses P-C12 fixed-point/integer semantics, bounded values and deterministic rounding.

Capacity and effect compatibility are independent checks. Mutually exclusive variants make an expression invalid unless an authored composition resolves the pair; never discard a contribution silently or choose by installation order. Duplicate Support suppression occurs before variant and numerical evaluation. Runtime dependency failures remain local under P12 and do not rewrite installed state.

Resolve each enhanced endpoint before Combo authorization. The exact Combo declares which enhanced component values and variants it consumes. It neither discards nor inherits all contributions by default. Count every contribution once; no Combo output feeds back into components or nested contributors.

Each contract states bounds, minimum costs/cooldowns where applicable, and its failure conditions. Concrete tuning remains content/SIM work; no numerical bonuses are invented here. Existing source/Faculty/anatomy/equipment, Triade position/floor, Payload, hook, aimed-mode and M-H5 power constraints still hold. The generated card view exposes operative values, costs, prerequisites, contributions and incompatibility reasons; latent uses may remain undiscovered. C1-F owns the remaining presentation/discovery design.

Required proofs: installation-order invariance; explicit conflict failure; duplicate highest-tier selection; installed duplicates consuming capacity; each contribution counted once; pinned replay provenance; no recursive amplification; supported Combos retaining authorized behaviour and exactly two hooks; dependency-local runtime failure without fallback.

**P-C23 · Critical.** Every Tarot enhancement is authorized by its exact receiving Technique compatibility contract, with declared fields/operators/bounds, deterministic variant-first evaluation and no recursive amplification. Supports may modify/add only authorized effects; resonance increases declared existing output. Combo transfer is explicit and counted once, and no contribution bypasses P12, Payload cardinality, hooks, tier/floor, footprints or aimed-mode authority.

### 2.4 Editing controls the designer gets without SQL

ID dropdowns restricted to registered taxonomy · enum rejection · conditional formatting for missing required components · protected calculated columns (pip totals, vector sums, shield budgets, tooltip counts) · formula previews for free hands and legal combo pairings · **revision lock — approved revisions are never edited in place** · validation sheet by rule ID and severity · flattened preview that is never canonical · fixture-coverage view showing which rules have no proving fixture.

---

## Part 3 — Core attributes

**CR-11 record families are immutable and revisioned** [ADOPTED 0.36.0]. Each publishes as a pinned revision like every other content record — a running simulation references a revision, never a mutable row.

| Family | Row grain |
| --- | --- |
| `substance_profiles` | one substance — its domain, carrier kind, propagation pulse interval, dissipation and capacity bounds |
| `material_profiles` | one material — immutable capacities and responses, referenced by `material_id` |
| `reaction_definitions` | one Named Reaction — inputs, outputs, and the transition it authorises |
| `timeline_node_kinds` | one node kind — what it represents and where it falls in same-tick order (**K-C15**) |
| `action_timing` | one action — `commit_tick` offset, milestone offsets, `resolve_tick`, optional `recovery_tick` |

**Numeric fields are integer or `_q` at scale 12 000 (P-C12), and no float enters canonical persistence or a proof digest.** *Identifiers, enum values and revision references are not numeric fields and are unaffected* — the earlier blanket phrasing implied otherwise.

### 3.1 Identity and governance

`equipment_id` (stable across revisions) · `equipment_revision_id` · `revision_number` · `schema_version` · `content_version` · `lifecycle_status` (draft / candidate / approved / deprecated / retired) · `design_status` (locked / sim / open / gap / fixture) · localisation keys for display, short, description, flavour and **accessibility** text · `introduced_in_version` / `deprecated_in_version` · `source_document_ref` · **`decision_origin`** · `content_hash` · `approved_by` / `approved_at`.

**`decision_origin` carries `[W]` / `[U]` / `[BOTH]` / `[NEW]`.** The reconciliation marks become queryable provenance rather than prose in a report nobody greps.

**Text lives in a localisation table** — `locale`, `text_key`, `text_kind`, `text_value`, `revision`. `en-GB` is the reference locale, explicitly labelled, never an unmarked default.

### 3.2 Protected flags are derived, not authored [LOCKED]

`is_secret` and `is_relic` are fields rather than tags because M-C6/C7/C8 make them lintable: generation may not create them, and salvage, reroll, sale and discard may not consume them.

**`can_drop`, `can_salvage`, `can_reroll`, `can_sell`, `can_discard` are derived** from category and protected flags — never freely authored. An authored row is one typo away from making a `[Secret]` destructible.

### 3.3 Damage and the martial profile

The taxonomy is M·2A.3's, unchanged: **Physical** (Slash, Impact, Pierce) · **Volatile** (Explosive, Fire, Lightning, Cold) · **Corruptive** (Corrosive, Poison) · **Structural** (Shatter, Tear) · **Occult** (Chaos, Divine, Psychic). Fourteen types, five groups, type-to-group controlled centrally.

**The final footprint never overwrites the base.** It is an evaluated chain:

```
base footprint
+ qualifying affix footprint
→ requirement-check footprint
→ skill redistribution            (zero-sum unless Transgressive/Inscription)
→ final action footprint
+ external bonus damage
→ resolved outcome
```

This ordering preserves M·2A's object boundary: affixes are part of the weapon and may satisfy requirements; external buffs change outcome but never weapon identity or skill access.

### 3.4 Fixed-point everywhere [LOCKED]

**All persisted simulation and trace state uses fixed-point integers** (`_q` suffix), never binary floats.

The reason is already a rule: **W-C10** bars render- and float-derived values from the proof digest, and the design requires deterministic reproduction. Float accumulation across a 10,000-seed sweep is not reproducible across platforms. The scale is a **versioned implementation constant**, never an undocumented multiplier.

### 3.5 Rarity is mechanical demand [LOCKED]

Not a magnitude multiplier. `broad` works from home or a shallow lean; `focused` rewards a corner or light pairing; `exacting` requires a region or a tight window. **Item level** controls roll magnitude; `is_unique` owns rule-breaking. Affix *count* may follow the rolled demand policy, but "rare" never implies an unconditionally larger stat total.

---

## Part 4 — Storage

### 4.1 DuckDB, pinned [LOCKED]

**DuckDB is the embedded analytical engine.** MIT-licensed in perpetuity, IP held by the non-profit DuckDB Foundation. In-process, no server, native Parquet and JSON reading with projection and filter pushdown, LIST/STRUCT/MAP/UNION nested types, direct Arrow/Polars/pandas interchange.

**Pin the v1.4 LTS line.** v1.5.x is current and **v2.0 lands September 2026**; the LTS is supported to the same month. Migrate after v2.0 has stabilised, not on release. *A design document naming a database without naming a version has a hidden dependency.* `[OPEN] ◇P1` — revisit at v2.0.

| Criterion | DuckDB | SQLite | Server DB |
| --- | --- | --- | --- |
| In-process | Yes | Yes | No |
| Analytical scans | Primary target | Not its target | Product-dependent |
| Parquet | Native | External work | Connector work |
| Arrow / Polars | Direct | Conversion | Driver-dependent |
| Multi-process writes | **Constrained** | Better for small OLTP | Natural escalation |
| Role here | **Catalogue and analytics** | Runtime metadata alternative | Later, if collaborative |

### 4.2 The single-writer boundary is accepted, not worked around

DuckDB permits many readers and **one writing process**. That is sufficient:

```
Human / agent branches  →  canonical JSON commits  →  one validation-import worker  →  triade.duckdb + trace Parquet
```

**Git is the collaboration and conflict-resolution layer.** DuckDB is a rebuildable local/CI artefact, not a multi-user authoring server.

**Escalation, if several live services ever write at once:** keep the schemas, move the operational catalogue to **PostgreSQL**, retain DuckDB for local analytics. DuckLake and the Quack client-server protocol are newer options — recorded, not chosen, because Postgres is proven and they are months old. `[OPEN] ◇P2`.

**Escalation, if file-level merges stop resolving content conflicts:** **Dolt** applies git semantics at cell level — branch, diff and merge individual rows rather than whole JSON files. Recorded, not chosen. Canonical JSON under git already supplies the versioning this project needs, and adopting Dolt costs a second storage engine and the loss of plain-text authoring, which is the property that makes *content is data, never code* inspectable by a human. The trigger is concrete and measurable: several authors editing one content file often enough that file-level merges become the bottleneck. **That frequency has never been measured**, so the escalation has no gate. Industry adoption was asserted in the 0.15.0 equipment-model reconciliation and is not verified here. `[OPEN] ◇P9`.

### 4.3 Physical layout

```
warehouse/  triade.duckdb
lake/
  traces/origin={simulation|in_game}/game_build=*/fixture_set=*/run_date=*/part-*.parquet
  signatures/algorithm=*/part-*.parquet
```

DuckDB schemas: `ref.*` controlled vocabularies · `content.*` approved revisions · `generation.*` policies · `runtime.*` local test instances · `fixture.*` frozen fixtures · `trace.*` metadata and indexes · `analytics.*` signatures and comparisons · `audit.*` provenance, validation, migrations.

**Never commit raw Parquet to git.** Sim output is reproducible from seeds — version the **seeds, config and sim code** instead. git-LFS only for deliberately tracked samples.

### 4.4 Validation stack [LOCKED]

| Layer | Tool | Role |
| --- | --- | --- |
| Record | **Pydantic v2** | Parse and validate every authored or agent-generated record at the boundary |
| Table | **Pandera** | Schema, dtype, range, cross-column and distribution checks on assembled tables |
| Marts | `dbt-duckdb` *(optional)* | Version-controlled SQL transforms with `dbt test` assertions |

Great Expectations was considered and **rejected as overkill** at this team size; it is the escalation if formal data-quality monitoring is ever needed.

**Database CHECK constraints enforce local arithmetic only** — `dm_q + df_q + di_q = 0` and similar. The content linter stays authoritative for cross-row and cross-domain rules: pip budgets, anchor reachability, shield dominance, mission-key protection, fixture coverage.

---

## Part 5 — Trace and telemetry

### 5.1 Not a JSON blob per combat

T·I.1 requires, for every action: Triade position, all three credit counters, region membership, the action taken, and the source of every state delta — with Opening provenance distinguishing player-created, environmental and enemy or self-inflicted. That needs an event-and-delta model.

```
TraceRun
 ├── TraceActor · TraceEncounter
 ├── LoadoutSnapshot → EquipmentSnapshot[]
 ├── ActionEvent[]
 │    ├── SourceUsage[] · StateSnapshotBefore
 │    ├── StateDelta[] · OpeningEvent[] · DamageResolution[]
 │    └── StateSnapshotAfter
 └── RunOutcome
```

### 5.2 Run provenance

`trace_run_id` · `trace_origin` (`unit_test`, `golden_test`, `simulation`, `playtest`, `in_game`, `replay`) · `game_build` · `content_snapshot_hash` · `schema_version` · `fixture_set_id` · `root_seed` · `rng_stream_manifest` · `generator_version` · `difficulty_policy_id` · `started_at` / `completed_at` · `outcome` · `player_consent_class` · `privacy_class`.

**`outcome` values: `victory`, `death`, `band_end_exit`, `abandonment`, `timeout`.** *Not* `extraction` — that word is reserved to the W§12 pipeline stage, and a band leaves through a `[Band-End Portal]`.

### 5.3 Per-delta attribution [LOCKED]

One row per state change: `delta_id` · `event_id` · `target_actor_id` · `state_domain` (Triade, credit, HP, integrity, ward, wound, status, AP, skill access) · `state_key` · `value_before_q` · `delta_value_q` · `value_after_q` · `unit_id` · `source_kind` · `source_revision_id` · `source_item_instance_id` · `contribution_role` (direct, multiplier, gate, conversion, mitigation, trigger) · `rule_id` · `parent_delta_id` · `opening_provenance` · **`is_counterfactual`**.

`is_counterfactual` marks paired runs, which is what makes **delta signatures** computable — a modifier's signature is the difference between traces with and without it.

This answers the question the design actually needs: *was this item strong because of raw damage, extra vocabulary, displacement, Opening creation, credit conversion, mitigation, or synergy?*

### 5.4 Power attribution

M·9.6's decomposition, stored as a fact table — one row per run, actor, segment and contribution class:

```
ln P_effective = ln P_gear + ln P_synergy + ln P_vocabulary + ln P_execution
```

`trace_run_id` · `actor_id` · `segment_id` (encounter / storey / band / run) · `contribution_class` · `log_power_contribution` · `source_revision_id` · `method_version` · `confidence` · `is_outlier`.

Multiplicative contributions become additive, so an outlier run is **attributed**, not merely detected. This is what rule **M-H5** — no interaction above ~20% of a band's log-power gain — is checked against.

### 5.5 Signatures

Actors (equipment, skills, faculties, enemies, builds) get direct signatures. Modifiers (affixes, passives, set bonuses, tomes) get **delta signatures** from paired runs.

Stored features: residency histogram · credit profile · displacement · excursion depth · region residency · transition matrix · credit economy · loop economy · provenance mix · equipment contribution · power decomposition.

Every signature is keyed by **source kind, source revision, fixture-set version, simulation build, signature algorithm version, paired-control revision, sample count.** Without all seven, a balance comparison can silently mix fixtures or algorithms. Earth Mover's Distance compares residency histograms, because it respects proximity between neighbouring simplex cells.

### 5.6 Capture levels — one schema, five densities

| Level | Origin | Detail |
| --- | --- | --- |
| Full deterministic | Unit and golden tests | Every event, input, RNG draw, delta |
| Full analytical | Simulation sweep | Every event and delta; compressed RNG provenance |
| Diagnostic | Playtest | Full data around flagged encounters |
| Sampled | Production | Selected fields plus aggregates |
| Aggregate only | Privacy-constrained production | Signatures and counters, no event stream |

**Simulation and live gameplay share one event schema**, distinguished by `trace_origin`. That is what makes "designed behaviour in fixtures" comparable with "observed behaviour in play" through the same signature algorithm — and a weapon whose sim signature is distinct but whose live signature collapses into the generic cluster is hard to use, badly communicated, or drowned by player habit.

---

## Part 6 — The agent pipeline

```
Brief → reserve IDs and schema version → generate or hand-edit tabular candidate
  → compile to canonical JSON → schema and invariant lints
  → import candidate revision into a DuckDB staging schema
  → generate item populations → paired fixture simulations
  → raw traces to Parquet → direct and delta signatures
  → redundancy, dominance and identity-drift checks
  → HUMAN APPROVAL → promote immutable revision
```

### 6.1 The agent's query path is read-only [LOCKED]

The agent reads through a **read-only MCP server**; content writes go through the validated Pydantic path and never through the agent's SQL tool.

**Why sandboxing rather than trust.** Text-to-SQL on a shallow, well-named schema like this one is reliable — roughly 94–95% accurate under realistic human-or-model review. Strict execution-accuracy benchmarks put it near 76%, and those benchmarks have documented annotation problems, so the true figure is uncertain in a direction nobody can currently pin down. **Read-only makes a wrong query harmless**, which is cheaper than making it correct.

Schema introspection — `DESCRIBE`, information-schema views, descriptive column names and a written data dictionary — does more for query accuracy than any semantic layer at this schema size.

### 6.2 Artefact provenance

Every artefact records agent ID, charter version, model, prompt hash, input schema hash, seed, validation results and human verdict, per M·5.1.

---

## Part 7 — Validation

```
Tabular structure → JSON Schema → referential linter → arithmetic/invariant linter
  → generation sweep → fixture simulation → trace/signature analysis → human design gate
```

Findings land in one `validation_result` table: `validation_run_id` · `subject_kind` · `subject_revision_id` · `rule_id` · `severity` · `result` · `message` · `field_path` · `evidence_payload` · `override_reason` (**required for High overrides**) · `validator_version` · `created_at`.

### 7.1 Core equipment lints

Unique identity · source resolution (T-C12) · category component completeness — `shield` requires the weapon **and** armour component sets · **scalar authoring — no array encoded as delimited text** · pip conservation (M-C-series) · footprint boundary — external buffs never satisfy weapon requirements · damage type maps to exactly one group · Structural resolves through integrity · vector sum zero (T-C1) · per-region threshold reductions only · temporary effects never mutate baseline floors (T-C6) · **exactly two delivery hooks (T-C13)** · free-hand requirements match actual occupancy · one pooled shield budget · both Opening-creation paths present on a shield · shield and body-armour integrity independent · protected flags unbreakable · affix exclusivity · tag budget · power band · readability budget · **fixture coverage — every locked subsystem names a proving fixture or an explicit gap.**

---

## Part 8 — Open items

| # | Question | Status | Owner |
| --- | --- | --- | --- |
| **◇P14** | **Tarot architecture closeout.** C1-A–E are adopted at §2.3f–i; C1-F must settle card information, discovery, V-owned visual templates and previews. C1-G must settle Support acquisition/persistence details and representative fixture/validation handoff before Session C1 closes. Stage 3 custody/economy and C2 implementation remain downstream. | **[OPEN]** | Design / P |

| # | Question | Status | Owner |
| --- | --- | --- | --- |
| **◇P1** | **DuckDB v2.0 migration.** v1.4 LTS is pinned and supported to September 2026, the same month v2.0 ships. Storage-format churn across that boundary is unassessed | **[OPEN]** | Tooling |
| **◇P2** | **Multi-writer escalation path.** PostgreSQL is the chosen fallback; DuckLake (v1.0, April 2026) and Quack (beta) are newer and unproven here | **[OPEN]** | Tooling |
| ~~**◈P3**~~ | **CLOSED 0.34.0.** `FIXED_POINT_SCALE = 12 000`; `1.0 = 12 000_q`; persisted as **signed 64-bit**; conversion **round-to-nearest, ties away from zero**; multiplication through a **checked wider intermediate** before dividing by 12 000. **Binary floats never enter canonical persistence or a proof digest.** *`world_tick`, tick durations, AP rates and bounded `u8` channels are ordinary integers — not `_q`* | — | — |

**The fixed-point contract** [ADOPTED 0.34.0, S-P01]:

| | |
| --- | --- |
| Scale | `FIXED_POINT_SCALE = 12 000`, so `1.0 = 12 000_q` |
| Storage | Signed **64-bit** integers |
| Conversion | **Round to nearest, ties away from zero** — stated because banker's rounding and truncation both look like defaults and disagree |
| Multiplication | Through a **checked wider intermediate**, then divide by 12 000. Unchecked `a_q × b_q` overflows at surprisingly ordinary magnitudes |
| Floats | **Never** in canonical persistence or a proof digest (**W-C10**, **P-C2**) |

**12 000 is derived, not chosen.** It is the smallest scale that exactly represents the fractions this corpus actually uses — `1/3`, `1/12`, `0.05`, `0.25`, `0.35`, `0.45`, and `1/6` and `0.1` besides. A scale that cannot represent `1/3` exactly would make the three-corner geometry lossy at its most common value, and the loss would be invisible until two platforms disagreed on a digest.

**Headroom is not the constraint.** Signed 64-bit at this scale reaches ±7.7 × 10¹⁴ in real units; nothing in the design approaches it.

**What is *not* `_q`.** `world_tick`, tick durations, AP rates, AP costs and bounded `u8` environmental channels are **ordinary integers**. The scale governs *persisted fractional simulation state*, never the clock — a ruling worth stating as a negative, because "we use fixed point" invites someone to store time in it.
| **◇P4** | **Trace volume per sweep.** A 10,000-seed sweep at full analytical density has no estimated row count or byte footprint, so the partition strategy is unvalidated | **[OPEN] [SIM]** | Tooling |
| **◇P5** | **Localisation scope.** `en-GB` is the reference locale; whether any second locale exists at ship is undecided, and it changes whether text tables are worth their joins | **[OPEN]** | Scope |
| **◇P6** | **Content package format for the game runtime — named, never specified.** *Widened 0.26.0:* this also owns the **canonical schema version contract**. `schema/equipment.schema.json` is a placeholder with no version contract while equipment rows expose `schema_version`, so the field stays blank rather than fabricated. Blocks canonical JSON validation and content-package approval; does not block the Grist candidate | **[OPEN] [GAP]** | No owner |
| ~~**◈P7**~~ | **CLOSED 0.20.0.** All 140 indexed rules are authored in their home document, measured against **P-C8** — the ID leads its line or its first table cell. The item was counted at seventeen, nineteen and thirty before it was measured; the answer was **twenty-five rows needing a tag, three home mis-assignments and zero rules needing to be written**. `L-M1`/`L-M2` now live in **L·12**; `M-C3`, `M-C5`, `M-H4` were already stated in **M** and simply carried no ID. Census and the published regeneration command agree at **140 of 142** | **CLOSED** | — |
| ~~**◈P7a**~~ | **CLOSED 0.19.0.** The regeneration command is correct. Its recovery — 109 of 142 — was independently reproduced by the ◇P7 census counting authored rows, and the two agree exactly. The shortfall was never a command defect; it was ◇P7 | **CLOSED** | — |
| **◇P9** | **Cell-level content versioning.** Dolt is the recorded escalation if file-level JSON merges stop resolving content conflicts. Unchosen, and **the trigger condition — concurrent authors on one content file — has never been measured**, so nothing would tell us we had crossed it. Adoption costs a second storage engine and plain-text authoring | **[OPEN]** | Tooling |
| **◇P10** | **The protected `ref_tags` registry is empty**, so no legal `equipment_tags` reference can be authored and tag-based search, generation and lints stay unavailable. Authoring plausible tag strings would bypass the protected registry, so the child table is correctly left empty. **The question is whether the M10 vertical slice requires a minimum protected tag registry** — scope, not semantics. No identity or martial-profile loss today | **[OPEN]** | Tooling / P |
| ~~**◈P11**~~ | **CLOSED 0.41.0.** P·2.3b registers four immutable Faculty identities, four base profiles, four explicit composite profiles, their hook requirements, exact damage footprints, primitive actor-pull signatures and 32 normalized Technique authorizations. Somatic remains bound-node authorization. Rend remains weapon-based; Hex is Arcana && Mudra; derived renditions are not duplicate vocabulary rows. | **CLOSED** | — |
| ~~**◈P12**~~ | **CLOSED 0.44.0.** P12-A fixes entitlement/acquisition identity; P12-B fixes candidate readiness and target-route dependency; P12-C fixes pure ordered evaluation, explicit environmental target domains and resolution-participant roles, exact-candidate atomic commitment, milestone-local live revalidation and autonomous scheduled/triggered Plannable Actions. C defines technical columns only through an explicit implementation pass. *Backlogged from `TS-M10F-02`, 0.30.0* | **CLOSED** | — |
| ~~**◈P13**~~ | **CLOSED 0.40.0.** P·2.3a registers the complete normalized lineage/physique grain plus deliberate/passive innate grants, per-Technique source nodes and per-Payload support dependencies. Equipment `chassis_profiles` remain barred. Somatic authorizes deliberate natural-node Techniques without duplicating their footprint or hook. | **CLOSED** | — |
| **◇P8** | **Fixture enemy and encounter-membership field sets.** P·10.5–10.6 specify frozen enemy fixtures and multi-enemy compositions; P·2.3 now registers `fixture_enemies` and `fixture_encounter_members` as the normalized relations, but **their column sets are unfixed**. The enemy-fixture fields must be reconciled against **E**'s capability ladder and tag classes and against **H**'s body templates before they are locked. Until then canonical ◈M10 fixture JSON cannot be frozen without guessing | **[OPEN] [GAP]** | Tooling / P *(with E, H)* |

---

## Part 9 — Validation rules

| ID | Rule | Severity |
| --- | --- | --- |
| **P-C1** | Canonical JSON is the source of truth; the build is one-directional, text → database, never the reverse | Critical |
| **P-C2** | All persisted simulation and trace state uses fixed-point integers, never binary floats *(W-C10)* | Critical |
| **P-C3** | No authored cell contains a delimited array; every repeatable value is a child row | Critical |
| **P-C4** | An approved revision is never edited in place — changes create a new revision | Critical |
| **P-C5** | Every trace event resolves to an exact content revision and `content_snapshot_hash` | Critical |
| **P-C6** | `can_drop` / `can_salvage` / `can_reroll` / `can_sell` / `can_discard` are derived from category and protected flags, never authored | Critical |
| **P-H1** | The agent's query path is read-only; writes pass through record validation | High |
| **P-H2** | Every signature is keyed by all seven identity fields | High |
| **P-H3** | Every `[SIM]` parameter has a `design_parameters` row carrying basis, gate and failure path | High |
| **P-H4** | Raw Parquet is never committed to git; seeds, config and sim code are versioned instead | High |
| **P-M1** | `en-GB` is the explicitly labelled reference locale, never an unmarked default | Medium |
| **P-C7** | Every locked subsystem names a proving fixture in P10, or an explicit gap in P·10.7 | Critical |
| **P-C8** | Every rule in the Validation Rules Index **leads its line or its first table cell** in its home document. A rule cited only inside another rule's text, or only in a changelog row, is not authored *(the ◇P7 test, made enforceable at 0.19.0)* | Critical |
| **P-H5** | Every item in an **intake record** carries exactly one **type** — `FINDING` or `AUTHORED DESIGN DECISION` — and exactly one **disposition** — `authored`, `enforced-elsewhere`, `backlog`, `struck` or `unresolved`. `authored` names its receiving document **and** section. An item naming two homes, or none, is unresolved and blocks retirement | High |
| **P-C10** | An `AUTHORED DESIGN DECISION` is non-authoritative until its disposition is `authored`. Until then a technical document marks it **authored-but-not-yet-centralised** and may not cite it as an existing rule. Implementation against it is legal; asserting it as design is not | Critical |
| **P-C11** | The **factual claims** of a historical changelog row or release summary — counts, severity splits, `N of M` figures — may not be altered. A version bump touches current-state assertions only. **Notation is exempt and migrates retroactively by design**: filenames are repointed so links resolve, identifiers gained glyphs at 0.18.0, section refs were normalised at 0.19.0. Enforced by `tools/history-check.sh` against the earliest archive holding each entry | Critical |
| **P-C12** | Critical | `FIXED_POINT_SCALE = 12 000`. `_q` values persist as signed 64-bit integers, convert by round-to-nearest ties-away-from-zero, and multiply through a checked wider intermediate. **No binary float enters canonical persistence or a proof digest.** `world_tick`, tick durations, AP rates and `u8` channels are ordinary integers, never `_q` |
| **P-C13** | Critical | A lineage revision references exactly one H-owned BodyTemplate, has at least one allowed size with exactly one `typical`, and carries exactly nine integer stat-offset rows summing to zero. The typical size has no physique pair; each other allowed size has at most two ordered positive-magnitude gain/loss pairs. Equipment `chassis_profiles` never store actor lineage or anatomy |
| **P-C14** | Critical | A passive innate grant binds no executable Technique. A deliberate innate grant references exactly one Faculty, explicitly declares `entitlement_mode` as `conferred` or `unlocked`, and every Technique binding resolves through an eligible source-node row. Payload support is authored at binding × Payload × node grain; a support node is never a source or delivery hook. Lineage never directly grants a Technique |
| **P-C15** | Critical | Every Faculty profile is an immutable base or explicitly registered unordered composite with normalized member, damage-entry and hook-requirement rows. Profile footprints and primitive actor-pull signatures equal M·2A.10a exactly; no universal composition arithmetic or additive runtime Faculty pull is legal |
| **P-C16** | Critical | Technique authorization is one Faculty profile × Technique revision row. The seed fixture contains exactly 32 rows; Rend is absent, Hex belongs to Arcana && Mudra, and Poisonous Bite/Poisonous Rend remain derived renditions rather than duplicate authorizations |
| **P-C17** | Critical | Entitlements attach only to base Faculties. Build instructions and actor acquisitions remain authoritative facts; the actor entitlement is a generated projection, possession derives from conferred or acquired, availability is never stored, and acquisition survives unlock-source loss unless explicitly leased or revocable |
| **P-C18** | Critical | `known`, `selectable` and `executable` are distinct derived predicates. Alternative complete execution candidates combine existentially; dependencies within a candidate combine conjunctively. Failure is dependency-local, transferred provisions cease depending on their provider unless continuous maintenance is explicit, and every failed gate is reported without executing side effects |
| **P-C19** | Critical | Technique evaluation is pure and deterministically ordered over one immutable snapshot, returning `pass`, `fail` or `blocked_by` without side effects. Target domains and selected/contact/recipient/reaction-product roles are explicit; executability validates the submitted target/origin and route while milestone resolution discovers and stably orders current resolution participants |

---

## Part 10 — The ◈M10 fixture set [LOCKED 0.15.0]

*Closes **◈M10**. Rebuilt against this document's fixture domain. K·15 specified the shape at 0.9.0; this supplies the records and corrects two things K·15 could not have known.*

### 10.1 Two corrections to K·15

**K·15 predates the faculty channel and cannot cast.** Its three loadouts — maul, daggers, sword and shield — occupy both hands each, so **none can source a `[Mudra]`**. The somatic gate, and Fantasy 3 which exists to validate it, had no fixture.

**The carrier is a free off-hand, not a wand.** Any one-handed weapon with an empty off-hand qualifies. Dual daggers are a *choice*, not a necessity. A single-dagger trickster and a mace-and-free-hand war priest are more idiomatic caster-hybrids than a wand specialist, and they exercise the same gate at no extra content cost.

### 10.2 Reference builds

Floor shapes are class-alone (T·D), `ΣF ≤ 0.45`, `F_x ≤ 0.25`. Stat weights are **relative and dimensionless** — the harness picks an absolute budget and normalises at instantiation, so the fixture never invents the scale the simulation is meant to discover.

| Build | `F_m` | `F_f` | `F_i` | Home region | Loadout | Free hand |
| --- | ---: | ---: | ---: | --- | --- | --- |
| **Striker** | **0.25** | 0.15 | 0.05 | Pressure | Maul *(two-handed)* | No |
| **Controller** | 0.09 | **0.18** | **0.18** | Discipline | **`1h-Sword`** and shield | No |
| **Technical** | 0.15 | 0.10 | **0.20** | Instinct | Twin daggers | No |
| **Trickster** | 0.12 | 0.08 | **0.25** | Instinct | **Single dagger** | **Yes** |
| **War priest** | 0.15 | **0.20** | 0.10 | Discipline | **`1h-Mace`** | **Yes** |

**Each build proves something structural, not merely something plausible.**

| Build | Proves |
| --- | --- |
| Striker | Sits **exactly on** the 0.25 per-corner cap — the fixture demonstrating the cap does not lock out the opposite region (T·A.2) |
| Controller | Deliberately **balanced parents** — the only configuration exercising the sector render's super-additivity, and therefore **T-C11** |
| Technical | Two independent footprints, two hooks, redistribution efficiency, limb-specific function loss |
| **Trickster** | `[Mudra]` from a free off-hand; `[Psyche]` gate on head and spine |
| **War priest** | `[Arcana]` on the voice hook; **Divine purge** conversion and its brake, **H-H6** |

| Stat weights | Str | Fin | Sta | Int | Will | Spi | Frm | Poi | Con |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Striker | **3** | 2 | 1 | 1 | 1 | 1 | 2 | 1 | 2 |
| Controller | 1 | 1 | **3** | 2 | 2 | **3** | 2 | 2 | **3** |
| Technical | 1 | **3** | 1 | **3** | 2 | 1 | 1 | 2 | 1 |
| Trickster | 1 | **3** | 1 | **3** | 2 | 2 | 1 | 2 | 1 |
| War priest | 2 | 1 | 2 | 2 | **3** | **3** | 2 | 2 | 2 |

**Striker and Controller together prove the within-corner axis** T·A4.1 asserts and nothing else tests: Reach emphasises capacity plus application, Floor emphasises resilience. Striker is capacity-heavy and reaches deep; Controller is resilience-heavy and holds.

### 10.3 Loadouts

| Item | Hands | Martial profile | Pips | Hooks |
| --- | --- | --- | ---: | --- |
| Maul | Both | `Impact +++, Shatter +` | 4 | 1 |
| Dagger | One | `Pierce ++, Slash +` | 3 | 1 per copy |
| Dagger *(off-hand form)* | One | `Pierce +, Slash +` — **M-C11**, one pip off the highest type | **2** | 1 |
| **`1h-Sword`** | One | `Slash ++, Pierce +` | **3** | 1 |
| Shield *(standard)* | One | `Impact +` + `Physical +` defence, **from one pooled budget** (M-C9, M-C10); integrity independent | 2 | 1 |

**Footprint order is significant.** A `base_footprint` list is stored and exported **in martial-priority order** — signature first, concession last (M·2A.9). A pipeline stage that sorts or re-serialises it alphabetically, or by pip count, changes what **M-C11** removes. Order is data, not presentation.
| **`1h-Mace`** | One | `Impact ++, Shatter +` | 3 | 1 |

**The maul carries the only full Structural load**, so it drives the Stable → Cracked → Fractured → Broken Guard ladder. **Daggers are the redistribution fixture** — a Pierce-heavy base is where M·2A.9's zero-sum move is cheapest and should read as *"superb on an estoc"* in the trace. **`1h-Sword` and shield is the only two-budget loadout.**

*These pip values are reference figures for the frozen set and now follow the locked handedness budget (**M-C1**, M·2A.9): an ordinary one-hander carries **3** base pips, an ordinary two-hander **4**. The formerly unqualified 4-pip Sword profile is a **`2h-Sword`** and is not part of this loadout.*

*Correction, 0.17.0.* The note previously here said the 4-pip one-hander norm remained unverified and was `[OPEN]` in **M**. **No such open item ever existed in M** — the cross-reference was dangling from 0.15.0, and a reader checking M's open-items table would have found nothing. The question it pointed at is now answered by M-C1 rather than tracked.

### 10.4 Combo-Action coverage — including the negative cases

| Combination | Fixture | Legal |
| --- | --- | --- |
| Two weapons | Technical | ✓ |
| Weapon + shield | Controller | ✓ |
| Weapon + `[Arcana]` | War priest, Striker | ✓ |
| Weapon + `[Mudra]` | **Trickster, War priest** | ✓ |
| `[Arcana]` + `[Mudra]` | Trickster, War priest | ✓ |
| `[Mudra]` + `[Mudra]` | *(needs two free hands — see P·10.7)* | — |
| `[Arcana]` + `[Arcana]` | — | **✗** one voice, one hook |
| Three sources | — | **✗** T-C13 |
| `[Mudra]` on a two-hander | Striker | **✗** — the paladin case, proving the gate bites |

**The negative cases are fixtures too.** A rule nothing fails is a rule nothing tests.

### 10.5 Enemies

| | Trash | Standard | Elite | Commander | **Beast** |
| --- | --- | --- | --- | --- | --- |
| Chassis | Goblin | Goblin | Goblin | **Ogre** | **Canine** |
| Physique | Small | Average | Average | Large | Average |
| Behaviour | Simpleminded | Compulsive | Compulsive, Simpleminded | Compulsive | Compulsive |
| Equipment | — *(0)* | Pike | Pike | Maul | — *(0)* |
| Faculty | `[Innate]`/upper | `[Innate]`/upper | `[Innate]`/upper | `[Innate]`/upper, **`[Arcana]`** | **`[Innate]`/bite, forelimb** |
| Role | — | — | `[Elite]` | `[Commander]` | — |
| Template | humanoid-5 | humanoid-5 | humanoid-full | humanoid-full + signature node | **quadruped** |

**Trash matters most.** Equipment cardinality 0 with `[Faculty]` ≥ 1 is exactly the hole rule **E-C6** closed — this fixture proves an enemy with no equipment can act.

**The Canine chassis buys three things at once.** It is the only **non-humanoid template** in the set, so it exercises `◇E5` and partially unblocks `◇V1` and `◇G6`. Its `[Innate]` slots derive from a quadruped template with no upper-limb group in the human sense, proving **H-C7**. And its **bite** gates on jaw and teeth — the same nodes that deny `[Arcana]`, so one wound denies two things with no new rule.

**The Commander carries `[Arcana]`**, giving Fantasy 3 a jaw to break. `aim_weight` → coverage cascade → jaw node → `function_denial` → Signature denied is the longest causal chain in the design, and nothing else tests it end to end.

### 10.6 Encounters

| Encounter | Zones | Composition | Proves |
| --- | ---: | --- | --- |
| **◈E1 Corridor** | 2 | 2 Trash | Minimum legal zone count; no `[Back-foot]` |
| **◇E2 Chamber** | 3 | 1 Standard, 2 Trash | `[Back-foot]` non-stacking per attacker |
| **◇E3 Gallery** | 4 | 1 Elite, 2 Standard | Maximum zones; Advantage by circumstance *and* by Opening |
| **◇E4 Vault** | 3 + `high_ground` | 1 Commander, 2 Standard | Signature charge; **◇E8's high-ground → S-E03 coupling** |
| **◇E5 Den** | 3 | 3 Beast | Non-humanoid anatomy; `[Innate]` bite; pack behaviour-diversity threshold (`E-H2`) |

**Composition is authored as normalized rows, never as a delimited cell.** The Composition column above is documentation prose; the authoring representation is one `fixture_enemies` row per enemy definition and one `fixture_encounter_members` row per encounter × enemy pairing, carrying an integer `quantity`. Encoding `1 Commander, 2 Standard` in a single authored cell would violate **P-C3**. The relations are registered in P·2.3 and their field sets remain **[OPEN]** under **◇P8**.

**Damage scope:** Physical + Structural + **Chaos** as the single Occult proof type — the only Occult type carrying `+corruption`, so it alone drives Divine purge's conversion path and **H-H6**. Linear ADM/CDM/EDM only, per K·15.

### 10.7 Declared coverage gaps

Recorded so nobody later reports the set as complete.

| Gap | Consequence |
| --- | --- |
| **`[Mudra]` + `[Mudra]`** | Needs two free hands; no build has them. An unarmed sixth build would close it — **deferred, not forgotten** |
| **Bands B and C** | These are band-A fixtures. The ×9 career curve and the 6.3% per-pick constant cannot be validated from them |
| **Non-humanoid breadth** | Canine is one quadruped. `◇E5` needs more templates before `◇V1` and `◇G6` fully clear |
| **Behaviour-tag legality** | `◇E3`'s contradictory-pair lint does not exist, so the Elite's two-tag combination is unconfirmed |
| **Encounter diversity threshold** | `S-E02` is unset, so ◇E3 and ◇E5 may violate a threshold nobody has chosen |

---

## Changelog

| Version | Change |
| --- | --- |
| **0.45.0** | **C1-A–E adopted at §2.3f–i.** Card acquisition/persistence, local-depth layout, Support/resonance capacity, exact same-depth Combos, inherent endpoints and deterministic modify/add enhancement centralized as P-C20–P-C23. ◇P14 owns C1-F/G; Stage 3 and C2 remain gated. |
| **0.44.0** | **`◈P12` closes.** §2.3e locks pure ordered evaluation, explicit environmental target domains and resolution-participant roles, exact-candidate atomic commitment, milestone-local live revalidation, cost/cooldown milestones and autonomous scheduled/triggered Plannable Actions (**P-C19**). |
| **0.43.0** | **`◇P12-B` closes.** §2.3d defines route-level readiness as `known`, `selectable` and `executable`; candidate alternatives are existential while within-route requirements are conjunctive. Dependency-local invalidation, transferred-provision survival, declared cooldown propagation and Technique-authored target-route validity are authoritative (**P-C18**). The missing authoritative source row for existing **P-C17** is restored. P12-C remains open for deterministic evaluation/commit order. |
| **0.42.0** | **`◇P12-A` closes.** P·2.3c adds authoritative build instructions and actor acquisitions plus a generated actor-entitlement projection (**P-C17**). Entitlements attach only to base Faculties; composite profiles remain authorization profiles. Possession derives from conferred/acquired, and acquisition normally survives loss of an unlock source. P12-B/C remain open for complete derived availability and evaluation order. |
| **0.41.0** | **`◈P11` closed.** P·2.3b adds four normalized Faculty relations, four immutable identities, eight exact profiles and 32 Technique authorizations (**P-C15**, **P-C16**). P·2.3a now lets Lineage grants explicitly confer or unlock a Faculty; both Venomous Hobgoblin grants confer Somatic (**P-C14**). `◇P12` remains open for actor/build entitlement persistence and complete derived availability. |
| **0.40.0** | **◈P13 closed.** Twelve normalized lineage, physique, innate-profile and grant relations added at §2.3a, taking the authoring set to forty-two sheets. Somatic is the authorization-only Faculty for deliberate natural-node Techniques; binding-source and Payload-support grains remain distinct (**P-C13**, **P-C14**). `◇P11` expands to four concrete Faculty instances and remains open; `◇P12` remains the normalized fixture build × Faculty relation. |
| **0.39.0** | Version alignment and boundary statement only. A2 is design-authored in T/H/K/E, but P adds no schema: intake A3 §12 remains the sole authoring/automation pass. Session B still starts at `◇P13`. |
| **0.36.0** | **CR-11 record families registered** as immutable pinned revisions — substances, materials, reactions, timeline-node kinds, action timing — all integer or `_q` at scale 12 000 (**P-C12**). |
| **0.32.0** | **`◇P11` restated.** It claimed no document stated a faculty's origin, footprint or vocabulary — M·2A.10a locks all three as *fields*; what is absent is **instances**. Unarmed left the item entirely for the lineage. |
| **0.31.0** | **Footprint order recorded as data, not presentation** — a `base_footprint` list is stored and exported in martial-priority order, because re-sorting it changes what **M-C11** removes. |
| **0.30.0** | **Technical intake dispositioned.** §10.3's Standard Shield fixture corrected to `Impact +` + `Physical +` **from one pooled budget** — the row also claimed *independent* defence, contradicting **M-C4**. The M-C11 off-hand dagger form added as a fixture. §10.5's `Medium` → `Average`. **`◇P11`, `◇P12`, `◇P13` registered** for faculty profiles, the `build × faculty` relation, and actor lineage/physique grain. |
| **0.27.0** | Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | **◇P10 registered** (empty protected `ref_tags`). **◇P6 widened** to own the canonical schema-version contract, rather than minting a near-duplicate for it. M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | **`P-C10` authored** — an `AUTHORED DESIGN DECISION` is non-authoritative until disposed `authored`. **`P-H5` amended** to carry a type axis and a fifth disposition. The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | **`P-H5` authored** *(as `P-C9`; renamed in-version — the ID letter is the severity, and it is High)* — intake-record disposition, one per item, `authored` naming a document and section. **◈P7 closed**: 141 of 141 rules authored, census and command agreeing exactly. Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | **`P-C8` authored** — every indexed rule leads its line or first table cell in its home document. The ◇P7 test, made enforceable. ◇P7 restated as a total of five; **◈P7a closed**. 32 subsection headings deletterd. Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | Eleven `Part P<n>` headings become `Part <n>`. **Part 9 reordered** — it had sat after Part 10 since 0.15.0. **◇P9 registered**: Dolt as the cell-level content-versioning escalation, trigger unmeasured, carried over from the retired equipment-model reconciliation. **◇P7 measured at thirty**, up from a stated nineteen. Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **39 glyphed identifiers in this document.** |
| **0.17.0** | **Two normalized fixture relations added to P·2.3** — `fixture_enemies` and `fixture_encounter_members`, taking the sheet count to **thirty**. P·10.5–10.6 had specified frozen enemy fixtures and multi-enemy compositions with **no authoring relation to hold them**, and **P-C3** forbids the delimited `1 Commander, 2 Standard` cell that would otherwise be the obvious workaround — so the locked ◈M10 fixture set could not be represented canonically at all. The relation is decided; the **column sets are not**, and must be reconciled against E and H before locking — registered as **◇P8 [OPEN] [GAP]**. **P·10.2–10.3 corrected to the handedness budget** (M·2A.9, **M-C1**): the Controller carries a **`1h-Sword`** at `Slash ++, Pierce +` = 3 pips, the War priest a **`1h-Mace`**, and the former unqualified 4-pip Sword is a **`2h-Sword`** outside this loadout. **A dangling cross-reference removed:** P·10.3's note had said the 4-pip one-hander norm was `[OPEN]` in **M**, and *no such open item ever existed there* — a reader checking M's table would have found nothing. **P·2.1 names Grist** as the concrete Stage 2 façade and drops the `.ods` example, with authority stated: P owns the logical model, the Content Authoring Technical Specification owns the Grist realization, and P wins any disagreement. **◇P7 corrected** from seventeen to at least nineteen and restated as a floor. **◇P7a registered** — the Validation Rules Index regeneration command recovers 82 of 139 rules. |
| **0.16.0** | **P·1.3's `category` enum gains `shield`**, resolving a self-contradiction shipped at 0.15.0: P·1.2 enumerated shields as a seventh peer while P·1.3's enum omitted them, and **both were marked `[LOCKED]`**. P·7.1's category-completeness lint now states the shield component set explicitly. *The contradiction survived a release because the two statements are four lines apart and neither was checked against the other.* |
| **0.15.0** | Document created by reconciling two independent studies — a domain model and a storage-technology sweep — which overlapped only on the storage layer and **agreed there**. Locks the five-object lifecycle, five bounded domains, canonical-JSON-as-source-of-truth with DuckDB as a rebuildable artefact, fixed-point persistence, per-delta attribution, and the read-only agent query path. Damage taxonomy verified unchanged against M·2A.3. `extraction` rejected as a trace outcome value for the third time — reserved to W§12; `band_end_exit` adopted. Six open items registered, of which **◇P6** is a gap. Eleven rules added. |
