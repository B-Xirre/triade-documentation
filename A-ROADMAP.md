# Triade — Roadmap

**Unversioned.** This file is a rolling statement of what happens next. It is not renamed at a version bump.

---

## What this document is, and is not

| | |
| --- | --- |
| **Owns** | Workstream ordering, the reason for that ordering, entry and exit conditions per stage |
| **Does not own** | What any individual item *is*. Item content lives in `TRIADE-Open Items Index`, which is **derived from markers** and must never be duplicated here |
| **Reference discipline** | Items appear by ID only — `S-H01`, `◈T6`, `◇E5`. If this file starts explaining what an item means, that content belongs in its source document instead |

**Two lists of open topics is the failure this rule prevents.** One generated, one hand-maintained, drifting apart.

**Staleness.** This file has no version string, so it cannot go stale by filename. It goes stale by *silence*: a stage that ships without its exit condition being struck here is a defect.

---

## Sequence

> **Exit conditions updated at 0.18.0.** Identifiers now carry a namespace glyph — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level (L·§0). An exit condition that names an unglyphed `Xn` is ambiguous and does not count as met. Two conditions moved as a result:
>
> - **Stage 2c** gains `◇P9` — the cell-level versioning escalation has no measured trigger, so "content authoring is stable" cannot be asserted until it is either measured or struck.
> - **Stage 5** gains `◇E11` / `◇W17` as a partner pair; they were live in E and W but absent from the register, so no stage had been carrying them.
>
> **Closed at 0.18.1.** Non-goals take `⦻` — `⦻W1`–`⦻W5`, `⦻H1`–`⦻H6`. The `N` collision with structural complexity (W·5.8) is gone and both documents state non-goals identically. **No identifier namespace in the set is now unglyphed.**

```
STAGE 0  debt          S-H01 · ◈T6 · ◈H4 · ◈E1
   |
STAGE 1  architecture  MAGIC / the capability channel
   |
STAGE 2  tooling       Sim harness + Foundations (M·Part 4)
   |     (parallel)    ◇V6 / S-V04 posture-at-fixed-angle prototype
   |
STAGE 3  ownership     INVENTORY + ECONOMY
   |
STAGE 4  content       SKILLS + SPELLS
   |
STAGE 5  content       ENEMIES
   |
STAGE 6  content       BOSSES
```

**Stages 0 and 1 ship together as 0.13.0.** Stage 0 is first in order of work, not in order of release — four corrections do not justify their own version, and Stage 1 edits the frozen action contract, which is structural by definition.

---

## Stage 0 — Debt

*Not a workstream. Rides the Stage 1 bump.*

**Status: complete, pending version rename and index regeneration.**

| Item | Owner doc | Outcome |
| --- | --- | --- |
| `S-H01` / `◈H2` | H | **Not a defect.** The SIM Register's "must normalise" entry restated rule H-M2, which already normalised the weights. The real question was the convention, locked **per-pair**. `%` sign struck from 13 values; column renamed *Coverage weight* |
| `◈H4` | H | Merged with S-H01 — they were one question. **Aim biases the coverage cascade** rather than branching around it; the deterministic `called_shot` branch is struck. Focus is a T·C.6 check bounded by new `[SIM]` **S-H09** |
| `◈T6` | T | Stated in A4.4 and promoted to rule **T-C11** (Critical). Closed simultaneously in W (◈W2d) and L. T also gained an **authored rule table** (Part ◈H2) — it had none, so the "derived" index was authored for T |
| `◈E1` | E | Unspent enemy Edge as 0–3 pips on the activation timeline. Propagated to V as Requirement 7a |

**Carried out of Stage 0:** `[Chassis]` made universal and given `body_template`; **◇H15** registered as a new gap (player chassis source undesigned); **◇E5** narrowed to a bounded mapping question.

**Standing correction.** This file previously repeated the register's "defect" framing for S-H01 without checking it. The lesson is the one already in the instructions: a derived index can be wrong about its own source.

---

## Stage 1 — Magic and the `capability` channel

**Why first.** The only undesigned system that locked documents already depend on. Six passages assume spells exist — the action contract (T·Part H), credit sources (T·B.1), trace actors (T·I.3), the Occult damage group and `ward` mitigation (M·2A.3, 2A.4), and the `[Combo-Action]` worked example (M·2A.10). None of them is answerable by simulation; all are structural. Cost of deciding late is proportional to content authored against the assumption — and because enemies and characters are one schema (E founding invariant), a late channel change invalidates the bestiary too.

