# Triade — Technical Implementation Stream

**Instructions version:** 1.3  
**Aligned to Triade:** v0.38.0  
**Filename:** `Z-Technical_Stream_Project_Instructions_TRIADE-[V_e_r].md`

## Purpose and authority

These instructions govern sessions implementing Triade and producing technical documentation. They supplement central `Z-Design_Stream_Project_Instructions_TRIADE-[V_e_r].md`; if they conflict, central instructions win.

Design authoring, proofing, reconciliation, versioning, index/ledger regeneration, archives, and final governance belong to the **central process**.

This stream owns the **technical implementation layer**: architecture, schemas, file layouts, APIs, tooling, deterministic pipelines, configuration, build/test harnesses, migrations, implementation proofs, and technical documentation.

Technical documents have **no game-design authority**. They may realize or test design-owned rules, but may not silently originate a rule, number, term, vocabulary lock, balance decision, or subsystem meaning. If implementation and design disagree, **design wins**; patch the implementation and record consequences.

## Source authority and session start

`X:\Documentation` is authoritative. Google Drive is a controlled copy; a Drive-only claim is not verified against the tracked store.

Before technical work:

1. Read `VERSION-MANIFEST.md`, including its handoff block.
2. Read current central instructions and the owning and directly constraining design documents.
3. Run every check listed in the manifest against the attached tracked store; report unavailable external dependencies separately.
4. Report exit codes and measured denominators. Stop on unexplained ledger drift, retirement survivors, or incomplete intake claims.
5. Treat derived indexes as indexes; verify material claims against source sections.
6. If a technical document is behind the manifest, version-align and re-proof it before extending it.

Memory, summaries, obsolete documents, archives, patch files, and Drive drift are not authority. Never edit `Archive\`.

## Authored design decisions

The stream may resolve a design decision when implementation requires a choice or defined boundary.

Record it in PATCHES / INTAKE as **`AUTHORED DESIGN DECISION`**, with decision, rationale, evidence, sources checked, affected documents, proposed owner + section, consequences, and rejected alternatives.

Implementation may use it as a working decision. Until centralised in exactly one design section, reconciled, indexed, and versioned, label it **authored-but-not-yet-centralised**; never cite it as an existing rule. Once centralised, re-proof against the authored source and cite it exactly.

## Technical documents

Each technical document must state:

- aligned Triade version;
- scope and owning design document(s);
- authority boundary;
- implementation state and blockers;
- proof/verification status;
- changelog.

Record **how design is realized**: schemas, types, paths, formats, versions, transforms, interfaces, validation, tests, and procedures. Prefer exact source references over duplicated design prose.

## Version alignment

Technical documents align to the latest released version in `VERSION-MANIFEST.md`. After a central release:

1. inspect changed design documents;
2. re-proof affected assumptions and migrations;
3. patch by anchored edits;
4. update current-state claims and governed filename;
5. distinguish design-driven from implementation-only changes;
6. run the version check and read back each changed claim.

Never independently choose or bump the Triade design-set version. Historical version claims, counts, hashes, and release facts are immutable; do not blanket-replace version strings.

## Session to durable documentation

When a session produces durable implementation knowledge:

1. separate **implementation fact** from **design implication**;
2. write implementation facts into the relevant technical document;
3. verify them against current authoritative sources;
4. update status, schemas/examples, proof notes, and changelog;
5. produce or update the companion PATCHES / INTAKE file.

Use exact anchors that fail loudly. Regenerate only when necessary; then compare with the prior governed version and report headings, terms, and material content lost.

## Mandatory PATCHES / INTAKE companion

When technical work changes a technical document or finds a cross-document consequence, produce an aligned **PATCHES / INTAKE** companion. It is a central handoff, not authoritative content.

Each item records:

- local patch label only — never mint a design ID;
- type: `FINDING` or `AUTHORED DESIGN DECISION`;
- finding/decision and implementation pressure;
- evidence and exact references checked;
- affected documents and recommended target document + section;
- recommended wording where useful;
- impact if not adopted;
- implementation blocker: yes/no;
- central disposition and reconciliation notes.

Central dispositions:

- `authored` — incorporated into exactly one design document + section;
- `enforced-elsewhere` — already authoritative; cite the existing ID/section;
- `backlog` — accepted but deferred; central process creates or uses a `◇` item in one named home;
- `struck` — rejected or superseded; reason required;
- `unresolved` — home, ruling, or reconciliation remains unsettled.

A `FINDING` recommending a new rule, term, number, or decision is only a proposal. Never assign authoritative rule or open-item IDs in this stream. **No ID before a design home.**

## Patch coverage and blockers

Before closing, check owning/constrained documents, Lexicon, markers, validation-rule sources, ROADMAP, VERSION-MANIFEST status, cross-references, and both instruction files. List reviewed documents under **No patch required**.

Classify each implementation question:

- **technical-only** → resolve here;
- **design decision resolvable here** → resolve as `AUTHORED DESIGN DECISION`;
- **design-owned unresolved** → PATCHES / INTAKE;
- **blocked by existing `◇`** → cite it; do not duplicate;
- **requires simulation** → cite the owning `[SIM]`; do not silently lock a value;
- **unowned design gap** → central reconciliation; do not invent an owner.

Proceed around unresolved design only with an explicit provisional assumption that cannot silently become canonical.

## Proofing and closeout

Prefer executable evidence: schema/migration tests, deterministic hashes, golden fixtures, idempotence, reference integrity, and measured coverage. A clean exit is insufficient when coverage is countable. Make new checks fail once on scratch, read back writes, and state denominators.

Never hand-edit the three derived indexes or `FOLDER-LEDGER.json`; the central process regenerates them after adopting source changes.

Default durable-work deliverables:

1. updated/new version-aligned technical document;
2. companion PATCHES / INTAKE;
3. proof summary separating verified from unverified;
4. implementation candidate/patch/package and checksums where applicable;
5. replacement technical-stream instructions only when alignment or governance requires it.

## Supplemental Project Instructions

The internal instruction version is independent; the filename follows the governed design-set version. The technical stream authors this file. The central process requests changes through a priced counter-patch and never edits it directly.

Prepare a **complete replacement** when alignment, technical ownership, deliverables, intake handling, technical-document classes, or central instructions change materially. Each replacement must state both versions, preserve valid obligations, stay below **8,000 characters**, be copy-ready Markdown, and be described as ready for manual insertion—not already installed.

The central process alone decides what enters the authoritative design corpus and whether the design-set version changes.
