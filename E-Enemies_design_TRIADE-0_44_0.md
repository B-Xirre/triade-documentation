# Triade — Enemies & Bestiary Design

**Version:** 0.44.0
**Date:** 27 September 2026
**Status:** Extracted from Core Mechanic Part F at 0.11.0. Architecture settled; numbers pending simulation.

**Document set:** this is one of **ten**.

| Ref | Document | Filename |
| --- | --- | --- |
| **T** | Core Mechanic | `T-Core_Mechanic_design_TRIADE-0_44_0.md` |
| **M** | Stats, Items, Equipment | `M-Stats_Items_Equipment_design_TRIADE-0_44_0.md` |
| **L** | Lexicon | `L-Lexicon_design_TRIADE-0_44_0.md` |
| **V** | Visual Design | `V-Visual_design_TRIADE-0_44_0.md` |
| **K** | Combat Design | `K-Combat_design_TRIADE-0_44_0.md` |
| **W** | World, Maps & Dungeons | `W-World_Generation_design_TRIADE-0_44_0.md` |
| **H** | Damage & Health | `H-Damage_Health_design_TRIADE-0_44_0.md` |
| **E** | **Enemies & Bestiary** — *this document* | `E-Enemies_design_TRIADE-0_44_0.md` |
| **G** | Tile Pipeline | `G-Tile_Pipeline_design_TRIADE-0_44_0.md` |
| **P** | **Content Pipeline & Data Model** | `P-Content_Pipeline_design_TRIADE-0_44_0.md` |
| — | *Open Items Index* | `B-Open_Items_Index_TRIADE-0_44_0.md` |
| — | *SIM Numbers Register* | `Y-SIM_Numbers_Register_TRIADE-0_44_0.md` |
| — | *Validation Rules Index* | `R-Validation_Rules_Index_TRIADE-0_44_0.md` |

**Scope.** This document is **E**. It owns the enemy capability ladder, tag composition, behaviour policy, enemy authoring and the combination-space validation that follows from them.

It does **not** own the state model, floor geometry or the action contract (**T**), combat resolution (**K**), the weapon and armour records enemies share with players (**M**), anatomical depth per tier (**H** — derived *from* the ladder defined here), or encounter placement and boss escalation structure (**W**).

**Founding invariant, retained in T:** enemies and characters are the same system — innate floor shape plus equipped vocabulary, one schema with two consumers. An enemy runs the identical action contract with the player and enemy roles swapped, so **every character validator covers enemies for free**. Nothing in this document may break that equivalence.

---

## Part 0 — Why this is a separate document

The capability ladder outgrew its section. Three documents now derive structure from it:

| Consumer | Derives |
| --- | --- |
| **H** · Damage & Health | Anatomical depth per tier — Trash none, Standard 5-node template, Elite full, Commander full plus signature-linked nodes (H·11). The `[Wounded]` behaviour tag (H·11.4) |
| **W** · World Generation | Enemy tier mix scaling with Delve depth (W·13.1); boss escalation across a Stratum, the same boss met at 3, 9 and 10 (W·5.2) |
| **K** · Combat Design | Enemy credit economy — Elite = Edge, Commander = Edge + Grit, neither gets Temper (K17) |

A section consumed by three documents is a subsystem. Bestiary content will also accumulate here faster than anywhere else in the set.

---

## Part 1 — The capability ladder

*Formerly T·F.0. Section numbering preserved as `F.n` so existing cross-references in T, K, W, H and L remain valid.*

### F.0 The four-tier capability ladder

The loop decomposes into four capabilities, and enemy difficulty is built by granting *loop stages*, not bigger numbers. Each tier is a qualitatively different threat, so a player reads which one they face by *what the enemy does with their exposure*, not by a health bar.

| Tier | Role tag | Capabilities | Threat the player feels |
| --- | --- | --- | --- |
| **Trash** | — | subject only: has a position, can be pushed into Openings and read/exploited by the player | I can exploit them; they cannot manipulate me |
| **Standard** | — | + creates Openings on the player → applies **[Back-foot]** | my next action against this enemy is compromised |
| **Elite** | `[Elite]` | + reads player Openings → one-shot **[Advantage] action** | it just did something it is normally locked out of |
| **Commander** | `[Commander]` | + a successful Advantage action banks **Grit** → **[Signature Action]** | it is building toward something I must prevent |