**Entry:** Stage 0 rulings settled.

**Must answer:**

| # | Question |
| --- | --- |
| 1 | Where does a spell's pip footprint come from? Pips are a property *of the weapon* and redistribution is zero-sum from a base footprint. A spell has no chassis |
| 2 | Does magic require a resource, or does Mind's threshold consumption verb (T·A.1) already serve? A new pool is a seventh tracked number |
| 3 | Is `capability` a first-class `sources` value with its own rules, and what are they? |
| 4 | What is `ward`? It is a locked mitigation path in M·2A.4 with no definition anywhere in the set |

**L-M2 collision load — check before naming anything:**

- `capability` already carries three senses — the action-record source slot (T·A3.8, M·2A.10, K·5.1), the enemy capability ladder (E·F.0), and T·Part D's *"Core Triade = capability."*
- `Flux` is currency-only (◇H11 open). `anchor`, `region` and `floor` are reserved.

**Status: complete. Released as 0.13.0 with Stage 0.**

| Question | Outcome |
| --- | --- |
| Spell pip footprint | A `faculty` carries its own base footprint, parallel to a weapon chassis. K·5.1 had already said so |
| Resource | **None.** Mind's "threshold — gates access" is the access economy, surfaced as `[Attunement]` — the Mind effective corner floor, not a new quantity |
| `capability` first-class? | Renamed **`faculty`**, given a record (M·2A.10a), an agent and rules T-C12/T-C13. The ladder keeps the word |
| `ward` | Defined as a state track on the integrity model (M·2A.4), after being named and undefined since 0.9.0 |

**Beyond the four:** three faculty families (`[Arcana]`, `[Mudra]`, `[Psyche]`) plus lineage-owned unarmed profiles per node (T·A4.8a); Combo-Action capped at two delivery hooks; the Occult triad remodelled with Divine as the two-way purge; occult load as a cumulative ratchet. **The corpus had no unarmed model** — Trash enemies with zero equipment could not act. Closed.

**Two errors corrected in-version:** `focus` was overloaded at Stage 0 despite a census being run; the premise that magic was undesigned was wrong.

---

## Stage 2 — Sim harness and Foundations

**Why here.** Fifteen open items carry blocking-category *Balance (needs the sim harness)*. Twenty-five of forty-three `[SIM]` values are basis `arbitrary`. M·1.4 states the harness is a prerequisite for stat balance rather than a convenience; M·2.5 requires it before the affix pool grows; M·Part 6 places it at ◇P1 with Foundations at ◇P2 and agents deliberately at ◇P5.

**Entry: Gate 0, not Stage 1.** ROADMAP had this wrong until 0.13.0. M·Part 6 puts the harness at ◇P1, behind **Gate 0**, whose four exit criteria are all unmet: `◈M1` (0.7), `◈M2` (0.9), `◇M3` (0.10) and three **reference fantasies** that have never been written.

**The apparent deadlock was a classification error.** `◈M1` and `◈M2` were indexed as *needs the sim harness* while Gate 0 required them before it. They are choices — a sweep tests whether ×N survives contact, it cannot tell you that you wanted ×N. Reclassified at 0.13.0.

**Gate T is the same shape.** `T-H2` and `T-H4` measure against reference builds and a sim, so P·0.5's gate is also partly harness-dependent. The gates are not strictly sequential. What is true: **decide the targets → build the harness → validate against them.**

### Stage 2a — Gate 0 *(design; no harness needed)* — **COMPLETE, released as 0.14.0**

| Criterion | Outcome |
| --- | --- |
| `◈M1` — 0.7 | **Closed.** M·Part 9. The **storey** is the pacing unit — 18 per career. Band C reduced 120–180 → **75–110 min**. Purchased access no longer lost to ordinary death |
| `◈M2` — 0.9 | **Closed.** **×9 career**, derived per storey. Constant **6.3% per acquisition** falls out |
| Three reference fantasies | **Written** (M·9.5) as the prose form of K·15's reference builds, so fantasy and fixture are one object |
| `◇M3` — 0.10 | **Still open**, on the prototype track. It does not gate the harness |

