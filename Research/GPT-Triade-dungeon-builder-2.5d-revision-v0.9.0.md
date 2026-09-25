# Triade Roguelike — Dungeon Builder System  
## 2.5D Constraint Audit and Revised Design

**Revision basis:** Triade design corpus v0.9.0  
**Date:** 31 July 2026  
**Status:** Proposed corrective revision for integration into the World, Maps & Dungeons workstream  
**Primary change:** Replace true volumetric 3D generation with a layered 2.5D logical-and-rendering architecture.

---

## 0. Executive decision

The previous dungeon-builder report is **not production-safe under a strict 2.5D graphical constraint without revision**.

The following parts remain valid:

- mission graph before geometry;
- deterministic seed namespaces;
- procedural arrangement of authored content;
- Model Synthesis / Wave Function Collapse as a local realisation method;
- separate furnishing, surface, zone-extraction, and proofing passes;
- sparse combat zone overlay;
- smart objects, affordance slots, and destruction-state validation;
- agentic proposal plus independent deterministic verification.

The following parts must change:

1. **Do not run unconstrained full-volume 3D WFC as the default dungeon solver.**
2. **Do not treat every voxel above and below a tile as a generation cell.**
3. **Do not assume a freely rotatable camera.**
4. **Do not allow graphical asset generation to produce game-ready tiles directly from unconstrained image generation.**
5. **Do not infer vertical interactions merely because two cells overlap in screen space or share an `(x,y)` coordinate.**
6. **Do not claim WFC guarantees global connectivity or progression correctness.** WFC guarantees local pattern compatibility; mission topology and global proofs remain separate.
7. **Do not expose full-resolution physical positioning to combat.** The locked 2–4-zone overlay remains authoritative in combat.

The revised architecture is:

> **A 2D square logical lattice with sparse stacked walk surfaces, discrete elevation bands, explicit vertical portals, fixed-camera 2.5D rendering, and Model Synthesis/WFC applied per surface layer or composite room module.**

The logical model may retain `(tx, ty, tz)`, but `tz` means **walk-surface layer**, not a voxel coordinate in a filled 3D volume.

---

## 1. Compatibility finding against the Triade corpus

### 1.1 World-generation compatibility

The existing World document already contains most of the correct substrate:

- square logical lattice;
- an `elevation` field per tile;
- explicit off-mesh links for climb, vault, and jump;
- elevation bands as seeds for zone extraction;
- mission graph as topology authority;
- tiles as authoring/nav/surface truth;
- combat consuming only the derived zone overlay;
- vertical connectors requiring safe landings.

These decisions are strongly compatible with 2.5D. They should be retained.

### 1.2 Combat compatibility

Combat is locked to a sparse zone graph of two to four named zones per room. Zones carry elevation, cover, capacity, environmental influences, and circumstantial Advantage. Range is measured in zone transitions, not tiles or metres.

Therefore, 2.5D verticality must produce:

- a readable zone adjacency edge;
- a movement cost;
- an elevation relationship;
- optional high-ground Advantage;
- optional local EDM;
- explicit access restrictions.

It must **not** create a second fine-grained tactical height system.

### 1.3 Visual-design conflict

The current Visual Design document recommends stylised low-poly 3D and an ideally rotatable camera. A strict 2.5D constraint supersedes that recommendation.

This is not only a dungeon-report correction. It requires an amendment to Visual Design Part V2:

- replace “stylised low-poly 3D” with a 2.5D production model;
- replace continuous camera rotation with a fixed camera or, at most, discrete authored viewpoints;
- preserve posture as the primary state display;
- implement posture through 2D skeletal blending, baked directional animation, or orthographic 3D characters rendered into the 2.5D scene.

---

## 2. Revised 2.5D graphical model

### 2.1 Recommended production model

**Default recommendation: fixed orthographic/dimetric camera, isometric-like 2D environment, 2D skeletal or orthographically rendered characters, and a 2D UI overlay.**

The environment is authored as layered sprites or scene tiles. Simulation remains engine-independent.

Three implementation variants are legal:

| Variant | Environment | Characters | Assessment |
|---|---|---|---|
| **A — pure 2D skeletal** | sprite/tile layers | 2D skeletons and paper-doll equipment | Lowest runtime cost; highest equipment-authoring burden |
| **B — hybrid 2.5D** | sprite/tile layers | low-poly 3D characters under an orthographic camera | Best posture/equipment scalability; depth integration requires discipline |
| **C — pre-rendered 3D** | baked sprite atlases | baked directional actors/props | Strong visual cohesion; expensive animation and equipment combinatorics |

Variant B is the best fit if equipment variety and posture telegraphing remain central. Variant A is the leanest technical implementation.

### 2.2 Camera rule

The camera is **fixed for normal play**.

Permitted:

- fixed isometric/dimetric angle;
- zoom within a bounded range;
- pan;
- authored cutaway transitions;
- optional discrete 90-degree viewpoints only when every environment and actor asset has matching variants.

Rejected for the base game:

- free continuous rotation;
- perspective-dependent puzzle geometry;
- mechanics requiring the player to discover hidden routes by rotating the camera;
- arbitrary camera pitch changes during combat.

A fixed camera turns render ordering, tile projection, cover silhouettes, and vertical readability into proofable properties.

### 2.3 Render stack

Each active room or chunk renders through explicit layers:

1. **Underlay** — void, water depth, distant background.
2. **Ground surface** — lowest walk surface.
3. **Ground structures** — walls, cliffs, floor edges.
4. **Ground actors and props** — Y-sorted within the elevation band.
5. **Upper support/facade** — pillars, bridge undersides, mezzanine faces.
6. **Upper walk surface** — gallery, bridge, balcony.
7. **Upper actors and props** — Y-sorted within the upper band.
8. **Roof/foreground occluders** — cut away or faded according to visibility rules.
9. **Effects and UI** — surfaces, targeting, relational-state indicators.

Every tile archetype declares which render layers it contributes to.

---

## 3. Revised spatial model

### 3.1 Three distinct meanings of “floor”

The earlier report blurred three concepts. They must be separated.

| Term | Meaning | Example |
|---|---|---|
| **Dungeon floor** | A macro level in a dungeon progression stack | Delve Floor 4 |
| **Walk-surface layer** | A local traversable sheet in one generated map | lower hall, upper gallery |
| **Elevation band** | A discrete height category used for rendering and zone extraction | band 0, band 1 |

Recommended provisional terminology:

- **[Dungeon Floor]** — macro progression level.
- **[Walk Surface]** — one connected traversable sheet.
- **[Elevation Band]** — local discrete height class.
- **[Vertical Portal]** — explicit traversal edge between walk surfaces or dungeon floors.
- **[Composite Room]** — authored or constrained room containing multiple walk surfaces.

### 3.2 Coordinate interpretation

Retain:

```text
tile cell = (tx, ty, tz)
```

Reinterpret:

- `tx`, `ty` — square logical lattice;
- `tz` — sparse walk-surface layer index;
- `elevation` — physical/render height band;
- no requirement that every `(tx,ty,tz)` position exists;
- no solid voxel volume between walk surfaces.

A lower floor and an upper balcony may share `(tx,ty)` but occupy distinct `tz` values. Their relationship is defined by support, occlusion, and portal metadata—not by generic vertical adjacency.

### 3.3 Vertical portal model

```json
{
  "portal_id": "room_07_stair_a",
  "kind": "stairs",
  "from": {"cell": [12, 8, 0], "zone": "hall_floor"},
  "to": {"cell": [14, 6, 1], "zone": "raised_gallery"},
  "bidirectional": true,
  "movement_ap": 2,
  "requires": [],
  "fall_allowed": false,
  "surface_transfer": ["smoke_up"],
  "render_cue": "stair_riser_bright_edge"
}
```

Portal kinds:

- stairs;
- ladder;
- ramp;
- lift;
- drop;
- jump;
- bridge transition;
- hatch;
- teleport or magical transition.

The portal is the only authoritative statement that traversal is possible.

---

## 4. Revised Model Synthesis / WFC architecture

### 4.1 Correct role of WFC

WFC/Model Synthesis is a **local compatibility solver**. It is suitable for:

- tile adjacency;
- facade continuation;
- corridor dressing;
- organic floor patterning;
- wall/corner consistency;
- support and railing continuation;
- decoration passes;
- filling a pre-reserved room mask.

It does not by itself guarantee:

- connected critical paths;
- key-before-lock order;
- boss accessibility;
- useful encounter pacing;
- two to four good combat zones;
- safe destruction states;
- camera readability.

Those are controlled by mission graphs, room graphs, reservations, and proofing.

### 4.2 Why full 3D WFC is rejected as the default

Higher-dimensional WFC is possible, but the state space and contradiction risk grow quickly. Under 2.5D, full voxel synthesis spends complexity on invisible volume that the game neither renders nor simulates.

The production system therefore uses **Layered Constrained Model Synthesis**:

```text
mission graph
    ↓
dungeon-floor graph
    ↓
room graph and reservations
    ↓
walk-surface masks
    ↓
elevation grammar
    ↓
2D WFC per walk surface
    ↓
cross-layer support and portal constraints
    ↓
facade/occluder synthesis
    ↓
furnishing and surfaces
    ↓
zone extraction and proofing
```

### 4.3 Solver domains

Use separate solver passes instead of one enormous wave:

| Pass | Domain | Examples |
|---|---|---|
| **Structural surface pass** | one 2D walk surface | floor, wall, void, doorway |
| **Cross-layer pass** | aligned sparse cells | support below, open void, balcony edge |
| **Connector pass** | reserved portal footprints | stairs, ladder, bridge landing |
| **Facade pass** | exposed height edges | cliff face, wall face, balcony underside |
| **Decoration pass** | non-critical visual variants | cracks, moss, trim, decals |
| **Furnishing pass** | semantic sockets | cover objects, tables, shrines |

Each pass has a smaller tile vocabulary and a clearer failure report.

### 4.4 Tile sockets

A structural tile exposes horizontal and vertical semantic sockets:

```json
{
  "tile_id": "gallery_edge_stone_n",
  "sockets": {
    "north": ["open", "railing"],
    "east": ["gallery"],
    "south": ["gallery"],
    "west": ["gallery"],
    "support_down": ["wall", "pillar", "solid"],
    "space_up": ["open"],
    "portal_up": [],
    "portal_down": []
  }
}
```

Vertical sockets are not generic `up/down` neighbours. They express a small authored vocabulary:

- `support_down`;
- `clearance_up`;
- `open_to_below`;
- `occludes_below`;
- `portal_up/down`;
- `surface_flow_up/down`;
- `facade_required`.

### 4.5 Composite room modules

Rooms containing two walk surfaces should not emerge from unrestricted local collapse. They use **composite macros** that reserve their critical geometry first.

Required launch macros:

- raised gallery over hall;
- balcony over courtyard;
- bridge over pit;
- split-level chamber;
- stairwell;
- collapsed floor with drop route;
- mezzanine with support columns;
- boss dais with lower arena.

A macro defines:

- footprint on each walk surface;
- required portals;
- support mask;
- open-to-below mask;
- zone seeds;
- camera cutaway mask;
- forbidden prop areas;
- surface-transfer edges;
- WFC-fillable subregions.

WFC fills the macro; it does not invent the macro’s topology.

---

## 5. Verticality rules

### 5.1 Local room verticality

Standard combat rooms:

- one or two walk surfaces;
- maximum two elevation bands visible and active at once;
- two to four combat zones total across both surfaces;
- at least one visually unambiguous vertical portal;
- upper floor footprint must not obscure mandatory lower-floor decisions.

Rare `complex_room` set pieces may use three elevation bands, but require a hand-authored shell and separate proofing thresholds.

### 5.2 Multiple dungeon floors

Dungeon-floor count is parameterised:

```json
{
  "dungeon_floor_count": 6,
  "floor_shape_policy": "variable",
  "connector_policy": {
    "critical": 1,
    "optional_shortcuts": [0, 2],
    "return_routes": "boss_exit_or_checkpoint"
  }
}
```

Pipeline:

1. Generate a dungeon-floor graph.
2. Assign mission beats to floors.
3. Reserve critical inter-floor connectors.
4. Generate each floor independently from its derived seed.
5. Validate the entire cross-floor progression graph.
6. Load/render one floor at a time, except authored transition vistas.

Separate dungeon floors are not stacked into one giant visual tilemap.

### 5.3 High ground

High ground is not a continuous ballistic simulation.

It produces zone-level properties:

- `high_ground`;
- cover summary;
- target-access modifiers;
- circumstantial Advantage;
- optional wind or unstable-footing EDM;
- movement cost through the connecting portal.

Line of sight remains a baked or rule-derived property. Combat does not raycast through every sprite pixel.

### 5.4 Falling and destruction

A destructible bridge or floor has explicit states:

```text
intact → damaged → collapsed
```

Each state defines:

- walk-surface cells enabled;
- portal edges enabled;
- zone adjacency changes;
- cover changes;
- surface transfer;
- render variant;
- safe landing or forbidden fall cells.

No collapse is allowed to create an unplanned critical-path soft lock.

---

## 6. Revised full dungeon generation pipeline

### Stage 1 — Brief and seed namespace

Inputs:

- region and Triade axis;
- dungeon archetype;
- delve depth;
- dungeon-floor count;
- room budget;
- local verticality quota;
- mission beats;
- encounter and affordance budgets;
- visual palette;
- generator version.

Outputs:

- immutable `DungeonBrief`;
- named per-stage seeds.

### Stage 2 — Mission graph

Generate and prove:

- entry;
- mandatory objectives;
- keys and locks;
- optional branches;
- boss;
- exit/checkpoint;
- cross-floor dependencies.

No tile generation occurs yet.

### Stage 3 — Dungeon-floor graph

Assign mission nodes across `N` dungeon floors.

Constraints:

- critical connector count;
- backtracking budget;
- floor transition frequency;
- safe boss return;
- no key placed below its own lock;
- optional shortcuts open only after their intended objective.

### Stage 4 — Room graph per floor

Create room nodes and corridor edges.

Each room declares:

- semantic type;
- axis bias;
- combat/non-combat role;
- expected zone count;
- vertical profile;
- connector sockets;
- furnishing grammar;
- surface budget.

### Stage 5 — Structural embedding

Embed rooms and corridors on a 2D square lattice.

Reserve:

- critical path;
- portals;
- boss shell;
- composite-room footprints;
- camera-safe margins;
- set-piece masks.

### Stage 6 — Walk-surface construction

For each room:

1. create lower walk-surface mask;
2. instantiate approved vertical macro if required;
3. create upper surface mask;
4. reserve portals and supports;
5. reject screen-space overlap that fails readability constraints.

### Stage 7 — Layered Model Synthesis/WFC

Run structural WFC per walk surface.

Then run:

- support constraints;
- facade synthesis;
- railing and edge synthesis;
- connector completion;
- decoration WFC.

Contradictions repair only the offending room/sub-seed where possible.

### Stage 8 — Progression proof before furnishing

Validate:

- all mission paths;
- cross-floor paths;
- vertical portal endpoints;
- no unintended vault/jump bypass;
- boss exit;
- local and global reachability.

### Stage 9 — Furnishing and combat objects

Use semantic sockets and path guards.

Objects may provide:

- half/full cover;
- push/topple;
- break;
- ignite;
- corrode;
- climb/vault;
- environmental combo-action sources.

All object states are proofed.

### Stage 10 — Surface initialisation

Initialise sparse integer surface channels.

Vertical propagation uses explicit transfer edges:

- liquid down drains/drop edges;
- smoke/heat up vent/open-shaft edges;
- electricity across conductive portal/structure edges;
- no generic propagation between screen-overlapping layers.

### Stage 11 — Zone extraction

Seed zones at:

- chokepoints;
- elevation bands;
- major cover clusters;
- vertical portal landings.

Merge to two to four zones across the whole room.

A two-level room might bake as:

```text
Lower Hall ── Stair Landing ── Raised Gallery
    │                                  │
Muddy Gate ───────────────────── Broken Walkway
```

The simulation consumes this graph only.

### Stage 12 — Render bake

Generate:

- TileMap layers or equivalent;
- render pivots and Y-sort origins;
- z/elevation bands;
- occlusion polygons;
- cutaway masks;
- collision/navigation polygons;
- actor/prop sorting groups;
- floor visibility groups.

### Stage 13 — Proofing and simulation

Run deterministic validation, encounter simulation, camera tests, and expressive-range metrics.

### Stage 14 — Package

Output:

- seed and generator version;
- room and mission graphs;
- walk-surface cells;
- vertical portals;
- props and surfaces;
- zone overlay;
- render package;
- proof report;
- determinism digest.

---

## 7. Separate 2.5D tile-generation module

### 7.1 Tile ontology

A “tile” is a content package, not only an image.

Required categories:

1. **Surface tile** — walkable floor.
2. **Boundary tile** — wall top, railing, cliff lip.
3. **Facade tile** — visible vertical face below a height edge.
4. **Support tile** — pillar, arch, wall support.
5. **Connector tile** — stairs, ladder, ramp, hatch.
6. **Occluder tile** — roof, foreground wall, canopy.
7. **Socket tile** — reserves a prop or affordance placement.
8. **Composite macro tile** — multi-cell authored arrangement.
9. **Stateful tile** — intact/cracked/broken, dry/wet/frozen, open/closed.

### 7.2 Tile concept brief

Human or agent produces a schema-valid brief:

```json
{
  "concept_id": "pressure_marches_stone_gallery",
  "projection": "fixed_dimetric",
  "logical_footprint": [1, 1],
  "elevation_band": 1,
  "material": "stone",
  "mechanic_roles": ["walk_surface", "high_ground", "railing_edge"],
  "required_states": ["intact", "cracked", "collapsed"],
  "lighting_direction": "upper_left",
  "palette_id": "pressure_marches_v1",
  "camera_view": "primary",
  "symmetry": "rotate_180_only"
}
```

### 7.3 Graphical production pipeline

1. **Concept generation**  
   Mood boards, silhouettes, material studies, and state sheets. Agentic image generation may be used here only as concept support.

2. **Projection lock**  
   Apply the project camera matrix, tile dimensions, pixels-per-unit, light direction, and elevation step.

3. **Source construction**  
   Create the tile from vector art, 2D paint, procedural geometry, or low-poly 3D.

4. **Orthographic bake**  
   Bake base colour, normal map if used, material mask, emission, shadow/caster mask, and cutaway mask.

5. **Atlas normalisation**  
   Snap footprint, crop bounds, pivot, render origin, and texture padding.

6. **State generation**  
   Produce intact/cracked/fractured/broken and relevant surface states from the same source asset.

7. **Semantic metadata**  
   Add collision, navigation, occlusion, WFC sockets, material, surface capacities, affordances, and zone contribution.

8. **Adjacency test matrix**  
   Render every permitted neighbour pair and every rotation/alternative.

9. **Scene test**  
   Place the tile in reference rooms with actors, props, lighting, surfaces, and cutaways.

10. **Batch proof**  
    Automated projection, seam, sorting, collision, navigation, and metadata checks.

11. **Human gate**  
    Art director or World Steward approves the family, not every random arrangement.

12. **Publish**  
    Versioned tile family enters the palette registry.

### 7.4 Why direct AI-to-tile export is rejected

Generative images do not reliably preserve:

- exact projection;
- footprint;
- edge continuity;
- pivot;
- light direction;
- state correspondence;
- collision;
- occlusion;
- semantic sockets;
- material identity;
- deterministic style.

Agents may generate concepts and structured variants. A deterministic bake and proof pipeline creates game-ready assets.

### 7.5 Required tile metadata