The escalation is *tempo → capability → threat*. Standard enemies tax your rhythm; Elites occasionally break their own rules; Commanders build toward a payoff. Reading and the Grit economy arrive **together** at the top tiers, because a read without Grit to spend is half a mechanic.

**[Back-foot] (Standard).** Creating an Opening on the player puts them [Back-footed] — relational and scoped exactly as in C.3a. Non-stacking per attacker; multiple Standard enemies create separate relationships; cleared by a successful action against that specific attacker (or, for an ambient [for All] Opening, [Back-footed] against all tier-2 opponents until balance is regained). It costs the enemy no economy machinery — the enemy shoves, the player eats a penalty.

**[Advantage] action (Elite).** An Elite that reads a player Opening earns [Advantage against the player] and may fire a one-shot Advantage-gated action. Its success scales on **the player's dot distance from the player's own class home position** — overcommitment arms the enemy. Play near home and the Elite's special action mostly fizzles; lean deep into a corner and it lands. Commitment cuts both ways: every step you take from home to enable *your* region actions also raises the enemy's conversion rate against you. Because [Advantage] is a first-class relational state, an Elite that is *tactically* better positioned (high ground, flank) can fire its Advantage actions **without** first creating an Opening — circumstance is the other path to Advantage (C.3a).

**[Signature Action] (Commander).** Only a *successful* Advantage action banks the Commander's Grit toward its Signature — a boss-tier skill. This gates the Signature behind the player's own exposure: play tight, the Commander's reads fizzle, no Grit banks, the Signature never charges. The player's positional discipline is the throttle on the boss's ultimate, and a charging Commander is legible evidence that *you* have been overcommitting. The wind-up is also the Commander's own moment of exposure — to read you it must commit position, so the instant it threatens most is the instant it is most exploitable.

**Elites and Commanders obey the geometry.** Their reads are position-dependent exactly as the player's are (C.6). You can watch an Elite lean into Pressure and know it is now poorly placed to read you, and bait it accordingly. An Elite that read from anywhere would be an opaque, unfair threat; an Elite bound by the same simplex is a duel you can outplay positionally. This is the more expensive AI and it is the reason the loop exists at all.

**Optional boss lever:** a Commander soft-countered by very disciplined play can be given a Standard-tier [Back-foot] pressure tool to *drive the player off home position* and manufacture the exposure it needs — the tier-2 create-capability handed to a tier-4 enemy, so it costs no new machinery.

### F.0a Aimed-mode access — acting tier, not target tier [AUTHORED 0.39.0]

| Attacking enemy tier | Aimed mode |
| --- | --- |
| **Trash** | unavailable |
| **Standard** | unavailable |
| **Elite** | available only where the selected Technique supports it |
| **Commander** | available only where the selected Technique supports it, including signature tactics |

This is an **acting-tier capability**. It does not change H·11's independent target-anatomy depth: the player may use a coarse-capable Technique against a Standard target, while a Standard enemy still cannot aim at the player's full anatomy. T·A3.8b supplies the Technique ceiling and H·6.2a supplies the reweighted placement; an enemy role grants permission to use that existing mode, never a new targeting path.

**Enemy aim is perception-bound.** Elite and Commander policy may rank only candidate Body Locations supported by their `PerceptionSnapshot`, public combat state and permitted observed history. Valid evidence includes visible exposure or armour damage, a perceived wound, an observed delivery node or locomotion function, and prior perceived bounces or penetrations. Ranking may weigh perceived placement chance, perceived carrier success, tactical value, behaviour preference, confidence, AP surcharge and positional risk. It may not query hidden armour, wounds, nodes or objective carrier odds.

When information is insufficient, the enemy uses the largest visibly exposed eligible Body Location or the unaimed form of the Technique. The choice follows the same deterministic behaviour-policy path as every other bot decision; hidden world truth never breaks a tie.

### F.1 Tag composition

Enemy shape is composed from typed tags with cardinality rules:

| Enemy Tag | Does what | Cardinality | Example |
| --- | --- | --- | --- |
| **Chassis** | base floor shape **and body template** | exactly 1 | Goblin |
| **Physique** | size and mass; biases Form and Pressure | 1 | Average size |
| **Behaviour** | drives AI policy | 1–2 | Compulsive, Simpleminded |
| **Equipment** | supplies region vocabulary | 0–2 | Pike |
| **Faculty** | acquired or conferred vocabulary authorization — `[Arcana]` / `[Mudra]` / `[Psyche]` / `[Somatic]` | ≥1 | Somatic Bite, Arcana Hex |
| **Role** | tier on the F.0 capability ladder | 0–1 | Elite, Commander |

