# Triade — Tarot-Card Skill System Concept

**Recorded:** 17 September 2026  
**Reference corpus:** Triade v0.38.0  
**Governed against:** Triade v0.45.0; the disposition table assigns C1-A–E to their authoritative home and preserves unresolved proposals
**Status:** C1-A–E ADOPTED AT P·2.3f–i, 0.45.0; C1-F/G remain unresolved under ◇P14. This source proposal stays non-authoritative.
**Authority:** This record does not author a rule, term, number, schema, economy decision, or balance value. It may not be cited as an adopted Triade design. Any adoption must be reconciled and centralised through the governed design process.

## 1. Concept summary

**Disposition takes precedence over the original proposal below.** The original concept is retained as proposal evidence, not current rules. Acquisition order is channel → owned Technique Card → acquired access → installation → P12 candidate. Conferred Techniques remain cardless. Support Cards are separate. Mind/Form/Momentum are access requirements, never spendable card currency. The current slot, contribution, Combo and enhancement contracts are P·2.3f–i; original differing acquisition/lifecycle/link hypotheses are superseded or deferred there.

| Reconciliation | Disposition | Authoritative home |
| --- | --- | --- |
| C1-A [BOTH] | Card identity, Technique authority, cardless inherent Techniques and Inventory/visual handoffs adopted | P · 2.3f |
| C1-B [BOTH] | Atomic acquisition, pinned revision/provenance, character persistence and uninstall retention adopted | P · 2.3f |
| C1-C [BOTH] | Stable local depths, build/runtime distinction, tier capacity, distinct Support/resonance, highest-tier duplicate contribution adopted | P · 2.3g |
| C1-D [BOTH] | Vertical expressions, same-depth exact Technique && tier Combo authorization, two distinct hooks and cardless inherent endpoints adopted | P · 2.3h |
| C1-E [BOTH] | Authorized modify/add fields, compatibility, deterministic stacking, conflicts, duplicate suppression, explicit Combo transfer and bounds adopted | P · 2.3i |
| C1-F | Card information, discovery, mandatory Technique/Support templates and build preview remain pending | P · Part 8, ◇P14; V presentation handoff |
| C1-G | Support acquisition/persistence details and architecture fixture/validation closeout remain pending | P · Part 8, ◇P14 |

The record remains tracked until all questions are assigned or struck. No early retirement is authorized.

The proposed skill system has two acquisition categories.

### 1.1 Inherent skills

Skills granted by **Lineage** at its body nodes, and by class or starting-character definition. A `BodyTemplate` describes H-owned anatomy; it is not itself a skill-grant owner unless a later authoritative decision makes it one.

Intended characteristics:

- relatively standard and dependable actions;
- narrower Combo-Action capability;
- limited delivery scope, primarily damage, damage mitigation, reach, and condition carriage;
- lower use cost and/or higher availability;
- progression mainly through expertise upgrades;
- capable of acting as foundations for later tarot-card skill development.

These characteristics are design hypotheses for the later session, not consequences already established by the corpus. In particular, lower cost, higher availability, narrower combination scope, and expertise-led progression require individual rulings before adoption.

### 1.2 Tarot-card skills

Skills bound to collectible tarot cards. Candidate acquisition routes:

- drops from Commanders and bosses;
- fixed chest or reward loot after defeating specified bosses or special monsters;
- purchase from specialised town vendors;
- possible card crafting, subject to a separate economy and provenance decision.

Each card has a learning cost that may contain:

- a currency component;
- a Mind requirement or commitment, represented by blue;
- a Form requirement or commitment, represented by yellow;
- a Momentum requirement or commitment, represented by red.

The Triade floor would carry skill nodes or slots into which learned cards can be installed. Slot position may affect accessibility requirements. The motivating example is a slot near Momentum requiring greater Mind access, creating cross-corner tension rather than simply rewarding the nearest corner.

Slots are connected by links. Installed cards may use these links to enhance effects or form legal combinations.

## 2. Compatibility with the existing Triade system

### 2.1 Strong conceptual fit

The split reinforces several existing Triade distinctions:

