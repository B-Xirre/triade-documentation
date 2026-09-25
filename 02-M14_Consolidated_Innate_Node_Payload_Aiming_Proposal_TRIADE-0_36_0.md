# Triade `◇M14` — Consolidated Innate, Node-Payload and Aiming Proposal

**Aligned corpus:** Triade 0.36.0 round-three candidate  
**Released baseline:** 0.35.0  
**Status:** **PROPOSAL — AUTHORED-BUT-NOT-YET-CENTRALISED**  
**Authority:** None until adopted by the central design process  
**Sign-off:** **PENDING** — unchanged  
**Primary owner:** M, with direct consequences for T, H, E, P, K, L, R and the technical implementation stream

## 1. Purpose

This proposal consolidates the design discussion around:

- innate damage magnitude;
- standard and monster-like anatomy;
- viable unarmed character builds;
- node-bound skill availability;
- reusable skill renditions such as Venomous, Searing and Freezing Bite;
- combat-derived condition and secondary-damage payloads;
- armour, slot and body-node interaction;
- anatomical hit distribution and aimed skill modes;
- enemy access to aimed modes;
- deterministic content-authoring and automation requirements.

It supersedes the **recommendations** in the earlier `◇M14` research handoff, especially the proposed universal four-pip body limit. It does not modify or supersede any authoritative Triade source.

## 2. Design principles

1. **A body node is a delivery source, not a condition container.** It carries its innate damage footprint. Skills carry special condition or secondary-damage payloads.
2. **Magnitude is constrained where it can be used.** Per-node and per-action concentration matter more than the sum of every dormant anatomical source.
3. **Anatomical breadth is real capability.** Extra claws, jaws, wings and tails provide vocabulary, redundancy and wound surface; they are not forced into a humanoid body-total budget.
4. **A payload is earned through its carrier.** It resolves only after related node-footprint damage proves the required delivery path.
5. **Payload magnitude is calculated.** It consumes outputs of the combat model rather than applying a fixed on-hit value.
6. **Armour is part of delivery resolution.** Coverage, construction, typed defence and integrity decide whether the carrier reaches the layer the payload requires.
7. **Aiming biases anatomy; it does not replace anatomy.** Target placement is always normalised from the target's realised body template and current exposure.
8. **Enemy decisions remain perception-bound.** No enemy selects the objectively weakest hidden armour from world truth.
9. **Automation composes governed parts.** It may derive renditions from a technique, node binding and authorised payload; it may not invent payload authority or balance values.

## 3. Innate magnitude

### 3.1 Four pips are a standard reference, not a universal ceiling

T·A4.8a's illustrative Human, Dwarf and Wolf profiles each total four pips:

| Illustration | Distribution | Total |
| --- | ---: | ---: |
| Human | four nodes × 1 | 4 |
| Dwarf | two nodes × 2 | 4 |
| Wolf | `1 + 1 + 2` | 4 |

That is a strong authoring reference for ordinary, weapon-capable bodies. It must not become a universal limit for anatomies whose natural sources replace held weapons.

A dragon with four legs, a tail, teeth and two wings may legitimately have innate profiles on every relevant node. The total across those nodes is not the magnitude of one attack because M-C3 prevents ordinary pooling.

### 3.2 Per-node grades

| Grade | Base innate pips | Meaning |
| --- | ---: | --- |
| **Incidental** | 1 | ordinary hand, foot, wing buffet or secondary limb |
| **Dedicated** | 2 | claw, combat-adapted limb, heavy tail, strong fist |
| **Apex** | 3 | monster-defining jaws, stinger, beak, horn or equivalent source |

Three is the ordinary single-node ceiling. Four remains reserved for a source that commits two delivery hooks, analogous to a two-handed weapon, or for an explicit Transgressive/Inscription exception.

The grade names are descriptive in this proposal and are not new Lexicon terms until central adoption decides whether they should be persisted.

### 3.3 Ordinary striking equipment

Ordinary striking equipment at one node uses a local two-pip pool:

```text
1 offensive pip + 1 local defensive pip
```

Its offensive contribution composes with the node's innate footprint but the ordinary offensive composite saturates at three pips.

Examples:

- Human hand `1` + permanent conditioning to `2` + glove `1` → `3`.
- Dwarf hand `2` + glove `1` → `3`.
- Dragon claw `2` + fitted striking equipment `1` → `3`.
- Apex jaws `3` remain `3`; ordinary equipment may still add defence, type access or affixes without increasing ordinary magnitude.

Holding a weapon suppresses innate and striking-equipment offence at that hand, as M·2A.10a already requires. Local equipment defence remains available.

