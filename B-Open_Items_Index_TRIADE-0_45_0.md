# Triade — Open Items Index

**Version:** 0.45.0
**Date:** 2 October 2026
**Status:** Generated from `[OPEN]`, `[SIM]` and `[GAP]` markers across the ten-document set. **Derived, not authored** — edit the source document, regenerate this.

> **Caveat withdrawn, 0.21.0 amended.** The sibling *Validation Rules Index* **is** fully derived — `◈P7` closed at 0.20.0, all 142 rules authored in their home document and verified against **P-C8**. This index has still not been audited the same way; a marker census across the ten design documents and the technical specification would settle it.

---

## Convention

| Marker | Meaning |
| --- | --- |
| **[OPEN]** | Unresolved design question. Has an owner and a blocking category |
| **[SIM]** | Provisional value pending the simulation harness |
| **[GAP]** | No document owns this. Not a question within a system — a missing system |

**ID scheme:** `{DOC}{n}`. IDs are stable; resolved items keep their ID and move to §5.

---

## 1. Blocking summary

| Blocking category | Count | Items |
| --- | ---: | --- |
| **Balance** *(needs the sim harness)* | 15 | ◇T1, ◇T2, ◇T3, ◇M4, ◇W2a, ◇W3, ◇W4, ◇W2g, ◇W15, ◇E2, ◇E4, ◇E8, ◇E9, **◇E11**, **◇W17** |
| **Design — gates the harness** | 0 | *(◈M1, ◈M2 closed 0.14.0 — Gate 0 passed)* |
| **Design — Tarot closeout** | 1 | ◇P14 — C1-F/G at P·Part 8 |
| **Content** | 12 | ◇T1, ◇T5, ◇W8, ◇W10, ◇W13, ◇E3, ◇E5, ◇E6, ◇E7, ◇G2, ◇G3, ◇G6 |
| **Economy** | 4 | ◇M6, ◇M7, ◇H13, ◇W14 |
| **UI / Prototype** | 5 | **◇M3**, ◇V2, **◇V3**, ◇H14, **◇V6** — ◇M3/◇V3 and ◇V6 run as one session |
| **Steward — needs a locked-doc edit** | 0 | *(◈T6 closed 0.13.0)* |
| **Lexicon** | 2 | ◇H11, ◇H12 |
| **Tooling** | 7 | ◇G5, ◇W12, **◇P1, ◇P2, **◇P8**, **◇P9**, **◇P10** |
| **Gap — no owner** | 8 | ◇V4, ◇V5, **◇V7/◇G7**, **◇M9**, **◇P6**, **◇P8**, plus Economy and Audio, **◇M12** |
| **Deferred by decision** | 3 | ◇T4, ◇T7, ◇W7 |

---

## 2. Highest-priority items

| # | Item | Why it ranks | Owner |
| --- | --- | --- | --- |
| **◇V6** | **Posture legibility at a fixed angle.** ◇V2's camera amendment strikes continuous rotation, which existed to serve silhouette reading — the primary state display | **New at 0.12.0 and it blocks its own amendment.** Also blocks ◇G4, and through ◇G4 the entire projection lock and every asset produced against it | **Prototype** |
| ~~**◈H15**~~ | **CLOSED 0.27.0.** Player chassis is the lineage (T·A4.8a) — the source was unnamed, not missing | **CLOSED** | — |
| **GAP-1** | **No Economy document.** Seven currencies with no owner — and 0.12.0 added an eighth question (◇W14) | Third cross-document currency question in three versions. The pattern is the argument | **Unassigned** |
| **◇V7 / ◇G7** | **No render proof harness.** V·4.9 adds four Critical render rules; nothing can execute them | 0.12.0 specified rules it cannot run. Not grep-able CI — needs camera, atlas, actors, cutaway state | **Unassigned** |
| **◇M9** | **`[Inventory]` undesigned.** M defines what items are, never what holds them | Fourth unowned system. Routed around by the run-scoped key register, so it blocks nothing today | **Unassigned** |
| ~~**◈M11**~~ | **CLOSED 0.24.0.** M·2A.7 gains a fourth weight class — **Medium**, damping **[Dot Dynamics]**, the one A2.2 component no class engaged | **CLOSED** | — |
| ~~**◈M12**~~ | **CLOSED 0.28.0, restated 0.29.0** — 2A.11 sets a flat **2-pip** pool with an authored split (**M-C9**) and the shared pip unit (**M-C10**). `S-M05` struck: the split was authored, not measured | — | — |
| ~~**◈M13**~~ | **CLOSED 0.31.0.** Ties resolve to the **last-declared** type — footprint order is martial priority, signature first, concession last (2A.9). Generalises to any *highest type* selector, including a `2/2` two-hander | — | — |
| ~~**◈M14**~~ | **CLOSED 0.37.0.** Magnitude is constrained **per node** — a body total never resolves under M-C3. Grades 1/2/3, ordinary ceiling 3, striking equipment a 2-pip pool saturating the composite at 3, `[Combo-Action]` at 3+2, and **a bare humanoid may reach 3 by Permanent conditioning alone** (H-C8). *My per-body budget proposal was withdrawn: it constrained a quantity that never appears in play* | — | — |
| **◇E8** | **High-ground density sets Commander Signature frequency** through the circumstantial-Advantage route | A level-generation parameter silently tuning boss difficulty. Must be set against S-E03, not by level design | **Balance / W** |

