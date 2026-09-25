# Triade — Tile Pipeline Design

**Version:** 0.43.0
**Date:** 25 September 2026
**Status:** Created at 0.12.0. Architecture settled; numbers pending simulation. Art production standards pending the ◇V6 posture test.

**Document set:** this is one of **ten**.

| Ref | Document | Filename |
| --- | --- | --- |
| **T** | Core Mechanic | `T-Core_Mechanic_design_TRIADE-0_43_0.md` |
| **M** | Stats, Items, Equipment | `M-Stats_Items_Equipment_design_TRIADE-0_43_0.md` |
| **L** | Lexicon | `L-Lexicon_design_TRIADE-0_43_0.md` |
| **V** | Visual Design | `V-Visual_design_TRIADE-0_43_0.md` |
| **K** | Combat Design | `K-Combat_design_TRIADE-0_43_0.md` |
| **W** | World, Maps & Dungeons | `W-World_Generation_design_TRIADE-0_43_0.md` |
| **H** | Damage & Health | `H-Damage_Health_design_TRIADE-0_43_0.md` |
| **E** | Enemies & Bestiary | `E-Enemies_design_TRIADE-0_43_0.md` |
| **G** | **Tile Pipeline** — *this document* | `G-Tile_Pipeline_design_TRIADE-0_43_0.md` |
| — | *Open Items Index* | `B-Open_Items_Index_TRIADE-0_43_0.md` |
| — | *SIM Numbers Register* | `Y-SIM_Numbers_Register_TRIADE-0_43_0.md` |
| — | *Validation Rules Index* | `R-Validation_Rules_Index_TRIADE-0_43_0.md` |

**Scope.** **G** owns the tile as a *content package*: ontology, concept brief, graphical production, socket and adjacency encoding, the archetype record, batch bake, linting, and the agentic and human authoring pipeline around all of it.

It does **not** own dungeon generation, storey structure, progression placement or zone extraction (**W**), the camera, render stack or render proofs (**V**), the 16-byte logical cell (**W**·9, locked and untouched here), or combat semantics of the objects a tile hosts (**K**, **M**).

---

## Part 0 — Why this is a separate document

Three reasons, in order of weight.

| Reason | Detail |
| --- | --- |
| **It is a production pipeline, not world design** | W owns world grammar and topology. Concept → projection lock → bake → adjacency audit → publish is a content-manufacturing process with human roles, review gates and tooling. Different subject, different reader |
| **It grows fastest** | Tile families accumulate per Territory package. W is already 1,255 lines |
| **It is cross-cutting** | It touches K's zones, E's encounter affordances, H's `[Body Location]` naming taboo, V's projection lock and M's affordance objects. A subsystem consumed by five documents is a document |

**The founding constraint, retained from W:** the tile substrate is *"the fine authoring/visual/nav grid that bakes into zone properties; **never seen by the simulation core**"* (W·9, W·12). Nothing in this document may give the simulation core a tile.

---

## Part 1 — The two-record split

The single most important structural decision, and it dissolves an apparent conflict rather than resolving one.

| | **Tile archetype record** | **Logical cell** |
| --- | --- | --- |
| Granularity | One per tile **type** | One per **cell** |
| Contents | Art, projection, pivot, Y-sort origin, z group, cutaway group, occlusion polygon, collision and nav shapes, socket vocabulary, symmetry class, state variants, `material_bindings`, provenance | `terrain`, `material`, `elevation`, `nav_cost`, `cover`, `los_block`, `surface_index`, `prop_ref`, `flags`, `zone_id` |
| Budget | Unbounded — authoring-side, never resident in simulation | **16 bytes, locked at W·9** |
| Lives in | The Territory content package | Chunked flat arrays |

**W·9's cell layout requires no change and must not receive one.** The cell's `terrain` enum indexes archetypes; **`material` resolves through the published `MaterialProfile` registry** (TD-CR-04), not through this document. The archetype is where rich authored data lives.

**The chunk arithmetic did change** [CORRECTED 0.33.0, TD-CR-08]. 64 KB is one **fully occupied Deck slice**; a chunk holds every occupied slice intersecting its XY footprint, so its cost is the **sum of resident cells across those slices**, plus overlays and indices. The unqualified 1 MB large-location figure carried the same error and is withdrawn — see W·9. Exact budgets are `[SIM]`.

**Consequence for verticality:** a `[Deck]` index is `tz`, a coordinate, not a stored field. `elevation` (`i8`) carries the band. `flags` retains eight named bits, and **neither `open_to_below` nor `facade_required` joins them** [ADOPTED 0.33.0, TD-CR-06]. Neither is a cell property: `open_to_below` is a **relationship between vertically aligned positions**, and `facade_required` is **directional and placement-dependent**. A cell-wide boolean cannot carry either without lying about one of them. `◈G1` closed as superseded.

---

## Part 2 — Tile ontology

A tile is a content package, not an image. Obligations attach to the **roles and capabilities present**, not to one exclusive class:

*The column below read `Category` until 0.16.0. `category` is the locked item classification (M·2.1, P·1.3); E·F.1's identical header became `Enemy Tag` in the same pass. Whether a **tile class** needed a stronger word than "class" was `◈G8`, **closed 0.31.0**: it does not, and L carries the entry.*