### 3.4 Ordinary physical Combo-Actions

An ordinary physical `[Combo-Action]` may draw at most:

```text
3 pips from its primary source + 2 from its supporting source = 5
```

This preserves the existing dual-wield envelope while supporting bite-and-tail, fist-and-kick and other anatomical combinations. A sixth available pip remains relevant to independent source use and skill access; it does not automatically collapse into one ordinary action.

This ceiling applies to the ordinary physical combination proposed here. It must not silently constrain unresolved faculty or exotic multi-channel magnitude work.

### 3.5 Example monster anatomy

An ordinary dragon-lineage proposal could carry:

| Node | Innate footprint | Pips |
| --- | --- | ---: |
| Teeth/jaws | `Pierce 2, Tear 1` | 3 |
| Tail | `Impact 2` | 2 |
| Front claw, each | `Slash 2` | 2 |
| Rear claw, each | `Slash 1` | 1 |
| Wing, each | `Impact 1` | 1 |

The body-wide total exceeds four, but no ordinary single source exceeds three and no ordinary physical Combo-Action exceeds five. The extra anatomy grants breadth and resilience while also creating additional woundable and denyable functions.

## 4. Unarmed character builds

Viable unarmed builds should use separate layers rather than giving every humanoid a weapon-equivalent body:

1. **Lineage anatomy** establishes the starting node footprint.
2. **Permanent martial conditioning** may promote selected nodes under H-C8. This is a permanent base-profile transformation, not a skill temporarily adding pips.
3. **Striking equipment** contributes offence, local defence, integrity and affixes.
4. **Skills** redistribute pips zero-sum and supply vocabulary, tempo, status, movement and combination effects.

This supports distinct builds:

| Build | Likely emphasis |
| --- | --- |
| Brawler | equipment independence, disruption, resilient bare sources |
| Pugilist | conditioned hands plus striking gloves; concentrated 3-pip sources |
| Warrior monk | several conditioned nodes and broad combination vocabulary |
| Specialist martial artist | one or two deeply supported source families |
| Natural-weapon lineage | dedicated/apex starting anatomy with different equipment access |

Whether a completely bare standard humanoid specialist may reach three pips through Permanent conditioning alone remains a central balance choice. The schema should permit it without making every ordinary skill additive.

## 5. Node-bound skill availability

### 5.1 Node footprint and skill payload remain separate

A serpent's teeth may carry only their physical innate footprint:

```yaml
lineage_innate:
  - node: teeth
    footprint:
      - { type: Pierce, pips: 2 }
```

Venom is supplied by the skill rendition and its lineage binding, not by adding Poison pips to the teeth:

```yaml
lineage_skill_binding:
  lineage: serpent
  node: teeth
  skill: bite
  allowed_payloads: [venomous]
```

If the teeth node is functionally denied, Bite and every skill rendition delivered through that node become unavailable.

### 5.2 Equivalent nodes produce source instances

A skill bound to symmetric or repeated anatomy produces one usable source instance per eligible active node:

```yaml
lineage_skill_bindings:
  - { skill: rake, node: left_claw,  payloads: [infectious] }
  - { skill: rake, node: right_claw, payloads: [infectious] }
```

Losing the left claw removes only the left-claw instance. The right-claw instance remains. The UI may group equivalent instances under one skill presentation while runtime and trace retain the selected node identity.

### 5.3 Optional producer dependencies

Deeper anatomy may be represented on the binding rather than on the node footprint:

```yaml
lineage_skill_binding:
  lineage: serpent
  node: teeth
  skill: bite
  payload: venomous
  requires_active_nodes: [venom_gland]
```

- Teeth denied → Bite and Venomous Bite unavailable.
- Venom gland denied → ordinary Bite remains; Venomous Bite is unavailable.
- The gland is a support dependency, not a delivery source and not a second Combo-Action hook.

Producer dependencies are optional anatomical depth, not required for every payload.

## 6. General skills and generated renditions

### 6.1 Technique archetype

```yaml
skill_archetype: bite
source_kind: innate_node
source_requirement:
  node_family: teeth_or_jaw
footprint_requirement:
  type: Pierce
  min_pips: 1
redistribution:
  target: Pierce
payload_slots: 1
```

The general technique owns:

- anchor and positional demand;
- AP structure;
- physical source requirement;
- footprint requirement and redistribution;
- ordinary effects;
- animation and targeting contract;
- whether aimed mode is supported.

### 6.2 Payload modules

```yaml
payload: venomous
condition: poisoned
delivery_route: inoculation
carrier_type: Pierce
```

```yaml
payload: searing
condition: burning
delivery_route: thermal_transfer
carrier_type: Pierce
```