- **source is not effect:** Lineage, body nodes, equipment, a faculty, and a card can grant access without each defining a separate resolution engine;
- **skill identity is not delivery:** a Technique can reference its source binding and legal delivery hooks while damage, mitigation, reach, conditions, movement, and timing remain explicit payload or action properties;
- **acquisition is not execution:** finding, buying, learning, installing, and executing a card are different states;
- **content is revisioned:** a card may reference an immutable Technique revision while character learning, installation, and expertise remain character state;
- **combinations are constrained:** card links can prepare or authorise combinations without invalidating the current two-delivery-hook Combo-Action ceiling.

### 2.2 Inherent remains a grant classification; Somatic is the natural-action Faculty

Since 0.41.0 the authoritative Faculty families are `[Arcana]`, `[Mudra]`, `[Psyche]`, and `[Somatic]`. Anatomical innate capability remains owned by Lineage and body nodes; Somatic only authorizes deliberate natural-node Techniques and supplies no footprint or hook. Therefore **inherent** remains a proposed acquisition/grant classification, not a synonym for Somatic and not a fifth Faculty family.

A future design should distinguish:

1. the Technique definition;
2. its grant source — Lineage/body node, class, equipment, faculty, card, or another authorised source;
3. its delivery hook or hooks;
4. the character's learned/expertise state.

This prevents `inherent`, `innate`, `faculty`, `class skill`, and `body action` from becoming overlapping identities.

### 2.3 Tarot cards should be an acquisition and installation layer

Recommended conceptual boundary:

- the **Technique** owns action meaning;
- the **TarotCard** owns collectible identity, acquisition metadata, learning requirements, presentation, and the Technique reference;
- the **character unlock** records that the Technique has been learned;
- the **installed-card state** records the skill-slot assignment and active links;
- the normal combat resolver executes the resulting Technique.

The card should not duplicate the Technique's full payload. Otherwise card and Technique revisions will drift.

### 2.4 Vocabulary collisions: `Deck` and `Arcana`

`[Deck]` is already a locked world-generation term for a traversable sheet inside a combat room. Using **Deck skills** or **skill deck** as a formal system name would create a direct cross-system collision.

For the future session, preserve **tarot-card skill** or **card-bound skill** as neutral working language. If *Deck* is desired for the player-facing presentation, central reconciliation must determine whether qualification is strong enough or whether another term is required. This record does not resolve the collision.

Conventional tarot language also uses *Major Arcana* and *Minor Arcana*, while `[Arcana]` is already a locked Triade faculty family. Card taxonomy must not reuse **Arcana** formally unless a later central vocabulary ruling proves the qualification unambiguous.

### 2.5 Triade floors are not currently spendable currency

The Triade floors constrain reachable state and class identity. They are not a pool that is paid down during learning. A card cost written as “2 Mind” is therefore ambiguous and could mean:

- minimum effective Mind floor;
- minimum reach or dwell in a Mind-oriented area;
- a persistent capacity reservation while installed;
- a permanent character-building commitment;
- a one-time spend from a new resource pool.

The last interpretation conflicts most strongly with the existing model and risks creating three new currencies disguised as floors. Until designed otherwise, the safest reading is **eligibility or persistent commitment**, not subtraction from a floor.

### 2.6 Positional skill slots can extend the geometry without rewriting it

The card layout should be treated as an overlay on Triade geometry, not as a replacement for the floor model.

A slot may eventually declare:

- stable slot identity;
- position or anchor in Triade space;
- accessibility tier;
- legal card families or tags;
- capacity or commitment rule;
- link endpoints;
- unlock provenance;
- whether it is permanent, run-scoped, class-granted, or otherwise acquired.

The proposed cross-corner example is promising: a slot close to Momentum could require Mind access, making it a synthesis or counterweight slot. However, the accessibility rule must be authored explicitly. Raw geometric distance should not silently become a cost formula.

### 2.7 Links must not bypass Combo-Action limits

Links could support at least three distinct functions:

1. **enhancement** — one installed card modifies an allowed property of another;
2. **sequence** — one card creates a state, Opening, or condition another card can exploit;
3. **Combo authorisation** — two cards may supply the two legal delivery hooks of a Combo-Action.

These functions should not be conflated. In particular:

- a chain of three linked cards must not become a three-source Combo-Action;
- occupancy, card adjacency, skill source, and delivery-hook count remain separate;
- enhancement must state the exact field or payload layer it may modify;
- all link resolution must be deterministic and attributable in traces.

### 2.8 Acquisition routes fit existing content domains but need ownership

The candidate routes map naturally onto existing systems:

- Commander/boss drops → enemy tier and loot-table entries;
- fixed post-kill chest loot → mission or encounter reward definitions;
- specialised vendor purchase → town service, inventory, and economy;
- crafting → recipe, inputs, provenance, failure/salvage, and output revision.

The concept is nevertheless blocked from full adoption by existing gaps:

- skill acquisition has no settled owner;
- `[Inventory]` remains undesigned;
- vendor services and several economy relationships remain open;
- actor Lineage/Physique authoring is settled at P·2.3a; concrete Faculty instances and actor/build × Faculty entitlement plus fixture relations remain unresolved;
- the runtime content-package contract is not yet fixed.

Card crafting should therefore remain a separate optional branch until acquisition, inventory, and economy ownership are established.

## 3. Candidate conceptual records

These are discussion aids, not an adopted schema.

| Candidate record | Responsibility |
| --- | --- |
| `TechniqueDef` | Candidate implementation name for the Technique definition; not an adopted record name. Action meaning: vocabulary, requirements, footprint, payload, timing, targeting, movement/influence, presentation hooks |
| `SkillGrantSource` | Normalised link from Lineage/body node, class, equipment, faculty, card, or other authorised source to a Technique revision |
| `TarotCardDef` | Collectible identity, rarity/presentation, acquisition class, learning-cost references, Technique revision, lifecycle and provenance |
| `CharacterSkillUnlock` | Character-specific learned state, source, acquisition event, and current expertise |
| `TriadeSkillSlotDef` | Stable overlay slot, position/anchor, accessibility rule, capacity, and link endpoints |
| `InstalledSkillCard` | Character-specific card/Technique assignment to one slot |
| `SkillLinkState` | Active connection between two occupied slots, including link function and validation state |
| `SkillExpertiseState` | Character progression separate from immutable content revisions |

Repeatable requirements, costs, sources, links, and payload entries should be normalised child rows rather than delimited cells or embedded prose.

## 4. Candidate lifecycle

1. Generate or place an exact card revision through an authorised loot, reward, vendor, or crafting source.
2. Acquire the card as an inventory/reward object.
3. Evaluate learning eligibility and cost.
4. Pay the governed currency component and satisfy the governed Triade requirement or commitment.
5. Record the character's Technique unlock and card state.
6. Install the learned card into an eligible Triade skill slot.
7. Validate active links, enhancement permissions, source hooks, and Combo-Action legality.
8. Execute the referenced Technique through the existing action resolver.
9. Attribute outcomes to the Technique revision, card revision, installed slot, link state, delivery hooks, and character expertise.

Whether learning consumes the physical card, preserves it, transforms it, or allows resale is unresolved.

## 5. Questions for the full design session

### System identity and ownership

1. What is the authoritative umbrella term: Technique, skill, card-bound skill, or another term?
2. Is **inherent** an acquisition class, a source class, or a player-facing grouping only?
3. Which document owns skill acquisition and the tarot-card layer?
4. Can the player-facing word *Deck* be used without violating the existing `[Deck]` lock?

### Learning and persistence

1. Is a card consumed on learning, retained as an installable object, or transformed into a permanent unlock?
2. Are learned cards permanent, run-scoped, character-scoped, or recoverable after death?
3. Is expertise attached to the character–Technique relation, the card instance, or both?
4. Can an inherent skill be upgraded directly, or only extended through card-bound Techniques?

### Triade slot geometry

1. Are skill slots fixed globally, authored per class, granted by Lineage, or unlocked during progression?
2. What does a Mind/Form/Momentum learning cost actually mean: threshold, reach, reservation, commitment, or spend?
3. Does slot position determine affinity only, or also accessibility and capacity?
4. How is the proposed cross-corner requirement derived and presented?
5. Are links fixed in the floor topology, created by cards, or authored by character progression?

### Links, enhancement, and combinations