**There is no exclusive `tile_class`** [ADOPTED 0.33.0, TD-CR-03]. The nine classes mixed five unrelated questions into one enum — structural contribution, render behaviour, placement reservation, composition scale and lifecycle capability — which made a legitimately multi-role archetype unrepresentable. A wall that is also a facade and also carries the deck lip had to pick one.

**An archetype declares a set of `structural_roles`**, deterministically ordered, and the set is what triggers obligations:

| Role | Obligation it triggers |
| --- | --- |
| `deck` | Navigation geometry, walkability, cover grade, and the **`material_bindings`** through which eligible faces reference their environmental capacities |
| `boundary` | Edge continuity and LOS behaviour |
| `facade` | Valid rendering below exposed elevation edges, and the applicable **V-C1** proof |
| `support` | Satisfaction of declared downward-support requirements |
| `connector` | Complete endpoints and decks, portal metadata; existing non-derived-rotation restrictions stand |

**The roles are not mutually exclusive.** `["boundary", "deck", "facade"]` is a legal, ordinary archetype. The array is semantically a **set**: canonical serialisation sorts and deduplicates it, so two authorings of the same roles produce one byte sequence and the bake hash stays stable.

**The other five classes were never structural roles, and become their own dimensions:**

| Former class | Canonical representation |
| --- | --- |
| `Surface` | `deck` in `structural_roles`; the human-readable archetype is a **Deck tile** (TD-CR-01) |
| `Boundary` · `Facade` · `Support` · `Connector` | the matching `structural_roles` member |
| `Occluder` | explicit render-occlusion and cutaway metadata — a rendering fact, not a structural one |
| `Socket` | `reserved_affordance_slots`. **An archetype is never classified as a Socket** |
| `Composite macro` | a separate `TileMacro` record type |
| `Stateful` | **derived** from a non-empty `state_variants` — no `stateful` class, no redundant boolean |

*Reason inline.* Each field now answers exactly one question. Obligations attach to the roles, capabilities and record type actually present, so the future JSON Schema enforces them **conditionally from those triggers** rather than through one enum that has to mean five things at once.

**Class 1 was named `Surface` until 0.33.0, and that was a reserved-word violation** [CORRECTED 0.33.0]. `surface` is locked to **environmental state channels and named reactions** (W·11) and is *never* traversable geometry — yet the row named walkable floor `Surface` while its own obligation column used the word correctly, in "surface capacities". One row, two senses. This is the same shadowing the corpus already rejected as `[Walk Surface]` at 0.12.0, reintroduced through a different door.

**Four terms, kept apart deliberately:**

| Term | Is |
| --- | --- |
| **`[Deck]`** | The aggregate traversable sheet in a combat room |
| **Deck tile** | The human-readable name of a `TileArchetype` contributing geometry to a `[Deck]` |
| **`deck`** | The machine-readable member of `structural_roles` |
| **`surface`** | Environmental channels, capacities, responses and states on tile or object **faces**. Never geometry |

**Alternatives rejected, with reasons, so they are not re-proposed:** *Deck face* wrongly implies a geometric face, and faces are precisely where environmental surfaces live. *Walkable* is an affordance or state, not an archetype or a structural identity. *Floor* is already prohibited and semantically occupied. Renaming the **environmental** sense instead was rejected as unnecessary blast radius — W and L already use it consistently. Qualifying both and dropping the bare word weakens the reserved-word lock without resolving the ontology.

> **Settled by TD-CR-03, adopted 0.33.0.** There should be **no exclusive `tile_class: deck_tile`**. The canonical representation is a `TileArchetype` carrying `deck` in `structural_roles`, and existing class-1 references migrate to that role. Recorded here when TD-CR-03 was still pending; **adopted at 0.33.0**, and the migration obligation stands.

**`◈G8` stays closed and did not settle this.** It established *tile class* as the general term; it never touched the invalid class **member**. The two were separate questions that happened to share a table.

### Footprint, `cell_stamp` and the archetype/macro boundary [ADOPTED 0.33.0, TD-CR-03]

**A footprint is a variable rectangle of integer cells, not a fixed 2×2.** The archetype owns an immutable local **`cell_stamp`** whose dimensions equal that footprint, defining the ordinary logical-cell values produced when it bakes into W's grid — terrain, material, navigation, cover, elevation and flags.

**What bakes is W's ordinary logical cells.** There is no persistent 2×2 tile object at runtime, and 2×2 was a presentation choice that would otherwise have become an accidental simulation constraint.

**Mutable environmental state never enters the stamp.** Wetness, heat, corrosion, freezing stay in W's surface-channel system (W·11). The stamp is immutable authored content; copying simulation state into it would build a second, silently diverging state machine inside a content record.

| | |
| --- | --- |
| **`TileArchetype`** | Atomic, placed indivisibly, one coherent graphical and physical package, fixed local `cell_stamp`. **Footprint size does not change this** — a 2×2 whose four cells are immutable is an archetype |
| **`TileMacro`** | A separate authored multi-cell or multi-deck **topology** record: child archetypes, masks, solver-fillable fill domains, topology reservations, portal requirements. A 2×2 that composes children, or lets the solver fill internal cells, is a macro |

**`state_variants` are discrete authored states** — intact/broken, open/closed — and each owes matching art, collision and navigation. Environmental conditions are *not* variants: they are consequences of W's integer channels, and duplicating them here would put simulation state in a graphics state machine.

### Connectivity is an interface, compatibility is a profile [ADOPTED 0.33.0, TD-CR-03]