**Role tags are defined as capability grants, not labels.** `[Elite]` = "unlocks reading player Openings + the one-shot [Advantage] action"; `[Commander]` = "+ banks Grit from successful Advantage actions → [Signature Action]." Absence of a Role tag leaves an enemy at Standard (creates Openings, applies [Back-foot]) or Trash (subject only), per its other tags.

**Every enemy has at least one `[Faculty]`, so cardinality-0 equipment is no longer cardinality-0 vocabulary.** [LOCKED 0.13.0; amended 0.40.0] Equipment stays `0–2`; a Trash-tier goblin with no equipment may acquire Somatic authorization for Techniques bound to active lineage-owned node profiles. Before 0.13.0 such an enemy had no vocabulary path at all and could not act — a hole this table did not know it had. Somatic adds no footprint or hook; the bound node remains the source.

**Unarmed footprints are authored per node on the lineage** (T·A4.8a, rule **H-C7**). A serpent's template has no upper-limb group and therefore no punch slot, with nothing authored per chassis. Authoring slots per chassis would repeat the mistake H-C6 exists to prevent.

**Chassis names the body template, and is universal.** [LOCKED 0.13.0] A chassis carries `body_template: ref(BodyTemplate)` (H·5.3). Templates are **referenced, never inlined**: there are many chassis and few body plans, so inlining coverage weights per chassis is the authoring explosion templates exist to prevent, and it would force H·11's tier ladder to be re-cut for every chassis. Rule **H-C6**.

`[Chassis]` applies to players too — a player carries exactly one, and **the source is the lineage** (T·A4.8a, `◈H15` closed 0.27.0). **The enemy case additionally sets base floor shape; the player case does not**, because a player's floor renders from stat fields (T·A4.2–A4.4) with class supplying a zero-sum stat offset (T·A4.8). Stated because the asymmetry otherwise invites correction.

### Physique — the size ladder [AUTHORED 0.27.0]

**Sizes are `Small → Average → Large → Giant`, and a lineage offers a subset.** A Rat offers Small and Average; a Human Small, Average and Large; a Troll all four. Exactly one is flagged **typical** — the lineage's ordinary member — and it need not be Average: a Rat's typical is Small, a Troll's is Large.

**A size the lineage does not offer is `null`, which is not the same as zero.** `null` means the size does not exist for that lineage; zero would mean it exists and is neutral. Only the **typical** size is zero.

> **Size is a position on the lineage's own ladder, never a world-scale measure.** A Small Troll is small *for a Troll*; nothing claims it is physically smaller than a Large Rat. Mass is carried by **Frame** (T·A4.1) and reaches the sheet through the pairs below. Stated as a negative because someone will otherwise make the ladder absolute and break every lineage whose typical is not Average.

**Each non-typical size carries up to two additive integer pairs, and every pair sums to zero.** A pair names one stat gained and one given up; the size's position sets the direction, so the same axis reads both ways.

*Worked example — Goblin, typical Average:*

| Size | Pair 1 | Pair 2 |
| --- | --- | --- |
| Small | −1 Strength, +1 Finesse | −1 Frame, +1 Stamina |
| **Average** | *typical — zero* | — |
| Large | +1 Strength, −1 Finesse | +1 Frame, −1 Stamina |
| Giant | *null — Goblins have no Giant* | — |

**Two pairs is the ceiling, by rule.** Beyond that, size stops being a lens on a lineage and becomes a second lineage — the *closed, short source list* discipline A2.2 applies to any stacked source.

**Additive integers, never multipliers.** A `×0.9 / ×1.1` pair only conserves when both base stats are equal, so it silently leaks the moment a character has more Strength than Finesse; and **P-C2** bars floats from persisted state because **W-C10** bars float-derived values from the proof digest. Every other conserving layer in the corpus is an additive integer vector, and this is one too.

**Arithmetic: chassis-plus-modifiers, then renormalise.** One chassis establishes the base shape; modifiers adjust it; the result is renormalised against the floor budget and per-corner cap. Predictable, order-independent, and it makes illegal enemies impossible to generate rather than merely unlikely.

