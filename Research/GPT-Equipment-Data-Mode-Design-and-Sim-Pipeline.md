# Cohesive Equipment Data Model for the Triade Design and Simulation Pipeline

## Executive design decision

The equipment system should use a **componentised, revisioned model** with five distinct lifecycle objects:

```text
Equipment definition
        ↓
Generated roll
        ↓
Owned item instance
        ↓
Equipped loadout snapshot
        ↓
Attributed combat trace
```

This separation is necessary because the documentation describes several different things that are easily conflated:

- a hand-authored chassis such as a maul, dagger, wand or shield;
- a procedurally generated item carrying item level, rarity policy, affixes and rolled values;
- a mutable in-game object carrying current integrity and ownership;
- a loadout whose hand occupancy and delivery hooks determine legal actions;
- and a trace source whose contribution must remain attributable even after the underlying content is revised.

The current design corpus is version 0.14.0. It requires content to be data rather than code, JSON Schemas for every content type, deterministic named RNG streams, a headless simulation interface, per-delta trace attribution, golden tests, a content linter and a frozen fixture set. The project instructions also require explicit source ownership, version-aware changes, provenance, and `[OPEN]`, `[SIM]` and `[GAP]` markers rather than implicit uncertainty. fileciteturn0file1 fileciteturn0file2 fileciteturn0file4

The recommended architecture is therefore:

| Layer | Recommended representation | Authority |
|---|---|---|
| Human editing | Normalised workbook generated from, and exportable to, CSV sheets | Editing façade |
| Canonical content | Deterministically ordered JSON records validated by JSON Schema | Source of truth |
| Operational catalogue | DuckDB tables and views imported from canonical JSON | Query and validation layer |
| Large traces | Append-only Parquet datasets | Analytical fact store |
| Derived analysis | DuckDB tables for signatures, deltas, validation findings and comparisons | Rebuildable outputs |
| Game runtime | Compiled or serialised content package generated from approved revisions | Deployment artefact |

The most important modelling rule is: **do not build one giant nullable `equipment` table**. The corpus defines five item layers—chassis, construction, behaviour, affixes and inscription—and different categories possess different combinations of them. Weapons, armour, shields, trinkets, consumables, currencies and tomes should share a small core identity record and attach typed components. fileciteturn0file1

Three classifications must remain separate:

| Classification | Meaning |
|---|---|
| `category` | What the object is: weapon, armour, trinket, consumable, currency or tome |
| `slot / occupancy` | Where and how it is equipped, including hands occupied |
| `delivery hook` | Through which channel an action is issued: `main_hand`, `off_hand`, `voice` or none |

Hand occupancy and hook count are explicitly different. A two-handed maul occupies two hands but presents one delivery hook; a wand occupies one hand and leaves another hand available for `[Mudra]`. Collapsing these into a single `hands` field would make `[Combo-Action]` legality impossible to model correctly. fileciteturn0file0 fileciteturn0file1

The reference fixture set should be a first-class content domain rather than test code. At minimum, it includes Striker/Maul, Controller/Sword-and-Shield, Technical/Daggers and Adept/Wand, with relative stat weights normalised when instantiated. The M10 study also identifies an inexpensive potential fifth fixture—an unarmed adept—to cover `[Mudra] + [Mudra]`, `[Psyche]` and Divine purge. fileciteturn0file0

## Human-editable tabular representation

### Authoring format

The authoring surface should be a multi-sheet workbook, but the workbook must not be the sole canonical artefact. A practical repository layout is:

```text
content/
  authoring/
    equipment-authoring.ods
    csv/
      equipment.csv
      equipment_slots.csv
      damage_profiles.csv
      ...
  canonical/
    equipment.data.json
    affixes.data.json
    faculties.data.json
    fixtures.data.json
  schema/
    equipment.schema.json
    affix.schema.json
    faculty.schema.json
    fixture.schema.json
```

The workbook provides filters, frozen columns, dropdowns, explanatory notes and cross-sheet lookups. Its deterministic CSV export is the diffable intermediate representation. A compiler then validates those tables and emits sorted canonical JSON.

Cells should contain **one scalar value only**. Tags, damage types, skills, vectors, slots and affixes should never be stored as comma-separated strings. Every repeatable value receives its own child-table row. This prevents spelling drift, makes referential validation possible and avoids opaque agent edits.

The workbook should contain three classes of sheets:

| Sheet class | Editing status | Purpose |
|---|---|---|
| Authoring sheets | Editable | Equipment, profiles, links, affixes and fixture definitions |
| Reference sheets | Protected | Enums, stat IDs, damage types, regions, hooks, slots and rule IDs |
| Generated sheets | Read-only | Flattened previews, tooltip previews, validation findings and trace summaries |

### Recommended workbook sheets

| Sheet | Row grain | Purpose |
|---|---|---|
| `equipment` | One row per equipment-definition revision | Core identity, taxonomy and lifecycle |
| `equipment_text` | One row per equipment, locale and text field | Names, descriptions, flavour and accessibility text |
| `slot_occupancy` | One row per occupied slot or hand | Equipping topology and free-hand calculation |
| `equipment_tags` | One row per equipment–tag relationship | Search, generation coherence, synergy and filtering |
| `chassis_profiles` | One row per reusable chassis | Family, handedness, weight, reach and base identity |
| `construction_profiles` | One row per construction profile | Material, rigidity, coverage, brittleness and armour family |
| `damage_profile_entries` | One row per profile and damage type | Base martial-profile pips |
| `defence_profile_entries` | One row per group/type defence entry | Group baselines and sharp exceptions |
| `integrity_profiles` | One row per integrity profile | Integrity state-machine identity |
| `integrity_states` | One row per profile and state | Stable, Cracked, Fractured, Broken Guard and their effects |
| `triade_effects` | One row per equipment-derived Triade effect | Pulls, dwell, efficiency, threshold and displacement behaviour |
| `vocabulary_links` | One row per equipment–skill relationship | Generic and region vocabulary, inherent skills and source hooks |
| `stat_modifiers` | One row per modifier | Primary, derived and technical-stat effects |
| `affixes` | One row per affix definition | Group, tier, weight, application and exclusivity |
| `affix_effects` | One row per effect within an affix | Numeric, typed, Triade or vocabulary effect |
| `inscriptions` | One row per hand-authored rule-break | Unique and narrowly scoped behaviour |
| `generation_policies` | One row per generation policy | Item-level, demand/rarity and affix-count rules |
| `loot_tables` | One row per loot table | Source, depth and smart-loot policy |
| `loot_entries` | One row per table entry | Weight, category/base type and item-level offset |
| `faculties` | One row per faculty | Innate, Arcana, Mudra and Psyche sources |
| `faculty_profiles` | One row per faculty damage or vocabulary entry | Footprint, hooks, gates and skill vocabulary |
| `fixture_builds` | One row per frozen build | Class/floor identity and fixture status |
| `fixture_stat_weights` | One row per build and stat | Relative weights, never invented absolute scales |
| `fixture_loadouts` | One row per build and equipped item | Fixture equipment and slot assignment |
| `fixture_encounters` | One row per encounter | Enemy composition, zones and environment |
| `fixture_coverage` | One row per fixture and rule/feature | What each fixture proves |
| `design_parameters` | One row per tunable number | `[SIM]` basis, gate and failure path |
| `provenance` | One row per revision or generated artefact | Human/agent/source-document provenance |

### Core equipment sheet