**Every boundary cell segment exposes its own `edge_socket`.** A 2×2 footprint therefore exposes **two segments per side**, not one socket per side — connectivity is per segment because geometry is per cell.

**An archetype owns its interface and never enumerates its compatible neighbours.** A versioned tileset-level **`AdjacencyProfile`** owns compatible socket pairs, complementary transition rules and profile-scoped restrictions; a `TileSet` references its allowed archetypes and one profile. Enumerating neighbours on the archetype would duplicate compatibility across every tile that shares an edge and guarantee drift.

**Terrain or material equality never establishes legal adjacency** — *sand meets sand* is not a connection. Compatibility may further constrain structural continuity, traversal, elevation, rendered seams, environmental transfer and portal behaviour. Material may *help a tool propose* a socket; only the explicit interface plus the selected profile **authorises** one.

**Adjacency sockets and affordance slots are different things.** `edge_sockets` are the deterministic adjacency constraint language; `reserved_affordance_slots` reserve positions for furniture, smart objects and combat affordances so decorative placement cannot consume them. Different schemas, different consumers, different proof obligations — which is why an archetype is never *classified* as a Socket.

**Composite macros are how multi-deck rooms are built.** A room with two decks does not emerge from unrestricted local collapse. Launch macro set: raised gallery over hall · balcony over courtyard · bridge over pit · split-level chamber · stairwell · collapsed deck with drop route · mezzanine with support columns · boss dais with lower arena.

A macro declares: footprint per deck · required `[Vertical Portal]`s · support mask · open-to-below mask · zone seeds · cutaway mask · forbidden prop areas · surface transfer edges · solver-fillable fill domains.

---

## Part 3 — Production pipeline: concept to published tile

Twelve stages. Human or agent may originate; only a human publishes.

| # | Stage | Actor | Output |
| --- | --- | --- | --- |
| 1 | **Concept** | Human or agent | Mood boards, silhouettes, material studies, state sheets. Generative imagery is permitted **here only** |
| 2 | **Projection lock** | Tool | Apply the locked camera matrix, tile dimensions, pixels-per-unit, light direction, elevation step |
| 3 | **Source construction** | Human or agent | Vector art, 2D paint, procedural geometry, or low-poly 3D |
| 4 | **Orthographic bake** | Tool | Base colour, normal, material mask, emission, shadow-caster mask, cutaway mask |
| 5 | **Atlas normalisation** | Tool | Footprint snap, crop bounds, pivot, render origin, padding |
| 6 | **State generation** | Tool | `state_variants` — intact / cracked / fractured / broken — from one source. **Environmental state is not a variant**: it lives in W's channels |
| 7 | **Semantic metadata** | Agent proposes, human verifies | Collision, navigation, occlusion, `edge_sockets`, `material_bindings`, `affordance_slots`. **Not** capacities, and **not** zone contribution — both retired at 0.33.0 |
| 8 | **Adjacency test matrix** | Tool | Render every permitted neighbour pair and every rotation |
| 9 | **Scene test** | Tool | Place in reference rooms with actors, props, lighting, surfaces, cutaways |
| 10 | **Batch proof** | Tool | Projection, seam, sorting, collision, navigation, metadata lints (Part 6) |
| 11 | **Human gate** | Art director / `[World Steward]` | Approves the **family**, not every arrangement |
| 12 | **Publish** | Tool | Versioned tile family enters the palette registry against `[Generator Version]` |

### 3.1 Why direct AI-to-tile export is rejected

Generative images do not reliably preserve exact projection, footprint, edge continuity, pivot, light direction, state correspondence, collision, occlusion, semantic sockets, material identity, or deterministic style. **Every one of those is load-bearing** — the first six break V·4.9's render proofs, the last four break generation.

Agents may generate concepts and structured variants. A deterministic bake and a proof pass produce the shippable asset. This is not scepticism about generative quality; it is that the pipeline needs *repeatability*, and W-C4 makes repeatability a Critical rule rather than a preference.

### 3.2 Atlas determinism

**The same tile set must always bake to the same atlas layout.** This is commonly framed as a multi-programmer convenience. Under W-C4 it is a **reproducibility requirement**: if atlas layout varies, render packages diverge between machines for identical seeds, and the golden-seed regression suite loses its meaning for anything touching render.

---

## Part 4 — Adjacency and sockets

### 4.1 Hand-authored sockets are the default

**One socket entry per boundary cell segment** [ADOPTED 0.33.0, TD-CR-03]. A 2×2 footprint exposes **two** north segments, not one north socket — connectivity follows geometry, and geometry is per cell. The example below shows one per side because its footprint is 1×1.

**`edge_sockets` are horizontal adjacency; `vertical_sockets` carry support, clearance and portal relations.** Neither is a **`reserved_affordance_slot`** — those reserve positions for furniture, smart objects and combat affordances so decorative placement cannot consume them, and they carry different schemas, consumers and proof obligations.

A structural tile exposes horizontal and vertical semantic sockets:

```json
{
  "tile_id": "gallery_edge_stone_n",
  "edge_sockets": {
    "north": ["open", "railing"],
    "east":  ["gallery"],
    "south": ["gallery"],
    "west":  ["gallery"]
  },
  "vertical_sockets": {
    "support_down": ["wall", "pillar", "solid"],
    "clearance_up": ["open"],
    "portal_up": [], "portal_down": []
  }
}
```

**Vertical sockets are not generic up/down neighbours.** They express a small authored vocabulary: `support_down`, `clearance_up`, `occludes_below`, `portal_up` / `portal_down`, `surface_flow_up` / `surface_flow_down`.