```yaml
payload: freezing
condition: chilled
delivery_route: thermal_transfer
carrier_type: Pierce
```

The payload owns:

- condition or secondary-damage identity;
- carrier type and proof;
- target-layer route;
- scaling inputs and curve class;
- payload-specific resistance path;
- stacking/refresh policy and bounds;
- any AP, risk or availability adjustment.

The payload does not add footprint pips, satisfy footprint requirements or participate in zero-sum redistribution.

### 6.3 Derived renditions

The controlled composition is:

```text
technique archetype
+ authorised lineage/node binding
+ zero or one ordinary payload module
= derived skill rendition
```

Examples:

```text
Bite + venomous → Venomous Bite
Bite + searing  → Searing Bite
Bite + freezing → Freezing Bite
Rake + infectious → Infectious Rake
Kick + freezing → Freezing Kick
```

An ordinary rendition carries zero or one payload. Multiple payloads require an explicit exceptional rule.

## 7. Carrier proof and calculated payload magnitude

### 7.1 Payload is not an on-hit proc

Payload resolution occurs only after the primary node-footprint damage has resolved:

```text
action check
→ final redistributed footprint
→ primary damage by type
→ interception, armour, integrity and body routing
→ carrier proof
→ calculated payload
```

### 7.2 Carrier proof reads final resolved damage

```yaml
payload:
  condition: poisoned
  carrier:
    type: Pierce
    required_layer: body
    proof: positive_residual
  scale_from: carrier_resolution
```

For Poisonous Bite:

| Primary result | Pierce at body layer | Poison result |
| --- | ---: | --- |
| Attack misses | 0 | not delivered |
| Shield fully intercepts | 0 | not delivered |
| Armour stops all Pierce | 0 | not delivered |
| Other damage succeeds but Pierce is 0 | 0 | not delivered |
| Pierce reaches tissue | positive | calculate payload |
| Pierce reaches tissue; target immune | positive | delivery succeeds, payload resolves to 0 |

The gate reads the final resolved carrier contribution. Merely having Pierce in the base footprint is insufficient.

### 7.3 Runtime magnitude

No rendition authors a fixed condition amount. It declares the calculation contract. Runtime consumes the already-resolved combat outputs:

```text
resolved carrier result
→ transmission depth/quality
→ effective skill state
→ target payload susceptibility/resistance
→ struck-node properties
→ bounded payload magnitude
```

The carrier result already incorporates source pips, redistribution, attacker and target statistics, positional state, interception, armour and situational modifiers. Payload calculation must consume those outputs rather than independently applying the same inputs again.

Exact curves, caps and quantisation belong to the combat model and relevant `[SIM]` work. This proposal fixes dependency direction, not numeric values.

### 7.4 Secondary damage and recursion brake

Where the payload produces damage rather than only a condition, it creates a linked secondary event after carrier proof. That event resolves through the appropriate typed defence and target layer.

A payload event:

- cannot become the carrier for another payload;
- cannot recursively trigger itself;
- must not award the same causal credit twice;
- retains the primary action, source node and carrier proof in its trace.

## 8. Armour, equipment slots and target layers

### 8.1 Bind to target anatomy, derive equipment interception

A skill targets a body node. It does not name a target equipment slot. The equipment model derives which functional items cover that node:

```text
target node
→ shield interception, if any
→ covering equipment by slot and coverage
→ construction, typed defence and integrity
→ body layer
```

`Unarmoured` is derived when no functional covering item intercepts the selected node. It is not a separately persisted condition.

### 8.2 Layer trace

Primary combat resolution exposes a deterministic trace:

```yaml
carrier_trace:
  type: Pierce
  target_node: torso
  layers:
    - { layer: shield, intercepted: false }
    - { layer: armour, item: plate_chest, incoming: ..., absorbed: ..., residual: ..., integrity_delta: ... }
    - { layer: body, received: ... }
```

Payload delivery reads this trace rather than final HP damage alone.

### 8.3 Payload routes

| Route | Required proof | Typical use |
| --- | --- | --- |
| Inoculation | carrier reaches viable body tissue | venom, infectious bite |
| Surface contact | carrier reaches an exposed body or covering surface | contact toxin |
| Armour corrosion | carrier damages an armour layer | acid-coated claw |
| Thermal transmission | positive heat/cold transfer through the struck layers | searing/freezing strike |
| Structural implantation | carrier breaches a permitted structural/body layer | barb, parasite |

Armour class establishes broad behaviour, but the result comes from the complete item state: coverage, construction, typed defence, integrity, gaps, shield interception and current damage. Heavy armour receives no universal payload immunity.