The `equipment` sheet should contain only scalar fields:

| Column | Type | Required | Meaning |
|---|---|---:|---|
| `equipment_id` | text ID | Yes | Stable identity across revisions |
| `equipment_revision` | positive integer | Yes | Immutable content revision |
| `schema_version` | semantic version | Yes | Schema against which the row validates |
| `content_version` | semantic version | Yes | Design-set version in which this revision exists |
| `lifecycle_status` | enum | Yes | `draft`, `candidate`, `approved`, `deprecated`, `retired` |
| `design_status` | enum | Yes | `locked`, `sim`, `open`, `gap`, `fixture` |
| `category_id` | reference | Yes | Weapon, armour, trinket, consumable, currency or tome |
| `chassis_id` | reference | Category-dependent | Reusable physical identity |
| `construction_profile_id` | reference | Category-dependent | Material and defensive construction |
| `behaviour_profile_id` | reference | Category-dependent | Triade and handling behaviour |
| `integrity_profile_id` | reference | Category-dependent | Equipment integrity state machine |
| `generation_policy_id` | reference | No | Applicable procedural-generation rules |
| `inscription_id` | reference | No | Hand-authored rule-breaking effect |
| `display_name_key` | localisation key | Yes | Localised display name |
| `short_name_key` | localisation key | No | Compact log or UI form |
| `description_key` | localisation key | Yes | Mechanical description |
| `flavour_key` | localisation key | No | Non-mechanical fiction |
| `demand_tier` | enum | Yes for equippables | `broad`, `focused`, `exacting` |
| `is_doctrinal` | Boolean | Yes | Demands a repeated behaviour loop |
| `is_transgressive` | Boolean | Yes | Deliberately breaks a normal rule |
| `is_unique` | Boolean | Yes | Hand-authored unique, never generated conventionally |
| `is_secret` | Boolean | Yes | Mission-placed storey-gate key |
| `is_relic` | Boolean | Yes | Carried progression-access object |
| `power_budget_policy_id` | reference | No | Expected item-power band |
| `readability_budget_id` | reference | No | Tooltip/visible-value budget |
| `introduced_in_version` | version | Yes | Audit history |
| `deprecated_in_version` | version | No | Audit history |
| `source_document_refs` | handled in relation | — | Must not be packed into this row |
| `content_hash` | generated text | Read-only | Canonical revision hash |

`[Secret]` and `[Relic]` need explicit fields rather than ordinary tags because the corpus makes their protection lintable against the internal attribute: generation may not create them, and salvage, reroll, sale or discard systems may not consume them. fileciteturn0file1 fileciteturn0file14

### Slot and hook representation

`slot_occupancy` should distinguish physical occupancy from action delivery:

| Column | Meaning |
|---|---|
| `equipment_revision_id` | Owning equipment definition revision |
| `slot_id` | Abstract equipment slot |
| `occupancy_role` | `primary`, `secondary`, `required`, `optional` |
| `hand_group` | `left`, `right`, `both`, `none`, or body-template-relative group |
| `occupancy_units` | Number of slot/hand units occupied |
| `delivery_hook` | `main_hand`, `off_hand`, `voice`, `none` |
| `provides_free_hand` | Derived, read-only rather than hand-authored |
| `supports_combo_source` | Whether it may fulfil a `[Combo-Action]` source |
| `sort_order` | Deterministic display and serialisation order |

For the M10 loadouts, the authoring projection would read:

| Loadout item | Hand occupancy | Delivery hooks | Base martial profile |
|---|---|---|---|
| Maul | Both hands | `main_hand` | Impact 3, Shatter 1 |
| Dagger, main | One hand | `main_hand` | Pierce 2, Slash 1 |
| Dagger, off | One hand | `off_hand` | Pierce 2, Slash 1 |
| Sword | One hand | `main_hand` | Slash 2, Impact 1, Pierce 1 |
| Shield | One hand | `off_hand` | Impact 2 plus independent defence/integrity |
| Wand | One hand | `main_hand` | Impact 1; second hand remains free |

These fixture pips are reference values for the frozen test set, not evidence that every one-handed weapon universally receives four pips. The M10 study explicitly records the baseline pip norm as unverified. fileciteturn0file0

### Human-editing controls

The workbook should enforce the following without requiring designers to understand SQL:

| Control | Behaviour |
|---|---|
| ID dropdowns | Select only registered taxonomy, skill, stat and profile IDs |
| Enum validation | Reject unregistered category, region, damage or hook values |
| Conditional formatting | Highlight missing required component rows |
| Protected calculated columns | Show pip totals, vector sums, shield budgets and tooltip counts |
| Formula previews | Show free hands, legal combo pairings and reachable vocabulary |
| Revision lock | Approved revisions cannot be edited in place; a new revision is created |
| Validation sheet | Displays Critical, High and Medium findings by rule ID |
| Flattened preview | Renders one designer-friendly row per item without becoming canonical |
| Tooltip preview | Shows current/candidate deltas and vocabulary gained/lost |
| Fixture coverage view | Shows which rules and systems have no fixture coverage |

## Canonical logical data model

### Domain separation

The canonical model should be divided into five bounded domains.

| Domain | Purpose | Mutability |
|---|---|---|
| Definition | What equipment, affixes, skills and faculties are designed to be | Immutable by revision |
| Generation | How a definition becomes a rolled item | Versioned policy |
| Runtime | Ownership, current integrity and equipped state | Mutable game state |
| Fixture | Frozen builds, loadouts, enemies and encounters | Immutable within a fixture-set version |
| Trace | What occurred and which source caused each delta | Append-only |

This division solves several otherwise difficult questions. A trace points to the exact equipment revision and rolled instance used at the time. A balance patch creates a new definition revision rather than rewriting historical traces. A designer may compare two item revisions under identical fixture seeds. A player-owned sword may be Fractured while the underlying sword definition remains unchanged.

### Definition entities

```text
EquipmentDef
 ├── EquipmentText
 ├── EquipmentTag
 ├── SlotOccupancy
 ├── ChassisProfile
 ├── ConstructionProfile
 │    ├── DefenceProfileEntry
 │    └── IntegrityProfile
 │         └── IntegrityState
 ├── BehaviourProfile
 │    ├── TriadeEffect
 │    ├── VocabularyLink
 │    ├── StatModifier
 │    └── ClumsinessCurve
 ├── DamageProfile
 │    └── DamageProfileEntry
 ├── AffixCapacity
 └── InscriptionRef
```

The five corpus layers map directly:

| Corpus layer | Logical objects |
|---|---|
| Chassis | `ChassisProfile`, `SlotOccupancy`, `DamageProfile` |
| Construction | `ConstructionProfile`, `DefenceProfile`, `IntegrityProfile` |
| Behaviour | `BehaviourProfile`, `TriadeEffect`, `VocabularyLink`, `ClumsinessCurve` |
| Affixes | `AffixDef`, `AffixTier`, `AffixEffect`, rolled `ItemAffix` |
| Inscription | `InscriptionDef`, constrained rule/effect references |

This preserves the rule that identity lives in the base object, expression in behaviour and bounded tuning in affixes. An affix can alter or extend a footprint, but it must not silently rewrite the chassis. fileciteturn0file1

### Runtime entities