**Carried out:** `◇W17`/`◇E11` — enemy scaling must implement M·9.7's encounter budget, or a ×9 career trivialises cleared bands. `◈M10` half-closed: fantasies written, fixture builds still unowned.

### Stage 2b — Prototype track *(parallel, starts now)*

`◇V6`/`S-V04` posture legibility **and** `◇M3`/`◇V3` readability budget, run as **one session**: S-V01, S-V03 and S-V04 are all sub-half-second recognition tests in the same register section, and one setup serves both. Alongside: `◇V7`/`◇G7` render proof harness.

### Stage 2c — ◇P1 harness and ◇P2 Foundations

**Entry: met.** 2a complete (0.14.0); `◈M10` closed at 0.15.0 in **P·Part 10**, so the harness has fixtures to measure against.

**`P` now specifies what the harness is built against** — schemas, storage layout, trace and delta model, signature keys, validation stack. M·Part 4's eight foundations map onto it:

| M·Part 4 item | Where it now lives |
| --- | --- |
| Content as data, JSON Schemas | P·2.1, P·2.2 |
| Deterministic named RNG streams | P·5.2 `rng_stream_manifest` |
| Headless simulation interface | Stage 2c build work |
| Per-delta trace attribution | P·5.3 |
| Golden tests | P·5.6 capture level 1 |
| Content linter | P·7.1 |
| **Frozen fixture set** | **P·10 — closed** |

**Exit:** first sweep runs against `S-K01`/`S-K02`. M·9.6's log-decomposition live — it is a requirement, not optional analysis, because it is what makes an outlier run *attributable* rather than merely detected.

**Carried in from P — CLOSED 0.34.0:** `◈P3`/`S-P01` fixed the scale at **12 000** before any trace was stored — changing it later invalidates every stored trace.

**Closed at 0.20.0:** `◈P7` — the source-rule defect. Counted at seventeen, nineteen and thirty before it was measured; the answer was five, and none of the five needed a rule written. All 142 rules are now authored in their home document, verified against **P-C8**. **No longer a Stage 2c exit condition.**

**Implementation progress (design baseline 0.45.0; technical schema remains at the pre-P13/P11/P12-A/B/C boundary pending implementation handoff and A3).** **R7 complete and centrally validated.** **M10 is complete** — dependency layer, five equipment revisions, and its earlier faculty/fixture checkpoint. Grist's existing Faculty rows predate the authoritative four identities, eight profiles, corrected hooks, normalized authorizations, explicit Lineage grant modes, entitlement/acquisition grains, candidate readiness, pure gate evaluation, exact-candidate commitment and Plannable Action contract adopted through 0.44.0; they are migration input, not proof of implementation. *Declared gaps are declared, not closed: proof declarations are not executed simulation results.*

**Tile/Dungeon reconciliation Set 1 adopted at 0.33.0** — TD-CR-01 through TD-CR-10, one governed change set, each decision in exactly one authoritative home. **Set 2 (CR-11: environmental system and Tactical Timeline) re-proofs against 0.33.0 as its baseline**, which satisfies the stream's stop condition. `◇W18` (Territory rename) is queued behind it.

**Exit:** M·Part 4's eight foundations in place. Reference fixture set frozen. Trace attribution live. First sweep runs against `S-K01`/`S-K02`. **`◇P7` closed** — every rule in the suite traces to an ID-bearing row in its source document, so the index is derivable by `grep` without loss.

### Stage 3 entry gained a dependency at 0.16.0

`shield` is now a `category` value, so the equipment authoring pipeline has its seventh component set. **Nothing in Stage 3 is unblocked by this** — it was a schema correction, not an inventory decision — but the authoring sheets in P·2.3 acquire a shield row, and that row is what ◇M9 will eventually need a container for.

**The shield budget closed at 0.28.0 and was reconciled at 0.29.0** — `◈M12`. Every shield draws a flat 2-pip pool with an authored split (**M-C9**), a defence pip buys a typed-defence group step (**M-C10**), and **M-C11** taxes a one-handed weapon in the off hand. `defence_profile_entries.rating_value` is populatable; the **off-hand transform is new work for equipment authoring** and no fixture models it. `S-M05` is struck.