---

## 3. Full register by document

### T · Core Mechanic

| # | Item | Markers | Blocking |
| --- | --- | --- | --- |
| ◇T1 | Region vocabulary size — actions per region per class | [OPEN] [SIM] | Content |
| ◇T2 | Modification budget size. Mechanism answered by `[Modification Ceiling]`; curve is ◇W2a | [OPEN] [SIM] | Balance |
| ◇T3 | Opening decay rate | [OPEN] [SIM] | Balance |
| ◇T4 | Non-linear condition interaction | [OPEN] | Deferred |
| ◇T5 | Skill level model validation | [OPEN] | Content |
| ~~◈T6~~ | Closed 0.13.0 — stated in A4.4, rule **T-C11** | — | — |
| ◇T7 | Dynamic Composure build-out | [OPEN] | Deferred |

### M · Stats, Items, Equipment

| # | Item | Markers | Blocking |
| --- | --- | --- | --- |
| ~~◈M1~~ | Closed 0.14.0 — M·Part 9. Storey pacing, band C at 75–110 min, 36 career acquisitions, death ledger | — | — |
| ~~◈M2~~ | Closed 0.14.0 — **×9 career**, derived per storey | — | — |
| ◇M3 | Readability budget — tooltip number cap *(0.10)* | [OPEN] [SIM] | **Prototype (with ◇V6)** |
| ◇M4 | Smart-loot dial value | [OPEN] [SIM] | Balance |
| ◇M5 | Synergy mechanism | [OPEN] | Design |
| ◇M6 | Temper versus item economy overlap | [OPEN] | Economy |
| ◇M7 | Scrap ↔ Flux conversion *(= ◇H13)* | [OPEN] | Economy |
| ◇M8 | Remedy items belong in M, not H | [OPEN] | Housekeeping |
| **◇M9** | **`[Inventory]` undesigned — no container model anywhere** | **[OPEN] [GAP]** | **No owner** |
| ~~◈M10~~ | **CLOSED 0.15.0** — P·Part 10. Five builds, Canine chassis, negative cases as fixtures; five gaps declared in P·10.7. *Superseded:* Reference fixture set unowned — Part 4 item 8; Gate T's T-H2/T-H4 measure against it; K·15 names three builds | **[OPEN] [GAP]** | **No owner** |

### K · Combat

No live open items. K's provisional numbers are in the SIM Register.

### V · Visual

| # | Item | Markers | Blocking |
| --- | --- | --- | --- |
| ◇V1 | Body template variation — non-humanoid rigs. Depends on ◇E5 | [OPEN] | Content / E |
| ◇V2 | Wound overlay read time | [OPEN] [SIM] | Prototype |
| ◇V3 | Tooltip readability budget *(= ◇M3)* | [OPEN] [SIM] | UI |
| **◇V4** | **Audio channel undesigned** | **[OPEN] [GAP]** | **No owner** |
| **◇V5** | **Accessibility — colourblind and low-vision support** | **[OPEN] [GAP]** | **No owner** |
| **◇V6** | **Posture legibility at a fixed angle — blocks the ◇V2 amendment** | **[OPEN] [SIM]** | **Prototype** |
| **◇V7** | **Render proof harness uncosted** *(= ◇G7)* | **[OPEN] [GAP]** | **No owner** |