```text
ItemInstance
 ├── EquipmentDefRevision
 ├── GenerationRecord
 ├── ItemAffixRoll[]
 ├── CurrentIntegrityState
 ├── CurrentWardState?
 ├── OwnershipRecord
 └── RuntimeFlags

Loadout
 └── LoadoutEntry[]
      ├── ItemInstance
      ├── EquippedSlot
      └── ActiveHook
```

A generated item is not merely an equipment definition with extra columns. It requires:

| Runtime field | Purpose |
|---|---|
| `item_instance_id` | Globally unique in-game identity |
| `equipment_revision_id` | Exact base definition revision |
| `generator_version` | Generation algorithm version |
| `generation_policy_revision_id` | Exact policy used |
| `roll_seed` | Reproduction of generated values |
| `rng_stream` | Normally the named `loot` or `affix` stream |
| `item_level` | Magnitude input |
| `demand_rarity_id` | Mechanical-demand rarity result |
| `quality_roll` | Within-tier roll input |
| `rolled_name_key` | Generated display-name reference |
| `current_integrity_state` | Mutable equipment state |
| `current_integrity_value` | Optional internal progress if state transitions need it |
| `current_ward_state` | Applicable Occult state |
| `is_secured` | Progression-loss treatment |
| `owner_actor_id` | Current owner |
| `acquisition_source_id` | Loot source, mission placement, crafting or fixture |
| `acquired_run_id` | Run provenance |
| `content_snapshot_hash` | Protection against definition drift |

### Affix entities

The affix model should implement the corpus contract directly:

```text
AffixDef
 ├── group: prefix | suffix | implicit
 ├── tags[]
 ├── applies_to[]
 ├── tiers[]
 ├── exclusivity_group
 ├── weight
 └── effects[]
```

The relational entities are:

| Entity | Important fields |
|---|---|
| `affix_def` | ID, group, name, tags, applicability, exclusivity, lifecycle |
| `affix_tier` | Tier, item-level requirement, roll weight, value curve |
| `affix_effect` | Effect kind, target, operation, range, unit, condition |
| `affix_triade_effect` | Pull, dwell, efficiency or per-region threshold effect |
| `affix_stat_effect` | Stat ID, operation, min/max roll and stacking rule |
| `item_affix_roll` | Item instance, affix revision, tier, rolled value and roll seed |

A stat-bonus affix is not merely a numerical bonus in this design. It can alter effective fields, reachable skill levels and what the character can do. Consequently, pricing fields should include simulation-delta results rather than only raw stat points. Threshold reductions must be region-specific and normally restricted to high-tier or unique content. fileciteturn0file1

### Skills, vocabulary and inherent capabilities

Equipment should reference skill records; it should not inline entire skills. The core relationship is:

```text
equipment_revision
    ──< vocabulary_link >── skill_revision
```

`vocabulary_link` needs:

| Field | Meaning |
|---|---|
| `equipment_revision_id` | Equipment carrying the vocabulary |
| `skill_revision_id` | Referenced skill |
| `region_id` | `generic`, `instinct`, `pressure`, `discipline` |
| `grant_mode` | `vocabulary`, `inherent`, `conditional`, `inscription` |
| `source_hook` | Main hand, off hand, voice or none |
| `min_integrity_state` | Optional equipment-function requirement |
| `requires_free_hand` | Derived or explicit skill requirement |
| `minimum_skill_level` | Optional access floor |
| `condition_expression_id` | Optional typed predicate |
| `sort_order` | Deterministic display order |

“Inherent skill” should mean **a linked skill granted by the item definition**, not a free-form effect embedded in a description. This lets the linter verify source resolution, hook legality, anchor reachability, UI display and trace attribution.

Faculties should use a parallel, separate model because they are non-item action sources:

| Faculty attribute | Scope |
|---|---|
| `faculty_id`, revision, display text | Identity |
| `family` | `innate`, `arcana`, `mudra`, `psyche` |
| `origin` | `innate`, `learned`, `granted` |
| `base_damage_profile_id` | Its own fourteen-type pip footprint |
| `delivery_hook` | Hand, voice or none |
| `gate_node_group_id` | Body locations whose function denial blocks it |
| `vocabulary_links` | Generic and region skills |
| `pull_vectors` | Zero-sum Triade influences |

An equipment definition may carry an `equipment_faculty_grant`, for example where a unique item grants an Arcana or Psyche faculty, but the faculty remains a first-class referenced record. The same faculty model closes the no-equipment action-source gap for innate enemy attacks and disarmed players. fileciteturn0file1 fileciteturn0file9

### Fixture entities

The fixture model should be stored alongside content and versioned independently:

```text
FixtureSet
 ├── FixtureBuild[]
 │    ├── FixtureStatWeight[]
 │    └── FixtureLoadoutEntry[]
 ├── FixtureEnemy[]
 ├── FixtureEncounter[]
 └── FixtureCoverageExpectation[]
```

Recommended fields include:

| Entity | Required attributes |
|---|---|
| `fixture_set` | ID, version, frozen date, content-version compatibility, notes |
| `fixture_build` | Build ID, class revision, home region, floor shape, intended fantasy |
| `fixture_stat_weight` | Build, stat ID, relative weight, normalisation group |
| `fixture_loadout_entry` | Build, equipment revision, slot, quantity, hand assignment |
| `fixture_enemy` | Enemy definition, role tier, chassis, equipment and faculties |
| `fixture_encounter` | Zone count, composition, environment and proof purpose |
| `fixture_coverage` | Fixture ID, rule ID, system feature, expected assertion |
| `fixture_gap` | Uncovered feature, consequence, accepted/deferred status |

Relative weights should remain dimensionless in the fixture records. The harness selects an absolute stat budget and normalises the weights when it constructs a test character. This avoids inventing the stat scale that the simulation is meant to discover. fileciteturn0file0

## Detailed attribute scope

The following catalogue distinguishes three kinds of field:

| Marker | Meaning |
|---|---|
| **Corpus** | Directly required or strongly implied by the existing documents |
| **Derived** | Necessary to implement a corpus rule consistently |
| **Proposed** | Recommended extension or operational metadata |

### Identity, text and governance

| Attribute | Status | Type | Purpose |
|---|---|---|---|
| `equipment_id` | Derived | Stable text ID | Identity independent of revision |
| `equipment_revision_id` | Derived | UUID/text | Immutable revision identity |
| `revision_number` | Derived | Integer | Ordered history |
| `schema_version` | Corpus | Version | Validation contract |
| `content_version` | Corpus | Version | Corpus compatibility |
| `lifecycle_status` | Proposed | Enum | Draft-to-retired workflow |
| `design_status` | Corpus | Enum | Locked, SIM, open, gap or fixture |
| `display_name_key` | Corpus | Localisation ref | Player-facing name |
| `short_name_key` | Proposed | Localisation ref | Logs and compact UI |
| `description_key` | Corpus | Localisation ref | Mechanical description |
| `flavour_key` | Corpus | Localisation ref | Fiction separated from mechanics |
| `accessibility_description_key` | Proposed | Localisation ref | Non-visual item identity |
| `introduced_in_version` | Derived | Version | History |
| `deprecated_in_version` | Derived | Version/null | History |
| `source_document_ref` | Corpus | Relation | Authoritative design source |
| `decision_origin` | Corpus workflow | Enum | `[W]`, `[U]`, `[BOTH]`, `[NEW]` |
| `authoring_notes` | Proposed | Text | Non-runtime designer context |
| `content_hash` | Derived | Hash | Determinism and trace linkage |
| `approval_status` | Derived | Enum | Human gate outcome |
| `approved_by` | Corpus agent workflow | Actor ref | Human authority |
| `approved_at` | Corpus agent workflow | Timestamp | Auditability |