```json
{
  "tile_id": "stone_gallery_edge_n_a",
  "family": "stone_gallery_edge",
  "projection_id": "dimetric_main_v1",
  "footprint": [1, 1],
  "walk_surface_layer": 1,
  "elevation_band": 1,
  "render": {
    "atlas": "pressure_tiles_v1",
    "region": [256, 128, 128, 128],
    "pivot": [64, 96],
    "y_sort_origin": 88,
    "z_group": "upper_surface",
    "cutaway_group": "room_occupancy",
    "occlusion_mask": "gallery_edge_n_occ"
  },
  "physics": {
    "collision_shape": "gallery_edge_n_col",
    "navigation_shape": "gallery_edge_n_nav"
  },
  "wfc": {
    "north": ["open", "railing"],
    "east": ["gallery"],
    "south": ["gallery"],
    "west": ["gallery"],
    "support_down": ["solid", "pillar"],
    "clearance_up": ["open"]
  },
  "gameplay": {
    "walkable": true,
    "cover_grade": "half",
    "material": "stone",
    "surface_capacity": {
      "wetness": 90,
      "heat": 51,
      "corrosion": 26
    }
  },
  "states": {
    "cracked": "stone_gallery_edge_n_cracked",
    "collapsed": "stone_gallery_edge_n_collapsed"
  }
}
```

---

## 8. Camera, occlusion, and readability proofing

### 8.1 Cutaway policy

When an upper structure obscures a relevant lower structure:

- fade or hide the occluding roof/foreground wall;
- preserve edge outlines so the room shape remains legible;
- never hide active combatants, telegraphs, portals, or mission-critical interactables;
- restore occluders with hysteresis to prevent flicker.

Visibility is driven by room/zone membership, not by raw sprite overlap alone.

### 8.2 Multi-level room policy

When the player is on the lower level:

- upper floors remain visible where they communicate high-ground threats;
- visually obstructive upper tiles become translucent or cut away;
- upper actors retain strong silhouettes and ground/contact shadows.

When the player is on the upper level:

- lower level is darkened or de-emphasised;
- active threats and public Openings remain readable;
- portal endpoints stay highlighted.

### 8.3 Visual hard-fail tests

A room fails if:

- an active actor is hidden behind static art;
- an enemy posture telegraph cannot be read;
- a Commander wind-up is obscured;
- a portal endpoint is visually ambiguous;
- two actors on different elevations appear to occupy the same space without a depth cue;
- a usable object cannot be selected deterministically;
- a cutaway reveals invalid void or missing facade art;
- Y-sort order changes incorrectly as an actor crosses a tile boundary;
- a destruction state produces a render/collision mismatch.

---

## 9. Triade mechanics integration

### 9.1 Environmental influences

Tile and object metadata may emit local EDM or temporary effective-field modifiers, as already defined.

2.5D adds one rule:

> **Vertical propagation and vertical influence require an authored transfer edge.**

Examples:

- wind across an exposed gallery;
- smoke rising through an open shaft;
- water falling through a broken floor;
- heat rising through a vent;
- corrosion dripping to a lower walk surface.

### 9.2 Combat objects

Objects retain smart slots and explicit combat roles.

2.5D-specific fields:

- walk-surface layer;
- elevation band;
- render pivot;
- occlusion group;
- upper/lower interaction reach;
- fall/topple target layer;
- post-destruction facade and cutaway state.

### 9.3 Zone extraction

Zone extraction remains the bridge to combat.

For stacked rooms:

- elevation changes seed zones;
- portals create adjacency;
- upper and lower surfaces do not automatically become separate zones if the room can remain legible within the 2–4-zone cap;
- a stair landing may be merged into a neighbouring zone unless it carries tactical meaning;
- `complex_room` is exceptional, not a loophole for arbitrary zone growth.

### 9.4 Environmental combo actions

The existing skill source list permits `environment`.

A 2.5D environment source is exposed through an affordance slot:

```json
{
  "source_kind": "environment",
  "source_id": "hanging_brazier_03",
  "walk_surface_layer": 1,
  "target_layers": [0, 1],
  "actions": ["cut_drop", "ignite_spill"]
}
```

The action still resolves through the locked action contract and zone graph.

---

## 10. Agentic and human authoring

### 10.1 Revised roster