### W · World, Maps & Dungeons

| # | Item | Markers | Blocking |
| --- | --- | --- | --- |
| ◇W2a | Modification-ceiling curve per Stratum | [OPEN] [SIM] | Balance |
| ◇W2g | Slot count `N` for `[Territory Vocabulary]` | [OPEN] [SIM] | Balance |
| ◇W3 | Lock cost curve | [OPEN] [SIM] | Balance |
| ◇W4 | Descent unlock discount curve | [OPEN] [SIM] | Balance |
| ◇W7 | **Environmental axis binding** — do authored environmental states ever produce direct Triade-axis influence, at which stage, or does the system stay permanently non-axis? *CR-11's adoption at 0.35.0 activated environmental mechanics **without** axis binding and closed, partially closed or prejudged nothing here* | [OPEN] | Deferred |
| ◇W8 | Boss escalation content *(shared with ◇E7)*. **Partially answered at 0.12.0** — the arena gains a storey at each meeting; the *content* remains open | [OPEN] | Content |
| ◇W9 | Town service consuming the lock payment | [OPEN] | Content |
| ◇W10 | Territory 2 and 3 content packages | [OPEN] | Content |
| **◇W11** | Re-placed `[Relic]` scope — **locked same-Location at 0.12.0**, alternative recorded | [OPEN] | — |
| **◇W12** | `[Modification Ceiling]` spatial expression — may need none | **[OPEN]** | Design |
| **◇W13** | Does every 10th `[Incursion]` depth host a landmark encounter? | **[OPEN]** | Content / E |
| **◇W14** | Net Marks yield per `[Incursion]` run after recovery | **[OPEN] [SIM]** | Economy |
| **◇W15** | `[Incursion]` pacing against S-W02 band targets | **[OPEN]** | Balance |
| **◇W16** | `[Inventory]` gap *(= ◇M9)* | **[OPEN] [GAP]** | **No owner** |
| **◇W17** | **Stratum scaling must follow the career power curve** — unimplemented, a ×9 career trivialises cleared bands *(partner to ◇E11)* | **[OPEN] [SIM]** | Balance / W |
| **◈W18** | **Rename the world/geographic `region` to Territory.** `region` is locked to **Triade regions (T)** and is never a map area, yet W uses it for geography — and W·5 proves the two are different: *multiple regions may declare the same axis*, so geographic identity is demonstrably not Triade identity. **Ruled 0.33.0, scheduled after Set 1**: `territory_id`, **Territory package**, **launch Territories**, and `[Territory Vocabulary]` where it means geographically taught content. T's and C's barycentric uses do **not** move. ~250 occurrences of `region` across 17 documents need discriminating by sense — a blanket replace is barred, and a half-done rename is worse than none | **[CLOSED 0.38.0]** | Vocabulary / W **Occurrence register at `00-W18_Region_Occurrence_Register_TRIADE-0_45_0.md`** **[CLOSED 0.38.0]** Applied in one transaction. **396 occurrences classified: 263 Triade, 83 geographic, 3 other-spatial, 47 meta/historical.** 75 hand-edits in A, G, L, T, W; the 8 in B, R and Y fell out of regeneration, never hand-edited. **24 identifier forms sat outside the census** — `\bregions?\b` cannot match `region_id` — of which W's 4 became `territory_id`; C's `ref_regions` is Triade (`parent_corner_a/b` → momentum/form/mind) and needed no counter-patch. **Territory is capitalised** for the record and its instances, compounds and plurals; machine identifiers stay snake_case (L · 9D). Historical rows untouched: 0 of 83 geographic occurrences fell in a changelog line. Classification is occurrence-based, never document-based: T·252's *faction/region flavour* is geographic inside the document that owns the barycentric sense. |