**`open_to_below` and `facade_required` left this vocabulary at 0.33.0** (TD-CR-06). Neither was ever a socket an archetype could declare: an opening is a **topology mask or reservation**, and a facade obligation is **derived per directed edge** at placement. A socket says *what may connect here*; these two said *what happened to be true over there*.

| Approach | Wins when | Cost |
| --- | --- | --- |
| **Hand-authored edge labels** *(default)* | Control, lintability and reproducibility matter — Triade's case | Authoring effort per family |
| Example-inferred adjacency | Fast prototyping of organic biomes | Learns incidental detail from the input; poor control. **Offline only**, baking to a fixed adjacency table so runtime stays integer and deterministic |

**Not every tileset is expressible as edge labels.** Sets where two pieces cannot be adjacent yet can be *connected* through a third are not edge-label-inducible. Such a set must be explicitly flagged (TILE-H1) rather than silently producing wrong adjacency.

### 4.2 Symmetry classes

Author one canonical tile, declare its symmetry class, derive rotations and reflections. This is the primary defence against combinatorial explosion in the tile library.

**Connectors and any intentionally anisotropic tile must be marked non-rotating.** A stair has a direction; deriving three rotations of it produces three wrong stairs.

### 4.3 Relationship to the solver

W·13 locks tile realisation: *"Template/prefab stitching; WFC or rule-tiles **only inside** organic rooms with authored adjacency… Rejected: WFC for whole maps. **Prefer Model Synthesis at scale**."*

G supplies the vocabulary that lock consumes. Two consequences for tile authoring:

1. **Sockets are a constraint language, not decoration.** A socket label with no legal complement guarantees contradictions (TILE-C1).
2. **No float may reach the digest** (W-C8). Socket identity, adjacency lookup and any hashing in the bake are integer operations. Entropy-style heuristics that require logarithms are excluded from anything whose output reaches the proof digest.

---

## Part 5 — The archetype record

**G authors the reference and the transmission contract; it owns neither capacities nor state** [ADOPTED 0.36.0, CR-11]. **Capacities and responses live in the published `MaterialProfile`** (TD-CR-04) — this document has never owned them, and the 0.36.0 wording that implied it did is corrected here. A stamped cell selects a `material_id`; the profile carries the values.

**What G does own is the geometry transmission contract**, per face:

| Hook | States |
| --- | --- |
| `aperture` | whether the face is open, and at what fraction, for volume propagation |
| `permeability` | whether an Airborne Volume may cross, independently of walkability |
| `transmissive` | whether light or line of sight passes while the face still blocks a projectile |
| `sealed` | whether a closed state severs propagation entirely |

**It holds no mutable channel value.** Duplicating runtime state into a content record builds a second simulation that diverges silently — the same argument that retired W's competing tile schema.

**G owns this record, and it is the only complete one** [ADOPTED 0.33.0, TD-CR-01]. **W consumes approved archetypes and does not define a competing tile-archetype schema.** W keeps its **locked 16-byte logical cell** — the substrate beneath this layer — unchanged. The two records were never in conflict, but W·14.1 carried a second full schema that had already drifted from this one, and a schema with two owners has none.

**`structural_roles` is a set, not a single value.** One archetype may contribute in several legitimate ways at once — a stair that is both `deck` and `connector`. The singular `structural_role` was the first proposal; the set-valued form is fixed by **TD-CR-03**, adopted 0.33.0.

> **`deck_role` was retired at 0.33.0 by TD-CR-04.** It carried `"upper"` — placement-relative Deck context, not a structural contribution — so it was never what `structural_roles` replaced, and overwriting it mechanically would have destroyed a distinct field. It is gone from the record, its meaning migrated (Part 5), and its name is out of the sanctioned vocabulary.
>
> **Authored values migrate; they are not discarded.** Deck membership or index → the placement's `[Deck]` reference or `tz`. Vertical relationship → placement base-elevation or connector-endpoint metadata. Purely visual layering → derived render context. The word also leaves G's sanctioned vocabulary once the migration lands.

**There is no semantic `shape` field, and there will not be one.** Geometry is `physics.collision_shape` and `physics.navigation_shape` — real geometry, authored and named. A `shape` string is a second, lossy description of the same thing that begins disagreeing with it immediately. `shape: "deck"` was **rejected** rather than adopted: a Deck is a topology and a structural role, never a collision primitive.

```json
{
  "tile_id": "stone_gallery_edge_n_a",
  "family_id": "stone_gallery_edge",
  "projection_id": "dimetric_main_v1",
  "structural_roles": ["boundary", "deck", "facade"],
  "footprint": { "width": 2, "height": 1 },
  "cell_stamp": [
    {
      "local": { "x": 0, "y": 0 },
      "terrain_id": "gallery_deck",
      "material_id": "stone_porous",
      "elevation_delta": 0,
      "nav_cost": 1,
      "cover_by_edge": { "north": "half", "east": "none", "south": "none", "west": "none" },
      "los_opacity": 0,
      "authored_flags": ["spawn_valid", "walkable"]
    },
    {
      "local": { "x": 1, "y": 0 },
      "terrain_id": "gallery_deck",
      "material_id": "stone_porous",
      "elevation_delta": 0,
      "nav_cost": 1,
      "cover_by_edge": { "north": "half", "east": "none", "south": "none", "west": "none" },
      "los_opacity": 0,
      "authored_flags": ["spawn_valid", "walkable"]
    }
  ],
  "edge_sockets": {},
  "reserved_affordance_slots": [],
  "render": { "atlas_rect_px": { "x": 256, "y": 128, "width": 128, "height": 128 } },
  "physics": {},
  "state_variants": {},
  "provenance": {
    "origin": "agent", "model": "…", "prompt_version": "…",
    "approved_by": "steward:…", "approved_at": "…"
  }
}
```