Worked example — *Goblin Pikeman*: `[Goblin]` chassis, `[Average size]` physique, `[Compulsive] [Simpleminded]` behaviour, `[Pike]` equipment. Result: a floor shape leaning toward Pressure over Mind, with Pike vocabulary and an AI policy that overcommits and never uses Instinct actions. Adding `[Elite]` grants credit layers and advanced vocabulary without touching anything else.

### F.2 Behaviour is the AI

**Bots read perceived committed intent, never world truth** [ADOPTED 0.36.0, CR-11]. Behaviour consumes the `PerceptionSnapshot` plus public combat state (**W-H17**) — currently perceived entities, last-known facts, permitted sensory events. **An Intent Marker is visible to a bot only where that bot perceives it**, and the player-facing timeline grants bots nothing. Losing sight changes an information state; it does not delete the target or reveal where it went.

**Bots plan through the same readiness predicates as players** [ADOPTED 0.43.0, ◈P12-B]. Policy may rank `known` Techniques and `selectable` candidates using only its `PerceptionSnapshot` and public state; it may commit only a fully `executable` candidate. An authored area route may strike an unseen occupant after resolving valid cells, but the possibility of that hit does not reveal or target the occupant during planning. Direct non-visual targeting requires the same explicit lock or mental-link route as any other actor.

If `[Compulsive]` means "commits to Momentum early and will not disengage" and `[Simpleminded]` means "never uses Instinct-region actions," then the tag set **is** the behaviour policy. One policy engine reading behaviour tags replaces per-enemy AI.

The second-order benefit matters more than the authoring saving: enemy behaviour becomes **learnable and transferable**. A player who works out that Compulsive things overcommit carries that knowledge to every enemy carrying the tag, for the rest of the game.

### F.3 Equipment records are shared

`[Pike]` is the same data record as a player polearm — same archetype, same Triade signature. Weapon archetype work pays off on both sides of the fight, and enemy traces validate through machinery already built.

### F.4 Validating the combination space

Tag combinations grow faster than they can be simulated exhaustively.

- Validate `chassis × role` exhaustively — small matrix.
- Sample the modifier space.
- Rely on floor renormalisation to guarantee no combination is structurally illegal.
- Lint for contradictory pairs.
- Validate at **encounter** level too: three enemies sharing a behaviour play like one large enemy, so encounter generation requires tag diversity within a group.

---

## Part 2 — Open items

| # | Question | Status | Owner |
| --- | --- | --- | --- |
| ~~◈E1~~ | **RESOLVED 0.13.0.** Unspent enemy Edge is displayed on the enemy portrait in the **activation sequence timeline** (K·3.1), as 0–3 pips — the same representation as player Edge (K·9.1), which suits the founding invariant. It **does not** count against K12's four-item visible-condition cap: that cap governs conditions, credits are a separate channel. Encoding is a V requirement (V·4) | — | — |
| ◇E2 | **Behaviour tag library size.** How many behaviour tags before the policy engine becomes unpredictable, and before players stop being able to learn them | **[OPEN]** [SIM] | Balance |
| ◇E3 | **Contradictory tag pairs.** F.4 requires a lint for these; the actual pair list is unwritten | **[OPEN]** | Content |
| ◇E4 | **Encounter tag diversity threshold.** F.4 requires diversity within a group — three enemies sharing a behaviour play like one large enemy. The threshold is unset | **[OPEN]** [SIM] | Balance |
| ◇E5 | **Chassis → body template mapping.** H·5.3 makes the body graph an instantiable template and 0.13.0 makes `[Chassis]` the thing that names one. The question is now bounded: which templates exist, and which chassis map to each — a many-to-few mapping, not an open content pile. Still blocks ◇V1 (rigs) and ◇G6 (palettes) | **[OPEN]** | Content / H |
| ◇E6 | **Commander signature-linked nodes.** H·11.3 anchors a `[Signature Action]` to breakable anatomy. Which Commanders, which nodes | **[OPEN]** | Content / H |
| ◇E8 | **High-ground density is a boss-difficulty parameter.** W§12 confirms `high_ground` as a *derived* tag. Because circumstantial Advantage (high ground, flank) is one of exactly two routes to an Elite's one-shot Advantage action — and a *successful* Advantage action banks Commander Grit toward the `[Signature Action]` — the level generator's high-ground density directly sets Commander Signature frequency. The band must be set against S-E03, not chosen by level design | **[OPEN]** [SIM] | Balance / W |
| **◇E11** | **Enemy tier mix must implement the encounter budget.** M·9.7's `E(x) = P(x)(0.92+0.18x)` is composite — durability, action quality, behaviour tags, spatial pressure, resource denial. Which levers E moves per band is unwritten *(= **◇W17**)* | **[OPEN]** | Balance / M |
| ~~**◈E10**~~ | **DISSOLVED 0.32.0 — not answered, made unaskable.** Bite was deferred here as a fourth `[Innate]` slot. There are no slots: a lineage authors a footprint at its teeth or it does not, and a jaw wound denies it as node state (T·A4.8a) | — | — |
| ◇E9 | **`[Incursion]` escalation past the ladder.** The ladder has four tiers and no fifth. Unrestricted `[Incursion]` depth (W§5.9) must escalate by density, tag composition and encounter size instead. This makes Incursions the natural harness for **◇E2** and **◇E4** — a mode generating arbitrarily deep encounters is the best available test of whether the tag system stays learnable | **[OPEN]** [SIM] | Balance |
| ◇E7 | **Boss escalation by kind.** W·5.2 requires the same boss to change across forms at 3, 9 and 10 *by kind, not number*. What changes is unwritten (◇W8) | **[OPEN]** | Content / W |