### H · Damage & Health

| # | Item | Markers | Blocking |
| --- | --- | --- | --- |
| ~~◈H2~~ | Closed 0.13.0 — not a defect; convention locked per-pair | — | — |
| ◇H3 | Concussion granularity | [OPEN] | Balance |
| ~~◈H4~~ | Closed 0.13.0 — aim biases the cascade (§6.2a) | — | — |
| ~~◈H15~~ | Closed 0.27.0 — the player chassis **is** the lineage (T·A4.8a); the source was unnamed, not missing | — | — |
| ◇H5 | Infection / disease scope | [OPEN] | Scope |
| ◇H6 | Cross-run scar carry | [OPEN] | Separate workstream |
| ◇H7 | Enemy wound persistence between encounters | [OPEN] | Balance |
| ◇H8 | Treatment slot limits | [OPEN] | Balance |
| ◇H9 | Routing delta budget | [OPEN] | Content |
| ◇H10 | All magnitudes | [OPEN] [SIM] | Sim |
| ◇H11 | Declare *Flux* currency-only | [OPEN] | Lexicon |
| ◇H12 | *Marks* / *landmark* proximity — accepted, recorded | [OPEN] | Lexicon |
| ◇H13 | Scrap ↔ Flux conversion *(= ◇M7)* | [OPEN] | Economy |
| ◇H14 | Five spendable resources at town | [OPEN] | UI |

### E · Enemies & Bestiary

| # | Item | Markers | Blocking |
| --- | --- | --- | --- |
| ~~◈E1~~ | Closed 0.13.0 — 0–3 pips on the activation timeline | — | — |
| ~~**◈E10**~~ | **DISSOLVED 0.32.0** — bite was a deferred fourth `[Innate]` slot; there are no slots. A lineage authors a footprint at its teeth or does not (T·A4.8a) | — | — |
| ◇E2 | Behaviour tag library size | [OPEN] [SIM] | Balance |
| ◇E3 | Contradictory tag pairs | [OPEN] | Content |
| ◇E4 | Encounter tag diversity threshold | [OPEN] [SIM] | Balance |
| ◇E5 | Chassis → body template mapping *(narrowed 0.13.0)* | [OPEN] | Content / H |
| ◇E6 | Commander signature-linked nodes | [OPEN] | Content / H |
| ◇E7 | Boss escalation by kind *(= ◇W8)* | [OPEN] | Content / W |
| **◇E8** | **High-ground density drives Commander Signature frequency** | **[OPEN] [SIM]** | **Balance / W** |
| **◇E9** | **`[Incursion]` escalation past a four-tier ladder** — makes Incursions the harness for ◇E2 and ◇E4 | **[OPEN] [SIM]** | Balance |
| **◇E11** | **Enemy tier mix must implement the encounter budget** — M·9.7's `E(x)` is composite; durability and threat must not both scale *(partner to ◇W17)* | **[OPEN] [SIM]** | Balance / E |

### P · Content Pipeline & Data Model