## 9. Anatomical targeting

### 9.1 Normalised area distribution

Each realised body template supplies relative anatomical area weights. Runtime computes:

```text
effective_weight(node)
= anatomical area
× pose and exposure
× range and attack arc
× cover
× shield geometry
```

Then:

```text
P(node | successful attack)
= effective_weight(node) / Σ effective_weight(eligible nodes)
```

Authored weights need not total 100. Runtime normalisation produces the percentage.

Armour ordinarily changes resolution after node selection, not the unaimed anatomical probability. Cover, posture and shield geometry may change which area is exposed before normalisation.

### 9.2 Anatomy-depth aggregation

Finer body-template nodes aggregate into the target tier's realised anatomy:

- Trash: no node distribution; HP and integrity only.
- Standard: coarse five-region distribution.
- Elite: full targetable nodes.
- Commander: full nodes plus signature-linked anatomy.

The same underlying area weights therefore support coarse and detailed targets without separate hand-authored probability tables.

## 10. Aimed skill modes

### 10.1 Skill capability

Appropriate skills may declare an aimed mode:

```yaml
aimed_mode:
  permitted_granularity: coarse | targeted
  ap_surcharge_rule: ...
  aim_strength_rule: ...
```

Sweeps, explosions, broad breath attacks and other area actions may remain unaimable.

The player selects a realised body node and sees:

- additional AP cost;
- attack-success probability;
- conditional selected-node placement probability;
- combined selected-node hit probability.

### 10.2 Aiming reweights rather than overrides

```text
aimed_weight(selected node)
= effective_weight(selected node) × calculated aim strength
```

All eligible weights are then renormalised. Aiming increases the chance of the selected node but does not guarantee it.

If the attack succeeds and placement does not land on the selected node, the actual node is sampled from the reweighted distribution. Placement failure does not automatically turn an otherwise successful attack into a miss.

Aim strength and AP pressure derive from the combat model, including target area, attacker skill and fields, target motion/posture, range, cover, skill precision and requested granularity. Exact formulas remain `[SIM]` work.

### 10.3 Payload relationship

Aiming improves the probability of selecting a node whose covering layers are favourable to the carrier. It never guarantees carrier proof or payload delivery.

```text
P(payload effect)
= P(attack succeeds)
× P(selected node | hit)
× P(carrier proof | node and layers)
× payload resolution against target susceptibility
```

## 11. Enemy aimed-mode access and selection

### 11.1 Acting-tier capability

| Attacking enemy tier | Aimed mode |
| --- | --- |
| Trash | unavailable |
| Standard | unavailable |
| Elite | available where the skill supports it |
| Commander | available, including signature tactics and observed history |

This restriction concerns the **attacking enemy tier**. It does not remove the player's coarse ability to aim at a Standard target.

### 11.2 Target anatomy remains independent

| Target tier | Available anatomical resolution |
| --- | --- |
| Trash | none |
| Standard | coarse five-region aim |
| Elite | full node aim |
| Commander | full node aim plus signature-linked nodes |

### 11.3 Perception-bound target choice

Elites and Commanders may score only perceived candidate nodes:

```text
aim_score(node)
= perceived placement probability
× perceived carrier-success probability
× tactical value for this skill
× behaviour preference
× information confidence
− AP and positional risk
```

They do not automatically target the objectively lowest-armoured hidden node.

Valid influences include:

- visible exposure or armour damage;
- a known wound;
- the node operating an observed weapon or faculty hook;
- locomotion or stance value;
- the skill's carrier and payload route;
- prior observed bounces or penetrations;
- behaviour tags and Commander tactics.

When information is insufficient, the enemy uses the largest visibly exposed suitable region or the unaimed mode.

## 12. Authoring and automation pipeline

### 12.1 Required authoring grains

The design implies at least these distinct records or equivalent normalised relations:

1. lineage innate footprint per body node;
2. general skill archetype;
3. payload module;
4. lineage skill-to-node binding;
5. optional support-node dependency;
6. generated rendition identity;
7. equipment-to-node coverage relation;
8. aimed-mode skill contract.

These must not be collapsed into equipment `chassis_profiles` or resurrect `[Innate]` as a faculty.

### 12.2 Deterministic generation

The generator may compose only explicitly authorised parts. A stable identity may follow a deterministic shape such as:

```text
skill.bite@node.teeth+payload.venomous
```

Presentation may display `Venomous Bite`, while runtime and telemetry retain technique, payload and selected-node identity separately.

Localisation should derive from governed naming templates with an override field for exceptions; it must not be improvised independently by runtime.

### 12.3 Automatic validation