---

## Part 3 — Validation

Enemy validation is character validation. These are the additional rules specific to composition, all registered in the Validation Rules Index.

| ID | Rule | Severity |
| --- | --- | --- |
| **E-C1** | Every enemy carries a position `(m,f,i)` summing to 1 | Critical |
| **E-C2** | Tag arithmetic renormalises against the floor budget (`ΣF ≤ 0.45`) and per-corner cap (`F ≤ 0.25`) — no combination may produce an illegal floor | Critical |
| **E-C3** | Elite and Commander reads are position-dependent exactly as the player's are (T·C.6) — no enemy reads from anywhere | Critical |
| **E-C4** | Exactly one chassis per enemy; cardinality respected for every tag category | Critical |
| **E-C5** | Every chassis names exactly one `BodyTemplate`; no chassis inlines coverage weights *(H-C6)* | Critical |
| **E-C6** | Every enemy carries at least one acquired or conferred `[Faculty]`; no enemy has zero authorized vocabulary paths. Somatic authorization adds no physical source — its bound active node remains the source | Critical |
| **E-C7** | A physique size map carries **at most two pairs** per size, each pair an additive integer gain and loss that **sums to zero**. The lineage's `typical` size carries none; a size the lineage does not offer is `null`, never zero | Critical |
| **E-C8** | Trash and Standard enemy actors cannot use aimed modes. Elite and Commander actors may do so only when the Technique permits and only from perceived candidate anatomy; target tier remains an independent H-owned constraint | Critical |
| **E-C9** | Enemy policy ranks `known` Techniques, `selectable` candidates and Plannable Action acquisitions only from its `PerceptionSnapshot` plus public state, and commits only an `executable` candidate. It uses the same exact-candidate, autonomous due-node and no-retarget rules as the player. Area or fixed-spatial resolution may hit an unseen occupant but never reveals that occupant during planning; identity-bound plans require perceived identity and direct non-visual targeting requires an explicit authored route | Critical |
| **E-H5** | An enemy's unarmed footprint is authored per **node** on its lineage, never per chassis and never as a slot *(H-C7, restated 0.32.0)* | High |
| **E-H1** | `chassis × role` matrix validated exhaustively | High |
| **E-H2** | Encounter generation enforces behaviour-tag diversity within a group | High |
| **E-H3** | No contradictory tag pairs (lint) | High |
| **E-H6** | Enemy tier mix per band implements M·9.7's encounter budget, not a health multiplier | High |
| **E-H4** | Enemy traces pass the redundancy gate — no two enemies play identically (T·I.4) | High |
| **E-M1** | Modifier space sampled, not exhaustively simulated | Medium |

---

## Changelog