Text should live in a localisation table with at least `locale`, `text_key`, `text_kind`, `text_value` and `revision`. `en-GB` should be the reference locale, not an unlabelled default.

### Taxonomy and equipment topology

| Attribute | Status | Type | Purpose |
|---|---|---|---|
| `category_id` | Corpus | Enum/ref | Weapon, armour, trinket, consumable, currency, tome |
| `base_type_id` | Corpus | Ref | Per-category base type |
| `chassis_id` | Corpus | Ref | Intrinsic equipment identity |
| `family_id` | Corpus | Ref | Sword, dagger, maul, shield family, and so forth |
| `slot_policy_id` | Corpus | Ref | Legal equipment slots |
| `handedness` | Corpus | Enum | One-handed, two-handed, handless |
| `occupancy_units` | Derived | Integer | Physical slot/hand use |
| `delivery_hooks` | Corpus | Relation | Action-delivery channels |
| `weight_class` | Corpus | Enum/ref | Heavy, light, cloth or category-appropriate value |
| `reach_class` | Corpus | Ref | Chassis reach identity |
| `demand_tier` | Corpus | Enum | Broad, Focused, Exacting |
| `is_doctrinal` | Corpus | Boolean | Temporal use demand |
| `is_transgressive` | Corpus | Boolean | Rule-breaking flag |
| `is_unique` | Corpus | Boolean | Hand-authored unique |
| `tag_budget` | Corpus | Integer/policy | Theme/readability constraint |
| `tags` | Corpus | Relation | Generation, synergy and semantic identity |
| `is_secret` | Corpus | Boolean | Mission gate key |
| `is_relic` | Corpus | Boolean | Carried progression key |
| `can_drop` | Derived | Boolean | Generation eligibility |
| `can_salvage` | Derived | Boolean | Economy permission |
| `can_reroll` | Derived | Boolean | Economy permission |
| `can_sell` | Derived | Boolean | Economy permission |
| `can_discard` | Derived | Boolean | Inventory permission |

The last five should normally be derived from category and protected flags. They should not be freely authored in a way that permits a Secret or Relic to become destructible through an inconsistent row.

### Chassis and construction

| Attribute | Status | Type | Purpose |
|---|---|---|---|
| `chassis_family` | Corpus | Ref | Stable physical identity |
| `base_martial_profile_id` | Corpus | Ref | Base pip footprint |
| `construction_family_id` | Corpus | Ref | Cloth, padded, leather, mail, plate, and so forth |
| `material_id` | Corpus | Ref | Construction material |
| `rigidity` | Corpus | Parameter/ref | Structural response |
| `coverage_profile_id` | Corpus | Ref | Protected body coverage |
| `brittleness` | Corpus | Parameter | Abrupt-failure tendency |
| `group_defence_profile_id` | Corpus | Ref | Five mitigation-group baselines |
| `type_exception_budget` | Derived | Integer/policy | Restricts sharp exceptions |
| `integrity_profile_id` | Corpus | Ref | State progression and effects |
| `ward_source_profile_id` | Corpus | Ref/null | Occult protection source |
| `bridge2_mechanism` | Corpus | Enum | EDM damping, home-well strengthening or none |
| `bridge2_scaling_stat_ids` | Corpus | Relation | Stats controlling magnitude |
| `encumbrance_profile_id` | Corpus | Ref | Reach and handling cost |
| `visual_mesh_family_id` | Derived | Ref | Equipment-render identity |
| `integrity_render_profile_id` | Corpus presentation | Ref | Separate equipment damage channel |

Armour and anatomical wounds must remain visually and mechanically separate: integrity belongs to equipment, while wounds and function denial belong to body locations. fileciteturn0file8 fileciteturn0file15

### Damage and martial profile

The controlled damage taxonomy is:

| Group | Types |
|---|---|
| Physical | Slash, Impact, Pierce |
| Volatile | Explosive, Fire, Lightning, Cold |
| Corruptive | Corrosive, Poison |
| Structural | Shatter, Tear |
| Occult | Chaos, Divine, Psychic |

The model requires `damage_group` and `damage_type` reference tables, with the type-to-group relationship controlled centrally. Structural types must resolve through integrity rather than ordinary typed mitigation; Occult types combine typed defence with Ward. fileciteturn0file1

Each `damage_profile_entry` should contain:

| Attribute | Status | Purpose |
|---|---|---|
| `profile_id` | Derived | Parent martial or faculty profile |
| `damage_type_id` | Corpus | One of the fourteen types |
| `base_pips` | Corpus | Chassis footprint |
| `pip_budget_group` | Derived | Conservation scope |
| `primary_status_hook_id` | Corpus | Status identity |
| `secondary_status_hook_id` | Corpus | Optional secondary behaviour |
| `requirement_eligible` | Derived | Whether pips count toward skill requirements |
| `source_layer` | Derived | Chassis, affix or inscription |
| `sort_order` | Proposed | Stable display and serialisation |

The final action footprint should not overwrite the base profile. It should be represented as an evaluated trace object:

```text
base footprint
+ qualifying affix footprint
→ requirement-check footprint
→ skill redistribution
→ final action footprint
+ external bonus damage
→ resolved outcome
```

That ordering preserves the object-boundary rule: affixes are part of the weapon and may unlock requirements; temporary external buffs alter outcome but not weapon identity or skill access. Pip redistribution is zero-sum unless an explicitly Transgressive or inscription-tier effect breaks the rule. fileciteturn0file1 fileciteturn0file14

### Defence, integrity and shield-specific attributes

`defence_profile_entry` should use:

| Attribute | Status | Meaning |
|---|---|---|
| `defence_profile_id` | Derived | Parent profile |
| `scope_kind` | Derived | `group` or `type_exception` |
| `damage_group_id` | Corpus | Baseline mitigation group |
| `damage_type_id` | Corpus | Sharp exception |
| `rating_value` | Corpus/[SIM] | Exact defence magnitude |
| `rating_unit` | Derived | Fixed unit or rating scale |
| `exception_polarity` | Derived | Strength or weakness |
| `condition_expression_id` | Proposed | Conditional defence |
| `narration_fragment_id` | Proposed | Dictionary integration |

`integrity_state` should use:

| Attribute | Meaning |
|---|---|
| `integrity_profile_id` | Parent profile |
| `state_id` | Stable, Cracked, Fractured or Broken Guard |
| `ordinal` | State order |
| `entry_condition_id` | State-transition rule |
| `opening_delta_modifier` | Deeper Opening effect |
| `opening_decay_modifier` | Slower decay where applicable |
| `discipline_creation_enabled` | Suppressed by Broken Guard |
| `finisher_gate_eligible` | Whether state can satisfy the Finisher gate |
| `render_state_id` | Equipment visual state |
| `repair_policy_id` | Encounter/run repair treatment |

A shield remains one equipment definition, not an armour row joined to a weapon row. Its shield component needs:

| Shield field | Meaning |
|---|---|
| `shield_subfamily` | Buckler, standard or tower |
| `shield_budget_id` | One pooled offence/defence budget |
| `offensive_budget_share` | Pip allocation |
| `defensive_budget_share` | Defence and integrity allocation |
| `damage_profile_id` | Shield weapon footprint |
| `defence_profile_id` | Shield protection |
| `integrity_profile_id` | Independent from body armour |
| `lean_scaling_curve_id` | Defence as a function of Form-ward lean |
| `supports_pressure_creation` | Bash/shove path |
| `supports_discipline_creation` | Brace/parry/counter path |
| `bridge2_mechanism` | Light, medium or heavy positional response |