### Parallel track — ◇V6 / S-V04

Independent of the design sequence, and should start immediately.

`S-V04` has the longest downstream chain in the SIM Register: it gates `◇G4`, the projection lock, and therefore every tile asset ever produced. A failed posture test after assets exist is the most expensive failure available.

Runs alongside: `◇V7` / `◇G7`, the render proof harness. 0.12.0 specified four Critical render rules that nothing can execute.

---

## Current bridge — Carrier, Lineage, Tarot architecture

The next design work is one dependency chain, not three parallel topics:

1. ~~**Session A — Carrier and Technique.**~~ **CLOSED 0.38.0.** A1 §§5–8 are centralised: node-bound source instances and Technique/Payload separation in T; carrier contract/delivery proof in K/H; target-node coverage and layer interception in M/H. Intake now **4 of 9 delivered**.
2. ~~**Session B — Lineage and Faculty.**~~ **CLOSED 0.44.0.** `◈P13`, `◈P11` and `◈P12-A/B/C` now own normalized Lineage/Physique grants, Faculty profiles/authorizations, entitlement/acquisition, candidate readiness and target routes, pure deterministic evaluation, exact-candidate atomic commitment, milestone-local revalidation and autonomous Plannable Actions. H-owned anatomy remains unchanged.
3. **Session C1 — Tarot-card architecture — CURRENT.** **C1-A through C1-E adopted 0.45.0** at P·2.3f–i: atomic card acquisition/persistence, local-depth layout, Support/resonance capacity, same-depth two-hook Combos, cardless inherent endpoints and deterministic bounded enhancement. `01-Tarot_Card_Skill_System_Concept_TRIADE-0_45_0.md` records disposition and remaining questions, not authority. **Next: C1-F** card information, discovery, visual templates and build previews; then **C1-G** Support acquisition/persistence details and authoritative-home/fixture/validation closeout. Aim remains under T-C17/K-C17/H-H5/E-C8 and planned actions inherit P12-C.

Technical table names in the concept remain candidates. `inherent` is the cardless conferred Technique classification at P·2.3f, not a synonym for Somatic. Installation comes from progression/build; runtime readiness comes from P12. Triade floor access remains an eligibility gate, not spendable card currency.

Stage 3 is then the hard gate for Tarot Card management: collection/library, installed/uninstalled custody, physical inputs versus persistent cards, storage/capacity, installation/removal workflow, duplicates, loss/recovery, trade/resale/salvage, vendors/crafting/provenance and run/death boundaries. Ownership/access retention on uninstallation is settled at P·2.3f. Inventory owns custody and operations, never Technique behaviour, acquisition identity or layout/Combo legality. Concrete Commander and boss rewards belong with Stages 5–6.

**Node-payload intake scope ruling.** The nine proposed sections are four adoption packages, never one silent adoption: ~~**A1 §§5–8** Carrier/Technique and target-layer boundary~~ **closed 0.38.0**; ~~**A2 §§9–11** anatomy, aimed modes and enemy access~~ **closed 0.39.0**; **A3 §12** authoring/automation only after A1 and A2; **A4 §13** UI/legibility only after the owning mechanics and V surface are fixed. Intake is **7/9 delivered**. A2 was reconciled before Session B because its Technique boundary constrains later Faculty and Tarot design, but it adds no lineage field and leaves H-owned anatomy closed.

---

## Stage 3 — Inventory and Economy

**Why together.** Two of the four unowned systems, and the same shape: what holds, and what consumes. Both are already legislated about from outside without existing — `M-C6`, `M-C7`, `M-C8` protect items from an inventory that has no model; H·8.1 bars progress currencies from sinks that have no owner.

**Trade-off named:** one document owning two things is what forced the E and G extractions. Accepted because the alternative leaves salvage and reroll sinks pricing against a container that does not exist.

**Entry:** Stage 2 harness available for economy sweeps (`S-H07`, `S-W13`).

**Exit:** `◇M9`/`◇W16`, `◇M6`, `◇M7`/`◇H13`, `◇W14`, `◇H14` closed. `◇M8` given a destination. Ref letter chosen by L-M2 grep, not by preference.

---

## Stage 4 — Skills and spells