1. Which fields may links enhance: cost, timing, reach, payload, condition carriage, targeting, or another bounded set?
2. Does a link authorise a Combo-Action, enhance one card, or only establish sequencing?
3. How are linked networks prevented from bypassing the exactly-two-delivery-hook rule?
4. Can inherent skills occupy slots and participate in links, or act as external roots?

### Acquisition and economy

1. Which enemy tiers and reward objects can provide cards?
2. Are boss/special-monster cards fixed authored rewards, weighted loot, or both in different contexts?
3. Which currency or currencies pay learning and vendor costs?
4. How do card rarity, duplicate cards, resale, salvage, loss, and replacement work?
5. Is crafting in the initial system or a later economy extension?

### Content, validation, and presentation

1. What is the minimum representative card fixture set?
2. How are card, Technique, link, slot, and expertise revisions packaged and migrated?
3. What tooltip/readability budget applies to a linked card network?
4. Which deterministic lints prove acquisition legality, slot eligibility, link legality, source hooks, and Combo-Action limits?
5. How are tarot identity, colour icons, and accessibility conveyed without depending on colour alone?

## 6. Required proofs if adopted

- An inherent skill and a card-bound skill using the same action resolver produce attributable traces.
- A lineage-owned body-node skill becomes unavailable or altered correctly when its delivery node is disabled.
- Mind/Form/Momentum eligibility is deterministic and does not mutate or spend the floor unless an explicit new rule authorises it.
- A legal two-card combination passes; a three-source linked combination fails before resolution.
- An enhancement link changes only authorised fields and cannot recursively amplify itself.
- The same content revisions, character state, slot layout, and named RNG streams produce the same installed network and proof digest.
- Boss reward, fixed chest reward, and vendor acquisition each resolve to an exact card revision.
- Colour-independent UI distinguishes Mind, Form, and Momentum costs and slot accessibility.
- Every card and link can be traced to immutable revisions and content hashes.

## 7. Recommended scheduling

The concept should inform—but not be silently folded into—the upcoming node-bound skill and payload work.

**Plan position: Session C, split at the Inventory/Economy boundary.** The dedicated tarot-card system begins only after both predecessor sessions close their design contracts:

1. **Session A — Carrier and Technique:** settle the Technique/source/payload/carrier contract and dispose the node-payload intake rulings required for it.
2. **Session B — Lineage and Faculty:** **closed 0.44.0.** Lineage/Physique grants, Faculty identities/profiles/vocabulary, entitlement/acquisition, candidate readiness, dependency locality, target-route contracts, deterministic evaluation, exact-candidate commitment and autonomous Plannable Actions are authoritative. This does not reopen H-owned anatomy.
3. **Session C1 — Tarot-card architecture — current:** C1-A–E are adopted at P·2.3f–i. C1-F/G now resolve card information, discovery, visual templates, build previews and architecture closeout. Any scheduled or triggered card action inherits P12-C's exact-candidate, autonomous due-node and no-silent-fallback rules.
4. **Stage 3 — Inventory and Economy:** settle custody, consumption/retention, duplicates, loss/recovery, resale/salvage, vendors, prices, and any crafting provenance.
5. **Session C2 — acquisition and installation contract:** realize the approved P-owned card/Technique references, unlock, expertise, slot/link, trace, validation and accessibility requirements after C1 closeout and Stage 3 custody/economy design, before broad Stage 4 content. Do not create a competing authority for C1-A–E.
6. **Stages 5–6 — concrete rewards:** author Commander, special-monster, encounter, and boss card placement only after those content owners exist.
7. Author schemas and fixtures only after the design homes and vocabulary are settled.
8. Validate with the headless simulator before broad card content production.

This places Tarot architecture after Carrier/Technique and Lineage/Faculty, then places its physical lifecycle after Inventory/Economy and before broad Stage 4 skill/spell content. Concrete enemy and boss rewards remain later content work.

## 8. Current disposition

**Partially dispositioned at 0.45.0.** C1-A–E are centralized at P·2.3f–i, with T/K/M/V/C integration handoffs and L vocabulary projection. C1-F/G remain ◇P14; the original proposal above has no authority. Implementation remains gated by C1 closeout, Stage 3 and C2. This record stays live and tracked; remaining acquisition/economy/presentation proposals do not become rules through this release.