The linter must verify that the shares draw from one budget, that the declared subfamily matches the split, that lean scaling is not flat and that both Opening-creation paths are present. fileciteturn0file1

### Triade behaviour

Each influence should be an atomic row:

| Attribute | Status | Meaning |
|---|---|---|
| `effect_id` | Derived | Stable influence ID |
| `owner_kind` | Derived | Equipment, affix, skill, faculty, condition or environment |
| `owner_revision_id` | Derived | Exact source revision |
| `effect_kind` | Derived | Pull, dwell, efficiency, threshold, recovery, displacement |
| `origin` | Corpus | ADM, CDM or EDM |
| `mode` | Corpus | Impulse or force |
| `dm_q` | Corpus | Quantised Momentum delta |
| `df_q` | Corpus | Quantised Form delta |
| `di_q` | Corpus | Quantised Mind delta |
| `vector_scale_id` | Derived | Fixed-point scale |
| `duration_kind` | Corpus | Instant, turn count or while active |
| `duration_value` | Derived | Number of turns where applicable |
| `dynamics_value_q` | Corpus | Optional carried Dot Dynamics |
| `conditional_expression_id` | Corpus | Activation predicate |
| `region_id` | Corpus | Region-specific relationship |
| `threshold_delta_q` | Corpus | Per-region threshold reduction only |
| `dwell_modifier_q` | Corpus | Position-holding change |
| `efficiency_modifier_q` | Corpus | Conversion/handling efficiency |
| `volatility_q` | Corpus | Movement variability or commitment |
| `recovery_q` | Corpus | Return/recovery behaviour |

The linter must enforce:

```text
dm_q + df_q + di_q = 0
```

It must also reject global threshold reductions, baseline-floor mutation by temporary effects and any invalid floor/cap result. These are Critical invariants in the validation suite. fileciteturn0file7 fileciteturn0file14

Using fixed-point integer columns rather than binary floating-point values is advisable for persisted simulation and trace state. The project already requires deterministic reproduction and elsewhere explicitly prohibits float-derived decisions from entering proof digests. The exact scale should be a versioned implementation constant rather than an undocumented multiplier. fileciteturn0file16

### Stats and modifiers

A stat modifier requires more than `stat_name` and `value`:

| Attribute | Meaning |
|---|---|
| `modifier_id` | Stable effect identity |
| `owner_revision_id` | Equipment, affix or inscription source |
| `stat_id` | Controlled stat reference |
| `stat_bucket` | Primary, derived, resource, meta or technical |
| `operation` | Flat add, additive-percent, multiplicative, set, min or max |
| `value_min_q`, `value_max_q` | Fixed or rolled range |
| `value_curve_id` | Item-level/quality scaling |
| `stacking_rule_id` | Additive, highest-only, unique and so forth |
| `stacking_group_id` | Near-duplicate prevention |
| `rounding_rule_id` | Global aggregation convention |
| `condition_expression_id` | Situational activation |
| `permanence_tier` | Baseline, worn/effective, consumable or run-scoped |
| `display_format_id` | UI rendering |
| `consumed_by_refs` | Honesty/audit mapping |
| `produced_by_refs` | Source mapping |

The current stat groups are Momentum—Strength, Finesse, Stamina; Mind—Intellect, Will, Spirit; and Form—Frame, Poise, Constitution. Equipment stat modifiers operate through effective fields and must not mutate baseline floors. fileciteturn0file7

### Rarity and generation

Rarity must not be represented as a conventional magnitude multiplier. In the corpus, rarity expresses **mechanical demand**:

| Demand tier | Meaning |
|---|---|
| Broad | Works from home or shallow lean |
| Focused | Rewards a corner or light pairing |
| Exacting | Requires a region or tight window |

Item level controls roll magnitude, while `is_unique` owns rule-breaking behaviour. Affix count can still be governed by the rolled demand/rarity policy, but the model should not assume that “rare” means an unconditional larger stat total. fileciteturn0file1

Generation entities require:

| Field group | Attributes |
|---|---|
| Base selection | Source loot table, base type, category weight |
| Item level | Base level, depth offset, variance policy, saturation cap |
| Demand/rarity | Demand class, depth curve, pity adjustment |
| Affix count | Minimum, maximum and distribution by policy |
| Affix selection | Weight, tag coherence, applies-to filter, exclusivity |
| Value roll | Tier range, item-level curve, quality roll |
| Postconditions | Clamp, dedupe, tag budget, power budget |
| Naming | Dominant tags, base type and flavour policy |
| Reproduction | Seed, RNG stream, generator version, policy revision |
| Validation | Schema, readability, power and protected-flag checks |

Shape-aware drop pools, per-slot pity counters and a smart-loot bias are policy tables rather than hard-coded generation branches. fileciteturn0file1

### Tuning and uncertainty

Every provisional numeric parameter should have a dedicated record:

| Attribute | Purpose |
|---|---|
| `parameter_id` | Stable SIM-number identity |
| `owner_revision_id` | Equipment, profile, affix or global policy |
| `field_path` | Exact field being tuned |
| `current_value` | Placeholder value |
| `unit` | Pips, turns, ratio, fixed-point scale and so forth |
| `basis` | `derived`, `precedent` or `arbitrary` |
| `validation_gate_id` | Metric that accepts or rejects it |
| `failure_path` | What changes when the gate fails |
| `status` | SIM, locked, rejected or superseded |
| `source_ref` | Home-document reference |
| `set_by_sweep_id` | Simulation result that established the value |
| `locked_in_version` | Version where it became authoritative |

This prevents `[SIM]` numbers from becoming hidden constants and follows the project’s explicit requirement that provisional values state their basis, gate and failure path. fileciteturn0file4 fileciteturn0file12

## Database and storage architecture

### Recommended database

**DuckDB should be the primary embedded analytical database for the equipment-design pipeline.**

The choice follows directly from the workload:

- embedded execution inside Python, Rust, Node.js or other pipeline processes;
- scan-heavy comparison of equipment definitions and large action traces;
- SQL joins between content, fixtures, validation results and telemetry;
- direct querying of JSON and Parquet;
- efficient DataFrame and Arrow interchange;
- reproducible single-file local databases;
- no mandatory database server.

DuckDB is explicitly designed as an in-process analytical SQL database and is distributed under the MIT licence. It can use persistent single-file or in-memory databases, provides clients for the major implementation languages, and integrates with Pandas, Polars, Arrow and NumPy. citeturn0search12turn0search15turn1search0turn1search4

DuckDB can query JSON and Parquet directly. Its Parquet reader supports projection and filter pushdown, allowing trace queries to read only necessary columns and row groups; it can also export query results or whole databases to Parquet. citeturn0search0turn0search2turn0search5turn0search11

DuckDB also supports typed nested values such as `LIST`, `MAP`, `STRUCT` and `UNION`. These are useful for analytical views and exported snapshots, although the authoritative authoring tables should remain normalised because one-row-per-relation is easier to edit, diff and validate. citeturn1search2turn1search5turn1search6

### Database comparison

