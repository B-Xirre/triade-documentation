# Triade — Core Systems Design

**Version 0.44.0** — 27 September 2026. Supersedes the first draft. The Triade has absorbed the state model, the credit economy, the class model and the enemy model, because all four turned out to be the same geometry viewed from different angles.

**Document set:** this is one of **ten**.

| Ref | Document | Filename |
| --- | --- | --- |
| **T** | **Core Mechanic** — *this document* | `T-Core_Mechanic_design_TRIADE-0_44_0.md` |
| **M** | Stats, Items, Equipment | `M-Stats_Items_Equipment_design_TRIADE-0_44_0.md` |
| **L** | Lexicon | `L-Lexicon_design_TRIADE-0_44_0.md` |
| **V** | Visual Design | `V-Visual_design_TRIADE-0_44_0.md` |
| **K** | Combat Design | `K-Combat_design_TRIADE-0_44_0.md` |
| **W** | World, Maps & Dungeons | `W-World_Generation_design_TRIADE-0_44_0.md` |
| **H** | Damage & Health | `H-Damage_Health_design_TRIADE-0_44_0.md` |
| **E** | Enemies & Bestiary | `E-Enemies_design_TRIADE-0_44_0.md` |
| **G** | Tile Pipeline | `G-Tile_Pipeline_design_TRIADE-0_44_0.md` |
| **P** | **Content Pipeline & Data Model** | `P-Content_Pipeline_design_TRIADE-0_44_0.md` |

**Position in the project:** Phase 0.5, upstream of stats, itemisation and equipment. Nothing in the main plan's Parts 1–3 can freeze until Gate T passes.

**Status:** Parts A–H settled. Dot Framework (A2), grid + Interpreter (A3), and stat-groups + field-rendered floor (A4) added. Skill Anchors (A3.7–A3.8) resolve the grid–math question; the skill system is complete in shape.

---

## Part A — State model

### A.1 Position

Combat state is a single point in a triangle. The three coordinates are **barycentric** and always sum to 1.

```
P = (m, f, i)      m = Momentum, f = Form, i = Mind
m + f + i = 1
```

Position is **stance** — what the character is leaning into right now. It is zero-sum by construction: leaning into one corner necessarily costs the others. This is the property the entire design rests on and it is not negotiable. The dot's *bearing* is this position; how it *moves* is the Dot Framework (Part A2).

The three corners:

| Corner | Represents | Reads as | Consumption verb |
| --- | --- | --- | --- |
| **Momentum** | tempo, right now | AP cost modifier on physical actions; combo continuation | continuous — spent by acting |
| **Form** | structure, defence | damage mitigation; conversion of defence into openings | continuous — spent by holding |
| **Mind** | control, leverage | availability gate and potency scalar for mind skills | threshold — gates access |

Representation is uniform; **consumption is what differs**. That asymmetry is deliberate and keeps this one system rather than three.

The triangle is also deliberately asymmetric in economic terms: Momentum is the primary credit generator, Mind the primary consumer, Form the stabiliser. Do not "fix" this in the name of elegance — it is what prevents any single corner becoming a self-sustaining loop.

### A.2 Floors

Each corner has a hard minimum below which it cannot fall. Floors are **class-determined at run start** and define a smaller, reachable inner triangle.

```
F = (F_m, F_f, F_i)
ΣF ≤ 0.45                  total floor budget
F_x ≤ 0.25   for all x     per-corner cap
```

Two properties follow from the geometry and are load-bearing:

**A high floor in corner X blocks the region opposite X.** One-to-one mapping, no special-case rules. Floor shape is therefore directly legible as a statement about which advanced techniques a character can reach.

**The per-corner cap of 0.25 guarantees no total lockout.** At 0.30 the opposite region becomes geometrically unreachable. At 0.25 it remains reachable through a narrow window. Worked example — a mage at `F = (0.10, 0.10, 0.25)` attempting Pressure (requires `m ≥ 0.35`, `f ≥ 0.35`, therefore `i ≤ 0.30`): the viable window is `i ∈ [0.25, 0.30]`, with Momentum and Form each squeezed into roughly `[0.35, 0.40]`. Possible, precise, unstable. Exactly "hard, not forbidden."

The cap is therefore not a tuning value. It is the constraint that keeps difficulty from becoming exclusion.

### A.3 Regions

The three inner regions are **derived, not tracked**. They are areas of the same simplex, located at the edge midpoints — the medial triangle. Being "in Instinct" is a readout of the position already being tracked, not a fourth quantity.

Membership requires a single threshold:

```
T = 0.35

Instinct    m ≥ T and i ≥ T      (Momentum ↔ Mind, low Form)
Pressure    m ≥ T and f ≥ T      (Momentum ↔ Form, low Mind)
Discipline  i ≥ T and f ≥ T      (Mind ↔ Form,     low Momentum)
```

No second condition is needed. In a zero-sum simplex, two coordinates at 0.35 force the third to 0.30 or below automatically.

Constraints on T:

```
T > 1/3                     or the balanced centroid qualifies for everything
T ≤ (1 − F_opposite) / 2    or the region is unreachable under legal floors
```

At the locked cap of `F_x ≤ 0.25` the viable band is `0.333 < T ≤ 0.375`. **T = 0.35** sits comfortably inside it.

**Regions are defined in absolute simplex coordinates and are identical for every character.** Class changes which part of the triangle is reachable and where neutral sits; it never moves the regions themselves. This preserves the property that a player can read the dot and know what it means, always.

The centre qualifies for no region. A character sitting balanced can use generic actions only — this is correct and intended. Advanced techniques require commitment, and commitment means giving something up.

### A.4 What is not tracked

Earlier drafts carried a separate `charge` scalar alongside position. It has been absorbed into the credit economy (Part B). **Charge** survives only as a derived readout — aggregate credit state, dominated by the Grit layer — used in metrics such as `recovery rate from low charge`.

Total tracked combat state per combatant: **three position coordinates plus three credit counters.** Six numbers, three of which are small integers. The Dot Framework (Part A2) adds no tracked variables at level 1 — forces are recomputed at each evaluation tick from what is currently active — with the single exception of the optional [Dot Dynamics] velocity property, carried only by combatants a source has imparted it to.

---

## Part A2 — The Dot Framework

**Terminology.** Three words that never collide:

- **Momentum** — only ever the corner (a stance). Never motion.
- **[Dot Framework]** — the umbrella system in this Part: the home-well, the influence pipeline, and the rules that turn summed influences into dot movement.
- **[Dot Dynamics]** — the *momentum-of-motion* specifically: carried velocity that makes the dot overshoot. An opt-in property a source may impart, not a global rule.

### A2.1 From assignment to forces

The dot is not a value actions *set*; it is a body actions *push*. Where the dot goes is the **sum of every influence currently acting on it**, integrated over elapsed **`world_tick`** — *not per turn: a turn is no longer a unit of time, since actors at different AP rates cross a 60-tick band at different counts* (**K-C11**). This reframes displacement from teleportation to forces, and it unifies what would otherwise be three separate systems — actions, conditions, and terrain/enemy-effects — into one mechanic with three origins.

| Origin | Source | Typical mode |
| --- | --- | --- |
| **[ADM]** active dot motion | the character's own skills, actions, movement | impulse |
| **[CDM]** condition dot motion | conditions on the character ([Blinded], [Poisoned], [Stunned], [Fed], [Thirsty], …) | force |
| **[EDM]** extrinsic dot motion | enemy actions and skills; environment ([Rain], [Muddy Terrain], …) | force |

ADM/CDM/EDM are not three systems — they are three *origins* of one object: a vector on the dot. This is where the deferred condition layer (former open question 10) lives: a condition is simply a CDM influence.

### A2.2 The model: force + well, inertia optional

The engine is **B+D with C localised**:

- **(D) Home-well.** The class home position sits at the bottom of a potential well; the dot is always gently pulled toward it. Decay-toward-home is therefore not a special rule — it is the well's standing pull, always on. Decay-resistance stats become **well depth**; floors are the well's **walls**.
- **(B) Forces and impulses.** Every influence is a **force** (a sustained push while its source is active) or an **impulse** (a one-shot jump). Terrain and conditions are usually forces — fields the dot moves through; actions are usually impulses on top.
- **(C, localised) [Dot Dynamics].** By default the dot **settles as its influences decay** — no carried velocity, and no per-turn settling step. A source may optionally impart [Dot Dynamics]: carried velocity that makes the dot overshoot and coast, countered rather than instantly reversed. This is reserved for moments where overshoot is the *point* — a committed heavy lunge — so the readability cost of a moving-and-oscillating dot is localised, not paid by every combatant continuously.

**Armour engages this layer (materiel Bridge 2 — see main plan 2A.7).** Armour's core Triade relationship is *positional*, and the **four** weight classes use four different engagements: Heavy damps incoming **[EDM]** force, Light strengthens the **home-well**, **Medium adds a second well at the barycentre**, Cloth engages none. **[Dot Dynamics] is engaged by no armour class** — it stays with actions (K·17). [PROPAGATED 0.25.0 from M·2A.7].

### A2.3 Tick resolution

One pipeline, no special cases:

```
1. gather all active influences on the combatant   (ADM impulses, CDM/EDM forces, well pull)
2. sum the forces
3. apply the impulses
4. integrate one step   (carry [Dot Dynamics] velocity only where a source imparted it)
5. clamp to the floor-well   (walls at the floors; home-pull at the centre)
```

At level 1, **influences sum linearly.** Muddy terrain + poisoned + your own action = vector addition, nothing more — exploit-free and predictable. Non-linear interaction between influences (one source dampening or amplifying another) is deferred to level 2 (see A2.5).

### A2.4 The influence schema and the zero-sum rule

Every action, condition, terrain tile and enemy effect carries concrete vector data, all under one schema:

```
influence: {
  origin: adm | cdm | edm,
  mode: impulse | force,
  vector: (dm, df, di),                 // MUST sum to zero (see below)
  duration: instant | n_ticks | while_active,     // world_tick, never turns
  dynamics: 0.0 | small | ...,          // optional carried velocity ([Dot Dynamics]); default 0
  conditional_on: null | { predicate }  // e.g. only while dot is in region X
}
```

**Hard rule — all dot vectors are zero-sum.** The dot is constrained to `m + f + i = 1`, so any vector must be *tangent* to that constraint: `dm + df + di = 0`, or it pushes the dot off the simplex. "A force toward Momentum" is therefore never `(+1, 0, 0)` but something like `(+1, −0.5, −0.5)` — gaining Momentum *must* cost the other two. This is a feature: every influence is inherently a tradeoff, on-brand for the zero-sum design. **The linter rejects any influence whose vector does not sum to zero.** Because level-1 influences sum linearly, a sum of zero-sum vectors stays zero-sum, so the invariant holds automatically for now.

### A2.5 What this consolidates, and what is parked

**Consolidates (a net simplification):**

- deletes the decay special case → it is now just the well,
- absorbs the condition layer → conditions are CDM influences,
- unifies actions, conditions, terrain and enemy effects → one `influence` schema.

Enhancements that remove concepts while adding capability are the good kind; this is one.

**Parked for level 2:**

- **Non-linear influence interaction** — sources dampening or amplifying each other ([Wet] amplifying [Cold]; [Braced] dampening incoming EDM). Note the coupling: the moment amplification exists, the zero-sum invariant (A2.4) must be re-checked, since an amplified vector may not stay zero-sum. Level 2 revisits both together.

---

## Part A3 — The grid and the Dot Interpreter

The backend runs on continuous barycentric coordinates. Players do not. This Part defines the **grid** — a discretised coordinate system over the reachable triangle — and the **[Dot Interpreter]**, the read-only system that narrates a dot's grid position to the player in world-language.

**Separation of concerns, locked:**

- The **grid** is a coordinate system. Whether and how it feeds backend math is *out of scope here* and deferred to skills & stats design (A3.5).
- The **[Dot Interpreter]** is a *narrator*. It reads position and speaks it; it never touches math. The player-facing description must never feed back into the simulation — that would make how a thing is *described* change how it *behaves*.

### A3.1 The grid

Twelve **spokes** radiate from the centroid to boundary landmarks, and three **rings** divide depth. The spokes are anchored to geometric truths on the triangle boundary, not to fixed angles, so their labels stay honest on an asymmetric (class-shaped) floor:

- **3 corner spokes** → the vertices (Mo, Fo, Mi) — pure single-stance leans.
- **3 region spokes** → the edge midpoints (In, Pr, Di) — the medial-triangle region centres.
- **6 transition spokes** → the edge quarter-points — the leans between an adjacent corner and region.

The three **rings** are nested scaled copies of the triangle outline (their vertices sit on the spokes), so ring bands **deform to the floor shape** rather than being circular. Ring 1 is nearest Composure, ring 3 nearest the floor wall.

This yields **12 sectors × 3 rings = 36 cells**, plus **Composure** (the central undivided polygon) = **37 addresses**.

**Reachability is class-dependent.** The floor shape clips the grid: some outer cells — especially corner cells near a vertex — lie beyond a class's reachable region and can never be occupied. The grid is universal; which cells a class can occupy is a legible readout of that class's limits.

### A3.2 Backend naming convention

Sectors are named clockwise, each `[landmark]` or `[landmark][landmark]` in wheel order:

```
Mo → MoIn → In → MiIn → Mi → MiDi → Di → FoDi → Fo → FoPr → Pr → MoPr → (Mo)
```

Compound (transition) names are always `[preceding landmark][following landmark]` in clockwise order, so a transition has exactly one name (never both `MoIn` and `InMo`). Two-letter camel, no separator.

**Address form:** `Sector/Ring`, e.g. `FoDi/2` (between Form and Discipline, two rings deep), `In/3` (deep Instinct), `Mo/1` (barely leaning Momentum). **Composure** has no ring number.

These are *backend* labels — machine-readable, sortable, linter-friendly. They are not what the player sees; translating them into world-language is the Interpreter's job (A3.4).

### A3.3 Landmark cells vs transition cells

The six **landmark columns** (the corner and region spokes) are *destinations*; the six **transition columns** (the intercardinals) are *transits* passed through while moving between landmarks. This asymmetry is meaningful: landmark cells are where the design hangs meaning; transition cells are movement between meanings.

### A3.4 The Dot Interpreter (read-only)

The Interpreter observes the dot's state and renders it to the player — the layer that makes the backend *felt* rather than *computed*. It is read-only: it reads, it narrates, it changes nothing. Its governing principle is that it narrates **stance, trajectory, affordance and events — never numbers.** A player should be able to play fluently having never seen a barycentric coordinate.

**Two channels, split by timescale.** State is continuous and belongs to the senses; events are discrete and belong to language.