| Version | Change |
| --- | --- |
| **0.44.0** | **P12-C planning boundary propagated.** Bots use the same exact-candidate, autonomous due-node, acquisition and no-retarget rules under their existing perception boundary; fixed-spatial effects may hit but never pre-reveal unseen participants (**E-C9**). |
| **0.43.0** | **P12-B propagated to enemy planning.** Bots consume the same `known`/`selectable`/`executable` predicates under their perception boundary; an area route may hit but never pre-reveal an unseen occupant (**E-C9**). |
| **0.42.0** | Version alignment only. P12-A changes entitlement persistence and projection, not enemy capability tiers, tags, anatomy or aiming authority. |
| **0.41.0** | Version alignment only. P11's concrete Faculty profiles and authorizations do not change enemy capability-tier, tag, anatomy or aiming authority. |
| **0.40.0** | **Somatic propagated into enemy composition.** Every enemy still carries at least one Faculty; Somatic authorizes natural-node Techniques while lineage profiles and active nodes remain their physical sources (**E-C6**). |
| **0.39.0** | **A2 acting-tier access authored in F.0a.** Trash and Standard enemies cannot aim; Elite and Commander enemies require Technique support and may choose only from perceived candidate anatomy. Target tier remains independently H-owned (**E-C8**). |
| **0.36.0** | **Perception-limited bot inputs authored** — behaviour consumes the `PerceptionSnapshot` plus public combat state (**W-H17**); an Intent Marker is visible to a bot only where that bot perceives it. |
| **0.32.0** | **`◈E10` dissolved — not answered, made unaskable.** Bite was a deferred fourth `[Innate]` slot; there are no slots. **E-H5 restated** to per-node authoring, and the Faculty tag narrowed to learned or granted sources. |
| **0.27.0** | **Physique size ladder authored** — `Small → Average → Large → Giant`, a per-lineage subset with one **typical**; up to two additive integer pairs per non-typical size, each summing to zero. **`[Medium size]` → `[Average size]`** — the old value was undefined by the ladder and collided with M·2A.7's `Medium` weight class. **`E-C7`** added. Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | `◈E1`'s row gained its missing cell — same three-under-four defect as T (MD056). Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | Four `Part E<n>` headings become `Part <n>`. ◇E11 registered in the Open Items Index, where it had never appeared. Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **31 glyphed identifiers in this document.** |
| **0.16.0** | **F.1's `Category` column renamed `Enemy Tag`** — `category` is the locked item classification (M·2.1, P·1.3) and this was a third sense of the word. No mechanical change; the six tag classes and their cardinalities are untouched. Propagated to L, whose *Tag composition* entry was **also missing `faculty`** — added at 0.13.0 at cardinality ≥1 under rule **E-C6**, and absent from the Lexicon for three versions. |
| **0.13.0** *(Stage 1)* | **`[Faculty]` added to F.1's tag categories at cardinality ≥1.** This closes a hole the table did not know it had: with Equipment at `0–2`, a Trash-tier enemy authored with no equipment had **no vocabulary source and could not act**. `[Innate]` slots derive from the body template rather than the chassis (**H-C7**), so a serpent has no punch slot without anything being authored. New rules **E-C6**, **E-H5**. **◇E10 registered** — bite as an Innate slot, deferred to the bestiary workstream. |
| **0.13.0** | **◈E1 closed** — unspent enemy Edge shows as 0–3 pips on the enemy portrait in the activation timeline, matching the player's representation; explicitly outside K12's condition cap. **`[Chassis]` gains `body_template`** and becomes universal across players and enemies, with the deliberate asymmetry stated: the enemy case also sets base floor shape, the player case does not. New rule **E-C5**. **◇E5 narrowed** from "which chassis need non-humanoid templates" to a bounded chassis→template mapping. |
| **0.14.0** | **◇E11 registered** — M·9.7 fixes enemy scaling as an encounter budget following the career power curve, covering durability, action quality, behaviour tags, spatial pressure and resource denial. Scaling enemy health alone would lengthen combat without testing the Triade. E does not yet say how the tier mix implements it *(partner: **◇W17**)*. New rule **E-H6**. |
| **0.12.0** | Two open items registered. **◇E8** — high-ground density set by world generation directly drives Commander Signature frequency through the circumstantial-Advantage route, so the band belongs to Balance rather than to level design. **◇E9** — `[Incursion]` depth is unrestricted while the capability ladder has exactly four tiers, making Incursions the harness for ◇E2 and ◇E4. W§5.8's storey table gives the boss arena one, two and three storeys at its three meetings, which is a partial structural answer to ◇E7/◇W8: the shape of the escalation, not its content. Document set grows to nine. |
| **0.11.0** | Document created by extraction from Core Mechanic Part F. Content preserved verbatim; `F.n` section numbering retained so existing cross-references stay valid. Added E0 (rationale and consumer map), ◇E2 (open items, seven registered), ◇E3 (validation rules with IDs). |