**Why one pass.** A spell is a Technique using a Faculty source. Authoring them separately duplicates the level ladder, Skill Anchor, falloff and linter. T·A3.7/A3.8 and M·5.6a own the baseline; P·2.3f–i owns Tarot architecture, pending C1-F/G before broad content.

**Entry:** Stages 1 and 2 complete; Sessions A, B and C1 closed; Stage 3 has settled the physical-card lifecycle and economy boundary. `◇T1` and `◇W2g`/`S-W06` swept.

**First work — Session C2.** Realize and validate the P·2.3f–i architecture after C1-F/G and Stage 3: acquisition/install implementation, immutable Technique/card references, expertise, slot/link validation, deterministic attribution and colour-independent presentation. C2 does not re-author the generic acquisition contract already owned by P.

**Exit:** C2 contract and representative fixtures validated before broad skill/card production. `◇T5` validated against concrete content. Anchor coverage map produced — voids become briefs for Stage 5.

---

## Stage 5 — Enemies

**Why after Stage 4.** Enemies equip the same vocabulary records as players (E·F.3), and Elite and Commander tiers fire Advantage actions drawn from it.

Concrete Commander/special-monster card drop tables and encounter reward hooks are authored here against the settled C2 contract. Their existence is not back-projected into C1 as a loot rule.

**Internal order:**

| Order | Item | Reason |
| --- | --- | --- |
| 1 | `◇E5` | Blocks `◇V1` and `◇G6` in two other documents. Highest leverage item in E |
| 2 | `◇E3` | Content the lint required by E·F.4 already assumes |
| 3 | `◇E2`, `◇E4` | Need a harness. `◇E9` names `[Incursion]` depth as that harness |
| 4 | `S-E03` | Gates `S-W14` |

**Exit:** `S-E03` set. `◇E5` closed, unblocking `◇V1` and `◇G6`.

---

## Stage 6 — Bosses

**Why last.** A boss is a Commander plus escalation content. It depends on a settled tag library (`◇E2`), a set Signature frequency (`S-E03`), and signature-linked anatomy nodes (`◇E6`, which needs `◇E5` and a fixed `S-H01`). W§5.8 already supplies the escalation *shape* — one, two and three storeys at the three meetings — so only the *kind* is open.

Fixed or weighted boss-card rewards are decided here, after the card lifecycle, enemy reward interface, and boss identities exist.

**Trade-off named:** doing bosses earlier means authoring Signature Actions against an unsettled tag library and an unset frequency band. That is precisely the `◇E8` failure already on the books — a level-generation parameter silently tuning boss difficulty.

**Exit:** `◇E7`/`◇W8` closed in E. `◇E6` closed. `◇E8`/`S-W14` set against `S-E03`.

---

> **Intake, from 0.20.0.** Work arriving from a technical stream or a third-party report lands as an **intake record**, not as edits. Each item takes one disposition — `authored`, `enforced-elsewhere`, `backlog`, `struck` — and `backlog` means a `◇` open item in a named document, never a note in a file with no authority. **P-H5** enforces it.

## ◉ Goals

Goals are **not** open items. They are standing tests a subsystem must keep passing, and they carry the `◉` glyph with a home reference so that `◉G4-W§2` can never be mistaken for the open item `◇G4`. Owned by their home document; listed here so the set is visible in one place.

### World, Maps & Dungeons — `W§2`

| ID | Goal | Test |
| --- | --- | --- |
| ◉G1-W§2 | Any location regenerable in isolation from its seed | `(run_seed, scope)` → identical artefact hash without generating siblings |
| ◉G2-W§2 | Platform-independent determinism | Identical hash across OS and across TS-prototype → Rust port |
| ◉G3-W§2 | Old seeds survive patches | `(seed, generator_version)` reproduces after generator changes |
| ◉G4-W§2 | Every map provably traversable and non-trapping | Reachability, no-soft-lock, key-before-lock pass on 10k-seed sweep, 0 failures |
| ◉G5-W§2 | Every map tactically interesting, not merely valid | Cover density, sightline spread, chokepoint count within axis bands |
| ◉G6-W§2 | World generation expresses the Triade | Every Territory declares an axis and biases layout/props/AI toward it |
| ◉G7-W§2 | Agents contribute safely | Schema-valid, sweep-tested, human-gated; no agent touches connectivity, determinism or numbers |
| ◉G8-W§2 | Everything bakes to the locked zone graph | Every map emits a valid K·4 zone graph; sim never sees the fine grid |
| ◉G9-W§2 | Territory is a clean expansion seam | New Territory = content package only; no code or schema change |