| Criterion | DuckDB | SQLite | Server database |
|---|---|---|---|
| In-process | Yes | Yes | Normally no |
| Analytical scans | Primary design target | Possible, not its defining target | Depends on product/configuration |
| Parquet querying | Native/direct | External application work | Usually connector/extension work |
| JSON ingestion | Native extension and JSON type | JSON functions available in modern builds | Product-dependent |
| Python/Arrow/Polars interchange | Direct | Application conversion | Driver-dependent |
| Operational overhead | Very low | Very low | Higher |
| Multi-process writes | Constrained | Better suited to small transactional workloads | Natural escalation path |
| Recommended Triade role | Primary catalogue and analytics | Lightweight runtime metadata alternative | Collaborative service if later needed |

SQLite is also serverless and zero-configuration, which makes it a credible small-footprint alternative for runtime metadata. DuckDB is nevertheless the better initial match because this pipeline is dominated by analytical comparisons, simulation traces and columnar datasets rather than high-frequency row transactions. That conclusion is an architectural inference from the two systems’ stated design goals. citeturn0search14turn0search16

### Concurrency boundary

Native DuckDB should be treated as a **single-writer-process database**. Multiple threads in one process can work concurrently, but stable multi-process writing to the same native database file requires an application-level writer boundary or a different deployment model. citeturn1search1turn1search3

For the Triade pipeline, this is acceptable:

```text
Human/agent branches
       ↓
Canonical JSON commits
       ↓
One validation/import worker
       ↓
triade.duckdb + trace Parquet
```

Git remains the collaboration and conflict-resolution layer. DuckDB is a rebuildable local/CI artefact, not the primary multi-user authoring server.

If the project later needs several live services writing simultaneously, keep the schemas and migrate the operational catalogue to PostgreSQL or another server database while retaining DuckDB for local analytics and trace querying. MySQL is not needed for the initial in-process pipeline.

### Recommended physical layout

```text
warehouse/
  triade.duckdb

lake/
  traces/
    origin=simulation/
      game_build=0.14.0-dev/
        fixture_set=m10-v1/
          run_date=2026-08-07/
            part-*.parquet
    origin=in_game/
      game_build=.../
        run_date=.../
          part-*.parquet
  signatures/
    algorithm=v1/
      part-*.parquet
```

The database should contain smaller, frequently joined tables:

```text
ref.*          controlled vocabularies
content.*      approved definitions and revisions
generation.*   generation and loot policies
runtime.*      optional local test instances
fixture.*      frozen fixture definitions
trace.*        trace metadata and indexes
analytics.*    signatures, comparisons and aggregate metrics
audit.*        provenance, validation and migration history
```

Raw action and delta events should live in partitioned Parquet. DuckDB views can expose them as SQL tables:

```sql
CREATE VIEW trace.action_event AS
SELECT *
FROM read_parquet(
  'lake/traces/origin=*/game_build=*/fixture_set=*/run_date=*/*.parquet',
  hive_partitioning = true,
  union_by_name = true
);
```

### Representative DuckDB schema

```sql
CREATE SCHEMA IF NOT EXISTS content;
CREATE SCHEMA IF NOT EXISTS fixture;
CREATE SCHEMA IF NOT EXISTS trace;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE content.equipment_def_revision (
    equipment_revision_id VARCHAR PRIMARY KEY,
    equipment_id          VARCHAR NOT NULL,
    revision_number       INTEGER NOT NULL CHECK (revision_number > 0),
    schema_version        VARCHAR NOT NULL,
    content_version       VARCHAR NOT NULL,
    lifecycle_status      VARCHAR NOT NULL,
    design_status         VARCHAR NOT NULL,
    category_id           VARCHAR NOT NULL,
    chassis_id            VARCHAR,
    construction_profile_id VARCHAR,
    behaviour_profile_id  VARCHAR,
    integrity_profile_id  VARCHAR,
    demand_tier           VARCHAR,
    is_doctrinal          BOOLEAN NOT NULL DEFAULT FALSE,
    is_transgressive      BOOLEAN NOT NULL DEFAULT FALSE,
    is_unique             BOOLEAN NOT NULL DEFAULT FALSE,
    is_secret             BOOLEAN NOT NULL DEFAULT FALSE,
    is_relic              BOOLEAN NOT NULL DEFAULT FALSE,
    display_name_key      VARCHAR NOT NULL,
    description_key       VARCHAR NOT NULL,
    content_hash          VARCHAR NOT NULL,
    UNIQUE (equipment_id, revision_number)
);

CREATE TABLE content.damage_profile_entry (
    equipment_revision_id VARCHAR NOT NULL,
    damage_type_id        VARCHAR NOT NULL,
    base_pips             INTEGER NOT NULL CHECK (base_pips >= 0),
    source_layer          VARCHAR NOT NULL,
    primary_status_hook_id VARCHAR,
    sort_order            INTEGER NOT NULL,
    PRIMARY KEY (
        equipment_revision_id,
        damage_type_id,
        source_layer
    )
);

CREATE TABLE content.triade_effect (
    effect_id             VARCHAR PRIMARY KEY,
    owner_revision_id     VARCHAR NOT NULL,
    effect_kind           VARCHAR NOT NULL,
    origin                VARCHAR,
    mode                  VARCHAR,
    dm_q                  INTEGER,
    df_q                  INTEGER,
    di_q                  INTEGER,
    vector_scale_id       VARCHAR,
    region_id             VARCHAR,
    duration_kind         VARCHAR,
    duration_value        INTEGER,
    condition_expression_id VARCHAR,
    CHECK (
        dm_q IS NULL
        OR dm_q + df_q + di_q = 0
    )
);

CREATE TABLE trace.run (
    trace_run_id           VARCHAR PRIMARY KEY,
    trace_origin           VARCHAR NOT NULL,
    game_build             VARCHAR NOT NULL,
    content_snapshot_hash  VARCHAR NOT NULL,
    schema_version         VARCHAR NOT NULL,
    fixture_set_id         VARCHAR,
    root_seed              VARCHAR,
    started_at             TIMESTAMP NOT NULL,
    completed_at           TIMESTAMP,
    outcome                VARCHAR,
    raw_trace_path         VARCHAR NOT NULL
);

CREATE TABLE analytics.trace_signature (
    signature_id           VARCHAR PRIMARY KEY,
    trace_source_kind      VARCHAR NOT NULL,
    trace_source_revision_id VARCHAR NOT NULL,
    fixture_set_id         VARCHAR NOT NULL,
    algorithm_version      VARCHAR NOT NULL,
    sample_count           BIGINT NOT NULL,
    signature_payload      JSON NOT NULL,
    created_at             TIMESTAMP NOT NULL
);
```

Database checks should enforce local arithmetic invariants, but the content linter remains authoritative for cross-row and cross-domain rules such as pip budgets, skill-anchor reachability, shield dominance, mission-key protection and fixture coverage.

## Trace and telemetry integration

### Trace design principle

The core documentation requires the simulation to record, for every action, the Triade position, all three credit counters, region membership, the action taken and the source of every state delta. Opening provenance must distinguish player-created, environmental and enemy/self-inflicted Openings. Traces are then aggregated across the fixture set into fixed-length signatures, while affixes and other modifiers receive **delta signatures** computed from paired traces with and without the modifier. fileciteturn0file7

This means trace storage cannot be a single JSON blob per combat. It needs an event-and-delta model.

### Trace hierarchy