**Capacities and responses live in the referenced `MaterialProfile`, not on the tile** [ADOPTED 0.33.0, TD-CR-04]. A stamped cell selects a `material_id`; the profile carries the bounded-integer capacities that feed W·11's channel model. **Mutable environmental state exists only in W's sparse overlay** — this document authors the reference and the proof hooks, never the state. A tile never carries a string enum of effects — *slippery*, *burning* and the rest are **named reactions**, resolved by fixed lookup from channel combinations, and that lookup is `[World Steward]` vocabulary.

**Naming taboo.** A tile is never called a *region* or a *zone*: both are locked elsewhere (T's Triade regions, K's combat zones), and H reserves *node* for `[Body Location]`. `footprint`, `family_id` and `structural_roles` are the sanctioned words. **`deck_role` left the vocabulary at 0.33.0** with the field itself (TD-CR-04).

**The taboo was kept in prose and broken in the schema** [ADOPTED 0.33.0, TD-CR-02]. This document forbade calling a tile a *region* while the archetype record carried `render.region` as an atlas rectangle — the locked word used for exactly the thing it is locked against, inside a fenced block no prose sweep ever read.

**A baked atlas extraction rectangle is `render.atlas_rect_px`:**

| Member | Contract |
| --- | --- |
| `x`, `y` | Non-negative integer pixels from the atlas **upper-left** origin |
| `width`, `height` | **Positive** integer pixel dimensions |
| Covered area | **Half-open** — `[x, x + width) × [y, y + height)` |
| `_px` suffix | Fixes the unit, and distinguishes it from normalized UV coordinates |

**`render.region` is not valid render metadata.**

*Reason inline.* Named members remove the ordering ambiguity a four-element array leaves implicit; half-open bounds make overlap and coverage proofs deterministic rather than off-by-one arguments; the suffix stops anyone reading pixels as UVs. **Rejected:** `uv_rect`, because the values are pixels and naming them otherwise is a lie the schema cannot catch, and a four-element array under any other name, because the order stays implicit and the misuse stays available.

---

### Ownership, placement and the bake [ADOPTED 0.33.0, TD-CR-04]

**G owns the authored contract. W owns the locked 16-byte logical cell and the deterministic placement and bake that produces it.** A validated **package compiler** sits between them, resolving authored identifiers into the package-local integer codes W consumes:

```text
G TileArchetype → validated package compiler → W placement + symmetry transform
                → locked 16-byte logical cells → later W generation passes
```

**A placement supplies `(tx, ty, tz, base_elevation, symmetry_transform)`.** Deck index and absolute elevation are **placement context, not intrinsic archetype identity** — which is why `deck_role` and `elevation_band` leave the record: the same archetype placed on two decks is the same archetype.

**Local coordinates and completeness.** `cell_stamp` carries exactly one entry per local coordinate in the declared footprint — **sparse or duplicate stamps are invalid**. Authoring space puts the **south-west** cell of the untransformed footprint at `(0, 0)`, positive `x` east, positive `y` north; canonical serialisation orders entries by `y`, then `x`. A symmetry transform applies **coherently** across footprint, stamp coordinates, edge sockets, cover facings, collision, navigation and render geometry — render-space pixels stay governed by `render.atlas_rect_px` (TD-CR-02).

| Authored `cell_stamp` field | Baked W field | Projection |
| --- | --- | --- |
| `terrain_id` | `terrain: u8` | Stable identifier → package-local integer code |
| `material_id` | `material: u8` | Resolved through the published material registry |
| `elevation_delta` | `elevation: i8` | Signed local delta **added to placement `base_elevation`**; overflow rejected |
| `nav_cost` | `nav_cost: u8` | Integer throughout — W's floating `1.0` example is retired |
| `cover_by_edge` | packed `cover: u8` | Four facings compiled into the existing 2-bit-per-facing layout **after** transform |
| `los_opacity` | `los_block: u8` | Integer `0..255` |
| permitted `authored_flags` | applicable `flags` bits | Only properties archetype authoring actually owns |

**Six values may never be forged as authored stamp data**, because a later pass owns them and authored content cannot overwrite a generation result:

| Value | Owner |
| --- | --- |
| `surface_index` | Surface initialisation and runtime mutation |
| `prop_ref` | Furniture and object placement |
| `zone_id` | Zone extraction |
| `path_critical` | Mission and path validation |
| `socket_reserved` | Derived from placed `reserved_affordance_slots` |
| `complex_room` | Room-template instantiation |

**Material properties live in a published `MaterialProfile` registry**, not at tile level. Each stamped cell selects a `material_id`; the compiler resolves it to the immutable profile and its `u8` code **without enlarging the logical cell**. Mutable wetness, heat and corrosion stay in W's sparse surface overlay — the registry carries capacity and response, never state.

**Fields retired from this record, and where their meaning went:**

