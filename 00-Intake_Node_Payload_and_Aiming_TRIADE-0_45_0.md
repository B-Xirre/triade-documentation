# Intake — node-bound skills, payload and aiming

**Source:** `02-M14_Consolidated_Innate_Node_Payload_Aiming_Proposal_TRIADE-0_36_0.md`, §§5–13
**Type:** `FINDING` — a design proposal arriving with `◇M14`, deliberately **not** adopted under it
**Central disposition:** `unresolved` — A1 §§5–8 and A2 §§9–11 closed; seven of nine delivery findings are authored or enforced elsewhere
**Aligned to:** Triade v0.45.0

## Why this is separate

`◇M14` asked one question: **what magnitudes may unarmed sources and striking equipment carry?** §3 and §4 answer it and were adopted at 0.37.0. §§5–13 propose node-bound skill availability, payload modules, carrier proof, anatomical targeting, aimed modes, enemy tier access, an authoring pipeline and UI.

**That is a far larger body than the item that carried it.** Adopting it under `◇M14` would repeat the *"Set 2 complete"* failure — a narrow item used as a door for a wide adoption, with the completion claim made for the sections written rather than the work asked. It gets its own record, its own rulings and its own checklist.

## Deliverables — 4 delivered, 5 open

- [x] §5 Node-bound skill availability — T · A3.8a / T-C15; footprint and payload separated, equivalent nodes remain source instances, optional producer dependencies gate Payload only
- [x] §6 Technique archetypes, payload modules and derived renditions — T · A3.8b / T-C16
- [x] §7 Carrier contract, delivery proof and bounded payload direction — K · 5.2a / K-C16; H · 6.1a / H-C9
- [x] §8 Armour, equipment slots and target layers — M · 2A.4a / M-C15; H · 6.1a / H-C9
- [x] §9 Anatomical targeting — H · 5.4 / H · 6.2a / H · 11 / H-C10; one normalised effective-weight distribution, tier aggregation, no parallel table
- [x] §10 Aimed skill modes — T · A3.8b / T-C17; K · 3.4 / K · 5.2a / K-C17; H · 6.2a / H-H5
- [x] §11 Enemy aimed-mode access — E · F.0a / E-C8; acting-tier permission, target independence and perception-bound choice
- [ ] §12 Authoring and automation pipeline — grains, deterministic generation, validation, regression fixtures
- [ ] §13 UI and legibility

## Prerequisite rulings — closed 4 of 4

| # | Disposition | Authoritative result |
| --- | --- | --- |
| 1 · Scope order | **`authored` — A-ROADMAP · Current bridge** | Four packages: A1 §§5–8, closed 0.38.0; A2 §§9–11; A3 §12 after A1+A2; A4 §13 after owning mechanics and V |
| 2 · Grade vocabulary | **`authored` — M · 2A.10a / M-C12; L · 7** | **Incidental = 1, Dedicated = 2, Apex = 3** persist as canonical base innate magnitude grades. Apex is the ordinary single-node ceiling |
| 3 · Carrier proof | **`authored` — K · 5.2a / K-C16; H · 6.1a / H-C9** | The carrier contract closes after step 7; delivery proof reads step 8's immutable layer trace exactly once. Payload resolution cannot feed back into primary resolution; secondary payloads cannot recurse as new carriers |
| 4 · Anatomical targeting | **`enforced-elsewhere` — H · 6.2a / H-H5 / S-H09** | Any aimed mode reweights the existing coverage cascade through `aim_weight < AIM_CEILING < 1.0`; it never selects a node or defines a parallel payload-specific aim value |

**A1 and A2 closed.** §§5–8 are centralised in T/M/K/H/L. §§9–11 reuse H's existing anatomy and coverage authority, add Technique/timing boundaries in T/K, and author enemy access in E. P schema/grain work remains deliberately deferred to A3 §12; technical C must not encode the A2 contract until that design grain is authored.

**Source restored.** The original 0.36.0 proposal is governed locally as `02-M14_Consolidated_Innate_Node_Payload_Aiming_Proposal_TRIADE-0_36_0.md`. Its historical version and non-authoritative status are preserved. Where it conflicted with the adopted resolution order, the central contract distinguishes the pre-damage carrier contract from post-mitigation delivery proof rather than copying proposal text verbatim.

**Sequence after A2:** Session B closed at 0.44.0: `◈P13`, `◈P11` and `◈P12-A/B/C` now own lineage/physique and innate grants, Faculty profiles/authorizations, entitlement/acquisition, derived readiness and target-route contracts, pure evaluation, exact-candidate commitment and autonomous Plannable Actions without reopening H-owned anatomy. Tarot Session C1 is now current. Faculty instances reference the Technique's existing aim capability rather than copy it. Tarot may later affect an already aim-capable Technique, but cannot create target nodes, raise granularity, bypass `AIM_CEILING`, bypass E's acting-tier/perception boundary, or bypass the exact-candidate/no-silent-fallback contract without an explicit new rule.

## Boundary

**No design decision is authored by this record.** Nothing here may be cited as a corpus rule, and no `[SIM]` value is registered from it. It retires to `Research\` when every item above is struck or assigned with a named destination.