```text
TraceRun
 ├── TraceActor
 ├── TraceEncounter
 ├── LoadoutSnapshot
 │    └── EquipmentSnapshot[]
 ├── ActionEvent[]
 │    ├── SourceUsage[]
 │    ├── StateSnapshotBefore
 │    ├── StateDelta[]
 │    ├── OpeningEvent[]
 │    ├── DamageResolution[]
 │    └── StateSnapshotAfter
 └── RunOutcome
```

### Run and provenance attributes

| Attribute | Purpose |
|---|---|
| `trace_run_id` | Stable trace-run identity |
| `trace_origin` | `unit_test`, `golden_test`, `simulation`, `playtest`, `in_game`, `replay` |
| `game_build` | Executable/build identity |
| `content_snapshot_hash` | Exact approved content package |
| `schema_version` | Trace schema |
| `fixture_set_id` | Frozen fixture context, if applicable |
| `root_seed` | Top-level deterministic seed |
| `rng_stream_manifest` | Named streams and initial states |
| `generator_version` | Applicable world/loot generator |
| `platform_id` | Reproduction/audit field |
| `difficulty_policy_id` | Encounter-budget context |
| `started_at`, `completed_at` | Operational metadata |
| `outcome` | Victory, death, extraction/portal exit, abandonment, timeout |
| `player_consent_class` | In-game telemetry governance |
| `privacy_class` | Data-retention and export policy |

### Equipment snapshot

A trace must capture the complete effective loadout without depending on mutable current tables:

| Attribute | Purpose |
|---|---|
| `equipment_snapshot_id` | Immutable trace-local identity |
| `item_instance_id` | Runtime item, where applicable |
| `equipment_revision_id` | Base content revision |
| `item_level` | Rolled progression state |
| `demand_rarity_id` | Mechanical-demand rarity |
| `quality_roll` | Rolled quality |
| `rolled_affixes` | Exact affix revision/value pairs |
| `integrity_state_before` | Equipment state entering the event/encounter |
| `ward_state_before` | Applicable Occult state |
| `equipped_slot` | Loadout topology |
| `delivery_hook` | Source legality |
| `content_payload_hash` | Detects stale or altered snapshots |

For efficient analysis, rolled affixes should be child rows in the relational catalogue and a compact nested list in Parquet trace snapshots.

### Action event

| Attribute | Purpose |
|---|---|
| `event_id` | Unique event identity |
| `trace_run_id` | Parent run |
| `encounter_id` | Encounter context |
| `round_no` | Combat round |
| `activation_no` | Activation sequence |
| `action_sequence_no` | Stable order |
| `actor_id`, `target_id` | Participants |
| `action_revision_id` | Exact action/skill definition |
| `action_outcome` | Miss, glance, success, critical and so forth |
| `source_count` | One or exactly two for a Combo-Action |
| `source_hook_1`, `source_hook_2` | Delivery channels |
| `equipment_snapshot_id_1/2` | Equipment contributors |
| `faculty_revision_id_1/2` | Non-item contributors |
| `zone_id`, `elevation_band` | Physical combat context |
| `position_m_q/f_q/i_q_before` | Triade position snapshot before resolution |
| `position_m_q/f_q/i_q_after` | Position after resolution/integration |
| `home_position_*` | Exposure and commitment reference |
| `floor_*` | Reachable-envelope context |
| `region_before`, `region_after` | Derived membership |
| `l1/l2/l3_before` | Internal credit counters |
| `l1/l2/l3_after` | Post-event counters |
| `ap_before`, `ap_cost`, `ap_after` | Action economy |
| `base_footprint_id` | Equipment/faculty base pips |
| `requirement_footprint` | Base plus qualifying affixes |
| `final_footprint` | Post-redistribution profile |
| `conversion_penalty_q` | Weapon–skill fit |
| `rng_draw_refs` | Reproduction of stochastic outcomes |
| `parent_event_id` | Compound command or reaction tree |
| `causal_chain_id` | End-to-end causal analysis |

The “position before” snapshot is particularly important because combat validation requires the action’s success to scale from the pre-resolution Triade state. fileciteturn0file6 fileciteturn0file14

### Per-delta attribution

Every state change should be one row:

| Attribute | Meaning |
|---|---|
| `delta_id` | Unique delta |
| `event_id` | Producing action event |
| `target_actor_id` | Affected actor |
| `state_domain` | Triade, credit, HP, integrity, ward, wound, status, AP, skill access |
| `state_key` | Exact value changed |
| `value_before_q` | Before value |
| `delta_value_q` | Signed delta |
| `value_after_q` | After value |
| `unit_id` | Fixed-point, pips, HP, turns, state ordinal |
| `source_kind` | Equipment, affix, skill, faculty, condition, environment, enemy, class |
| `source_revision_id` | Exact contributing content |
| `source_item_instance_id` | Applicable rolled item |
| `contribution_role` | Direct, multiplier, gate, conversion, mitigation, trigger |
| `rule_id` | Governing validation/design rule |
| `parent_delta_id` | Derived or cascading delta |
| `opening_provenance` | Player, environment, enemy or self-inflicted |
| `is_counterfactual` | Used for paired/delta-signature runs |

This structure supports queries such as:

```sql
SELECT
    source_revision_id,
    state_domain,
    state_key,
    sum(delta_value_q) AS total_contribution
FROM trace.state_delta
WHERE trace_run_id = ?
GROUP BY ALL;
```

It also allows the harness to answer whether an item was strong because of raw damage, additional vocabulary, displacement, Opening creation, credit conversion, mitigation or synergy.

### Power attribution

The equipment trace model should also store the log-decomposed power contributions required by the run contract:

```text
ln P_effective
  = ln P_gear
  + ln P_synergy
  + ln P_vocabulary
  + ln P_execution
```

A `power_attribution` fact table should contain one row per run, actor, segment and contribution class:

| Field | Meaning |
|---|---|
| `trace_run_id` | Run |
| `actor_id` | Build or enemy |
| `segment_id` | Encounter, storey, band or full run |
| `contribution_class` | Gear, synergy, vocabulary, execution |
| `log_power_contribution` | Additive log-space contribution |
| `source_revision_id` | Equipment/affix/skill where attributable |
| `method_version` | Attribution algorithm version |
| `confidence` | Optional estimator quality |
| `is_outlier` | Review trigger |

This is how the system distinguishes an overpowered base item from an unexpectedly strong two-item interaction or unusually broad skill vocabulary. fileciteturn0file3 fileciteturn0file1

### Trace signatures

The analytical model should preserve all signature features named in the core design:

| Signature family | Stored feature |
|---|---|
| Residency histogram | Fraction of actions in each discretised simplex cell |
| Credit profile | Mean, variance, autocorrelation, threshold times and conversion rates per layer |
| Displacement | Mean and distribution of per-action dot movement |
| Excursion depth | Furthest lean toward each corner |
| Region residency | Fraction in Instinct, Pressure and Discipline; time to first entry |
| Transition matrix | Cell-to-cell movement frequencies |
| Credit economy | Generation, spend timing and overflow by layer |
| Loop economy | Openings created, read and exploited; Loop/Flow/Endure split |
| Provenance mix | Player-created, environmental and enemy/self-created Openings |
| Equipment contribution | Per-item and per-affix attributed deltas |
| Power decomposition | Gear, synergy, vocabulary and execution |

The storage model should use:

```text
trace_signature
signature_feature
signature_histogram_bin
signature_transition
signature_comparison
delta_signature
```