| Retired | Replacement |
| --- | --- |
| `family` | reference-shaped `family_id` |
| **`deck_role`** | **removed** — deck and absolute vertical context come from placement and connector metadata |
| `elevation_band` | per-cell `elevation_delta` + placement `base_elevation` |
| `gameplay.walkable` | each applicable cell's `authored_flags` |
| scalar `cover_grade` | per-facing `cover_by_edge` |
| tile-level `material` | per-cell `material_id` |
| tile-level `surface_capacity` | the referenced `MaterialProfile` |
| `states` | `state_variants` |

> **`deck_role` values migrate, they are not dropped.** Deck membership or index → the placement's `[Deck]` reference or `tz`; vertical relationship → placement `base_elevation` or connector-endpoint metadata; purely visual layering → derived render context. The word also leaves this document's sanctioned vocabulary.

---

### Vertical contracts: what an archetype declares [ADOPTED 0.33.0, TD-CR-06]

**Vertical structure is three contracts, not one.** An archetype or macro owns **local** geometry, occupancy and intentional-void masks, structural requirements and transform-aware **portal anchors**. W owns the resolved traversal edge, and W-derived records own exposed edges, facade obligations, support satisfaction and cutaway relationships. Nothing here resolves anything: this document declares, placement decides.

**Intentional voids are declared, never inferred.** A multi-cell archetype may declare a local void mask; multi-deck topology and reservations belong primarily to `TileMacro`. A declared void means **the solver must not fill that position**, and may drive lower-geometry visibility, cutaway, falling, environmental transfer or facade obligations. **Mere absence outside an explicit reservation is not authored intent** — a hole nobody asked for is a bug, not a balcony.

**Support is declared locally and resolved at placement.** An archetype or macro states its support requirements or anchors; a requirement is satisfied only by continuous structural geometry below, a compatible `support`-role archetype, a support reserved by the containing macro, or an explicit bounded cantilever rule. **Missing support never silently implies a valid span.**

**A connector exposes `portal_anchors`; it does not own the portal.** Each anchor declares its local cell and elevation, approach facing and referenced landing-clearance mask. Binding anchors into a traversal edge is W's.

**A connector may use only the transforms its archetype lists**, and a permitted transform must move *everything* coherently — footprint, `cell_stamp`, geometry, anchors, landing masks, elevations, approach facings, sockets and render package. **Content that cannot transform exactly declares `identity` only** and ships separately authored variants instead. A rotation that moves the art but not the landing mask is how a stair ends in a wall.

---

### Model Synthesis and the three structural levels [ADOPTED 0.33.0, TD-CR-09]

**Model Synthesis — Wave Function Collapse included — is a room-scoped deterministic tile-realisation solver, and nothing more.** It runs only *after* the `DungeonPlan`, room contract, mandatory reservations, qualified portals and any selected `RoomTemplate` are known. It chooses legal approved archetype revisions, permitted transforms and compatible placements for **declared fill domains**, consuming adjacency profiles, boundary sockets, support requirements, Deck membership, openings, landing reservations and style constraints without owning any of them.

**It cannot author progression.** Mission topology, gates, portal obligations, mandatory rooms, encounters, objective order and protected witnesses enter the solver as **immutable boundary conditions**. A contradiction is resolved by bounded deterministic backtracking or retry inside the named retry scope, and failure escalates through W's outward repair ladder — **the solver may never silently weaken a constraint**.

**Pipeline order:** compile the plan and room contract → select any required `RoomTemplate` → reserve portals, landings, protected sites and fixed geometry → place accepted `TileMacro` packages → solve remaining fill domains → expand macros into placements → validate geometry, support, traversal, reservations and adjacency → emit the `RoomCompositionPlan` and its proof trace.

**Three levels, chosen by the invariant being protected — never by size:**

| Level | Is | Use when |
| --- | --- | --- |
| **`TileArchetype`** | One indivisible authored element, possibly multi-cell | The geometry and state package is inseparable |
| **`TileMacro`** | An atomic *recipe* of coordinated approved placements — accepted or rejected as one choice, then expanded into ordinary placed tiles | A reusable coordinated assembly of ordinary tiles |
| **`RoomTemplate`** | A room-scale scaffold: footprint, fixed structural geometry, mandatory openings, protected reservations, anchors and explicit **fill domains** | A room needs fixed and variable areas together |

**Size alone never promotes a record.** A large tile is not a macro; a fixed multi-cell piece is not a template; a template is not an oversized tile record. And **degrees of freedom must be explicit** — the solver cannot infer which structure is protected from visual size or appearance. A macro **expands**; it retains no opaque parallel runtime state afterwards.

---

## Part 6 — Linting and validation