### Damage & Health — `H§3`

| ID | Goal | Test |
| --- | --- | --- |
| ◉H1-H§3 | HP remains the primary victory condition | No damage path kills above the Finisher threshold except by HP depletion |
| ◉H2-H§3 | Anatomy changes *how* you deteriorate, never *whether* HP matters | Removing the wound layer leaves a playable, coherent game |
| ◉H3-H§3 | No injury state renders a region mechanically mute | `Φ_eff` clamp holds against every wound and surface combination |
| ◉H4-H§3 | Injury changes the player's problem, not merely their numbers | Wounded builds show region-residency *shift*, not uniform loss |
| ◉H5-H§3 | Ambient bookkeeping stays inside the legibility budget | ≤4 surfaced wound families at any time |
| ◉H6-H§3 | Recovery never costs progress currency | Linter forbids `Location Grounding` and Temper in recovery costs |
| ◉H7-H§3 | The baseline invariant survives injury | `ΣF_rendered == ΣF_baseline` at run start, unconditionally (W§16.1) |
| ◉H8-H§3 | Enemy wound state is readable through an existing channel | No new enemy UI surface; posture telegraph carries it |

> **`◉H1`–`◉H8` and `◇H3`–`◇H8` are different things.** Before 0.18.0 they were the same eight tokens in one document. The glyph is what separates them.

### Non-goals — `⦻`

Non-goals are commitments too. They are listed so that a proposal contradicting one is caught as a contradiction rather than debated as a new idea. Glyphed **⦻** at 0.18.1 — `⦻H3` (no second kill race), `◉H3-H§3` (no region rendered mute) and `◇H3` (concussion granularity) were one token before it.

| ID | Non-goal | Home |
| --- | --- | --- |
| ⦻W1 | No per-pixel material simulation | W§2 |
| ⦻W2 | No second full-resolution positional combat system | W§2 |
| ⦻W3 | No open persistent world — run-structured | W§2 |
| ⦻W4 | No agent authority over numbers, connectivity, determinism or vocabulary | W§2 |
| ⦻W5 | No procedural history generation in scope | W§2 |
| ⦻H1 | No trauma simulator — plausibility, not gore | H§3 |
| ⦻H2 | No per-location HP pools | H§3 |
| ⦻H3 | No second kill race | H§3 |
| ⦻H4 | No permanent-injury economy in this document | H§3 |
| ⦻H5 | No infection or disease layer in MVP | H§3 |
| ⦻H6 | No agent authority over clamp values, brake thresholds or the vital-hit gate | H§3 |

> **`⊜` proposed and rejected, 0.19.0.** A glyph for *resolved* non-goals. Rejected because a non-goal has no resolved state — it is a standing commitment, like a goal, and `◉` has no closed form for the same reason. A non-goal that is **withdrawn** is a design reversal, and the corpus already has a convention for that: `~~⦻W3~~` plus a changelog row, as `~~W2~~ **DISSOLVED**` reads in W today. Recorded here so it is not re-proposed — `extraction` was proposed three times across two versions before anyone wrote down that it had been settled.

---

## Not sequenced

| Topic | Status |
| --- | --- |
| **Audio** (`◇V4`) | Unowned. T·A3.4 already specifies the ambient channel as posture **and sound cues** — assumed by a locked section |
| **Accessibility** (`◇V5`) | Unowned. The primary state display is a silhouette |
| **Onboarding, exploration verbs** | Deferred by the manifest, no owner, no dependency |
| **Content package format** (`◇P6`) | Unowned. P names the runtime deployment artefact and specifies nothing about it |

---

## Closed as not-open

| Claimed open | Finding |
| --- | --- |
| **Combat mechanics** | Open Items Index §3: *"K · Combat — No live open items."* K17 is a closed-question ledger. What remains is numbers, which are Stage 2. `◈H4` and `◈E1` touch combat but close in H and E |
| **Monster proofing and generation pipeline** | Specified at E·F.4, M·5.6, and rules `E-C1`…`E-M1`. What is open is content and two harness-blocked numbers |