`signature_comparison` should record algorithm version, distance metric, fixture set and paired-control context. Earth Mover’s Distance is the specified comparison for residency histograms because it respects spatial proximity between neighbouring and opposite cells. fileciteturn0file7

Actors—equipment, skills, faculties, enemies and builds—receive direct signatures. Modifiers—affixes, passives, set bonuses and tomes—receive delta signatures from paired runs. Every signature should therefore be keyed by:

```text
source kind
source revision
fixture-set version
simulation build
signature algorithm version
paired-control revision
sample count
```

Without those keys, a balance-patch comparison could silently mix different fixtures or aggregation algorithms.

### In-game telemetry linkage

Test and in-game traces should use the same event schema, with different capture levels:

| Capture level | Typical origin | Stored detail |
|---|---|---|
| Full deterministic | Unit/golden tests | Every event, input, RNG draw and delta |
| Full analytical | Simulation sweep | Every event and delta; compressed RNG provenance |
| Diagnostic | Playtest | Full data around flagged encounters |
| Sampled telemetry | Production game | Selected action/delta fields plus aggregates |
| Aggregate only | Privacy-constrained production | Signatures and counters, no detailed event stream |

The common schema makes it possible to compare “designed behaviour in fixtures” with “observed behaviour in play” using the same signature algorithm. A weapon whose simulation signature is distinct but whose in-game signature collapses into a generic cluster is likely difficult to use, poorly communicated or dominated by player behaviour.

## Validation and implementation scope

### Required validation layers

The pipeline should run validation in this order:

```text
Tabular structure
    ↓
JSON Schema
    ↓
Referential linter
    ↓
Arithmetic and invariant linter
    ↓
Generation sweep
    ↓
Fixture simulation
    ↓
Trace/signature analysis
    ↓
Human design gate
```

The database should store every finding in a common `validation_result` table:

| Attribute | Meaning |
|---|---|
| `validation_run_id` | Execution identity |
| `subject_kind` | Equipment, affix, fixture, loadout, trace or database migration |
| `subject_revision_id` | Exact record |
| `rule_id` | Stable validation-rule ID |
| `severity` | Critical, High or Medium |
| `result` | Pass, fail, warning, override |
| `message` | Human-readable explanation |
| `field_path` | Exact offending field |
| `evidence_payload` | Machine-readable supporting values |
| `override_reason` | Required for High overrides |
| `validator_version` | Reproduction |
| `created_at` | Audit time |

The current rule suite already defines Critical materiel requirements such as pip conservation, Structural resolution through integrity, non-pooling of two-vector loadouts, one shield budget, protected mission items and exactly two Combo-Action hooks. It also contains global Triade rules for zero-sum vectors, floor budgets, temporary-effect restrictions and source resolution. fileciteturn0file14

### Core equipment lints

| Rule | Expected behaviour |
|---|---|
| Unique identity | No duplicate stable ID or revision |
| Source resolution | Every equipment, skill, faculty, affix and profile reference exists |
| Category components | Required component set exists for the category |
| Scalar authoring | No array encoded as delimited text |
| Pip conservation | Skill redistribution preserves total pips unless explicitly Transgressive |
| Footprint boundary | External buffs do not satisfy weapon requirements |
| Damage taxonomy | Every type maps to exactly one controlled group |
| Structural path | Shatter and Tear use integrity |
| Vector sum | Every Triade vector sums to zero |
| Threshold legality | Only per-region threshold reductions |
| Temporary-effects rule | Worn or temporary effects do not mutate baseline floors |
| Hook legality | Combo-Actions declare exactly two valid delivery hooks |
| Occupancy legality | Free-hand requirements match actual hand occupancy |
| Shield budget | Offence and defence use one pooled budget |
| Shield identity | Both Pressure and Discipline Opening paths exist |
| Integrity separation | Shield and body-armour integrity remain independent |
| Protected flags | Secret/Relic cannot be generated or consumed by economy systems |
| Affix exclusivity | No conflicting or duplicate near-equivalent affixes |
| Tag budget | Item remains within its readability/theme limit |
| Power band | Generated item sits within its policy band |
| Readability | Tooltip surface remains within the prototype-defined budget |
| Fixture coverage | Every locked subsystem identifies a proving fixture or an explicit gap |

### Fixture validation

The M10 fixtures should become executable records with expected assertions rather than merely sample equipment:

| Fixture | Principal equipment assertions |
|---|---|
| Striker with maul | Two-hand occupancy, one hook, Impact/Shatter profile, Structural integrity path |
| Controller with sword and shield | Separate weapon/shield profiles, two-source loadout, shield budget and independent integrity |
| Technical with daggers | Two independent footprints, main/off hooks, redistribution efficiency and limb-specific function loss |
| Adept with wand | One occupied hand, free-hand Mudra legality, Arcana voice hook, faculty-owned damage footprint |
| Optional unarmed adept | Two free-hand Mudras, Psyche gate and Divine purge coverage |

The fixture set should also preserve negative cases: `[Arcana] + [Arcana]` is impossible because there is one voice hook; three-source combinations are illegal; a two-hander cannot perform `[Mudra]`; and ordinary two-vector loadouts do not pool damage footprints. fileciteturn0file0

### Agent pipeline

A complete equipment-design pass should be:

```text
Brief
  ↓
Reserve IDs and schema version
  ↓
Generate or manually edit tabular candidate
  ↓
Compile to canonical JSON
  ↓
Run schema and invariant lints
  ↓
Import candidate revision into DuckDB staging schema
  ↓
Generate item populations
  ↓
Run paired fixture simulations
  ↓
Write raw traces to Parquet
  ↓
Compute direct and delta signatures in DuckDB
  ↓
Run redundancy, dominance and identity-drift checks
  ↓
Human approval
  ↓
Promote immutable revision
```

Every artefact should record agent ID, charter version, model, prompt hash, input schema hash, seed, validation results and human verdict, as required by the existing agentic-development plan. fileciteturn0file1

### Implementation sequence

| Stage | Deliverable | Exit condition |
|---|---|---|
| Schema foundation | Reference enums, JSON Schemas, ID registry | All sample records schema-valid |
| Authoring foundation | CSV package and generated workbook | Round-trip produces byte-stable canonical JSON |
| Definition catalogue | Equipment, profiles, affixes, faculties and skills | Referential linter green |
| Fixture catalogue | M10 builds, loadouts, enemies and encounters | Coverage gaps explicitly represented |
| DuckDB warehouse | Content schemas, import compiler and views | Rebuildable from canonical files |
| Runtime model | Generated roll, instance and loadout snapshot | Seeded generation reproducible |
| Trace core | Run, action, snapshot and per-delta schemas | Full attribution on one golden encounter |
| Parquet trace lake | Partitioned raw event output | DuckDB can query without loading all data |
| Signature pipeline | Actor and modifier delta signatures | Paired fixture comparison reproducible |
| Human gates | Preview, validation and comparison reports | Candidate item can be evaluated without raw SQL |
| Production telemetry | Capture tiers and retention policy | In-game signatures comparable with fixtures |

The first implementation should deliberately remain small: the four M10 loadouts, the fourteen damage types, a minimal armour-family set, one affix of each major effect class, the four faculties and the four M10 encounters. The purpose of the first vertical slice is not content volume. It is to prove that a manually edited equipment row can travel through canonical JSON, database import, deterministic generation, a fixture simulation, per-delta attribution and a reproducible trace signature without losing its identity.