| # | Item | Markers | Blocking |
| --- | --- | --- | --- |
| **◇P14** | **Tarot architecture closeout.** C1-A–E are adopted at §2.3f–i; C1-F must settle card information, discovery, V-owned visual templates and previews. C1-G must settle Support acquisition/persistence details and representative fixture/validation handoff before Session C1 closes. Stage 3 custody/economy and C2 implementation remain downstream. | **[OPEN]** | Design / P |
| ◇P1 | DuckDB v2.0 migration — v1.4 LTS pinned; v2.0 and LTS expiry land the same month | [OPEN] | Tooling |
| ◇P2 | Multi-writer escalation — PostgreSQL chosen; DuckLake and Quack unproven here | [OPEN] | Tooling |
| ~~**◈P3**~~ | **CLOSED 0.34.0** — `FIXED_POINT_SCALE = 12 000`, derived from the Triade fractions the corpus uses | — | — |
| ◇P4 | Trace volume per 10k-seed sweep — partition strategy unvalidated | [OPEN] [SIM] | Tooling |
| ◇P5 | Localisation scope — whether a second locale exists at ship | [OPEN] | Scope |
| **◇P6** | **Content package format for the game runtime — named, never specified.** *Widened 0.26.0* to own the **canonical schema version contract**: the equipment schema is a placeholder with no version contract while rows expose `schema_version` | **[OPEN] [GAP]** | **No owner** |
| ~~**◈P7**~~ | **CLOSED 0.20.0.** All 140 indexed rules are authored in their home document, measured against **P-C8** — the ID leads its line or its first table cell. The item was counted at seventeen, nineteen and thirty before it was measured; the answer was **twenty-five rows needing a tag, three home mis-assignments and zero rules needing to be written**. `L-M1`/`L-M2` now live in **L·12**; `M-C3`, `M-C5`, `M-H4` were already stated in **M** and simply carried no ID. Census and the published regeneration command agree at **140 of 142** | **CLOSED** | — |
| ~~**◈P7a**~~ | **CLOSED 0.19.0.** The regeneration command is correct. Its recovery — 109 of 142 — was independently reproduced by the ◇P7 census counting authored rows, and the two agree exactly. The shortfall was never a command defect; it was ◇P7 | **CLOSED** | — |
| ◇P9 | Cell-level content versioning — Dolt recorded as the escalation if file-level JSON merges stop resolving; **trigger frequency never measured, so the escalation has no gate** | [OPEN] | Tooling |
| **◇P10** | **Protected `ref_tags` registry is empty** — no legal `equipment_tags` reference can be authored; tag search, generation and lints unavailable. Scope question, not semantics | **[OPEN]** | Tooling / P |
| ~~**◈P11**~~ | **CLOSED 0.41.0.** P·2.3b registers four immutable Faculty identities, four base profiles, four explicit composite profiles, their hook requirements, exact damage footprints, primitive actor-pull signatures and 32 normalized Technique authorizations. Somatic remains bound-node authorization. Rend remains weapon-based; Hex is Arcana && Mudra; derived renditions are not duplicate vocabulary rows. | **CLOSED** | — |
| ~~**◈P12**~~ | **CLOSED 0.44.0.** P12-A fixes entitlement/acquisition; P12-B fixes candidate readiness and target-route dependency; P12-C fixes pure ordered evaluation, environmental target domains and resolution participants, exact-candidate atomic commitment, milestone-local revalidation and autonomous scheduled/triggered Plannable Actions. | **CLOSED** | — |
| ~~**◈P13**~~ | **CLOSED 0.40.0.** P·2.3a registers the normalized Lineage/Physique grain, innate grants, per-Technique source nodes and per-Payload support dependencies. Equipment `chassis_profiles` remain barred; Somatic authorizes natural-node Techniques without duplicating source, footprint or hook. | **CLOSED** | — |
| **◇P8** | **Fixture enemy and encounter-membership field sets undecided.** The normalized relations are registered in P·2.3; their columns must be reconciled against E and H before canonical ◈M10 fixture JSON can be frozen | **[OPEN] [GAP]** | **No owner** *(P, with E, H)* |

### G · Tile Pipeline

| # | Item | Markers | Blocking |
| --- | --- | --- | --- |
| ~~◈G1~~ | **SUPERSEDED 0.33.0** — neither flag added; openings are masks, facade obligation is derived per directed edge | — | — |
| ◇G2 | Tile family count per Territory package | [OPEN] [SIM] | Content |
| ◇G3 | Socket vocabulary size before the matrix stops being auditable | [OPEN] [SIM] | Content |
| **◇G4** | **Exact projection angle and elevation step — blocked on ◇V6** | **[OPEN]** | **Blocked on V** |
| ◇G5 | Example-inferred adjacency used at all, or hand-authored only | [OPEN] | Tooling |
| ◇G6 | Non-architectural palettes; depends on ◇E5 | [OPEN] | Content / E |
| **◇G7** | **Render proof harness uncosted** *(= ◇V7)* | **[OPEN] [GAP]** | **No owner** |
| ~~◈G8~~ | **CLOSED 0.31.0** — `tile class` needs no stronger word; L now carries the entry. Authored in G at closure: it had never had a home row | — | — |

---

## 4. Cross-document duplicates