| ID | Severity | Rule |
| --- | --- | --- |
| **TILE-C1** | Critical | Every socket label has ≥1 legal complement — no dead-end tile, which would guarantee solver contradictions |
| **TILE-C2** | Critical | Every archetype declares a `projection_id` matching the locked camera matrix (V·2) |
| **TILE-C3** | Critical | Atlas bake is deterministic: the same tile set produces byte-identical atlas layout. Reproducibility, not convenience (W-C4) |
| **TILE-C4** | Critical | No float participates in socket identity, adjacency lookup or any bake hash reaching the proof digest (W-C7, W-C8) |
| **TILE-C5** | Critical | G owns the canonical `TileArchetype`; no other document defines a competing complete tile-archetype schema. Geometry is collision and navigation geometry — there is no semantic `shape` field |
| **TILE-C6** | Critical | A baked atlas extraction rectangle is `render.atlas_rect_px` with integer `x`, `y`, `width`, `height`; upper-left origin, positive dimensions, half-open bounds. `render.region` is prohibited |
| **TILE-C7** | Critical | A `TileArchetype` has no exclusive `tile_class`. It declares a set-valued `structural_roles` — `deck`, `boundary`, `facade`, `support`, `connector` — canonically sorted and deduplicated; obligations attach to the roles, capabilities and record type present |
| **TILE-C8** | Critical | An archetype owns its `edge_sockets` interface per boundary **cell segment** and never enumerates compatible neighbours; a versioned tileset-level `AdjacencyProfile` owns compatibility. Terrain or material equality never authorises adjacency |
| **TILE-H5** | High | `cell_stamp` is immutable authored content sized to the footprint. Mutable environmental state stays in W's surface channels and is never copied into it |
| **TILE-C9** | Critical | G owns the authored `TileArchetype`; W owns the locked 16-byte logical cell and the deterministic bake. `cell_stamp` has exactly one entry per footprint coordinate — sparse or duplicate stamps are invalid — with south-west `(0,0)`, `+x` east, `+y` north, serialised by `y` then `x` |
| **TILE-C10** | Critical | `surface_index`, `prop_ref`, `zone_id`, `path_critical`, `socket_reserved` and `complex_room` are owned by later generation passes and may never be forged as authored `cell_stamp` values |
| **TILE-H6** | High | Material-dependent immutable capacities and responses live in a published `MaterialProfile`; a cell selects `material_id`. Mutable environmental values stay in W's sparse surface overlay |
| **TILE-H1** | High | A tileset not inducible from edge labels is explicitly flagged as such rather than silently mis-inferred |
| **TILE-H2** | High | Symmetry class declared; rotations derived, not duplicated. Connectors and anisotropic tiles marked non-rotating |
| **TILE-H3** | High | Every state variant has matching art, collision and navigation (pairs with V-C4) |
| **TILE-H4** | High | Every agent-originated archetype carries complete provenance and a recorded human approval before publish |
| **TILE-M1** | Medium | Adjacency inferred from examples does not encode incidental detail from the source |
| **TILE-M2** | Medium | Decorative props do not occupy reserved affordance sockets (tile-level mirror of W-M3) |
| **TILE-M3** | Medium | Schema completeness — every archetype has `tile_id`, collision shape, `z_group` and `projection_id` |

---

## Part 7 — Agentic and human authoring

### 7.1 Roles

| Role | Owns | Authority |
| --- | --- | --- |
| **`[World Steward]`** | World grammar, Territory schema, axis taxonomy, surface vocabulary | **Human only** |
| **Projection Steward** | Camera matrix, tile projection, light direction, elevation step, render-layer ordering | **Human only** |
| **Tile Semantic Smith** | Sockets, materials, affordances, state metadata | Agent proposal |
| **Visual Tile Smith** | Concept sheets, source-asset variants | Agent-assisted |
| **Batch Renderer** | Deterministic atlas bake | Tool, not a generative agent |
| **Adjacency Auditor** | Socket compatibility matrix | Deterministic verifier |
| **Occlusion Auditor** | Cutaway, sorting, silhouette tests | Deterministic verifier |

**No agent may alter** camera projection · tile dimensions · elevation step · render-layer ordering · RNG implementation · combat zone rules · Triade vocabulary.

*Adding a second human-only role is a real governance cost, taken knowingly: projection is the one property that, once wrong, invalidates every asset produced against it.*

### 7.2 The gate pattern

Agents write to a durable proposal store. Nothing enters a shipped tileset without a recorded human approval, and irreversible edits — schema, vocabulary, projection — are agent-forbidden by construction rather than by policy.

**Runtime is different and simpler: no human, ever.** Generation cannot pause to ask, and W-C4 makes that structural — a human decision is not reproducible from `(seed, generator_version)`. Human authoring happens at content time; the generator only ever *reads* what humans approved.

### 7.3 Human authoring surfaces

Humans author at four levels: **intent** (Territory, axis, room fantasy, set-piece purpose) · **grammar** (approved macros, tile families, portal types) · **exemplars** (small positive and negative example maps) · **exceptions** (boss shells, landmarks, `complex_room` templates).

Humans do not hand-place routine decoration across generated dungeons. A designer may pin cells or macros, forbid a family, reserve a portal, redraw a deck mask, or reject a generated family — and **all such edits are stored as constraints or deltas**, never as untracked scene changes, or the seed stops reproducing the result.

---

## Part 8 — Open items

| # | Question | Markers | Blocking |
| --- | --- | --- | --- |
| ~~**◈G1**~~ | **SUPERSEDED 0.33.0, TD-CR-06.** Neither flag is added. Intentional openings are topology masks or reservations; facade obligation is derived **per directed edge**, not stored per cell | — | — |
| **◇G2** | Tile family count per Territory package before authoring cost dominates | **[OPEN]** [SIM] | Content |
| **◇G3** | Socket vocabulary size — how many distinct labels before the adjacency matrix stops being auditable by hand | **[OPEN]** [SIM] | Content |
| **◇G4** | Exact projection angle and elevation step. Blocked on **◇V6** — the fixed-angle posture test gates the whole projection lock | **[OPEN]** | **Blocked on V** |
| **◇G5** | Whether example-inferred adjacency is used at all, or hand-authored sockets are the sole route | **[OPEN]** | Tooling |
| **◇G6** | Non-humanoid and non-architectural palettes — caves, organic interiors — need socket vocabularies that may not be edge-label inducible. Depends on **◇E5** | **[OPEN]** | Content / E |
| **◇G7** | **[GAP]** Render proof harness is uncosted (= **◇V7**). The batch proof at stage 10 assumes tooling nobody owns | **[OPEN]** [GAP] | **No owner** |
| ~~**◈G8**~~ | **CLOSED 0.31.0 — and authored here for the first time.** Whether a **tile class** needs a stronger word than *class*: it does not. The 0.16.0 rename off `Category` cleared the only collision, the word carries no mechanical weight, and L now holds the entry. *This item existed only in the Open Items Index — no archive back to v0.16.0 has a row for it in this document. The index minted the ID; a closure without a home would repeat that* | — | — |