| Role | Owns | Authority |
|---|---|---|
| **World Steward** | grammar, region identity, schemas, vocabulary | human-only |
| **Projection Steward** | camera matrix, tile projection, light direction, elevation step, render ordering | human-only |
| **Dungeon Smith** | mission and dungeon-floor graphs | agent proposal |
| **Room Smith** | room graph, composite macro selection | agent proposal |
| **Surface Layout Smith** | walk-surface masks and reservations | agent proposal |
| **Tile Semantic Smith** | sockets, materials, affordances, state metadata | agent proposal |
| **Visual Tile Smith** | concept sheets and source-asset variants | agent-assisted |
| **Batch Renderer** | deterministic atlas bake | tool, not generative agent |
| **Adjacency Auditor** | WFC compatibility matrix | deterministic verifier |
| **Occlusion Auditor** | cutaway, sorting, silhouette tests | deterministic verifier |
| **Map Proofing Auditor** | final location proof report | independent agent plus CI |

No agent may alter:

- camera projection;
- tile dimensions;
- elevation step;
- render-layer ordering;
- mission connectivity;
- RNG implementation;
- combat zone rules;
- Triade vocabulary.

### 10.2 Human authoring surfaces

Humans author at four levels:

1. **Intent:** region, axis, room fantasy, set-piece purpose.
2. **Grammar:** approved macros, tile families, portal types.
3. **Exemplars:** small positive/negative example maps for Model Synthesis.
4. **Exceptions:** boss shells, landmarks, complex rooms.

Humans do not hand-place routine decoration across every generated dungeon.

### 10.3 Mixed-initiative correction

A designer may:

- pin cells or macros;
- forbid a tile family;
- reserve a portal;
- redraw a walk-surface mask;
- mark an occlusion failure;
- accept/reject a generated family;
- regenerate only the offending room or pass.

All edits are stored as constraints or deltas, not as untracked manual scene changes.

---

## 11. Revised proofing suite

### 11.1 Critical gameplay proofs

- mission graph solvable;
- every dungeon floor reachable in intended order;
- all critical vertical portals reachable;
- no lock bypass through climb, vault, drop, or destruction;
- no object or tile state blocks the only critical route;
- boss exit reachable;
- same seed and generator version reproduce the same digest;
- zone overlay valid;
- surfaces never alter baseline Triade geometry;
- multi-level rooms remain within zone-count policy.

### 11.2 Critical 2.5D render proofs

- every walkable cell has a valid rendered surface;
- every exposed elevation edge has a facade or intentional void treatment;
- every portal has visually matched endpoints;
- collision/navigation/render states agree;
- no active actor or telegraph is fully occluded;
- cutaway state is deterministic;
- Y-sort ordering is stable;
- every destruction state has matching art and topology;
- screen-space selection resolves to one intended target.

### 11.3 High proofs

- upper/lower floor visual contrast in band;
- portal cue visibility;
- camera-safe margin maintained;
- no excessive translucent overlap;
- high-ground zones visually read as high ground;
- ranged encounters have readable cover;
- off-mesh links have safe endpoints;
- surface transfer edges are bounded;
- tile family adjacency coverage exceeds target threshold.

### 11.4 Metrics

Add to existing metrics:

- local elevation-band count;
- stacked-room frequency;
- vertical portal frequency;
- average cross-layer movement cost;
- actor-occlusion rate;
- telegraph visibility rate;
- cutaway activation frequency;
- depth-order error count;
- screen-space target ambiguity count;
- facade completeness;
- tile adjacency coverage;
- WFC contradiction rate per pass;
- repair rate per room;
- vertical surface-transfer count.

---

## 12. Implementation roadmap

### Phase 0 — Projection foundation

Deliver:

- fixed camera matrix;
- logical-to-screen transform;
- tile dimensions;
- elevation step;
- Y-sort and z-layer rules;
- cutaway prototype;
- one actor posture prototype.

Gate:

- posture and enemy telegraph readable in under the project target;
- no sort failures in a two-level test room.

### Phase 1 — Single-surface dungeon

Deliver:

- mission graph;
- room graph;
- 2D WFC structural pass;
- zone extraction;
- basic tile pipeline;
- deterministic proofing.

Gate:

- 10,000 seeds, zero Critical gameplay failures.

### Phase 2 — Local verticality

Deliver:

- two walk-surface layers;
- stairs, ladder, bridge;
- composite room macros;
- support/facade synthesis;
- vertical portal graph;
- cutaway and occlusion proofing.

Gate:

- zero Critical render failures in the reference vertical-room suite.

### Phase 3 — Affordances and destruction

Deliver:

- push/topple/break;
- bridge/floor collapse;
- post-state zone rebuild;
- stateful tile art.

Gate:

- all plausible destruction states remain valid or intentionally terminal.

### Phase 4 — Surfaces across elevation

Deliver:

- explicit vertical transfer edges;
- smoke rise, liquid fall, conductivity cases;
- bounded nav updates.

Gate:

- deterministic surface propagation and no accidental cross-layer leakage.

### Phase 5 — Multi-floor dungeons

Deliver:

- parameterised dungeon-floor graph;
- floor-specific seeds;
- inter-floor lock/key proofing;
- transition scenes;
- persistence and replay.

Gate:

- complete run simulations across target floor-count distributions.

### Phase 6 — Agentic bulk tile authoring

Deliver:

- concept brief generator;
- semantic metadata generator;
- deterministic batch bake;
- adjacency and occlusion auditors;
- human family-level approval.

Gate:

- accepted tile families meet projection, semantic, and adjacency quality thresholds.

---

## 13. Required cross-document amendments

### 13.1 Visual Design V2

Replace the current graphical recommendation with:

> **Triade uses a fixed-camera 2.5D presentation. The simulation and world substrate are 2D with discrete elevation bands and sparse stacked walk surfaces. Environments are rendered through isometric/dimetric tile layers. Characters use 2D skeletal animation, pre-rendered directional animation, or low-poly 3D under an orthographic camera. Continuous camera rotation is not part of the base design.**

### 13.2 Visual Design V5

Add:

- orthographic batch-render pipeline;
- sprite atlas and normal/mask bake;
- Y-sort and cutaway test scenes;
- elevation/facade preview;
- screen-space selection debugger;
- occlusion proof visualiser.

### 13.3 World coordinate section

Clarify:

> `tz` is a sparse walk-surface layer index. It is not a filled voxel dimension. `elevation` is the discrete physical/render height band. Separate dungeon floors are separate generated bundles linked in the dungeon-floor graph.

### 13.4 Tile schema

Add or reference archetype-level fields:

- projection ID;
- render pivot;
- Y-sort origin;
- z group;
- cutaway group;
- occlusion polygon;
- facade requirement;
- support/clearance sockets;
- state variants.

### 13.5 Lexicon additions

Provisional:

- **[Walk Surface]**
- **[Elevation Band]**
- **[Vertical Portal]**
- **[Composite Room]**
- **Layered Constrained Model Synthesis**
- **Projection Steward**

---

## 14. Final recommendation

Adopt the revision.

The best-fit dungeon builder for Triade under 2.5D is **not** a voxel dungeon generator that happens to be viewed isometrically. It is a hierarchical graph-and-surface generator:

1. mission topology;
2. dungeon-floor topology;
3. room topology;
4. sparse walk surfaces;
5. constrained elevation macros;
6. per-layer Model Synthesis/WFC;
7. explicit vertical portals;
8. semantic furnishing and surfaces;
9. zone extraction;
10. gameplay, render, and camera proofing.

This preserves the strongest parts of the existing World design and aligns them with the locked combat abstraction. It also makes verticality cheaper, more legible, more deterministic, and more authorable than a full 3D WFC volume.

---

## 15. Research basis

Project sources:

- Triade Roguelike — World, Maps & Dungeons Design Plan v0.9.0.
- Triade — Core Systems Design v0.9.0.
- Combat Design v0.9.0.
- Visual Design v0.9.0.
- Character Stats, Itemisation & Equipment Design Plan v0.9.0.
- Project Lexicon v0.9.0.

External primary and official sources:

- Paul Merrell, *Example-Based Model Synthesis* and *Model Synthesis*.
- Maxim Gumin, *WaveFunctionCollapse* reference implementation and documentation.
- Isaac Karth and Adam M. Smith, *WaveFunctionCollapse is Constraint Solving in the Wild*.
- Godot Engine official documentation: TileSet, TileMapLayer, isometric tile shape, Y-sorting, custom data, navigation, occlusion, 2D lighting, and NavigationLink2D.