The pipeline can hard-reject:

- binding to a node absent from the lineage's body template;
- technique used through an incompatible node family;
- unmet base-footprint requirement;
- unauthorised payload rendition;
- too many ordinary payloads;
- undefined payload condition, route or carrier proof;
- dependency node outside the body template;
- payload recursion;
- aimed granularity finer than the realised target anatomy;
- aimed mode used by a Trash or Standard enemy actor;
- use of world-truth armour data by enemy target selection.

### 12.4 Derived regression fixtures

For every node-bound payload rendition, automatically generate at least:

1. delivery node active/inactive;
2. optional producer node active/inactive;
3. attack miss;
4. successful attack with shield interception;
5. successful attack with carrier fully absorbed by armour;
6. non-carrier damage positive while carrier damage is zero;
7. positive carrier residual at the required layer;
8. carrier succeeds but payload immunity resolves magnitude to zero;
9. equivalent paired node lost while its sibling remains;
10. deterministic replay and trace identity.

Aimed-mode fixtures additionally cover normalisation, coarse aggregation, AP pricing inputs, placement failure fallback and enemy-tier rejection.

## 13. UI and legibility

The player needs to see the causal chain without reading formulas:

- which node delivers the skill;
- which node injury disables it;
- which optional organ supports its payload;
- which damage type carries the payload;
- whether the payload requires contact, armour damage or tissue penetration;
- attack chance, aimed-placement chance and combined chance;
- visible/perceived armour information used for the estimate;
- why a payload failed: miss, interception, no carrier residual, resistance or immunity.

Equivalent limb instances may be grouped for readability, but node-specific denial and source selection must remain inspectable.

## 14. Remaining central choices

The architecture is coherent without fixing these values now, but central adoption must assign or preserve their homes:

1. exact payload scaling curves, caps and quantisation — combat model / `[SIM]`;
2. exact aimed-mode AP and aim-strength formulas — combat model / `[SIM]`;
3. payload stacking, refresh, decay and immunity semantics per condition family;
4. whether a bare standard humanoid specialist may reach three pips through Permanent conditioning alone;
5. authoring constraints for multiple Apex nodes on playable lineages versus exceptional enemies;
6. exact source-binding and generated-rendition schema in T/P;
7. actual Infection, Disease and Mutation consequences — still deferred and not to be disguised as Poison;
8. exact layer trace data contract between K, M and H;
9. whether failed aimed placement samples all eligible nodes or excludes the selected node after failure—the reweighted full distribution is recommended;
10. telemetry and balance thresholds for excessive anatomical breadth, redundancy or aimed-payload reliability.

None of these permits a fixed payload amount, an on-hit shortcut, hidden-information AI, or a universal four-pip body ceiling to enter implementation provisionally.

## 15. Cross-document adoption boundary

Central reconciliation should:

- author innate magnitude and striking-equipment rules in M;
- update T's lineage example and narrow its statement that footprint alone gates every innate skill;
- introduce node-aware skill source/binding semantics in T;
- preserve H-C8 and place node denial, target layers and anatomy aggregation consistently in H;
- preserve perception-bounded enemy choice in E/W;
- add the layer-trace and secondary-payload execution contract in K/M/H;
- assign P the normalised authoring grains only after the design contract is authored;
- update L, R, B, ROADMAP and VERSION-MANIFEST from source authorship;
- leave `◇P13` open until its actual schema gap is answered;
- keep `signed_off: PENDING` until technical re-audit proves the adopted contract.

The current technical C contains stale pre-0.32 Innate-faculty assumptions and must not be treated as authority or as an implementation of this proposal.

## 16. Consolidated decision statement

> **Innate combat is node-sourced, skill-shaped and anatomy-gated.** Four innate pips are the reference envelope for ordinary weapon-capable bodies, not a universal anatomical ceiling. Ordinary node sources concentrate at one to three pips, ordinary striking equipment contributes one offensive and one local defensive pip without lifting an ordinary source above three, and ordinary physical two-source actions draw at most three plus two. A node supplies the primary damage footprint; a governed skill rendition supplies any condition or secondary-damage payload. The rendition is available only through its authorised active node binding. Its payload resolves only after related final-footprint damage proves the required path through the target's normalised anatomy, coverage, armour and body layers, and its magnitude is calculated from the resulting combat trace rather than fixed. Appropriate skills may enter an AP-priced aimed mode that reweights the target's anatomical-area distribution. Trash and Standard enemies cannot use aimed modes; Elites and Commanders may do so only from perceived information. All derived renditions, source instances, delivery proofs and targeting outcomes remain deterministic, traceable and machine-validatable.