---

## Changelog

| Version | Change |
| --- | --- |
| **0.43.0** | Version alignment only. P12-B changes no tile, material, adjacency, bake or render-proof contract. |
| **0.42.0** | Version alignment only. P12-A changes no tile, material, adjacency, bake or render-proof contract. |
| **0.41.0** | Version alignment only. P11 changes no tile, material, adjacency, bake or render-proof contract. |
| **0.40.0** | Version alignment only. The P13 Lineage/Physique and Somatic authorization ruling changes no tile, material, adjacency, bake or render-proof contract. |
| **0.39.0** | Version alignment only. A2 changes no tile, material, adjacency, bake or render-proof contract. |
| **0.38.0** | 5 geographic occurrences → Territory; Territory package and Territory content package. |
| **0.36.0** | **Authored material capacities and geometry transmission hooks recorded**, with **no mutable runtime duplication** — a content record holding channel state would be a second simulation that diverges silently. |
| **0.33.0** | **TD-CR-01 adopted, and a reserved-word violation corrected.** Tile class 1 renamed `Surface` → **Deck tile**: `surface` is locked to environmental channels and is *never* traversable geometry, yet the row named walkable floor `Surface` while using the word correctly in its own obligation column. Part 5 affirms **G owns the canonical `TileArchetype`** (**TILE-C5**), declares `structural_roles`, and states there is no semantic `shape` field. The stale inline `[OPEN] ◇G8` sentence at §2 was swept — `◈G8` closed at 0.31.0 and the prose never followed. **TD-CR-02 adopted**: `render.region` becomes **`render.atlas_rect_px`** with named integer members, upper-left origin and half-open bounds (**TILE-C6**) — the naming taboo had been kept in prose and broken in the schema. **TD-CR-03 adopted**: the nine-class ontology becomes set-valued **`structural_roles`** (**TILE-C7**), with occluder, socket, macro and stateful split into their own dimensions. Variable footprints and an immutable `cell_stamp`; `edge_sockets` per boundary cell segment with compatibility owned by a versioned `AdjacencyProfile` (**TILE-C8**, **TILE-H5**). **TD-CR-04 adopted**: the archetype record is rewritten to `family_id` / `structural_roles` / `footprint` / `cell_stamp`, with `deck_role`, `elevation_band`, scalar `cover_grade`, tile-level `material` and `surface_capacity` **retired and their meanings migrated** (**TILE-C9**, **TILE-C10**, **TILE-H6**). Placement supplies deck and elevation context; a `MaterialProfile` registry owns material capacities. **TD-CR-06 adopted, `◈G1` superseded.** Neither `open_to_below` nor `facade_required` joins the 16-byte flags — one is a relationship between aligned positions, the other is directional and placement-dependent. Archetypes declare local voids, support requirements and `portal_anchors`; a permitted transform must move geometry, anchors, landing masks, facings and render together, or declare `identity` only. **TD-CR-09 adopted**: Model Synthesis is a room-scoped solver over declared fill domains only, running after planning obligations are fixed, and the three structural levels — `TileArchetype`, `TileMacro`, `RoomTemplate` — are chosen by the invariant being protected, never by size. **Corrective pass.** Surface capacities and responses reframed as `MaterialProfile`-owned throughout §1, §2, §3 and §5 — G authors the reference and the proof hooks, never the state. Pre-adoption survivals cleared: the "nine classes" line, two "not yet adopted" claims, the `W·9 requires no change` framing, and the unqualified 1 MB figure. |
| **0.31.0** | **`◈G8` closed, and given a home for the first time.** The item existed only in the Open Items Index; no archive back to v0.16.0 carries a row for it here. A `tile class` needs no stronger word than *class*, and L now holds the entry. |
| **0.27.0** | Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | 8 subsection headings deletterd. Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | Nine `Part G<n>` headings become `Part <n>`; its open items ◇G1–◇G8 no longer collide with **W**'s design goals. Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **16 glyphed identifiers in this document.** |
| **0.12.0** | Document created. Establishes the archetype-record / 16-byte-cell split, resolving the apparent conflict between rich tile metadata and W·9's locked budget — **W·9 is unchanged**. Nine-category tile ontology; twelve-stage production pipeline with generative imagery confined to concept and a mandatory human family gate; hand-authored socket vocabulary as default with vertical sockets enumerated; symmetry classes with connectors marked non-rotating; eleven lint rules (TILE-C1…C4, TILE-H1…◈H4, TILE-M1…◇M3); agentic roles with the Projection Steward added as a second human-only owner. Seven open items registered, one an unowned gap shared with ◇V7. |