| Question | IDs | Canonical owner |
| --- | --- | --- |
| Scrap ↔ Flux conversion | **◇M7** = **◇H13** | Economy *(no doc — GAP-1)* |
| Tooltip readability budget | **◇M3** = **◇V3** | V |
| Boss escalation by kind | **◇W8** = **◇E7** | E |
| Non-humanoid body templates | **◇V1** ← **◇E5** ← **◇G6** | E |
| Modification budget / ceiling curve | **◇T2** ⊃ **◇W2a** | W |
| **`[Inventory]` gap** | **◇M9** = **◇W16** | *No doc* |
| **Render proof harness** | **◇V7** = **◇G7** | V |
| **High-ground density** | **◇E8** ⊃ **W-H8** | Balance |

---

## 5. Recently closed

| # | Item | Closed | Resolution |
| --- | --- | --- | --- |
| **Storey semantics** | What "floor" means; whether depth gains a second axis | **0.12.0** | One Delve level = one dungeon of `N` storeys, one descent charge. `N` derived 1/2/3 from Stratum band, fixed. `N` partitions rather than multiplies space |
| **Vertical naming** | `[Walk Surface]` / `[Dungeon Floor]` | **0.12.0** | Both rejected as L-M2 collisions. `[Deck]` and `[Storey]` adopted |
| **`cz`** | What the chunk z-axis was for | **0.12.0** | Declared, never implemented. Struck |
| **`complex_room` authority** | Who sets it, and what it exempts | **0.12.0** | Template instantiation only (W-C20); exempts the 2-zone floor, never the 4-zone ceiling, so K·4 stands unamended |
| **Zone merge failure** | What happens when a room cannot reach 2 zones | **0.12.0** | Furnishing repair → reseed → demotion to non-combat. Terminates without human intervention |
| **`[Secret]` and inventory** | How a carried key survives loss paths | **0.12.0** | Run-scoped key register, decoupled from inventory |
| ◈W2e, ◈W2f, ◈W5, ◈W6, ◈H1 | Injury persistence, run-boundary clear, Grounding shadow, currency names | 0.10.0 | See W§19, H |
| T·K 1,2,4,5,7,9,10,13 · M·8.4 | Nine stale entries | 0.11.0 | Cleared |

---

## 6. Regeneration

```bash
grep -nE "\[OPEN\]|\[SIM\]|\[GAP\]" [A-Z]-*_TRIADE-0_45_0.md
```

**Corrected at 0.17.0 and run before publishing.** The previous command globbed `TRIADE-*design-0.17.0.md`, which matched **zero files** on two counts: filenames use underscores in the version (`0_17_0`), and `*design*` excluded the three indexes and the technical specification. It had been publishing a clean result by matching nothing. **The first correction was also wrong** — `TRIADE-*_0_17_0.md` matches nothing either, because the version is preceded by a hyphen, not an underscore. Both were caught by running the command instead of reading it.

Any item in a source document without a marker, or in this index without a source, is a defect in one of the two.

---

## Changelog