- **Ambient channel** — character posture/animation, sound cues. Continuous, wordless, present-tense. Carries **stance** (which way you lean), **trajectory** (where you're drifting), **exposure** (how overextended). No radar chart is shown; the character's body *is* the state display. A sound cue may ping when a threshold is crossed (a deep skill opens, or you're ejected).
- **Log channel** — legible past-tense prose, event-driven. Carries **what just happened**: the resolved outcome of each action, in plain language.

Example log lines:
> *You try to stun the Goblin Pikeman with Shield Bash. The Pikeman avoids your attack, leaving you open for a counter.*
> *Your Riposte critically strikes for 5 damage and leaves the Goblin Pikeman stunned.*

**Log editorial policy — "narrate what a player needs to explain their situation to themselves."** The log speaks when: an **action resolves** (yours or an enemy's); a **relational state changes** consequentially ([Opening]/[Advantage]/[Back-foot], narrated as "you're open for a counter," not as a status tag); an **affordance opens or closes** the player was reaching for; a **condition lands or clears**. It stays **silent** on raw coordinate drift (the body shows that), credit accrual (unless a threshold is crossed), and anything ambient already conveys. It is events and consequences to reason about, not a telemetry feed.

**Cause-narration rule.** When a state change is *not* the player's own doing, the log explains *why* — "the Pikeman's pressure drives you back on your heels" — so a pushed-dot ([EDM]) affordance loss is never a mystery. The player must always be able to trace why their options changed.

**Affordance lives in the UI, not the prose.** Which skills are currently castable is shown by the **skill bar lighting up / greying out** as the dot moves — not narrated. This keeps the log from cluttering with "you could now…". Roles stay clean: ambient *hints* (a sound when access changes), skill UI *shows* (which skills are lit), log *explains* (why something closed).

### A3.4a The Dictionary

The log must read as narrative, not "you hit for 5" repeated. The **Dictionary** is structured data the Interpreter *composes* sentences from — a grammar, not a phrasebook. The backend emits a mechanical event (`actor, action, target, outcome, consequences`); the Interpreter looks up each element and composes a line from **fragments**, each slot having many weighted fragments so the same event reads freshly each time.

*"Your Riposte critically strikes for 5 damage and leaves the Goblin Pikeman stunned"* composes from a verb fragment (`Riposte + crit-success`), a target reference (Goblin Pikeman), and a consequence clause (`applied [Stunned]`) — each drawn from a pool, so the next crit-riposte reads *"Your blade finds the gap — the Pikeman reels, stunned."*

**Four parts:**

1. **General language (mechanical grammar)** — keyed on generic events, content-independent: outcome verbs (success/failure/crit/partial pools); magnitude modifiers (a "glancing 2" vs a "crushing 40"); **relational-state clauses** (the plain-language faces of Opening/Advantage/Back-foot); causation connectives (the "why" glue); tempo/register words.
2. **Lore-specific (world vocabulary)** — keyed on entities: enemy/race lexicon (names, epithets, characteristic verbs — a [Compulsive] enemy draws aggressive verbs, tying voice to Behaviour tags for free); terrain/tile lexicon (how [Muddy Terrain], [Slippery] narrate when they act via [EDM]); weapon/gear lexicon (same skill reads differently by weapon); faction/Territory flavour.
3. **Mechanics-to-story (the heart)** — keyed on specific mechanics: skill narration (per skill, per outcome, per level — ⌬L3's Create Opening reads as "the gap yawns wide"); dot-state translation (stance-as-posture language); condition narration (entry/exit fiction per buff/debuff); the rare credit/economy events that surface (a charging Signature Action: "the creature's fury is building"); threshold/affordance moments.
4. **Tone profiles** — a selector, not content, in **two layers**:
   - **Base tone** — the campaign/scene register (grim / heroic / clinical / pulpy), set by context. Slow.
   - **Momentary tone** — a live modifier driven by *fight state*, biasing fragment weights on top of the base: grim near death (low HP), heroic on a clutch reversal (a crit that turns or ends a fight), desperate when overwhelmed, clinical in routine exchanges. Fast, event-driven.

   Momentary tone reads the **same signals already computed** — HP fraction, winning/losing the exchange (credit trajectory, [Back-foot] vs [Advantage]), decisive events (crit, kill, near-death) — so it is a *derived reading*, not new state. Base and momentary **compose**: a grim-base game still lifts heroic on a miracle, but its heroic is grimmer than a pulpy game's, so no two games' triumphant moments sound alike.

   **Hysteresis rule:** momentary tone shifts only on meaningful thresholds and decisive events, and settles back gradually — it must not whipsaw grim/heroic every turn as HP jitters (the same no-oscillation discipline as dynamic Composure). Tone changes should feel *earned*, hence relatively rare. A consequence worth having: because momentary tone tracks winning/losing, the log's *mood* becomes its own ambient legibility channel — a half-attending player feels the fight turn as the language darkens or lifts.

**Hard rule — the Dictionary never invents mechanical claims.** A fragment describes an outcome the backend already decided; it can never introduce an effect the event does not carry. Fragments are pure description of a *resolved* event, downstream of resolution, always. This keeps flavour and mechanics separate (agent-separation principle).

**Agent-ready.** The Dictionary is ideal bulk agentic content — additive fragments with a weak failure mode (a bad fragment reads awkwardly; it cannot break the game). A **Lexicographer** agent (or the extended Namer/Flavourist) bulk-generates fragments per skill/enemy/outcome under the "generate → sample-review 10%" workflow. The one guard is the hard rule above: fragments describe, never decide.

**The Narrator (optional, future).** A read-aloud engine that voices the log. Noted as future work — but the two-channel design already affords it *for free*: the log is clean past-tense prose composed from a controlled Dictionary, not UI-fragment soup, so it is read-aloud-ready by construction, and momentary tone makes a voiced line that darkens near death genuine atmosphere. Keep log prose clean enough to voice regardless, since a read-aloud log is also a meaningful accessibility feature (low-vision players). The Narrator needs no architectural redesign to support — only to be built.

### A3.4b The legibility stack

Three surfaces, clean roles, no overlap:

| Surface | Carries | When |
| --- | --- | --- |
| **Ambient** (posture, sound) | continuous felt state — stance, trajectory, exposure | always, wordless |
| **Log + Dictionary** (prose) | what happened and why | per resolved event |
| **UI inspection** (hover) + skill bar | precise current state list; current affordances | on demand / reactive |

**All states — buffs, debuffs, [Back-foot], [Advantage], [Opening], conditions — are surfaced by UI inspection** (hover over a character or enemy to see the full list). Locked in principle; the specific UI design is a later task. Combined with the skill bar lighting for affordance, this completes the stack: *feel* the state (ambient), *read* what happened (log), *inspect* the specifics (UI).

### A3.4c UI requirements — see Visual Design

The visual encoding requirements have moved to **`V-Visual_design_TRIADE-0_44_0.md` (Part 4)**. Seven requirements are locked there, governed by the principle that *the UI conveys proximity and consequence, never coordinates*.

The two that most affect the mechanics in this document:

- **The two failure modes must look different** (V·4.1, Requirement 1). *Wrong direction* (angular, unavailable) and *under-committed* (radial, weak) must be visually distinct, or the player cannot tell whether to change stance or push deeper — which discards the value of the anchor decomposition in A3.7.
- **Potency must render as a continuous ramp** (V·4.1, Requirement 2). The radial falloff is smooth specifically to avoid boundary-camping; stepped rendering re-introduces the cliff perceptually even though the maths is smooth.

Design rationale for what must be conveyed stays here (A3.4–A3.4b); the encoding spec lives in Visual Design.

### A3.5 Grid–math interaction — resolved

**The rule, locked:**

> **Scaling reads continuous position. Gating may read discrete cells. The grid is the coordinate language for authoring and display.**

This resolves the long-deferred question. The grid is not merely display-only, but neither do cells drive continuous magnitude (which would create boundary cliffs and camping). Skill Anchors (A3.7) are the mechanism that earns the exception: they are *authored* in grid coordinates and *displayed* through the grid, while all falloff math resolves against the underlying continuous position.

Two consequences: the 12-sector resolution and the six transition sectors — previously inert — become mechanically meaningful (A3.7); and per-cell effect tables are rejected outright, since 36 cells × N skills is the same authoring explosion avoided elsewhere.

**Rejected outright, not deferred:** *latched cell effects* (entering a cell latching an encounter-scoped benefit). It duplicates what anchors do, more coarsely, and adds a second positional mechanism competing for the same design space.

### A3.6 Composure sizing

**Composure** — the central undivided polygon — is the neutral zone: near enough to home to count as leaning nowhere, where only generic actions apply. Its size is a real playstyle property (small = twitchy and expressive, every drift commits; large = stable and deliberate, leaving neutral takes real commitment).

**Base size is parametric**, set at character creation from [Character Stats] and [Character Class]: a grounded/defensive build gets a larger Composure, an aggressive/twitchy build a smaller one. One number per character.

**Dynamic influence is permitted but strictly guarded** — never an oscillating target:

1. **Closed, short source list** — only a few enumerated mechanics may resize it, not an emergent sum of everything.
2. **One direction per source, slow** — a source only ever shrinks *or* grows Composure, at a bounded rate, so it drifts rather than snaps. No source reverses direction by condition (that is what creates oscillation).
3. **Bounded band** — dynamic size stays within `[min, max]` around the parametric base; the identity size is the anchor, dynamics a limited excursion.

The candidate worth building first, if any: **Composure shrinks under sustained pressure and recovers as you stabilise** — "losing your center." It obeys all three rules (one source, one direction, bounded, slow). Opt-in and later, not part of the base spec.

Composure sizing is a *simulation* property; the Interpreter may report it ("your center feels narrow") but does not set it — the read-only line holds.

### A3.7 Skill Anchors

Every skill declares an **anchor** — an ideal position, authored in grid coordinates (`anchored at MoIn/2`) — and its effects scale with distance from that anchor, computed on continuous position.

This **completes C.6** rather than competing with it. C.6 locked the principle that "action success checks scale on Triade position" and gave worked examples ("a counter is more reliable from within Discipline") but never specified a formula. An anchor *is* that formula. It also completes the skill model: [Reach Cost] and [Level Requirement] read *depth* only, leaving angular position mechanically inert. Anchors generalise skill positioning from ring-only to ring-plus-sector, which is what finally gives the 12-sector resolution and the six transition sectors a purpose.

**Distance decomposes into two axes, and they mean different things:**

| Axis | Measures | Governs | Behaviour |
| --- | --- | --- | --- |
| **Angular** (sector alignment) | are you leaning the *right way*? | **availability** | **hard cutoff** — beyond the angular window the skill is unavailable |
| **Radial** (ring depth) | how *committed* are you? | **potency** | **falloff, no cutoff** — wrong depth is weak, never impossible |

The decomposition is load-bearing. A single 2D distance loses information: standing at `In/1` when a skill wants `In/3` (right direction, under-committed) is a different failure from standing at `Pr/3` (right depth, wrong direction). The first is *weak but usable*; the second is *not this action at all*. **Wrong direction means no; insufficient depth means weak.**

**Anchors tighten with [Skill Level].** ⌬L1 carries a broad angular window; ⌬L3 a tight one. Deeper mastery demands more precise positioning — so firing the deep version of a skill requires **both** sufficient build (reach meeting its [Level Requirement], A4.7) **and** precise position (clearing the tighter angular window). Build gates the ceiling; position gates the execution. Two different demands, no redundancy.

**Transition sectors carry anchors.** The six intercardinals (`MoIn`, `MiIn`, `MiDi`, `FoDi`, `FoPr`, `MoPr`) are legitimate anchor positions. This is what converts them from decorative transits into destinations, and it is a primary reason to adopt anchors at all.

**Explicitly rejected:** *weapon-shifted anchors* (a weapon altering a skill's anchor) — too much complexity, and a conditional anchor multiplies the validation surface, where a fixed anchor is checkable. The anchor is a property of the **skill**, always.

**Why this avoids the classic failure modes:**

- **No boundary camping** — falloff is smooth, so there is no cliff edge to hug.
- **Denial is telegraphed** — when [EDM] pushes you off an anchor, potency *fades* rather than cutting out, turning a frustrating denial into readable pressure.
- **Authoring is one anchor plus one falloff per skill**, not a 36-cell table.
- **Readability holds** — the player needs *proximity*, not coordinates. The skill bar (the locked affordance surface, A3.4) shows a potency indicator per skill; no coordinates surface.

**Three emergent consequences worth having:**

1. **Falloff width *is* the positional demand tier.** A Broad skill has a wide window; an Exacting one a tight window. The positional tier (main plan 2A.2) becomes mechanically implemented rather than a descriptive label — and is therefore **derived** from `angular_window`, never authored separately, so the two can never contradict. The **Doctrinal** and **Transgressive** flags are *orthogonal* and remain authored: one is a temporal demand (repeated, disciplined use), the other a rule-break marker, and neither maps onto an angular window.
2. **Kit spread becomes a build axis.** Skills anchored close together make a positionally efficient but predictable build; a spread kit forces traversal to use it. That feeds straight into the traversal requirement (C.4), where the Grit engine already rewards moving between regions — a spread kit is harder to pilot and generates more economy.
3. **Enemy posture telegraphs enemy capability.** Enemies carry positions and the ambient channel shows posture, so if enemy skills have anchors, an enemy's *stance* reveals which skills it can currently use. "When the Pikeman drops into that lean, the bash is coming" — a fighting-game-quality read layer, emergent from anchors plus the locked ambient display, and a reason for the player to watch the enemy rather than their own UI.

### A3.8 The skill record and builder specification

**The complete skill record**, assembling everything locked:

```
skill: {
  id, display_name,

  // Positional anchor (A3.7)
  anchor: { sector, ring },              // authored in grid coords
  angular_window,                         // hard cutoff; tightens per level
  radial_falloff,                         // potency curve; no cutoff
  demand_tier,                            // DERIVED from angular_window (Broad|Focused|Exacting)

  // Orthogonal demand flags (authored; main plan 2A.2)
  doctrinal: bool,                        // wants repeated, disciplined use — temporal, not positional
  transgressive: bool,                    // breaks a rule at a sharp cost

  // Access (DERIVED from vocabulary membership — display only)
  access_scope,                           // universal | class-exclusive | subclass-exclusive
  skill_type,                             // Specialised (peak-gated) | Shareable (tiered)

  // Level ladder (A4.7)
  levels: [
    { level, level_requirement, angular_window, effects[], pips_moved }
  ],

  // Sources and weapon gating (main plan 2A.10)
  sources: [ main_hand | off_hand | faculty | environment | innate_node ],
  required_faculty?: ref(Faculty),
  weapon_requirement: { type | group, min_pips } | null,
  source_binding: {
    delivery_node?: ref(BodyNode),
    node_family?: string,
    footprint_requirement?: { type, min_pips },
    requires_active_nodes?: ref(BodyNode)[]
  } | null,
  conversion_penalty,
  redistribution: { target_type, pips_moved },
  payload: ref(PayloadModule) | null,       // zero or one ordinary payload

  // Triade interface (Part H)
  region_effect: { kind, target, opening_scope, opening_delta },
  check: { scales_on[], base_difficulty },
  credit_on_success / failure / crit: { l1, l2 },
  ap_cost_base, ap_cost_modifier_source
}
```

**Builder specification — the authoring procedure, in order:**

1. **Declare intent.** What does this skill do fictionally, and which verb does it serve (create / read / exploit / resist / none)?
2. **Place the anchor.** Choose sector and ring. *This is the primary design act* — it decides what kind of fighter uses this skill.
3. **Set the angular window.** Wide = Broad, tight = Exacting. The positional *demand tier* is computed from this; do not author it separately. Set the **Doctrinal** and **Transgressive** flags independently if they apply — they are orthogonal to position.
4. **Set the radial falloff.** How sharply potency degrades with wrong depth.
5. **Build the level ladder.** Each level: additive and *qualitative* effects (never just bigger numbers), its [Level Requirement], and a tighter angular window than the level below.
6. **Declare sources and gating.** For equipment, use `requires` (fiction demands the weapon can do it) or `permits with penalty` (possible but ill-suited). For `innate_node`, name the delivery-node family, the physical footprint requirement, every optional support-node dependency and the authorised lineage binding.
7. **Set pip redistribution per level** — zero-sum; higher levels shift more pips toward the **redistribution target** (sharper, not bigger).
8. **Wire credits through status hooks**, never by direct type→credit mapping (main plan 2A.8).
9. **Validate** — see below.

**Validation rules (all automatable):**

| Check | Rule |
| --- | --- |
| **Anchor reachability** | every skill in a class's vocabulary must have an anchor inside that class's reachable region (floors clip the grid). Hard fail. |
| **Demand consistency** | `demand_tier` must equal the value derived from `angular_window`. Hard fail. The Doctrinal/Transgressive flags are exempt — they are orthogonal and authored. |
| **Access derivation** | `access_scope` must match vocabulary membership (universal / class / sub-class). Derived, display-only; never authored independently. Hard fail on mismatch. |
| **Ladder monotonicity** | each level keeps lower effects and adds a qualitative one; windows tighten monotonically. Hard fail. |
| **Pip conservation** | redistribution is zero-sum unless the skill is Transgressive/Inscription tier. Hard fail. |
| **Source binding** | every `innate_node` source resolves to an authorised lineage binding and an active realised delivery node; optional support nodes belong to the payload and never count as delivery hooks. Hard fail. |
| **Payload boundary** | an ordinary rendition carries zero or one authorised payload; a payload adds no footprint pips, cannot satisfy a footprint requirement and does not enter redistribution. Hard fail. |
| **Aim boundary** | the Technique alone declares no aimed mode, `coarse`, or `targeted` as its maximum granularity. Runtime intersects that declaration with the target's realised anatomy. A binding, Payload or later enhancement may not grant or raise aim capability. Hard fail. |
| **Anchor redundancy** | two skills with near-identical anchors and similar effects are duplicates — EMD-style test, as for weapons. Warning. |
| **Anchor coverage** | project all anchors onto the grid; clusters signal redundant design space, voids signal unused regions. Advisory. |
| **Class-anchor fit** | distance from a class's home position to its kit's anchors = that class's positional workload. Computable, tunable, advisory. |

**Tuning note.** How much positional workload is *fun* is a playtest question, not an argument. Default to **broad falloffs**, tightening only where a skill's identity genuinely demands precision.

### A3.8a Node-bound source instances [AUTHORED 0.38.0]

An `innate_node` Technique is available through an **authorised lineage binding**, not merely because a body happens to contain a compatible node. The binding names the Technique, the delivery-node family, the allowed Payloads and any optional support-node dependencies. It restricts the lineage-specific route; it does not itself grant the Technique. Every deliberate player-usable innate action also names a required Faculty, and that Faculty must authorize the Technique and be possessed and available. Runtime resolves the binding against the actor's realised `BodyTemplate` and creates one source instance per eligible active node.

`[Somatic]` is the bound-node Faculty for this route. It contributes no footprint and no delivery hook: `innate_node` remains the source, while Somatic supplies conferred, unlocked-and-acquired, or otherwise acquired authorization. A Lineage grant explicitly declares whether it confers the Faculty or only unlocks its acquisition. A passive anatomical grant names no executable Technique and requires no Faculty.

Equivalent nodes remain distinct sources. A left claw and right claw may be grouped under one presentation entry, but the selected instance retains its node identity in the action and trace. Denial of one claw removes only that source instance. A denied delivery node removes the technique and every rendition delivered through it.

An optional support node is a producer dependency, not a delivery source. Denying a venom gland disables the Venomous payload while leaving an ordinary Bite available through active teeth. The support node never becomes a second `[Combo-Action]` hook and cannot supply carrier magnitude.

### A3.8b Technique archetypes and payload modules [AUTHORED 0.38.0]

The existing skill record is the **Technique archetype**. It owns anchor, action-time cost, check, spatial contract, source and physical footprint requirements, zero-sum redistribution, ordinary effects, animation and whether aimed mode is supported.

**Aim capability belongs to the Technique and nowhere else.** A Technique declares no aimed mode, `coarse`, or `targeted` as its maximum granularity. Runtime takes the lesser of that declaration and the target's realised anatomical depth (H·11): a targeted Technique remains coarse against a Standard target and has no aimed mode against Trash. Sweeps, explosions and other broad-area actions ordinarily declare none. Source bindings, Payload modules and later enhancement layers may alter neither the declaration nor the target's anatomy; they cannot manufacture a called shot around the Technique contract.

A **Payload module** owns a condition or linked secondary-damage identity, its required carrier type and target-layer route, its bounded scaling inputs, resistance path, stacking/refresh policy and any explicit cost or risk adjustment. It owns no base footprint. It cannot add pips, satisfy the Technique's source requirement or participate in redistribution.

The controlled composition is:

```text
Technique archetype
+ authorised source binding and selected source instance
+ zero or one ordinary Payload module
= derived skill rendition
```

Multiple ordinary payloads are invalid. An exceptional multi-payload rendition requires an explicit Transgressive/Inscription rule; merely listing several modules is not authority. The derived rendition retains immutable references to its Technique, binding, source node and Payload module so replay and attribution never depend on display-name reconstruction.

### A3.8c Faculty authorization, footprint and pull [AUTHORED 0.41.0, ◈P11]

A Faculty profile authorizes a bounded Technique vocabulary; it does not own the Technique's executable behaviour. The Technique remains the sole owner of anchor, angular window, radial falloff, targeting, demand, effects, Payload permissions, costs, cooldowns, progression and presentation. Region membership is derived from the Technique anchor and is never duplicated as Faculty vocabulary arrays.

The Faculty damage footprint is an executable source footprint, separate from Triade position. Chaos, Divine and Psychic do not map automatically to Momentum, Form or Mind. M·2A.10a owns the exact base/composite footprints and primitive pull signatures.

The pull signature constrains only the Technique's actor movement. The Technique-owned `position_delta_q` is the sole applied delta and must be zero-sum and positive-collinear with that profile signature. The Faculty contributes no second additive delta. Target displacement and environmental movement follow their own contracts.

Two-hand Mudra requires one possessed Mudra Faculty plus two functional, unoccupied hands, each resolving a distinct functional finger hook. Composite profiles are authorization profiles rather than entitlements and require their possessed base Faculties plus all declared hooks at execution. Arcana + Arcana and Psyche + Psyche are invalid because the actor exposes only one voice and one Brain hook respectively.

### A3.8d Execution candidates and target-route contracts [AUTHORED 0.43.0, ◈P12-B]

Technique readiness is expressed as `known`, `selectable` and `executable`, never one persisted `available` flag. `known` proves vocabulary and authorization. `selectable` proves that at least one complete actor-side candidate can initiate, including current Triade position and accessible floor. `executable` proves one fully specified source/rendition/carrier/target candidate and is the only predicate that permits cost commitment and resolution.

Every candidate retains its exact authorization, grant/binding, source and hook, support/provider, provision, carrier and target-route dependencies. Alternative candidates combine by `OR`; requirements declared inside one candidate combine by `AND`. Thus another functional hand may preserve a one-hand Punch candidate, while a `Mudra && Mudra` candidate fails unless **both** required hands are functional and unoccupied and each supplies its own distinct functional finger hook.

Dependency failure is local. Denied teeth invalidate Bite candidates using them but not Punch, Kick or Apply Venom. A support/provider gates only the declared rendition or provision operation and cannot replace the Technique source. After a valid transfer, a coating or other provision owns its remaining uses and expiry; provider loss or cooldown blocks replenishment but does not erase the instance unless continuous maintenance is explicitly authored.

The Technique's target-route contract declares conceptually:

```text
selection_origin      actor | selected_actor | selected_cell | selected_path
selection_shape       single | radius | ring | cone | line | authored_pattern
reach_source          weapon_reach | throw_range | Technique_range | self_radius
visibility_requirement actor_LOS | perceived_cell | nonvisual_lock | none
delivery_route        direct | ballistic | propagated_area | self_centred | mental_link
```

These are logical requirements, not a technical column prescription. Direct actor-targeted weapon and projectile routes require their selected reach/range, target perception, actor line of sight and direct/path geometry. A direct Psyche route requires Technique-authored Psyche reach, perception and actor line of sight; only an explicit mental-link or non-visual-lock route replaces those visual gates.

Area routes do not select every affected actor. A self-centred weapon area validates its source, authored pattern and local geometry; its radius may read weapon reach without requiring line of sight to every occupant. A throwable area validates its selected destination under the authored visibility rule, throw range, ballistic route and landing cell, then resolves the propagated area. Area resolution may strike an unseen occupant without revealing that occupant before resolution, and geometry may still exclude cells. A broad source category never authorizes firing through walls, selecting unknown cells or bypassing blocked trajectories.

Candidate diagnostics preserve all failed gates — distinct reach/range, perception, line-of-sight, path, ballistic, landing-cell, pattern, propagation and non-visual-lock failures included. Collecting them does not execute later effects. P12-C's deterministic check and commit order follow in A3.8e.

### A3.8e Exact binding, resolution participants and planned activation [AUTHORED 0.44.0, ◈P12-C]

The authoritative resolver is pure. It evaluates one immutable snapshot in the P·2.3e stage order and returns stable `pass`, `fail(reason_code)` and `blocked_by(gate_id)` results without committing costs, cooldowns, randomness or effects. `executable` remains the sole permission to commit; P12-C introduces no fourth readiness predicate.

One exact candidate is bound before submission: Technique revision, selected level and aim, authorizing Faculty profile, grant/binding, every source and hook, rendition and Payload, support/provider or transferred provision, carrier and delivery route, plus the selected target or origin. Equivalent UI choices may be grouped, but after submission no other hand, weapon, ammunition, provision, rendition, target, cell, level, aim or carrier may replace it silently.

Target contracts declare actor, object, `cell_surface`, `environmental_volume`, or `path_or_area` as eligible domains and may require target capabilities or state. An object uses its W-owned runtime state; environmental surfaces and volumes use W-owned state channels. A **selected target** is part of the command. A **route contact**, **effect recipient** or **reaction product** may arise only later. These four roles are **resolution participants**. A valid area command need not predict all recipients: its consuming milestone discovers the affected set in deterministic order, applies compatibility per recipient, and returns `resolved_no_effect` when that set is empty unless at least one recipient is an explicit Technique requirement.

Indirect collision, displacement, propagation and Named Reaction consequences are child events with traceable parentage, not recursive retargeting. Immediate child effects require an authored immediate rule; otherwise W processes them in its same-tick deterministic batch. Geometry changes remain atomic across collision, navigation, occlusion, line of fire, cover and affordances.

Commitment atomically records the exact command/candidate, captures the pre-commit Triade position and usable skill level, computes effective cost and duration from current AP rate, reserves actual spendables and exclusive dependencies, and creates the action, milestones, timeline nodes, Intent Marker and audit digest. Any write failure rolls the whole commitment back. After success, candidate identity and captured potency inputs are immutable; current world state is revalidated only at the milestone that consumes it.

A Technique may explicitly permit a **Plannable Action**. The plan binds the exact candidate and one acquisition mode: `first_eligible`, `bound_identity`, or `fixed_spatial`. `first_eligible` uses authored trigger criteria and deterministic simultaneous ordering; `bound_identity` ignores all other participants and never retargets by default; `fixed_spatial` binds an origin/path/area and discovers recipients at resolution. Target acquisition selects what the plan attempts; the ordinary Technique target-route contract still decides whether that attempt is executable.

Arming a plan validates current actor-side gates, pays declared setup costs, reserves declared dependencies and creates an autonomous `world_tick` plan node with a visible Intent Marker. A scheduled plan attempts at its authored tick; a triggered plan fixes its attempt at `trigger_tick + response_delay`. The attempt is independent of the owner's later actor-timeline position, Readiness, AP rate or opportunity to act. Haste and Slow do not move it. Only an explicit node-targeted Advance or Delay effect may do so. At the due tick the bound candidate receives a fresh `executable` verdict; failure follows the declared branch, defaults to `cancelled_failed`, never silently retargets, downgrades, retries or reschedules, and releases only unreached reservations.

---

## Part A4 — Stat groups and the field-rendered floor

Two linked ideas ground the floor in character build: **stats are grouped by corner**, and the **floor is rendered from three stat-fields** rather than being a static class attribute.

### A4.1 Stat groups

**Locked: nine stats, three per corner, structured as capacity / application / resilience.** Nine is the superset — scaling to six later is a merge (drop the resilience column, or fuse two stats), not an invention.

| Corner | Capacity (raw) | Application (directed) | Resilience (withstand) |
| --- | --- | --- | --- |
| **Momentum** | **Strength** — raw physical power | **Finesse** — precise, controlled movement | **Stamina** — physical endurance |
| **Mind** | **Intellect** — mental capacity, perception | **Will** — willed direction, imposing | **Spirit** — mental endurance |
| **Form** | **Frame** — mass, rootedness, immovability | **Poise** — balance, coordination | **Constitution** — withstanding disruption |

The capacity / application / resilience triad keeps the three verbs distinct by construction — *what you have, how you direct it, how you withstand its domain being attacked*. A strong-but-clumsy character is high capacity, low application; a frail-but-skilled one the reverse. Names are collision-free against locked terms (Grit, Composure, Edge, Temper, Momentum/Form/Mind).

**Downstream use — the wound-effect derivation rule (H·5.2).** This structure also supplies the mapping from injury to stat, replacing per-wound authoring: bone and structural trauma hits **capacity**; tendon, nerve, joint and fine-motor trauma hits **application**; organ, bleed and systemic trauma hits **resilience**. Combined with render emphasis (A4.4) this produces an emergent counterplay axis at zero authoring cost — because Reach emphasises capacity+application and Floor emphasises resilience, **bone-breaking damage counters strikers and bleeding damage counters controllers.**

**Rule — three distinct verbs per corner.** The test is the standing one: for any two stats in a group, a player states the difference in one sentence. If they can't, merge them. The capacity/application/resilience structure exists to guarantee this.

**Render emphasis — the structure is mechanical, not just thematic (one field, no new state).** The corner still has **one field** `Φ` (headline value, conserved at baseline, everything in A4.2–A4.4 unchanged). But the two renders read the three stats with *different emphasis*:

- **Reach render** (depth, striker) emphasises **capacity + application** (e.g. Strength, Finesse).
- **Floor render** (staying, controller) emphasises **resilience** (e.g. Stamina).

This is a formula difference in the render functions, not a second stored field — renders were always computed, so different stat-emphasis costs zero tracked state. The consequence: **within-corner build composition now matters mechanically.** Two characters with identical `Φm` play differently — a Strength-heavy Momentum build reaches deep (striker), a Stamina-heavy one holds (controller). The striker/controller axis exists *within a single corner's investment*, not only across corners. Sub-fields were rejected (they would double the field math); the formula collapses the richness back into one field.

**Primary-corner-only to start.** Each stat feeds its own corner's group. Secondary cross-corner contributions are a deliberate later addition — secondaries are where multiplicative-interaction exploits breed. Individual stats are also read by *other* systems (skill checks, saves, condition resistances) even where the field only reads their composed value.

### A4.2 The three fields

Each stat group fuels a **field** — a value that shapes the floor, rather than pushing the dot. This is the concrete mechanism for the previously-unspecified "stats modulate floor extent" channel.

Fields are **quasi-static**: not a separate stored value and not drifting from play, but a direct read of the stats behind them, recomputed whenever a stat changes. There is no field state to track — the field is a projection of current stats, exactly as skill level projects from renders and regions project from position. The system keeps refusing to store what it can compute.

**Two field states — baseline and effective.**

```
Φ_base = (Φm, Φf, Φi)    from stats at creation + progression + rare permanent changes
Σ Φ_base = constant       CONSERVED — the invariant (locked)

Φ_eff = Φ_base + Σ(temporary stat modifiers)    injuries, poisons, potions, food, blessings
                          clamped to per-corner caps; NOT conserved; renders the floor
```

**Conservation lives on baseline, not effective.** This is the key split. Baseline is the "normal" state of the build and only changes through deliberate, controlled means (progression, the rare permanent stat change), so `Σ Φ_base` stays fixed — no permanent power creep, every guarantee the modification budget (G.2) protects is preserved.

**Effective is allowed to break the sum, in either direction, because it is temporary and reversible.** A [Broken Arm] dropping Strength/Dexterity pushes effective *below* baseline (you are genuinely diminished until it heals); a potion pushes it *above* (genuinely enhanced until it wears off). Neither touches baseline, so the instant the modifier clears, effective snaps back to baseline exactly. This lets injury *diminish* and buffs *enhance* honestly — without the conservation guarantee ever being at risk, because the guarantee was only ever about baseline.

**Effective is clamped even though it is not conserved.** The per-corner cap (0.25) and floor semantics apply to the rendered result, which reads effective. So stacking blessings cannot push effective past the caps into nonsense — buff-stacking is not a new power-creep vector. **Rule: baseline conserves; effective is clamped.** Two disciplines, two layers.

### A4.2a Injuries, buffs, and the safer route to deep skills

Temporary stat modifiers are how conditions reshape the floor. A condition applies stat modifiers → effective fields shift → the floor re-renders → reachable regions and usable skill levels change. This gives a condition up to **two mechanical effects, both via already-existing pathways**:

- push the dot ([CDM] force/impulse, A2.1), and/or
- modify stats → shift effective fields → re-render floor (this section).

Example: `[Broken Arm]` drops Strength 2 / Dexterity 1 (Momentum-group), and its `[Pain 2]` rider drops Mind 1 — the Momentum and Mind fields fall, the floor contracts, deep skills in the affected regions become unreachable until it heals. `[Pain 2]` might *also* push the dot toward Form (you flinch defensive). One condition schema, two effect channels, both already built.

**Positive modifiers are the important half.** Because effective can exceed baseline, a temporary buff (potion, food, blessing) can lift effective reach/floor enough to meet a higher skill level's [Level Requirement] (A4.7) — letting a build reach a skill level its *baseline* cannot sustain. A balanced controller who drinks a peak-boosting potion becomes a **temporary striker**: for the duration, their effective reach meets ⌬L3, so they can fire it. When it wears off, they are back to ⌬L2. The buff borrows a ceiling; it does not grant mastery — staying floor is unchanged, so they are still ejected after the deep hit (the reach-vs-staying logic of A4.7 survives untouched).

**Every stat-modifying source feeds effective fields — one channel, three permanence tiers.** The buff case generalises: anything that changes a stat flows through the same effective-field pathway, differing only in its clear-condition. This aligns with the item permanence tiers (G.3):

| Tier | Source | Moves | Clear-condition |
| --- | --- | --- | --- |
| **Permanent** | progression, rare permanent stat changes | **baseline** (conserved) | — |
| **Worn** | equipment stat bonuses (e.g. a +2 Dexterity dagger) | **effective** | on unequip |
| **Temporary** | consumables, conditions | **effective** | on duration/heal, **or the run boundary — whichever first** |

**Run-boundary clear.** [LOCKED — ◈W2f, Steward 28 July 2026] Temporary-tier modifiers clear at the run boundary in addition to their existing duration and heal conditions.

This converts a convention into an architectural guarantee: with Temporary state unable to survive a run boundary, the only things persisting between runs are baseline and equipment, so **at every run start the rendered floor *is* the baseline render by construction.** Assertable as `ΣF_rendered == ΣF_baseline` at run start (W·§16.1), which means the invariant stops depending on discipline and starts depending on the save format. It also keeps G.4's identity display honest — the deforming floor triangle shows earned shape, never borrowed shape blended in indistinguishably.

**Injury interaction — resolved (H·9.3).** Wounds split by channel. The `field_modifier` a wound emits is Temporary-tier and clears here. The wound's `[CDM]` influence, max-HP cap and function denial **persist until treated**, and none of them touch `ΣF_rendered` — so the invariant above holds unconditionally while injury still carries weight past the run. Recovery is a paid town service, priced in renewable currency only (H·8.1).

So **stat-bearing equipment is inherently floor-shaping.** A +2 Dexterity dagger lifts the Momentum-group effective field, which can unlock a Level 3 skill in a sector the *baseline* floor denies. Gear choice becomes a decision about *which skill levels are reachable*, not just a stat-stick — which is exactly the "behavioural over numeric" property itemisation wants (M·2.3), emerging automatically: any stat-bearing item is behavioural because stats render into the floor and the floor gates skills. This also gives weapons a *second* Triade channel independent of `weapon_triade`: pull vectors move the *dot* (how it plays), stat bonuses lift the *floor* (what it unlocks) — separable design dials.

**The tactical prize — buffs and gear are the safer route to deep skills.** Normally a deep skill level costs *exposure*: to meet its [Level Requirement] you must lean the dot to the deep, exposed part of the region (`In/3`), arming enemy Advantage. A modifier that raises effective floor lets you meet the same [Level Requirement] from a *safer* dot position — the deep skill without the deep exposure. So **positioning and effective-field modifiers (consumables or gear) are two different routes to the same skill level, trading exposure against a resource — consumed, or an equipment slot.**

**Injury clamp (H·10.2).** Injury-driven reductions to effective fields are additionally bounded below by the **Trauma Safety Clamp**, applied to the *sum of all effective-field reductions from all sources* — wounds and environmental surfaces (W·11.4) both write to this channel. The clamp guarantees the **Reach** render still meets the lowest `[Reach Cost]`/`[Level Requirement]` in the character's vocabulary, which is what restores the I.5 Mind-lockout guarantee under injury. Note the caps and the clamp guard opposite ends of the same axis: caps stop effective fields rising into free unreachable skills, the clamp stops them falling into mute regions.

**Clamp discipline is load-bearing here, especially for gear.** Worn bonuses are persistent, so the per-corner cap on effective matters more than for a transient potion: a stack of stat-boosting equipment cannot push effective past the caps into free unreachable-skills. Gear shifts *where* the reachable ceiling sits, not *how high the sum* goes. A useful consequence falls out — because effective is capped, a +2 Dexterity dagger helps a build whose Momentum field is *below* cap far more than one already near it. The same dagger is a minor upgrade for a Momentum specialist and a build-*opening* item for a Mind specialist, delivering the "same drop, different meaning per build" smart-loot texture (M·2.7) for free.

### A4.3 Rendering the floor: corners single, regions dual

The floor shape is **rendered** from the three fields through the medial-triangle geometry. Fields map to a corner **plus the two regions that corner participates in**, so regions are **co-authored by two parent fields** — exactly mirroring "a region is the combination of two corners":

- **Mind** field → `Mi` + `In` + `Di`
- **Momentum** field → `Mo` + `In` + `Pr`
- **Form** field → `Fo` + `Pr` + `Di`

Each region is claimed by both its parents (`In` by Momentum+Mind, `Pr` by Momentum+Form, `Di` by Mind+Form). Composure (the centre) is owned by nothing — it is never stat-sculpted.

This echoes the region-level rule at the stat layer: **corners reward specialisation in one group; regions reward developing two.** To be strong in Instinct you need both Momentum and Mind stats — the same breadth-over-narrowness pressure the dot (traversal, C.4) and the geometry (regions need two corners) already impose, now echoed a third time in stats. The consistency is the point.

### A4.4 Two renders: Floor (staying) and Reach (depth)

A region has two different properties, driven by the *same* two parent fields through *different* render functions. This is the reach-vs-dwell split (G.1) grounded in stats.

**Region Floor — staying power — super-additive, rewards balance.**
`In_floor = 2·Φm·Φi` (or a blended `(Φm+Φi)/2 + bonus·Φm·Φi`). Peaks when both parents are high *and balanced*. Governs how well you hold the region — resistance to being knocked out. Within a corner, Floor emphasises the **resilience** stat (Stamina, Spirit, Constitution) — see A4.1.

*Worked example (field budget 1.0, product render):* Specialist `(Φm=0.7, Φi=0.1)` → Instinct floor `2·0.7·0.1 = 0.14`, weak. Balanced dualist `(0.4, 0.4)` → `2·0.4·0.4 = 0.32`, over twice as strong, for the same budget spent. Balance is rewarded as *synergy*, not by capping the strong parent (which min() would do — min() is rejected: it punishes the strong parent and feels like a cap, not a payoff).

**Region Reach — depth of access — peak-driven, rewards specialisation.**
`In_reach = f(max(Φm, Φi))`. Gated by the *stronger* parent. Governs how deep into the region the dot can push (`In/1` → `In/2` → `In/3`). Within a corner, Reach emphasises the **capacity + application** stats (Strength/Finesse, Intellect/Will, Frame/Poise) — see A4.1.

*Same example:* Specialist `max = 0.7` → deep reach, pushes to `In/3`. Dualist `max = 0.4` → shallow reach, capped at `In/2`.

**The result is the striker/controller split:**

| | Fields | Region floor (staying) | Region reach (depth) | Plays as |
| --- | --- | --- | --- | --- |
| **Specialist** | lopsided | low — easily displaced | deep — reaches `In/3` | *striker*: hits the deepest skill, one window, then knocked out |
| **Dualist** | balanced | high — immovable | shallow — capped short | *controller*: can't reach top skills, but holds the region all fight |

Same region, same baseline budget, opposite profiles — determined by how the player splits two stat groups. Large build variety from one field set and two renders, and the two profiles have visibly different trace signatures, so the redundancy tooling sees them as distinct with no authored tag. (Temporary modifiers shift the *effective* fields on top of this baseline — A4.2a.)

**Conservation also eases entry, for free.** Dual investment raises `Φm` and `Φi`, which by conservation lowers `Φf` (Form) — a lower Form floor fights the Instinct lean less, so the region is *easier to enter*. One conserved, dual-rendered field system delivers both "stronger in the region" (product floor) and "easier to reach the region" (conservation lowering the opposite floor).

**Per-corner cap and floor semantics apply to the rendered result**, exactly as with the modification budget.

**The two renders carry two different mathematical requirements.** [LOCKED 0.13.0 — rule **T-C11**, closes ◈T6 / ◈W2d]

| Render | Requirement | Why |
| --- | --- | --- |
| **Corner floor** | **affine in its field** | Sum-preservation (G.2) holds only if the corner render is affine. A non-affine corner render lets `ΣF_rendered` drift as fields move, so drift accumulates across a *career* rather than resetting each run |
| **Sector floor** | **deliberately super-additive** (`≈2·Φa·Φb`) | This is the balance reward of A4.4 and must not be "corrected" for consistency with the corner render |

The requirements point in opposite directions on purpose. They apply to different objects — a corner floor is a budget component, a sector floor is a derived staying value — and conflating them breaks either sum-preservation or the striker/controller split.

*The render's exercised domain is bounded below by H·10.2's Trauma Safety Clamp, which is what made this statable rather than open-ended.*

Because both renders feed the skill layer, these fields are also the root of skill accessibility: reach and staying floor here are exactly the two gates A4.7 reads a skill's level against.

### A4.5 The render curve is a tuning knob

The *shape* of the rule is locked (Floor super-additive/balance-rewarding; Reach peak/specialisation-rewarding; deep cells gate on Reach, staying resists via Floor). The exact curves — pure product vs blended for Floor, the Reach function — are set in simulation against the reference builds, not by argument. Pure product rewards balance aggressively (weak specialist regions); a blended form is gentler.

### A4.6 Field breathing — resolved

The static-vs-drifting question is settled: fields are **quasi-static** (A4.2). They neither stay fixed-at-creation nor drift from *play* — they are a live read of current stats, with a conserved **baseline** and a clamped-but-unconserved **effective** layer (baseline + temporary modifiers). The floor deforms not from how you have been playing but from what has happened to your stats (injury, poison, buff), which the Dot Interpreter surfaces. Play-driven drift and reactive/fast breathing are both rejected.

### A4.7 Skill Characteristics and the level model (preliminary)

Every region skill carries three characteristics, and its usable level at any moment is derived from the two floor renders. This is **preliminary** — the first concrete [Skill Characteristics], filed under the deferred grid–math/skills work (A3.5, open questions 11 and 16) — but the shape is settled.

**The three characteristics:**

1. **[Reach Cost]** — the region depth (ring) at which the skill becomes accessible at all. A uniform access gate: everyone who reaches that depth can attempt the skill. Not build-dependent.
2. **Skill type** — *Specialised* (exists only for peaked builds; gated by reach, exclusive) or *Shareable* (available to anyone at depth, but tiered — see below).
3. **[Skill Level]** — for shareable skills, a ladder of discrete, **additive, qualitative** tiers. Each level keeps the lower effects and adds a new one, and each carries a **[Level Requirement]**: a sector-floor threshold it demands.

Worked example (shareable skill, In/3):

```
Riposte ⌬L1 — [Level Requirement] f1 — Damage 5
Riposte ⌬L2 — [Level Requirement] f2 — Damage 5 + Stun 2
Riposte ⌬L3 — [Level Requirement] f3 — Damage 5 + Stun 2 + Create Opening
```

Higher levels are *qualitatively* richer (⌬L3 creates an Opening; ⌬L1 simply cannot), not merely bigger numbers. This is what stops tiering from collapsing into "specialist is just a stronger dualist."

**Deriving the usable level — the two renders gate it, and they fight.** A skill carries all its levels; which one you can fire is read from your build against the [Level Requirement]:

- **Reach** (peak render, `f(max Φ)`) → the highest level you can *momentarily* satisfy — the deepest you can push the dot into the sector.
- **Sector floor / staying** (balance render, `≈2·Φa·Φb`) → the highest level you can *hold* without being ejected.

If your reach meets ⌬L3's requirement but your staying floor does not: **you fire ⌬L3, then decay ejects you** down toward Composure, dropping you to the level your staying floor sustains (⌬L1–⌬L2) until you fight deep again. Firing the deep level *spends the depth that granted it*. (This is emergent from the reach-vs-staying gap — confirmed model B — not an authored per-skill recoil.)

**This makes deep skills self-limiting and keeps the whole ladder live.** ⌬L3 is never dominant because reaching it undoes the position that grants it; lower levels are never dead content because they are all a low-staying build can hold. No "always pick the highest level" degeneracy — depth is self-consuming.

**The result — striker / controller / master, expressed on one skill:**

| Build | Reach vs staying | Riposte behaviour |
| --- | --- | --- |
| **Striker** (peaked) | reach ≫ staying | fires ⌬L3 as a **periodic spike**, ejected, must rebuild — devastating, rare, rhythmic |
| **Controller** (balanced) | small gap, lower peak | camps **⌬L2 sustainably**, never ejected, relentless — no ceiling, but reliable |
| **Master** (high both) | reach ≈ staying, both high | fires ⌬L3 **and holds it** — spike *and* stay |

**Mastery has a concrete meaning:** raising your staying floor until it meets your reach, so the deep version no longer ejects you — spike-and-drop becomes spike-and-stay. The skill never changed; your ability to *hold* its deep version did. That is a clean progression target and a natural sink for training/Temper.

**Specialised skills** (type 2) remain the peaked build's exclusive domain, gated by reach: things a balanced build cannot do at all. So the two skill categories map onto the two renders — shareable-skill *levels* reward staying/balance, specialised skills reward reach/peak — and neither build strictly dominates: the controller gets rich reliable shared skills, the striker gets exclusive techniques and deep spikes.

**Naming discipline:** *sector floor* is a value on the character (rendered from fields); *[Level Requirement]* is a threshold on a skill level. Execution compares the two — "your sector floor meets the skill's Level Requirement." Never call both "floor" once they are in the same sentence.

**The full chain — stats are the root of skill accessibility.** Both gates (reach and staying floor) are renders of the three stat-fields (A4.2–A4.4), so the complete causal path is:

```
stat groups → fields (Φ, conserved) → renders → sector floor & reach → usable skill level
```

The dot's *position* is the moment-to-moment lever, but the *fields* — your character build, working silently in the background — are the standing capability that sets the ceiling on which skill levels are ever open to you. Two characters at the identical dot position can access different skill levels there, because their fields render different floors and reaches. Nothing in the skill layer is a new primitive: it is stats, all the way down, read through geometry already locked.

### A4.8 Class, sub-class, multi-class

Class is a **stat lens, never a term in the field formula** (Model 1). It shapes *which stats you develop*; stats shape the field; the field shapes the floor. Class sits upstream of the whole A4 chain and therefore inherits every downstream mechanic (fields, renders, floor, skills, striker/controller) with no new wiring — it only decides which stats you can realistically grow.

**A class is two things:**

```
class {
  offset:   9-stat vector, MUST sum to zero        // where you start in stat-space
  gradient: 9 per-stat growth costs                 // which way is downhill (mains cheap, off costly)
}
```

**1. Starting offset — zero-sum, hard rule.** A `±` mask applied once at creation. Example Fighter: `+Strength +Stamina +Poise / −Intellect −Finesse −Spirit`. The offset **must sum to zero** — class sets *shape*, never *size*. Linter-enforced; a non-zero-sum offset is invalid. This is the class-layer echo of the conserved baseline field budget: a Fighter and a Mage begin with the same stat total, differently distributed.

**Author offsets against the capacity/application/resilience grid (A4.1).** *Which cell* within a corner you boost sets the class's striker/controller lean, not just its corner. The Fighter above boosts Strength (Mo-capacity → Reach) *and* Stamina (Mo-resilience → Floor) — powerful *and* tough in Momentum — but cuts Finesse (Mo-application), so it is a bruiser, not a duelist. Two "Momentum classes" feel entirely different depending on whether they buff the capacity or the resilience cell. This is a design-language rule for class authors.

**2. Growth-cost gradient (model b) — path, not destination.** Main stats are cheaper to raise, off-stats reachable but costly. This never breaks zero-sum, because of the **path/destination principle:**

> Zero-sum governs stat/field **totals** (the destination). The growth economy — per-stat costs, class cheapness — governs the **path** to a destination, never the total. The total growth budget is fixed and class-independent; only exchange rates vary. Cheapness biases which shapes are *efficient to reach*; it never expands the space of reachable totals.

The guard-rail: **the growth budget (total points) is fixed and class-independent; only per-stat costs differ by class.** If the budget itself ever flexed with class efficiency, that would be power creep through the back door. It does not.

**Sub-class — zero-sum on stats; rewarded by depth + vocabulary (A+C).** A sub-class does **not** deviate from zero-sum. Its reward is:

- **(A) a sharper offset** — deeper `±` on a narrower set (Fighter +1/−1 → Berserker +2/−2), still summing to zero. Reward is *depth* (a sharper peak reaches deeper, per the Reach render), paid for with *breadth* (bigger negatives). Self-policed by the sum.
- **(C) exclusive vocabulary** — Specialised skills (A4.7) and higher [Skill Level] ceilings available only to the sub-class's peaked profile. This is the *feels-like-progression* reward, living entirely in the skill layer, touching no stat total.
- *(Optional B — steeper gradient:* mains even cheaper, off-stats even costlier. Zero-sum-safe, reserved for sub-classes whose identity is relentless deepening.)*

**Guard-rail:** Specialised sub-class skills gate on the sub-class's own peaked profile, so a broad multi-class cannot cherry-pick a sub-class's best skill while staying versatile — you get the Berserker's exclusive skill only if you have the Berserker's peaked Strength to meet its [Level Requirement].

**Multi-class — versatile but shallow, emergent, no authored penalty.** Combining two classes' offsets and gradients:

- **Summed offsets → toward neutral.** Two zero-sum offsets sum to zero-sum (no power gain), and often partially cancel (a Fighter's +Str and a Mage's −Str net out), so a multi-class starts *more neutral* — closer to Composure, less pre-shaped. Thematically perfect for a jack of two trades.
- **Unioned gradients → thinner growth.** More stats marked cheap means the fixed growth budget spreads across more mains → each peaks lower → shallower Reach in any one region. You reach `In/2` in two regions but `In/3` in none. "Versatile but not deep" falls out of the fixed budget twice over — no penalty is authored.

### A4.8a Lineage — the other stat lens [AUTHORED 0.27.0]

**Lineage is a stat lens of the same kind as class**, and the same object as `[Chassis]`: one record naming what an actor *is*. Class shapes which stats you develop; lineage sets which you were born with. Both are `±` masks over the A4.1 grid, neither is a term in the field formula.

```
lineage {
  body_template: ref(BodyTemplate)    // H·5.3 — anatomy, never restated here
  sizes:  [ size ]                    // a subset of Small → Average → Large → Giant
  typical: size                       // exactly one, flagged; the baseline
  offset:  9-stat vector, MUST sum to zero   // measured AT the typical size
  innate:  [ { node: ref(BodyNode), footprint: { type, pips }[] } ]   // 0.32.0 — per node, at typical size
  skill_bindings: [ {
    technique: ref(skill), delivery_node: ref(BodyNode),
    allowed_payloads: ref(PayloadModule)[], requires_active_nodes: ref(BodyNode)[]
  } ]
  floor_shape: …                      // enemies only; a player floor renders from stat fields
}
```

**`innate` is the unarmed profile, and it hangs on nodes rather than on a faculty** [AUTHORED 0.32.0]. A lineage states what its body does with no equipment at all: a human, `Impact +` at each hand and each leg; a dwarf, `Impact ++` at each hand; a wolf, `Slash +` at each front leg and `Pierce ++` at the teeth. The list is authored **at `typical` size**, exactly like `offset`, and physique scales it the same way.

**Gating is not a rule here — it is node state.** Because a profile is attached to a node, it is available precisely while that node is active. A broken arm removes that hand's contribution with nothing authored; `[Hobbled]` removes a leg's. This is why the profile moved: the previous model carried `gate_nodes : [ref(BodyNodeArchetype)]` on a faculty record *pointing at* H's `function_denial`, which is a pointer maintained by hand where an attachment would have been free. **A jaw wound already denied both bite and `[Arcana]`; now bite needs no slot to be denied, because it is a node with a profile.**

**This dissolves `◈E10` rather than answering it.** Bite was deferred to the bestiary workstream as a fourth `[Innate]` slot. There are no slots: there are nodes, and a lineage either authors a profile at its teeth or does not.

**Trade-off named.** Innate profiles are now authored per lineage per node, which is more rows than one faculty record per family — a serpent authors nothing at its absent limbs, but a dragon authors tail, wings, jaws and claws separately. The compensation is that no gate, no slot table and no denial rule has to be maintained alongside them.

**A profile does not act — a skill does.** The node states what the body *is capable of*; delivery is vocabulary. `Ferocious Bite`, `Gnaw`, `Tearing Maw`, `Jawlock` are skills that draw on a teeth profile, exactly as a weapon skill draws on a weapon's footprint, and 2A.9's zero-sum redistribution applies unchanged.

**The profile is the physical access gate; the lineage binding is the vocabulary gate.** 2A.10's requirement check reads the base footprint, so compatible teeth may perform a Bite Technique while an incompatible node cannot. A Venomous Bite additionally requires an authorised venomous Payload binding and any declared producer node. Venom is not authored as Poison pips on the teeth. The same mechanism that decides a mace cannot thrust proves physical eligibility; the binding decides which governed renditions the lineage actually owns.

**What may change a profile is H's, at 7.1a.** Only the **Permanent** channel of G.3 may alter one — worn equipment composes with it, a temporary state never touches it (**H-C8**). Today nothing is on that channel for the body, because `converts_to_scar` ships off under `⦻H4`.

**Magnitudes are M's, at 2A.11** [0.37.0, **◈M14**]. The four-pip illustrations above are the authoring reference for an ordinary weapon-capable body — **not a ceiling**. An anatomy whose natural sources replace held weapons may carry profiles on every relevant node; **M-C3** bars pooling, so the body total is never the magnitude of one attack (**M-C12**).

**No magnitudes are locked here.** Every pip figure above is illustrative; the budget question — what a body may carry unarmed, and how it composes with worn equipment — is **M**'s, at 2A.9 and 2A.10a.

**`[Chassis]` and lineage are one object, not two.** Every chassis carries exactly one lineage and every lineage names one body template, so a separate identity field would only be a second name for the same row that could drift out of sync. **Many chassis, few templates** (H·5.3) is what makes lineage plural: Human, High Elf and Goblin are three lineages sharing `humanoid-full`.

**The offset is measured at the typical size.** A Rat's typical is Small, a Troll's is Large — so a lineage's vector always describes *an ordinary member of that lineage*, wherever ordinary happens to sit on its ladder. **The typical row therefore carries no physique modifiers**: it is the zero point, not a step from one.

**Every stat source in the game conserves.** Class offsets sum to zero (A4.8), sub-class offsets sum to zero, lineage offsets sum to zero, and physique trades in balanced pairs (E·F.1). Two zero-sum offsets sum to zero-sum, so **no combination of lineage, class, sub-class and size produces a power gain** — only a shape. This is the stat-space form of the conservation the dot already obeys under A2.4.

**Trade-off named.** A Rat and a Troll have the *same stat total*. That follows from T·F.0 — the four enemy tiers are defined *"by which loop stages they possess, not by stat size"* — so threat comes from tier, anatomy depth and equipment, never from bigger numbers. **Lineage is shape; tier is capability; nothing is scale.** A design that later wants a numerically larger creature has to reopen this, not work around it.

**Composition order is fixed:** creation base → lineage offset → class offset → sub-class offset → physique pairs. Closed list, stated order, per A2.2's discipline for any stacked source.

### A4.9 Agentic class design

Classes are unusually agent-friendly: a small typed object (`offset + gradient`) with a **hard arithmetic validity gate** (offset sums to zero) and a **machine-checkable quality signal** (the trace system — a class is a build-trace generator, and the redundancy gate answers "is this class distinct?" via EMD on residency, exactly as for weapons). Hard-constrained *and* trace-measurable is the sweet spot for safe automation.

The **Class Smith** agent proposes only the numeric core; everything downstream (field render → floor → skills → trace) is deterministic machinery that already exists, so the agent cannot invent mechanics or break geometry — it writes a 9-number vector the fixed formula consumes. "Agents propose data; code decides truth," in its purest form.

Validation pipeline: Linter (offset sums to zero — hard reject; grid-distribution metrics — *warning* for lopsided offsets, since deliberate lopsidedness is sometimes the point) → field renderer (deterministic) → Trajectory Auditor (build-trace signature; redundancy gate vs existing classes; brief-fit, e.g. controller-lean ⇒ high floor-residency) → Balance Auditor (degenerate peaks, dominance) → human gate. See main plan §5 for the agent roster placement.

---

## Part B — Credit economy

### B.1 Sources

Credits are generated by being in the exchange, through two channels running on **different clocks**.

**[Action] — event-based.** Fires on an outcome attributable to a choice: a landed hit, a parry inside the window, a spell resolved, a critical in either direction. Rewards skill. Sets the ceiling for competent play.

**[Context] — rate-based.** Accrues per round from the situation: outnumbered, fighting above tier, sustained threat, terrain disadvantage, fight duration. Rewards exposure, not performance. Sets the floor of credit income in hard fights.

Separate clocks give two independent tuning knobs, and make [Context] unfarmable — it does not respond to action frequency at all, only to danger. This is the structural defence against degenerate loops in the credit economy.

[Context] is also what keeps Form-leaning defensive builds solvent. They land few hits and would starve on [Action] alone.

**Exploit rule: [Context] pays for incoming threat, never for the character's own damaged state.** Threat is enemy-controlled and cannot be self-inflicted; sitting at low health is a state the player can choose and would farm.

### B.2 The three layers

| Layer | Name | Source | Horizon | Spent on | Cap |
| --- | --- | --- | --- | --- | --- |
| ⌬L1 | **Edge** | Action + Context | expires in a few turns | Opportunity actions | 0–3 |
| ⌬L2 | **Grit** | Action | the encounter | Boosts, Special actions | 0–10 |
| ⌬L3 | **Temper** | Context | held until a trigger | between-encounter use | larger |

Each layer answers a different question on a different horizon — *do I capitalise right now* / *how do I spend this fight* / *what am I saving for*. Three decision timescales rather than one.

**Names locked: Edge / Grit / Temper.** A steel-working family — the cutting edge, the abrasive that sharpens, the heat treatment that reshapes. Temper is more than flavour: tempering trades hardness for flexibility without adding material, which is exactly the sum-preserving floor modification it funds (Part G).

**Internal keys are `l1` / `l2` / `l3`.** Display names live in a separate string table and must not appear in the action contract, trace signature field names, or linter rules. Player-facing names are the cheapest thing in the design to change and the most likely to change after first playtest.

### B.3 The cascade

Unspent credits convert **downward only**, at a loss.

```
Edge  →  Grit  →  Temper
```

This solves two problems:

**Hoarding.** Unspent credit is suboptimal rather than wasted, which makes conservative play a real strategy with a real cost instead of a punished one.

**Temper's skill correlation.** Sourced from [Context] alone, Temper income would be uncorrelated with play quality. The overflow makes it an exposure *floor* from Context plus a skill-correlated *surplus* from Grit the player was good enough not to need.

**No upward conversion, ever.** Temper cannot be poured into a fight in progress; that would let players trivialise hard encounters with banked reserve and would destroy the run-level decision.

Optional and recommended: a **single dramatic intervention** per encounter, funded by a steep Temper cost. This preserves the turn-the-tide fantasy without making Temper generally spendable.

### B.4 Risk weighting, per layer

Each layer rewards a different verb. Do not share a risk function between them.

| Layer | Weighted by | Rewards |
| --- | --- | --- |
| **Edge** | tightness — narrow windows, exploiting a state the enemy just entered | **timing** |
| **Grit** | exposure accepted — attacking into real threat, committing position | **commitment** |
| **Temper** | sustained exposure — duration at high threat, encounters above tier, punishment survived | **endurance** |

A build can be strong at one and weak at another. That is character differentiation obtained without adding a single stat.

Temper's weighting also makes route choice pay off, which is the roguelike incentive the run layer needs.

### B.5 Readability discipline

The credit economy is the element most likely to fail, and it will fail on **legibility**, not on maths. Two disciplines:

- Caps stay **small integers**. Edge 0–3 is readable at a glance; a percentage is not.
- **⌬L1 conversion rate is a tracked metric.** If Edges expire unused most of the time they are invisible noise; if they are always consumed they are not a decision. Target roughly 60–70% for competent play, measured rather than assumed.

---

## Part C — Region semantics

### C.1 What the inner layer is for

The core triangle is **your own state**. The regions are the layer that acts on **the opponent's state**.

| Region | Between | Verb | Does |
| --- | --- | --- | --- |
| **Instinct** | Momentum ↔ Mind | **read** | perceive an Opening on a combatant's dot and convert it into Edge |
| **Pressure** | Momentum ↔ Form | **force** | displace the opponent's dot directly, creating an Opening |
| **Discipline** | Mind ↔ Form | **resist** | hold your own dot against disruption; counter, provoking the opponent to displace their own dot |

Read / force / resist. Each sits between two corners because each is produced by combining two of your own stances, and each operates on the exchange rather than on you. The two force-and-resist regions are the offensive *setup* — they create Openings — and Instinct is the shared *converter* that turns Openings into economy. This is why Instinct sits opposite no single strategy: both entry paths route through it.

### C.2 The Opening

An **Opening** is a *property of a combatant's position* — a vulnerable state on their dot — not a resource anyone holds. It lives on the board, on the target's dot, and it decays as that dot drifts back toward home.

**Openings are scoped by cause.** The adjudication is a single question: did a combatant's *direct action* displace the dot, or did a *board condition*?

- **[Opening for X]** — created by actor X's direct action against a target's dot: Pressure (displace) or Discipline (counter into overextension). Readable and exploitable **only by X**. Private. No handoff — a teammate cannot cash X's setup, and enemy B cannot cash enemy A's.
- **[Opening for All]** — created by any environmental or board condition displacing a dot, **irrespective of who established the condition**. Readable by any opponent. Public.

The scope rule resolves the previously messy cases cleanly. An enemy slips on an oil slick you laid: the slick is a board condition, so the resulting Opening is **[for All]** — anyone may exploit it, including the enemy if your own dot later lands on it. Engineering the environment is a *public good, not a private weapon*; the reward is positioning the hazard well, not owning its outcome. An enemy that overextends on its own turn (a Compulsive Behaviour tag) creates an **[Opening for All]** on itself — genuinely ambient, which is what keeps a pure-Instinct build able to feed on aggressive enemies (C.4).

Pressure and Discipline are the two offensive *setup* verbs for private Openings — one proactive, one reactive. Aggressor versus counter-fighter, the same Opening object created two ways.

**Integrity modifies Openings (materiel Bridge 1 — see main plan 2A.6).** A target's armour integrity state changes the Openings that can be created on them: against **Cracked** or **Fractured** armour, Openings are **deeper** (larger `opening_delta`), and against **Fractured** they **decay more slowly**, widening the read window. **Broken Guard** suppresses that target's Discipline-based Opening creation — they cannot counter their way out. Structural damage is therefore a *setup channel feeding this loop*, not a parallel damage race, and it gives Pressure a physical expression alongside its positional one.

### C.3 The loop

```
[create]   Pressure / Discipline / environment / self    →  Opening (for X, or for All)
[read]     Instinct action, checked (see C.6)            →  Edge, tagged to that Opening
[exploit]  spend Edge on the Opening                      →  [Advantage against X]
[convert]  Advantage-gated action                         →  if successful, Grit (and puts X [Back-footed])
```

Four distinct things kept distinct: the Opening is a board state, Edge is the moment-scale conversion currency, Advantage is the earned tactical edge, Grit is the encounter-scale accumulation. The loop is the offensive backbone, and every region feeds into it rather than funding itself.

**No step self-funds.** Creating an Opening banks nothing. Reading produces Edge only against a real Opening — reading empty air yields nothing. Edge exits by being spent to earn Advantage; only a *successful Advantage-gated action* produces Grit. The inner layer cannot spin on its own axis because the create-step and the read-step happen in different regions and no combatant can occupy two regions at once (C.4).

### C.3a The three relational states

The exchange runs on three directional states, each an edge in the combat graph rather than a status on a node (except where scoped to All). They form the causal chain of a winning exchange:

```
their Opening  →  my Advantage  →  their Back-foot
```

| State | Meaning | Scope | Expiry |
| --- | --- | --- | --- |
| **[Opening]** | a combatant's dot is exposed | for X (private) or for All (public) | decays as the dot drifts home |
| **[Advantage]** | the holder has a favourable footing over a target | against X, or against All | loop-earned: one-shot (spent on the action). Circumstantial: persists while the circumstance holds |
| **[Back-foot]** | the holder's next actions against a target are penalised (AP up, success down) | against X, or against All | cleared when the holder next resolves a successful action, scoped to match |

**[Advantage] has two sources.** The loop is the *effortful* path — read an Opening, spend Edge, earn Advantage. **Circumstance** is the *free* path — high ground, a flank, surprise, elevation grant [Advantage against X or All] with no Opening and no read. Any source of Advantage unlocks the same Advantage-gated vocabulary; a well-positioned fighter gets there for free, a fighter on even ground earns it through the loop. This is what finally gives terrain and tactical positioning a hook into the Triade economy rather than being flavour.

**Circumstantial Advantage must be losable.** Every Advantage carries a maintenance condition: loop-earned Advantage is one-shot; high-ground Advantage ends when you leave the high ground or the enemy reaches it; surprise is brief. It is a live tactical state gained and lost mid-fight, never a coin pocketed permanently.

**[Back-foot] is relational and scoped.** A [for X] Opening exploited against you leaves you [Back-footed against that specific attacker] only. An [Opening for All] — an ambient slip — leaves you [Back-footed against all tier-2 opponents] until you regain balance. Environmental exposure is *public*; engineered exposure is *private*. This makes a stumble in a crowd automatically far more dangerous than a stumble in a duel, with no special crowd rule — the "for All" scope does it. Multiple attackers create *separate* [Back-foot] relationships rather than a stacking debuff, so being swarmed compromises you against each threat in its own lane rather than multiplicatively locking you.

### C.4 The traversal requirement

The loop's create-step and read-step live in different regions, and the zero-sum simplex forbids standing in both. This is the mechanism — not a bonus — that makes mixed play generate more than single-region play.

A pure-Pressure fighter creates Openings while standing deep in Pressure, which is *far from Instinct*, so their own reads are poor (C.6) and their Openings go unconverted. A fighter who creates and then *drifts toward Instinct to read* completes the loop. The traversal is not rewarded; it is **required by the geometry** to close the loop at all.

| Playstyle | Loop status | Grit outcome |
| --- | --- | --- |
| Pure Pressure | creates Openings, poorly positioned to read them | Flow trickle only |
| Pure Discipline | counters into Openings, poorly positioned to read them | Endure trickle only |
| Pure Instinct | converter with no generator | starves unless the enemy self-inflicts an [Opening for All], or the terrain provides one; spiky, matchup- and encounter-dependent |
| Pressure ↔ Instinct | full loop, aggressor route | full Loop Grit |
| Discipline ↔ Instinct | full loop, counter-fighter route | full Loop Grit |

This is the counterweight to corner-camping. Floors, region weapons and clumsiness all reward commitment; the Grit engine rewards traversal. That tension is the intended texture of skilled play.

**Consequence — Instinct is the pivot of the offensive economy.** Every Loop routes through it, so anything that denies a player Instinct access (a high enemy Mind floor, a Behaviour tag that suppresses reads) collapses their Grit engine to trickles. This is a powerful, legible control tool for enemies, but it must be a **deliberate, telegraphed** capability — an accidental Instinct-denial makes a fight feel randomly dead.

### C.5 Grit sources

Grit fills three ways. **Loop Grit is the backbone; the two trickles are minor and region-flavoured.** If the trickles grow large, the regions drift back toward self-funding independence — keep them seasoning, not engines.

| Source | Mechanism | Region flavour |
| --- | --- | --- |
| **Loop Grit** | Opening → read → Edge → successful exploit | shared backbone, any route |
| **Flow Grit** | combos, crits, clean sequences | Pressure-leaning |
| **Endure Grit** | bracing, punishment survived | Discipline-leaning |

Edge and Grit exit the pipeline at **different horizons**: Edge is spent inside the exchange to exploit an Opening; Grit is spent at encounter scale on boosts and Special actions. Because exploiting an Opening (spending Edge) is what *produces* Loop Grit, the moment-scale layer causally feeds the encounter-scale layer — the cascade direction from B.3, now with a mechanism rather than only overflow.

Temper is untouched by all of this — it remains [Context]-only (B.1). Regions are actions; the loop stops at Grit.

**Both offensive regions carry two verbs, and no single action does both.** Discipline *braces* (Endure Grit) or *counters* (creates an Opening) — different actions, so it does not double-dip. Pressure *combos* (Flow Grit) or *displaces* (creates an Opening) — likewise. A region action never both banks a trickle and creates an Opening; the player chooses per action.

### C.6 Position-dependent checks

**General rule, locked: action success/failure checks scale on Triade position.** An action attempted from a favourable position resolves more reliably than the same action from an unfavourable one.

The load-bearing instance is the **read check**. Read success scales on:

- **proximity to Instinct** (your Momentum–Mind position) — the mechanism behind C.4; reading from deep in Pressure is meaningfully worse than reading from Instinct
- **Opening depth** — a deep overextension is easier to read than a shallow displacement
- **Opening age** — a fresh Opening is hard to perceive, a lingering one easier, but it is decaying; too early fails, too late and it is gone. This makes reading a *timing* skill, consistent with Edge being the timing-weighted layer (B.4)
- **Instinct-channel stat** — the character's raw aptitude

The same principle generalises to other actions: a Pressure displacement lands harder from within Pressure, a counter is more reliable from within Discipline, and so on. Formulas are per-action content; the *rule* — that position modulates the check — is a locked invariant, and it is what makes region commitment matter beyond mere access gating.

### C.7 Baseline, not unlocked

The regions exist from the start. Because they are derived rather than tracked, they cost nothing in state complexity. What grows over a run is **vocabulary** — the actions available within a region — not the geometry.

---

## Part D — Class model

A class is two data structures:

```
class: {
  floor_shape: (F_m, F_f, F_i),        // ΣF ≤ 0.45, each ≤ 0.25
  vocabulary: {                         // region-gated actions
    instinct[], pressure[], discipline[], generic[]
  },
  channel_bias: { pull, floor_extent, decay_resistance }
}
```

**Floor shape is class-alone at run start.** Equipment does not modify it (see Part G for the one budgeted exception).

**Home position** is the centroid of the class's reachable region. It shifts toward whichever corner carries the highest floor, so a Form-heavy class genuinely rests in structure.

**Commitment cost** is the distance from home position to each region — a per-class cost table computed from geometry, not authored. A class far from Instinct is bad at reading opponents without any rule saying so, and the number states by how much.

**Core Triade = capability. Regions = vocabulary.** Capability is generic progression (how hard you can lean, how fast you drift back, how stable your shape). Vocabulary is class- and weapon-specific. This split is what keeps class content combinatorial rather than additive.

---

## Part E — Weapons

### E.1 Three relationships, which need not align

| Relationship | What it is | Where it lives |
| --- | --- | --- |
| **Affinity** | which region the weapon's actions push you toward | emergent from pull vectors — observed, not authored |
| **Vocabulary** | which region-gated actions the weapon supplies | explicit list |
| **Efficiency** | how well the weapon performs while standing in a region | multiplier table |

**Alignment is a design dial.** A weapon where all three agree is a *pure* weapon — easy, does one thing well. A weapon where affinity and vocabulary diverge is a *technical* weapon: it drifts you away from where its best actions are, so playing it well means resisting your own weapon's momentum.

This gives weapons a **difficulty axis orthogonal to power level**, which is rare and worth having.

### E.2 Corner weapons and region weapons

A region demands two corners high simultaneously — a real commitment. Not every weapon should ask for it.

- **Corner weapons** — push toward a single corner, forgiving, generic vocabulary. Common, early, always usable.
- **Region weapons** — demand a narrow part of the triangle, reward it heavily. Rare, deep.

**This is what rarity means.** Not bigger numbers: greater mechanical demand. It self-balances, since a region weapon is a jackpot for a class whose floor shape reaches that region cheaply and a curiosity for one that does not. Loot variance without stat inflation.

### E.3 One-vector and two-vector weapons

A two-hander demands a **single deep point**: one pull vector, sharp distance penalty, high commitment.

A one-hand-plus-offhand loadout demands a **segment** — satisfiable anywhere along the line between its two pulls. Sword and shield pulls toward Form via the shield and Momentum via the sword; the player chooses which to lean on turn by turn.

This makes one-hand-plus-offhand versus two-handed a structural choice about **control versus commitment**, not a damage-versus-defence stat trade. Offhand loadouts are also inherently more forgiving across classes, which falls out of the geometry rather than being authored.

### E.4 Demand and clumsiness

**Weapon demand** is a derived statistic: the deepest region requirement across the weapon's vocabulary, compared against the character's reachable envelope. Displayed at pickup as *within reach* / *at the edge of your reach* / *beyond you*. This fills the item-evaluation gap traces deliberately do not address — traces tell designers whether a weapon is distinct, not players whether it is for them.

**Clumsiness** is the mechanic: distance from the character's home position to the weapon's demand scales a penalty to AP cost and recovery, applied even to the weapon's generic actions. It requires no new data — it is the commitment-cost distance measured to a different target.

**Cap the penalty deliberately.** In a roguelike the player uses what they find. An off-class weapon must stay better than nothing, and sometimes better than a poor on-class one. Uncapped clumsiness makes players hoard and reject drops, and makes the smart-loot dial load-bearing in a way it should not be.

### E.5 Signature block

```
weapon_triade: {
  archetype: "heavy_builder" | "fast_sustainer" | "defensive_converter" | ...,
  pull_vectors: [ (dm, df, di), ... ],   // one for single, two for offhand loadouts
  pull_magnitude: 0.0–1.0,
  volatility: 0.0–1.0,
  recovery: 0.0–1.0,
  vocabulary: { instinct[], pressure[], discipline[], generic[] },
  efficiency: { instinct, pressure, discipline },
  threshold_modifier: { region, delta } | null    // uniques and high-tier affixes only
}
```

Worked examples:

- **Daggers → Instinct.** Low pull magnitude, fast recovery, high timing sensitivity. Form exclusion is a real weakness: forced to hold structure, daggers stop working.
- **Maul → Pressure.** High pull magnitude, high volatility, poor recovery. Does not read the opponent; imposes on them. Punishes misses hardest.
- **Sword and shield → Discipline.** Two-vector. The player controls their own drift.

**Threshold modifiers** lower `T` for one region only, never globally — a global reduction is strictly better with no tradeoff and becomes mandatory gear. Reserve for uniques and high-tier affixes; it partially bypasses the commitment cost that makes regions meaningful.

---

## Part F — Enemies — MOVED

**Extracted to `E-Enemies_design_TRIADE-0_44_0.md` (ref E) at 0.11.0.**

Enemies remain **the same system as characters** — innate floor shape plus equipped vocabulary, one schema with two consumers, running the identical action contract (Part H) with roles swapped. That equivalence is a T-level invariant and stays here.

What moved to **E**: the four-tier capability ladder (F.0), tag composition (F.1), behaviour-as-AI (F.2), shared equipment records (F.3), and combination-space validation (F.4).

**Why it moved.** The capability ladder became load-bearing for two other documents — H derives anatomical depth and the `[Wounded]` behaviour tag from it, W derives encounter composition and boss escalation from it — and the bestiary is where content volume will accumulate. It is a subsystem, not a section.

**What T retains:**

- Enemies carry a position; it is not optional (the read/force/resist verbs are meaningless otherwise)
- Enemies use the same floor-shape machinery, budget and per-corner cap as characters
- Enemy validators are character validators; no separate suite exists
- Elite and Commander reads are **position-dependent exactly as the player's are** (C.6) — this is a geometry invariant, enforced here, applied in E

## Part G — Modification and progression

Special items, tomes and training may alter how far into the regions a character can reach. Because this is the one declared exception to the class-alone invariant, the **constraint** belongs in the Constitution; the individual items are the depth-plasticity pillar (W·3) content.

### G.1 Reach versus dwell

Two mechanics that feel identical to the player and behave completely differently:

**Reach** — can the region threshold be satisfied at all. Binary, geometric, gated by floors. Dangerous to grant.

**Dwell** — how long a deep position can be held once reached. Continuous, gated by decay resistance and pull magnitude. Safe to grant: it makes what was already possible practical, without unlocking anything new.

Most of the drama lives in dwell.

### G.2 Sum-preservation

**Any floor modification holds the total floor budget constant at 0.45.** A tome does not add reach; it *trades* it. Lower one floor by 0.05, raise another by 0.05.

This keeps the zero-sum discipline of the design consistent at the progression layer, turns tomes into decisions rather than upgrades, and contributes exactly zero power creep — only specialisation.

Supporting rules:

- The per-corner cap of 0.25 must hold **after** modification, or a stack of tomes recreates the lockout the cap was designed to prevent.
- Threshold reductions are always per-region, never global.

Without sum-preservation, the mechanic fails in a specific way: a late-run character carrying several reach items is not overpowered so much as **classless**, which dissolves the identity system rather than merely unbalancing it. Everything of value in this design — commitment cost, class identity, region-weapon variance, clumsiness — derives from geometric scarcity.

### G.3 Permanence determines channel

**Elapsed time enters through `world_tick`, and through nothing else** [ADOPTED 0.36.0, CR-11]. Active ADM, CDM and EDM influences integrate against the single authoritative timestamp (**K-C11**); there is no second clock and no per-frame delta. G.3's three permanence tiers are unchanged — an influence's *channel* is still decided by how long it lasts, not by how it is timed.

| Permanence | May affect | Examples |
| --- | --- | --- |
| **Permanent** | floor shape, sum-preserving | tomes, training, rituals |
| **Worn** | region threshold `T` for one region; dwell | equipment, affixes |
| **Temporary** | dwell only | consumables |

Temporary reach is specifically excluded. A consumable granting reach converts a hard fight into "drink the potion, use the technique," bypassing the commitment that makes regions meaningful at exactly the moment the commitment was the point.

### G.4 What this closes

**Temper gains its sink.** Training and tomes at a town trigger are what Temper is spent on. Run-level performance converts into character shape, and the credit economy loop closes.

**The run gains a visible identity narrative.** The floor triangle deforms over a run — a geometric, legible progression readout, and a considerably better meta-progression display than a list of incremented numbers.

### G.5 Risk: irreversibility

Permanent reshaping can produce a character incompatible with the weapons later found. That is drama or a ruined run depending entirely on information. Required: **mandatory preview** of the resulting shape before commit, **shape-aware drop pools**, and **reversal at steep cost**. Irreversibility is only fair when fully informed.

---

## Part H — Action contract and AP

Every action declares its interface to the Triade. This block is the single boundary between the Triade and everything else — weapons, spells, skills, enemy abilities and affixes all speak through it.

```
action: {
  id,
  position_delta: (dm, df, di),        // normalised; applied to the actor's dot

  region_effect: {                     // the Triade-state payload (C.2–C.3a); null for a plain action
    kind: create_opening              //   Pressure/Discipline: displace or provoke → Opening on target
        | read_opening                //   Instinct: checked perception → Edge tagged to the Opening
        | exploit                     //   spend Edge on a read Opening → [Advantage against target]
        | advantage_action            //   Advantage-gated action → on success, Grit + target [Back-foot]
        | resist                      //   Discipline: reduce incoming deltas / suppress own decay
        | none,
    target: opponent | self,
    opening_scope: for_x | for_all | null,   // create_opening: private (direct action) vs public (board condition)
    opening_delta: (dm, df, di) | null       // create_opening: how the target's dot is displaced
  } | null,

  check: {                             // C.6 — position-dependent resolution; null for auto-resolve
    scales_on: [ instinct_proximity, opening_depth, opening_age, channel_stat,
                 self_distance_from_home, ... ],   // advantage_action success scales on actor's exposure
    base_difficulty
  } | null,

  advantage_source: loop | circumstance | null,  // loop-earned = one-shot; circumstantial = maintained
  advantage_maintenance: null | { condition },    // circumstantial Advantage expiry (leave high ground, etc.)

  credit_on_success: { l1, l2 },       // l2 (Grit) from advantage_action success, or Flow/Endure trickle
  credit_on_failure: { l1, l2 },
  credit_on_crit:    { l1, l2 },
  risk_weight: 0.0–1.0,                 // scales gain per Part B.4

  requires: { region, ... } | { corner, min }
          | { opening_present: true } | { advantage_against: target } | null,
  ap_cost_base,
  ap_cost_modifier_source: momentum | mind | form | none
}
```

Notes on the region fields:

- `create_opening` writes to the *target's* dot and banks nothing. `opening_scope` is `for_x` when the displacement comes from a direct action (Pressure/Discipline), `for_all` when it comes from a board condition — irrespective of who established that condition.
- `read_opening` requires an Opening the actor is permitted to read (own [for X], or any [for All]) and produces Edge only on a successful `check`.
- `exploit` spends Edge to convert a read Opening into `[Advantage against target]`.
- `advantage_action` requires `advantage_against`, and its `check` scales on the actor's own `self_distance_from_home` — overcommitment lowers success. Circumstantial Advantage (high ground, flank) satisfies the same requirement without the loop.
- The relational states ([Opening], [Advantage], [Back-foot]) are combat-graph edges, not fields on this record; actions create and consume them but do not carry them.
- Temper never appears in `credit_*`. It is [Context]-sourced and accrues outside the action contract.

**AP coupling rules:**

- At most **one** corner may modify the AP *pool*. The others modify costs or availability. If all three touch the pool, the interaction matrix acquires a multiplicative chain.
- Recommended default: Momentum modifies physical action cost, Mind modifies mental action cost, nothing modifies the pool.
- A **minimum AP floor** is guaranteed regardless of state, so a bad position never means a skipped turn.

**Check resolution (C.6) is a locked invariant:** any action carrying a `check` block resolves against Triade position, not on a flat probability. Formulas are per-action content; that position modulates the outcome is not negotiable.

---

## Part ◈H2 — T's rule table

*Added at 0.13.0. These IDs were in circulation from 0.11.0 but had no authored home in **T** — the Validation Rules Index carried them while declaring itself derived from source rule tables. For **T** it was not. This table is that home; the index regenerates from here.*

| ID | Rule | Section | Severity |
| --- | --- | --- | --- |
| **T-C1** | All dot vectors satisfy `dm + df + di = 0` | A2.4 | Critical |
| **T-C2** | `ΣF ≤ 0.45` and `F ≤ 0.25` hold for every character at every point | A.2 | Critical |
| **T-C3** | `Σ Φ_base` is conserved — no permanent power creep | A4.2 | Critical |
| **T-C4** | Any floor modification is sum-preserving; threshold reductions per-region only | G.2 | Critical |
| **T-C5** | Region geometry valid under **every legal floor shape** | A.3, J.4 | Critical |
| **T-C6** | Temporary effects cannot modify baseline floors or global thresholds | A4.2a | Critical |
| **T-C7** | At run start, `ΣF_rendered == ΣF_baseline` | A4.2a *(◈W2f)* | Critical |
| **T-C8** | Action success scales on Triade position — no position-independent resolution | C.6 | Critical |
| **T-C9** | AP cannot fall below the guaranteed floor | Part H, K·3.3 | Critical |
| **T-C10** | Every skill anchor is reachable by its intended vocabulary owner | A3.8 | Critical |
| **T-C11** | The **corner**-floor render is affine in its field; the **sector**-floor render is super-additive | A4.4 | Critical |
| **T-C12** | Every `sources` entry resolves to a record — a weapon, shield, `faculty`, environment object or authorised active `innate_node` binding. No action draws from an unbacked source | A3.8, M·2A.12 | Critical |
| **T-C13** | A `[Combo-Action]` declares **exactly two** delivery hooks. Never one, never three | M·2A.10 | Critical |
| **T-C14** | A lineage `offset` is a 9-stat integer vector that **sums to zero**, measured at the lineage's `typical` size; the typical size carries no physique modifiers | A4.8a | Critical |
| **T-C15** | Every node-bound Technique resolves to an authorised lineage binding and one active realised delivery-node instance. Equivalent nodes remain separate sources; support nodes gate the Payload only and never become delivery hooks | A3.8a | Critical |
| **T-C16** | A Technique owns physical requirements and redistribution; an ordinary derived rendition carries zero or one authorised Payload module. A Payload adds no footprint pips, satisfies no footprint requirement and never enters redistribution | A3.8b | Critical |
| **T-C17** | Aim capability is declared only by the Technique as none, `coarse`, or `targeted`; runtime caps it at the target's realised anatomical depth. Bindings, Payloads and later enhancement layers cannot grant or raise it | A3.8b, H·11 | Critical |
| **T-C18** | Every deliberate player-usable `innate_node` Technique requires a possessed authorizing Faculty in addition to its lineage binding and active source node. Current route readiness is evaluated separately; Somatic contributes no footprint or hook, and a passive innate grant binds no executable Technique | A3.8a, P·2.3a | Critical |
| **T-C19** | An execution candidate retains every typed dependency. Alternative complete candidates combine existentially and requirements within one candidate conjunctively; invalidation is dependency-local. The Technique owns selection origin/shape, reach source, visibility and delivery route; direct and area routes therefore apply their authored perception, LOS, path and propagation gates rather than one universal LOS rule | A3.8d, P·2.3d | Critical |
| **T-C20** | One exact candidate and command are bound before an atomic commitment and never gain silent source, rendition, target, level, aim or carrier fallback. Selected targets and later resolution participants are distinct. A permitted Plannable Action binds an acquisition mode and attempts a fresh executable verdict from its autonomous `world_tick` node, independent of the owner's later actor-timeline position | A3.8e, P·2.3e | Critical |
| **T-H1** | Every reinforcing loop has a **named brake** | I.5 | High |
| **T-H2** | No reference build shows an unrecoverable spiral | Gate T | High |
| **T-H3** | Candidate entities exceed the trace-distance redundancy threshold | I.4 | High |
| **T-H4** | Triangle coverage above target across reference builds | Gate T | High |

**T-C11 is Critical because the failure is unbounded in time.** A non-affine corner render lets `ΣF_rendered` drift as fields move, and nothing resets it at a run boundary — so the error accumulates across a career rather than a run (W§13). That is the same class of failure as T-C6.

---

## Part I — Validation and metrics

*Severity scheme standardised at 0.11.0. T's invariants carry `T-C{n}` / `T-H{n}` IDs; Gate T exit criteria remain a **gate**, distinct from the continuous rule suite. Full cross-document suite in `R-Validation_Rules_Index_TRIADE-0_44_0.md`.*

### I.1 Trace instrumentation

The sim records, per action: position, all three credit counters, region membership, action taken, **and the source of every state delta**.

**Attribution must be built in from day one.** Retrofitting it into a simulation is miserable; adding it at the start is cheap. Without it, traces cannot be sliced by contributor and the modifier delta-signatures in I.3 are impossible.

Attribution also records **Opening provenance** — whether each Opening was created by the player (Pressure/Discipline), by the environment, or self-inflicted by the enemy. This is what lets the metrics distinguish a build that manufactures its own Openings from one that only converts openings the enemy hands it (C.4), and it is what makes the loop's per-source Grit generation measurable rather than guessed.

### I.2 Signature

Traces are aggregated across the fixture set into a fixed-length signature.

| Feature | Detail |
| --- | --- |
| **Residency histogram** | 36-cell discretisation of the simplex; fraction of actions per cell. The spatial fingerprint; alone catches most redundancy |
| **Credit profile** | mean, variance, autocorrelation, time-to-first-threshold — **per layer**, plus the two cascade conversion rates |
| **Displacement magnitude** | mean per-action movement of the dot; separates weapons that yank from weapons that nudge |
| **Excursion depth** | furthest lean toward each corner at peak |
| **Region residency** | fraction of actions inside each region; time-to-first-region-entry |
| **Transition matrix** | cell-to-cell movement frequencies; captures dynamics rather than occupancy. Add past ~30 weapons |
| **Credit economy** | per-layer generation rate, spend timing, overflow volume |
| **Loop economy** | Openings created vs read vs exploited; Loop/Flow/Endure Grit split; Opening provenance mix (self / environmental / enemy). Distinguishes a manufacturer from a converter (C.4) |

**Distance metric: Earth Mover's Distance** for the residency histogram. Euclidean treats "adjacent cell" and "opposite corner" as equally different and will report near-identical weapons as wildly distinct.

**Confound control: compare paired.** Hold constant everything except the entity under test — for a weapon that is build and enemy and seed; for a build it is enemy, varying weapons; for an enemy it is the player side. Same rule, stated at the right level.

**Build the cheap version first.** Residency histogram plus credit mean and variance is roughly eight numbers and captures most of the value. Resist building the full pipeline before there is content to measure — this is the kind of system that quietly becomes a research project.

### I.3 Actors and modifiers

The signature is defined against an **abstract trace source**, not against weapons.

- **Actors** — weapons, skills, spells, enemies, builds — get a signature directly.
- **Modifiers** — affixes, passives, set bonuses, tomes — get a **delta signature**: the difference between traces with and without them.

The delta signature is also the simulation-delta method needed to price Triade-affecting affixes in the item power budget, which was the hardest open problem in the main plan. The trace system solves it as a side effect.

### I.4 What traces are used for

**Redundancy gate.** A candidate must exceed a distance threshold from every existing entity. Evaluate **within type as well as across it** — weapons cluster by type now that vocabulary is type-bound, so every polearm will look distinct from every rapier while being indistinguishable from every other polearm.

**Coverage map.** Project all signatures into 2D for a map of the design space with clusters and voids. Voids become content briefs — machine-specified targets, ideal for agent input.

**Archetype validation.** Cluster signatures without supervision. If emergent clusters do not match declared archetypes, the archetype vocabulary is wrong — either two names for one thing, or one archetype secretly containing two.

**Identity-drift detection.** If a balance patch moves a signature significantly, it changed how the entity *plays*, not just its numbers. Normally invisible until players complain weeks later.

**Class identity check.** Measure a maximally-modified character's build trace against its class baseline cluster. If divergence exceeds threshold, the Part G modification budget is too generous. Tunable empirically rather than by argument.

**Encounter variety.** If enemy traces cluster, fights feel samey regardless of how different the stat blocks are.

**The honest limit:** divergence measures distinctness, not quality. Two entities can be maximally divergent and both tedious. It is a necessary-not-sufficient filter — it clears duplicates so the human review budget is spent entirely on "is this interesting."

### I.5 Loop audit

Map every feedback loop and label it reinforcing or balancing. Every reinforcing loop needs a **named brake**.

| Loop | Brake |
| --- | --- |
| Momentum success spiral (+) | diminishing position pull near a corner; enemy adaptation |
| Collapse spiral (−) | floors guarantee minimum access to every corner; Temper intervention |
| Mind lockout (−) | floor `F_i` guarantees a basic Mind action is always reachable |
| **Injury spiral (+)** | **four named brakes (H·10.1): Trauma Safety Clamp · AP minimum floor · free Minor-scoped field dressing · Clumsiness cap.** Note this loop attacks the Mind-lockout brake directly — `F_i`'s guarantee weakens exactly as injury drives `Φi` down, which is what the clamp's computed `Φ_safe_x` restores |
| Grit hoarding | cascade conversion at a loss |
| Edge waste | conversion-rate metric, tuned to 60–70% |
| Loop self-funding (+) | create and read live in different regions; traversal required (C.4); trickles kept minor |
| Instinct-denial dead fight (−) | enemy Instinct-suppression must be deliberate and telegraphed, never incidental |
| Opening farm | reads yield Edge only against a real Opening; shallow Openings read poorly and decay (C.6) |

**The exits from a collapse must be expensive, not unavailable.** Escaping should cost the Temper banked for the boss, converting a bad fight into run-level attrition rather than a death.

**Do not settle spiral questions by argument.** `recovery rate from low charge` across the fixture set — if fewer than the threshold share of low-credit states recover, there is a spiral regardless of which exits exist on paper.

---

## Part J — Design steps and Gate T

**J.1** Write the state machine formally — representation, legal ranges, all transition sources. One page, no prose ambiguity.

**J.2** Freeze the action contract (Part H). Everything downstream speaks through it.

**J.3** Specify AP coupling and the minimum-AP floor.

**J.4** Define region membership thresholds and validate the geometry against every legal floor shape, including the most lopsided.

**J.5** Author one proof action per region. Content libraries are deferred; the regions must exist now because they constrain the position maths and threshold tuning.

**J.6** Define class floor shapes for the reference classes; derive home positions and commitment-cost tables.

**J.7** Build trace instrumentation with attribution (I.1) and the cheap signature (I.2).

**J.8** Loop audit with named brakes (I.5).

**J.9** Prototype the state display before finalising the maths (see Visual Design ◇V1–◇V2 for the graphical model). If the state cannot be read in under half a second, simplify the maths — not the UI. The barycentric dot is the leading candidate: position for lean, ghost trail for recent trajectory, three small integers for credits.

**Gate T exit criteria**

- State machine specified; action contract frozen
- Every reinforcing loop has a named brake
- No reference build shows an unrecoverable spiral
- Region geometry valid under every legal floor shape
- Triangle coverage above target across reference builds
- ⌬L1 conversion rate inside the 60–70% band for competent play
- Trace divergence threshold defined
- State readable in under half a second in prototype

---

## Part K — Open questions

*Standardised at 0.11.0. Every live item carries **[OPEN]**; every provisional number carries **[SIM]**. All items are mirrored in `B-Open_Items_Index_TRIADE-0_44_0.md`, which is generated from these markers — edit here, regenerate there.*

**Resolved since 0.9.0 and removed from this list.** Eight entries were still listed as open after K17 answered them; they were carried stale into 0.10.0 and are cleared here. Their resolutions:

| Was | Resolved by |
| --- | --- |
| Position persistence out of combat | K17 — decay toward home over two or three exploration turns |
| AP **rate** coupling *(restated 0.34.0, K-C12)* | no corner contributes an additive or multiplicative term to AP rate; Form's floor is a clamp; three symmetric tempo levers (K·3.3) |
| Temper's combat intervention | K17 — excluded from MVP |
| Enemy credit layers at elite tier | K17 — Elite = Edge; Commander = Edge + Grit; neither gets Temper |
| Trickle magnitude | K17 — Loop 70–85%; Flow and Endure ≤15% each (K·9.2) |
| Back-foot / Advantage representation | K17 — keep as first-class relational states |
| Dynamic Composure | K17 — off in MVP |
| Enemy Opening reads | F.0 (now **E**) — yes at Elite and above, bound by the same position-dependent reads |

Items 11, 12, 14 and 15 of the former list were already marked RESOLVED in place and are likewise removed; their resolutions live in the sections they refer to (A3.5/A3.7, A3.4–A3.4b, A4.2/A4.2a, A4.1) and are indexed in **L**.

### Live items

| # | Question | Marker | Blocking |
| --- | --- | --- | --- |
| **◇T1** | **Region vocabulary size.** How many actions per region per class before the vocabulary becomes unreadable. | **[OPEN]** [SIM] | Content |
| **◇T2** | **Modification budget size.** How much floor reshaping is available across a full run, tuned against the class-identity divergence check in I.4. *Mechanism answered by W·5.6's `[Modification Ceiling]`; the **curve** remains open (◇W2a).* | **[OPEN]** [SIM] | Balance |
| **◇T3** | **Opening decay rate.** Governs the read timing window (C.6) and how punishing pure-setup play feels. Interacts with position decay. | **[OPEN]** [SIM] | Balance |
| **◇T4** | **Non-linear condition interaction.** The parked level-2 slot (A2.5) — e.g. `[Wet]` amplifying `[Cold]`. Couples with re-checking the zero-sum invariant. K17 holds it off until level-1 combat passes validation. | **[OPEN]** | Deferred to level 2 |
| **◇T5** | **Skill level model validation (A4.7).** The three-characteristic model and the reach-vs-staying ejection dynamic are settled in shape but preliminary — to be validated when skills are designed against concrete content. | **[OPEN]** | Content |
| ~~◈T6~~ | **RESOLVED 0.13.0.** Stated in A4.4 and promoted to rule **T-C11**. Raised in W as ◈W2d and closed there in the same pass | — | — |
| **◇T7** | **Dynamic Composure build-out.** Base parametric sizing is locked; whether to build the pressure-driven shrink, and which closed set of mechanics may resize Composure, is deferred. K17 confirms off in MVP. | **[OPEN]** | Deferred |

---

## Changelog

| Version | Change |
| --- | --- |
| **0.44.0** | **P12-C execution identity adopted.** A3.8e locks pure deterministic evaluation, exact-candidate atomic commitment, explicit target domains and resolution-participant roles, and autonomous Plannable Actions with `first_eligible`, `bound_identity` or `fixed_spatial` acquisition and no silent fallback (**T-C20**). |
| **0.43.0** | **P12-B execution contract adopted.** A3.8d separates `known`, `selectable` and `executable`, makes dependency invalidation candidate-local, and assigns selection shape, visibility and delivery-route requirements to the Technique (**T-C19**). Candidate alternatives are existential; within-candidate requirements are conjunctive, so Mudra && Mudra requires both complete hand/finger-hook requirements. |
| **0.42.0** | **P12-A execution identity aligned.** Composite profiles authorize execution but are never entitlements. Two-hand Mudra requires one possessed Mudra plus two functional, unoccupied hands, each resolving a distinct functional finger hook. Complete availability ordering remains P12-B/C. |
| **0.41.0** | **`◈P11` action boundary adopted.** Faculty profiles authorize Techniques and supply an executable source footprint plus a primitive actor-pull constraint; Techniques remain sole owners of behaviour and the applied `position_delta_q`. Correct voice/finger/Brain/bound-node hook semantics and explicit Lineage confer-or-unlock grants replace the earlier universal-unlock wording. |
| **0.40.0** | **Somatic authorization and lineage-grant boundary.** Every deliberate `innate_node` Technique requires a Faculty as well as its lineage binding; Somatic authorizes natural-node Techniques without becoming their source, footprint or hook (**T-C18**). A lineage unlocks rather than acquires the Faculty, and passive grants bind no Technique. |
| **0.39.0** | **A2 aim ownership.** A Technique alone declares no aimed mode, `coarse`, or `targeted`; runtime caps it at realised target anatomy, and bindings, Payloads and later enhancement layers cannot raise it (**T-C17**). |
| **0.38.0** | 1 geographic occurrence renamed — T·252's *faction/territory flavour*, geographic inside the document owning the barycentric sense. **Session A:** A3.8a/b authors node-bound source instances, Technique/Payload separation and deterministic derived renditions (**T-C15**, **T-C16**); T-C12 now resolves `innate_node` through an authorised active lineage binding. |
| **0.37.0** | **A4.8a's four-pip illustrations reframed as an authoring reference, not a ceiling** — an anatomy whose natural sources replace held weapons may carry profiles on every relevant node (**M-C12**). |
| **0.36.0** | **Elapsed-time integration bound to `world_tick`** — active ADM/CDM/EDM influences integrate against the single authoritative timestamp. G.3's permanence tiers unchanged. |
| **0.33.0** | **Skill-level line repointed to `redistribution_target`** — `focus` is locked Mind-side. |
| **0.32.0** | **`[Innate]` moves into the lineage.** A4.8a's record gains `innate: [{ node, footprint }]`, authored at `typical` like `offset`. Gating is **node state**, not a rule — a broken arm removes that hand's contribution with nothing authored. Delivery is vocabulary: a profile gates which bite skills a jaw can reach, via 2A.10's existing requirement check. |
| **0.27.0** | **A4.8a authored — Lineage, the other stat lens.** Same record as `[Chassis]`: body template, available sizes with one flagged **typical**, and a 9-stat offset **summing to zero, measured at typical**. **`T-C14`** added. Composition order fixed: creation → lineage → class → sub-class → physique. Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | A2.2's armour note re-propagated: Medium adds a barycentre well; **[Dot Dynamics] is engaged by no armour class**. Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | A2.2's armour note propagated — **four** weight classes, four engagements. Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | `◈T6`'s row gained its missing marker cell — it had three cells under a four-cell header and was losing a column at render (MD056). Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **45 glyphed identifiers in this document.** |
| **0.13.0** | **Stage 1 — the `faculty` channel.** A3.8's `sources` enum renames `capability` to `faculty`; the word *capability* is returned undivided to the enemy capability ladder (E·F.0), which held 38 of its 42 uses. New rules **T-C12** (every source resolves to a record — the hole that let `capability` sit for three versions as an enum value with no object) and **T-C13** (a Combo-Action declares exactly two hooks). Magic takes **no new resource**: Mind's locked consumption verb, *"threshold — gates access"* (A.1), is the access economy, surfaced player-facing as `[Attunement]`. Stated as a negative — there is no mana, and its absence is load-bearing. |
| **0.13.0** | **Part ◈H2 added — T finally has an authored rule table.** T-C1…T-C10 had been in circulation since 0.11.0 with no home in T; the Validation Rules Index carried them while declaring itself derived from source rule tables, which for T it was not. **◈T6 closed after surviving two passes.** A4.4 now states the two-render requirement — corner floor affine, sector floor super-additive — and it is promoted to rule **T-C11** (Critical) rather than left as prose, which is what let it survive. Closed simultaneously in W (◈W2d) and struck from L's deferred list. |
| **0.12.0** | No structural change to T. Cross-references updated for the nine-document set. Recorded for coherence: *floor* remains reserved to its Triade sense throughout — W§5.8 adopts `[Deck]` and `[Storey]` for dungeon geometry rather than importing a second meaning for T's most load-bearing word. ◈T6 (corner-floor render affinity) remains **[OPEN]** and unaddressed by this pass. |
| **0.11.0** | **Part F (Enemies) extracted** to `E-Enemies_design_TRIADE-0_44_0.md`; a pointer stub retains the T-level invariants — enemies are the same system as characters, carry positions, and read position-dependently. **Part K rewritten**: eight entries that K17 had already answered were still listed as open and are cleared; seven live items now carry `[OPEN]`/`[SIM]` markers and appear in the Open Items Index. Part I aligned to the set-wide severity scheme. Document set grows to eight. |
| **0.10.0** | Document set grows to seven with **H — Damage & Health**; filename convention standardised to `TRIADE-[System] design-[Version]`. **A4.2a: ◈W2f propagated** — Temporary-tier modifiers now clear at the run boundary (Steward-locked 28 Jul 2026), making `ΣF_rendered == ΣF_baseline` at run start architectural rather than conventional; injury interaction resolved via H·9.3's channel split. **A4.2:** effective-field reductions bounded below by the Trauma Safety Clamp (H·10.2), summed across wounds and surfaces. **A4.1:** capacity/application/resilience identified as the wound-effect derivation rule, producing the bone-counters-striker / bleed-counters-controller axis. **I.5:** injury spiral added to the loop audit with four named brakes. |
| **0.9.0** | Combat Design document split out; Skill Anchors resolve the grid–math question. |
| **0.8.0** | UI requirements moved to the new `V-Visual_design_TRIADE-0_44_0.md`; A3.4c is now a pointer. Document-set note added. |
| **0.7.x** | Skill Anchors (A3.7–A3.8) resolving the grid–math question; demand tier split from Doctrinal/Transgressive flags; UI requirements; Weapon/Armour/Shield Smith agent specs; shield budget. |
| **0.6.x** | Materiel system: damage taxonomy with Structural group, integrity states, the three bridges, pips and redistribution, shield duality. |
| **0.5.x** | Dot Framework, grid + Dot Interpreter, stat-groups and field-rendered floor, skill level model, class system, Dictionary and tone. |