| Version | Change |
| --- | --- |
| **0.45.0** | P-owned ◇P14 generated for remaining C1-F/G; live-row census 70. C1-A–E are adopted at P·2.3f–i. |
| **0.44.0** | **`◈P12` closed.** The regenerated projection records the complete A/B/C contract and removes the final Session B gate. Board recount: **68 live items**. |
| **0.43.0** | **`◇P12-B` closed internally; `◇P12` remains open for P12-C only.** The index now projects route-level `known`/`selectable`/`executable`, dependency-local invalidation and Technique-authored direct/area targeting. Board recount remains **69 live items**. |
| **0.42.0** | **`◇P12-A` closed internally; `◇P12` remains open.** Entitlement/acquisition identity is now sourced from P·2.3c; P12-B/C retain complete availability evaluation. Board recount remains **69 live items**. |
| **0.41.0** | **`◈P11` closed** and regenerated from P·2.3b. `◇P12` is the remaining Session B gate. Board recount: **69 live items**. |
| **0.40.0** | **`◈P13` closed** and regenerated from P·2.3a. `◇P11` now names four concrete Faculty families and the accepted lifecycle; `◇P12` now includes derived availability, Triade position and floor access. Board recount: **70 live items**. |
| **0.39.0** | Regenerated after A2. No open item closes or opens; §§9–11 were intake deliverables, not hidden `◇` items. Counts remain 71 live items. |
| **0.38.0** | `◇W18` → `◈W18`, **[CLOSED 0.38.0]**. 3 Territory projections regenerated from source, not hand-edited. **20 September alignment:** the stale `◇P11` projection was regenerated from P's source row; it now states that concrete faculty instances are absent, not their already-authored field contract. Counts unchanged. |
| **0.37.0** | **`◈M14` closed.** New intake opened for the node-payload and aiming proposal's §§5–13, deliberately **not** adopted under M14. |
| **0.36.0** | **`◇W7` restated** to match W and to record that CR-11's adoption prejudged nothing; **`◇W18` counts corrected** to 396 / 313. |
| **0.33.0** | **`◈G1` superseded** by TD-CR-06. §1 Tooling row recounted by measurement. |
| **0.32.0** | **`◈E10` dissolved; `◇M14` registered; `◇P11` restated.** §1 recounted by measurement. |
| **0.31.0** | **`◈M13` and `◈G8` struck.** §1 Lexicon row recounted by measurement. Register census run: home and index now agree exactly. |
| **0.30.0** | **`◇P11`, `◇P12`, `◇P13` registered** from technical intake. §1 recounted by measurement. |
| **0.29.0** | **`◇M13` registered** — the M-C11 tie-break. §1 recounted by measurement. |
| **0.28.0** | **`◈M12` closed.** §1 recounted by measurement. |
| **0.27.0** | **◈H15 closed**; §1 recounted. Character system opened: lineage, size and the stat-space conservation that binds them. |
| **0.26.0** | **◇M12 and ◇P10 registered; ◇P6 widened.** §1 recounted — Tooling 9, Gap 9. M10 equipment closeout dispositioned — three findings backlogged or enforced elsewhere, one authored. No AUTHORED DESIGN DECISION this run. |
| **0.25.0** | Medium armour pulls toward the barycentre. The mechanism authored at 0.24.0 was dynamic where 2A.7 is positional; this one is positional. |
| **0.24.0** | **◈M11 closed.** §1 recounted; Gap 9 → 8. Fourth weight class adopted. No new quantity invented — the class occupies a seat the dot model already had. |
| **0.23.0** | **◇M11 registered** — the Standard shield's `medium` weight class has no Bridge-2 mechanism and no membership in 2A.7's set. §1 recounted; Gap 8 → 9. M10 dependency handoff dispositioned — one authored design decision centralised, one finding backlogged, three accepted. |
| **0.22.0** | Ref **B**. §6's regeneration glob repointed and re-run. Filename convention adopted — `<REF>-<Name>_TRIADE-[V_e_r].md`. The ref letter leads so the folder reads at a glance; `TRIADE` moves into the stem. |
| **0.21.0** | The technical-stream instructions enter the governed set as `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md`; the central instructions are renamed `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md`. Both carry the design-set version in the filename as a co-authorship marker. |
| **0.20.0** | **◈P7 closed.** §1 recounted; Tooling falls to 8. Corpus normalised to `markdownlint` under a tracked `.markdownlint.jsonc`; 1,956 table separators unified. Content-equivalence proven by whitespace-normalised diff against `Archive/v0.19.0/`. |
| **0.19.0** | **◇P7 restated: five, and a total rather than a floor** — three home mis-assignments and two rules never written. **◈P7a closed.** §1 recounted; Tooling 10 → 9. Subsection headings lost the document letter — `### V4.1` → `### 4.1` — completing the 0.18.0 pass, which had changed `## Part Xn` and left `### Xn.n`. Bare `Xn.n` references normalised to `X·n.n`. |
| **0.18.1** | Non-goals take **⦻** (`⦻Xn`), the sixth and last unglyphed identifier namespace. No design decision changed. |
| **0.18.0** | **◇E11 and ◇W17 added to the register** — both live `[OPEN]` in their home documents and absent here. **◈M10 struck from the Gap row**, closed at 0.15.0. All ten §1 counts recomputed by counting; Balance 13 → 15, Gap 10 → 8. §6's regeneration command corrected twice and run. Identifier glyphs adopted set-wide — `◇` live open item, `◈` closed, `◉` goal, `⇥` phase, `⌬` skill level. Stale spaced filenames repointed to the underscored convention. **245 glyphed identifiers in this document.** |
| **0.17.0** | Regenerated. **Three items registered, all from P** — **◇P9** added post-release from the equipment-model reconciliation (Dolt as cell-level versioning escalation), which also retired that record to `Research\`. §6's regeneration command was corrected: it had globbed a filename pattern matching zero files. Originally: **two items registered, both from P** — **◇P7a** (the Validation Rules Index's published regeneration command recovers 82 of 139 rules: `P` is missing from its character class and H's invariants sit in a code block no `^\|` pattern reaches) and **◇P8** (`fixture_enemies` / `fixture_encounter_members` are registered as relations in P·2.3, but their column sets are unfixed and must be reconciled against E and H before canonical ◈M10 fixture JSON is frozen). **◇P7 corrected** from seventeen to at least nineteen and restated as a floor rather than a total. **No items closed.** Tooling 7 → 9; unowned systems 9 → 10. The header caveat still applies: *this* index has not been audited against the test that found ◇P7. |
| **0.16.0** | Regenerated. **Two items registered** — **◇P7** (seventeen validation rules with no source-document row, so the Validation Rules Index is authored rather than derived for those) and **◇G8** (whether *tile class* wants a stronger word). No items closed: 0.16.0 was a coherence pass, not a design pass. A caveat added to the header — the sibling index was found underived in part, and this index has not been audited against the same test. |
| **0.15.0** | Regenerated for **ten documents**. **◈M10 closed** by P·Part 10 — the fixture set is records now, with five coverage gaps declared rather than discovered later. **Six P items registered**, of which **◇P6** (content package format) is a gap, bringing unowned systems to six. Tooling category triples, which is the expected shape of a version that added a pipeline document. |
| **0.14.0** | Regenerated. **◈M1 and ◈M2 closed** — Gate 0 passes on three of four criteria, and the *Design — gates the harness* category created one version ago is now empty. **◈M10 half-closed**: the three reference fantasies are written, the fixture builds are not. **◇W17 and ◇E11 registered** as a partner pair — enemy scaling must implement M·9.7's encounter budget or a ×9 career trivialises cleared bands. 0.10 stays open on the prototype track and does not gate the harness. |
| **0.13.0** *(Gate 0 prep)* | Regenerated after M's marker changes. **New blocking category — *Design — gates the harness*** holding ◈M1 and ◈M2, reclassified out of *Balance*: Gate 0 requires them before ◇P1 builds the harness, so the old classification described a deadlock that did not exist. ◇M3 moved to the prototype track with ◇V6. **◈M10 registered** — the reference fixture set, a Part 4 foundation owned by no document. Unowned systems: six. |
| **0.13.0** | Regenerated. **Five items closed** — ◈T6, ◈H2, ◈H4, ◈E1, ◈W2d. **Two registered** — ◇H15 (player chassis source, fifth unowned system) and ◇E10 (bite as an Innate slot). ◇E5 narrowed from an open content pile to a bounded chassis→template mapping. The Steward category is now empty for the first time since 0.10.0. |
| **0.12.0** | Regenerated for nine documents. **Fourteen items added** — ◇W11–◇W16, ◇V6, ◇V7, ◇E8, ◇E9, ◇G1–◇G7, ◇M9. Six items closed by the 0.12.0 locks. Two new unowned gaps: `[Inventory]` (◇M9/◇W16) and the render proof harness (◇V7/◇G7), bringing unowned systems to four — Economy, Audio, Accessibility, Inventory — plus one unowned tool. **◇V6 enters as a top-priority blocker**: it gates its own amendment and, through ◇G4, the projection lock. ◈T6 remains open and untouched by this pass. |
| **0.11.0** | Index created. Markers standardised across eight documents. Nine stale entries cleared. Five duplicate pairs identified. Two gaps registered. |
