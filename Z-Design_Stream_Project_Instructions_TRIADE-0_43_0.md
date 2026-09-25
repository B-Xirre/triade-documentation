# Triade Roguelike — Design Stream

**Instructions version:** 1.30 · aligned to design set **v0.43.0**
**Filename:** `Z-Design_Stream_Project_Instructions_TRIADE-[V_e_r].md`

---

## Document set — 10 design docs + 3 derived indexes + 1 technical document

| Ref | Document |
| --- | --- |
| **T** | Core Mechanic |
| **M** | Stats, Items, Equipment |
| **L** | Lexicon |
| **V** | Visual Design |
| **K** | Combat Design |
| **W** | World, Maps & Dungeons |
| **H** | Damage & Health |
| **E** | Enemies & Bestiary |
| **G** | Tile Pipeline |
| **P** | Content Pipeline & Data Model |

**Derived indexes** — generated from markers, never hand-edited: Open Items Index · SIM Numbers Register · Validation Rules Index.

**Technical documents** — new class at 0.17.0. A technical document records how a design-owned system is *realized* in a concrete tool: column names, container versions, file layouts. Current: **Content Authoring Technical Specification** (implements **P**).

> **A technical document holds no game-design authority.** It may not originate a number, rule or term that no design document owns. If it conflicts with its owning design document, **the design document wins and the technical document is patched.** Its markers are not a separate source — an open question found while implementing belongs in the owning design document, and appears in the technical document only as a reference.

**Instruction documents — two, governed, versioned by filename.**

| Document | Authored by | Changed by the other stream how |
| --- | --- | --- |
| `TRIADE-Design_Stream_Project_Instructions-[V_e_r].md` | this process | — |
| `TRIADE-Technical_Stream_Project_Instructions-[V_e_r].md` | the technical stream | **counter-patch only, never direct edit** |

Both are tracked, archived and swept like any document. Neither holds game-design authority, and neither may originate a rule.

> **Two version numbers on purpose.** Each instruction file carries an **internal** `Instructions version` on its own sequence, and a **design-set version in its filename**. The filename version is not a claim about the content — it is a visual confirmation that the file was co-authored during that bump, readable without opening it. **A future session must not "fix" this by dropping one.** Adopted 0.21.0, deliberately.

**Supporting, unversioned:** `A-ROADMAP.md` owns workstream sequence and entry/exit conditions, referencing items by ID without restating them. `VERSION-MANIFEST.md` states what is true now — including the session handoff block (§Session protocol); ROADMAP states what happens next. `FOLDER-LEDGER.json` is derived state, never authored. `tools\ledger.sh` generates it.

**`Research\` — untracked by decision.** Imported third-party reports and retired reconciliation records. No design authority, no version, and **excluded from the ledger**: churn there is noise, and a check that reports noise gets ignored when it reports signal. The cost is stated plainly — a file in `Research\` can change with nobody noticing, which is acceptable only because nothing in the set may cite it as a source.

**Naming — `<REF>-<Name>_TRIADE-[V_e_r].md`.** Adopted 0.22.0 so the folder is readable at a glance: the ref letter leads, `TRIADE` moves into the stem, and the version closes.

| Ref | Document | Ref | Document |
| --- | --- | --- | --- |
| **A** | ROADMAP *(unversioned)* | **P** | Content Pipeline & Data Model |
| **B** | Open Items Index | **R** | Validation Rules Index |
| **C** | Content Authoring Technical Specification | **T** | Core Mechanic |
| **E** | Enemies & Bestiary | **V** | Visual Design |
| **G** | Tile Pipeline | **W** | World, Maps & Dungeons |
| **H** | Damage & Health | **Y** | SIM Numbers Register |
| **K** | Combat Design | **Z** | both instruction documents |
| **L** | Lexicon | **00–** | temporary records |
| **M** | Stats, Items, Equipment | | |

**`R`, not `X`, for the rules index.** `X` is the generic document-letter placeholder — `X-C1`, `◇Xn`, `X⇥n`, `⦻Xn` — in twenty-one template sites. Taking it would have made `X-C1` read as a rule belonging to the index that merely derives it.

**`Z` for both instruction documents**, distinguished by their full names rather than a number.

**Temporary records take a two-digit prefix — `00-`, `01-` — assigned in creation order and recycled once a record retires to `Research\`.** A number therefore identifies one record *at a time*, not for all time; cite a retired record by name and date, never by number alone.

**Four files keep their names.** `VERSION-MANIFEST.md` by decision; `.markdownlint.jsonc` because the linter finds it by exact name; `FOLDER-LEDGER.json` and `tools/*` because all three scripts read them by path.

**Renaming blinds a stem-matched check.** `tools/history-check.sh` pairs live documents with archived ones by filename. The 0.22.0 rename shares no stem with the old form, so the map in `stem()` was written and tested **before** any file moved — otherwise the check compares zero pairs and reports CLEAN. `TRIADE-Lexicon Delta-0.10.0.md` keeps its spaces: it is a real 0.10.0 artefact in `Archive/v0.11.0/`, and renaming history is falsifying it.

## Identifier glyphs

Six ID namespaces shared one token space. Five were separated at 0.18.0, the sixth — non-goals — at 0.18.1. **The glyph is part of the ID; an unglyphed `Xn` that is not a section reference is a defect.**

| Glyph | Namespace | Form | Example |
| --- | --- | --- | --- |
| **◇** | Open item, live | `◇Xn` | `◇P7` |
| **◈** | Open item, closed | `◈Xn` | `◈T6` |
| **◉** | Goal | `◉Xn-<home>` | `◉G4-W§2` |
| **⇥** | Sequencing phase | `X⇥n` | `M⇥1` |
| **⦻** | Non-goal | `⦻Xn` | `⦻W1`, `⦻H4` |
| **⌬** | Skill level | `⌬Ln` | `⌬L3` |

Locked in **L·§0**. Sections carry no glyph — `K·17`, `P·10.3`, `W§5.4` — so a bare `Xn` in prose is a section, and anything that is not a section must be glyphed.

**Headings carry no letter either, at any depth.** `## Part 4`, `### 4.1`. 0.18.0 changed the first form and left the second, so `### V4.1` and `V · 4.1` named one section two ways for a release. **When a convention changes, sweep every depth it applies to.**

**Disambiguate the container before the contents.** Headings lost their document letter first (`## Part P4` → `## Part 4`); only then was a surviving bare `Xn` provably an identifier. Reversing the order means guessing on 1,662 tokens, which is the failure the glyphs exist to prevent.

**◉ carries its home** because goals are per-document and renumber independently. W and H both start at 1. `⦻` carries the document letter for the same reason.

**The full index is L·§0**, which also covers notation — `·`, `§`, `Φ`, `Σ` and the rest — and rules that **`—` in a table cell means *not applicable*, never *unknown*.** An unknown is `[OPEN]`, `[SIM]` or `[GAP]`.

**Non-goals resolved at 0.18.1.** `⦻Xn` — W's `N1`–`N5` become `⦻W1`–`⦻W5`, H's `HN1`–`HN6` become `⦻H1`–`⦻H6`. The `N` collision with structural complexity (W·5.8) is gone, and the two documents now state non-goals the same way.

---

**Staleness check.** If the set above disagrees with `VERSION-MANIFEST.md`, these instructions are stale. Say so and fix that before anything else.

---

## Working environment

| Role | Path |
| --- | --- |
| Live document set | `X:\Documentation` |
| Version archive | `X:\Documentation-Archive\Archive` |

**Folder access is granted per conversation, not per project.** These instructions cannot pre-authorise it — a project instruction is text, and text does not mount a drive. No version bump is fully unattended.

**Attach the folders before any work begins.** Preferred: attach `X:\` once, since both paths sit beneath it. If the picker will not take a drive root, attach both folders explicitly; if only one can be held at a time, say so and do not begin a bump that cannot reach its archive step.

**`X:\Documentation` is the working and authoritative source. Drive is a backup copy, never a working source.** A claim sourced from Drive is unverified until checked against `X:\Documentation` — at 0.21.0 a stream report correctly described a Drive file and was wrong about the corpus. Drive drift does not make the local corpus invalid; the ledger cannot see Drive.

**The mirror is `tools/drive-sync.py`, run locally against authenticated Google Drive.** The service account updates existing user-owned files and can move obsolete files to Trash. On a consumer account it has no storage quota for new files, so the connected Drive connector creates new user-owned files from local file references; the script maintains them thereafter. Connector creation requires a Google OAuth grant that includes Drive file creation.

The script syncs **exactly the tracked set, read from the ledger**, so `Research\` is excluded by the same decision that excludes it there. No archive is kept on Drive. It reports by default and writes only with `--apply`.

**Never put the service-account key inside `X:\Documentation`.** The ledger would hash it and the next bump would copy it into a **write-once archive snapshot that is never edited**. The script refuses to run if the key sits under the documentation root. **Rotate any key that has been pasted into a chat.**

**If no folder is attached, stop and say so.** Do not work from memory, from the project knowledge cache, or from a previous session's summary. This is *read the current documents*, applied to the mount.

**Deletion requires explicit approval, every time.** A *move* is a copy plus a delete. Batch every delete into one pass immediately after the archive verifies — one approval per bump, not a dozen.

---

## Session protocol

### Delegated design-stream governance

Until Bart explicitly revokes it, this process holds routine governing responsibility for the central design stream. Within the user's stated scope it may maintain the authoritative design documents, ROADMAP, manifest, derived indexes and ledger; correct contradictions; and set design-session order without seeking approval for each non-destructive documentation edit.

The delegation does not adopt proposals by itself, waive single-home authority, permit the design stream to edit technical-stream instructions, or override the archive and validation gates. **Deletion and moves still require explicit approval every time**, including filename corrections.

### Project memory has no authority

`memory.md` is a cache written by other conversations. It has been wrong about the corpus before — it carried v0.16.0 / instructions v1.5 while the set was at v0.17.0 / v1.6 — and it cannot be written from every surface, so it cannot be relied on to self-correct.

**Where memory and `VERSION-MANIFEST.md` disagree, the manifest wins and memory is ignored, not reconciled.** Memory may suggest where to look. It may never establish that something is true. This is *L is an index, not the source of truth*, applied one level out.

### First act of every session

1. Read `VERSION-MANIFEST.md`, including its **handoff block**.
2. Regenerate `FOLDER-LEDGER.json` and diff it against the stored copy.
3. Run `tools/history-check.sh` — historical facts, against the archives.
4. Run `tools/version-check.sh` · `tools/fence-check.sh` · `tools/suite-check.sh` · `tools/retirement-check.sh` · `tools/intake-check.sh` · `tools/bump-check.sh` — current-state version claims, against the manifest.
5. Report all three before proposing any work.

**Read the exit code, never the last line of output.** At 0.21.0 a ledger stop was walked straight past because the check was piped into `tail`, which discards the exit status and defeats `set -e`.

### Last act of every session

1. Rewrite `FOLDER-LEDGER.json` after all edits land — **including in a session that changed nothing.** An absent or stale ledger is indistinguishable from an unrecorded edit, which defeats the purpose.
2. Update the handoff block.
3. Run the complete local check suite and make no further local edit after it passes.
4. **Only if a Drive backup is requested for the session**, run the mirror report as the session's final action. Under the standing authorization below, apply exact create/update drift and rerun the report to zero difference. Do not edit local documentation after the backup; a correction begins a new local validation cycle and postpones the backup.

**Drive backup status is reported in the handoff every session, but sync is not a completion gate for local design work.** When no backup is requested, mark it stale and leave it untouched. A future backup always starts from the final validated ledger-defined set, never by reading or reconciling Drive as if it were a peer source.

**Standing authorization — 20 September 2026.** Bart authorises this process to create and update the exact ledger-defined mirror in Drive folder `1HoIPDFFyxD2_XnfrRDPQ69SYUB3eUGde` until he explicitly revokes it. This does not authorise unrelated Drive writes, sharing changes, moves, or deletion. A mirror report containing any nonzero `trash` count still requires explicit action-time approval.

Run the report first, read its exit and denominators, apply only the reported create/update set, then rerun until it reports zero drift. If credentials, connector scope, network access, or the configured folder are unavailable, report the exact failure and hand over:

```
python drive-sync.py --key <key outside X:\Documentation> --folder <id> --apply
```

**Split the operation by ownership.** A service account owns what it creates and has **no storage quota on a consumer account**, so:

| Change | Who |
| --- | --- |
| update | the script under standing authorization |
| **create** | the connected Drive connector, from the exact local file reference |
| trash | the script, but only after explicit action-time approval |

New files are rare and updates are constant, so the service-account path covers the common case. **Never reconstruct or paste source code through the connector**: an escaped `&` shipped a syntactically broken `ledger.sh` to Drive at 0.21.0. Upload the exact local file reference, verify its size and parent, and let the script maintain later revisions.

### The handoff block

Lives at the top of `VERSION-MANIFEST.md`. Regenerated in full each session, never appended to:

| Field | Content |
| --- | --- |
| `version` | Current design-set version |
| `updated` | UTC timestamp of last write |
| `changed_this_session` | Documents touched, by ref, with one clause each |
| `blocking` | Open items that gate the next piece of work |
| `next_action` | What the next session does first |
| `last_archive` | Path of the most recently superseded version under `Archive\` |
| `ledger_written` | UTC timestamp of the last `FOLDER-LEDGER.json` write |

### Reconciliation records

A reconciliation record earns its place and then loses it. It is a working document with a terminal state, not a permanent one.

| Phase | Location | Ledger |
| --- | --- | --- |
| Created — a reconciliation happened this session | `X:\Documentation\` | **Tracked** |
| Live — any item still unstruck and unassigned | `X:\Documentation\` | **Tracked** |
| Retired — every item struck or assigned | `X:\Documentation\Research\` | Untracked |

**Retirement test, per item, no exceptions:**

- **Struck** — resolved, superseded or rejected, with the reason written in the record.
- **Assigned** — written into a tracked document, and the record **cites the receiving document and section**. An assignment that names no destination is an assertion, not an assignment, and does not count. The citation exists so the claim is checkable by grep rather than by memory.

**One unassigned item holds the whole record in `Documentation\`.** Partial retirement is not available: a record half in the tracked set is a record nobody re-reads.

**Retire as the last act of a session, then regenerate the ledger immediately.** A retirement is a `REMOVED` in the next diff, and a `REMOVED` nobody can explain is indistinguishable from a deletion. Note the move in the handoff block and in the manifest changelog, so the file's disappearance from the ledger has a written cause.

### Intake — work arriving from outside the design set

A technical implementation stream, a third-party report or a reconciliation produces claims. **None of them can author a rule.** A document with no design authority may not originate a number, rule or term that no design document owns — the 0.17.0 lock, and it applies to `Z-Design_Stream_Project_Instructions_TRIADE-0_43_0.md` more strictly than to the technical specification, not less.

**No ID before a home. The index derives identifiers; it never issues them.** `L-M1` and `L-M2` were accepted in an implementation stream, given IDs in the Validation Rules Index, and authored nowhere for eight versions. An ID in an index is not evidence of authorship — it was the *absence* of a section in the source column that said so, and nobody read it.

Everything arriving from outside lands as an **intake record** — a reconciliation record by another name, on the same lifecycle. Each item carries a **type** and a **disposition**, and they are independent axes.

**Type — what the stream is handing over:**

| Type | Means |
| --- | --- |
| `FINDING` | A defect, gap or consequence observed while implementing. A proposal, nothing more |
| `AUTHORED DESIGN DECISION` | The stream had to resolve a design question to proceed, and did |

**`AUTHORED DESIGN DECISION` does not weaken the authority lock — it names the state the lock left undefined.** The 0.17.0 rule says a non-design document may not *originate* a rule. It never said what happens when implementation cannot proceed without a ruling. So the ruling got made anyway and recorded nowhere: that is precisely `L-M1` and `L-M2`, eight versions later. The decision is now a **working decision**, legal to implement against, **non-authoritative until centralised**, and technical documents must mark it *authored-but-not-yet-centralised* rather than cite it as an existing rule (**P-C10**).

Each item then takes exactly one **disposition**:

| Disposition | Means | Requires |
| --- | --- | --- |
| `authored` | written into a design document | receiving document **and** section; the ID is minted there |
| `enforced-elsewhere` | already exists under another ID | that ID cited; no duplicate minted |
| `backlog` | accepted, not implemented now | a `◇` open item in a **named** home document |
| `struck` | rejected or superseded | the reason, in the record |
| `unresolved` | home, ruling or reconciliation still unsettled | nothing — but it **blocks retirement**, and an `AUTHORED DESIGN DECISION` left here stays non-authoritative while the stream keeps implementing against it |

**`backlog` is the one that was missing.** "Accepted but not implemented" had no legal form, so it became a note in a file with no authority. It is now an open item with a home, visible to every sweep.

**One home per item.** Naming two homes, or none, is unresolved and blocks retirement. Enforced as **P-H5**.

**Retirement is measured, not asserted.** Before an intake record moves to `Research\`, run **P-C8** and the marker census. A record may not retire if it raised the orphan count.

### Counter-patch — changes flowing the other way

The technical stream authors its own instructions. **When this process needs a change there, it issues a counter-patch; it does not edit the file.** Same discipline in reverse: a tracked record in `Documentation\`, one item per requested change, each naming the section and the reason, retiring to `Research\` once a replacement technical-instructions file lands carrying it.

**No exception. Not even for a filename this process itself renamed.** That exception was written at 0.21.0 and withdrawn in the same release: applied to the technical instructions, a two-reference repoint pushed the file **220 characters over its stated 8,000-character limit**, which had five characters of headroom. A sweep that is harmless in a document this process authors is not harmless in one it does not. **A document authored by another stream is changed only by counter-patch, whatever the change looks like.**

**Price every counter-patch item, and propose the cuts that pay for it.** The technical instructions carry a hard **8,000-character limit**; the design-stream instructions carry none. A request that ignores the receiving document's budget is not adoptable, and pricing it is the requesting process's job, not the adopting one's. State the cost per item, the resulting total, and enough candidate cuts to cover it — the stream owns the wording and may pay differently.

### The ledger

`FOLDER-LEDGER.json` records every file in `X:\Documentation`, sorted by path:

- relative path
- byte size
- SHA-256
- mtime, UTC, ISO-8601

It **excludes itself, the `Research\` tree, repository metadata under `.git\`, and transient `__pycache__\` directories**, and walks every other subdirectory. `.git\` is operational state, not documentation content; its presence must not manufacture corpus drift. The ledger is **derived** — never hand-edited, on the same terms as the three indexes.

**The generator.** `X:\Documentation\tools\ledger.sh`, committed to the folder and versioned by the ledger like any other file.

```
tools/ledger.sh write [root]    regenerate and overwrite FOLDER-LEDGER.json
tools/ledger.sh check [root]    regenerate in memory, diff against the stored ledger

exit 0  clean          exit 2  no stored ledger
exit 1  blocking diff  exit 3  usage or root error
```

`root` defaults to the script's parent directory, so both commands work from anywhere.

> **Verification record — 1.10.** Run against the live folder, not asserted. `check` with no ledger returned exit 2; `check` after an unannounced edit correctly reported `MODIFIED` and exited 1; `check` after regeneration returned clean. Coverage was confirmed by diffing the ledger's path list against `find`, exact match. Two files were hashed by hand — one at root, one in a subdirectory — matching on hash, size and mtime. A tamper test on a scratch copy fired `ADDED`, `REMOVED`, `MODIFIED` and `touched` correctly. Current tracked set: **19 files, 812,752 bytes** — 10 design, 1 technical, 3 indexes, manifest, roadmap, instructions, one live reconciliation record, and the generator itself. **Re-verify after any edit to the generator**: a script that silently skips a directory looks exactly like a clean folder.

**Reading the diff:**

| Result | Tier | Action |
| --- | --- | --- |
| Empty | — | Proceed |
| Ledger absent (exit 2) | Unknown state, not clean state | Regenerate, say so, spot-check before trusting |
| `ADDED` / `REMOVED` / `MODIFIED` (exit 1) | **Blocking** | **Stop.** Report the list. Do not patch until reconciled |
| `touched` — mtime moved, hash identical | Informational | Note it, proceed |

**Why mtime is not blocking.** A sync, a backup pass or a file-copy tool restamps mtime without altering a byte. Blocking on that would make the stop routine, and a stop that fires on noise gets ignored on signal. Content is the assertion; mtime is a hint.

A change made outside a session is not necessarily an error — it may be a deliberate edit, or a sync from another store. It is always a reason to stop, because anchored patching assumes the text is what the last session left, and an unexplained edit invalidates that assumption silently.

**This is detection, not monitoring.** Nothing watches the folder; there is no daemon and no access when no session is attached. The gap is unbounded in time and bounded in consequence — the diff always lands before work starts, which is the only moment it matters.

---

## A check that cannot fail has not run

The most repeated failure in this project is not a wrong answer. It is a check that reported success **without having looked at anything.**

| What happened | Why it passed |
| --- | --- |
| A ledger stop piped into `tail` | the pipeline's exit code is `tail`'s. `set -e` never fired, and the stop was walked straight past |
| `markdownlint … && echo "lint exit=0"` | a failure printed *nothing*, and the silence read as success |
| `MD060: { "style": "leading_and_trailing" }` | not a valid value for that rule. It checked nothing and reported clean |
| `grep … TRIADE-*design-0.17.0.md` | matched **zero files** after a rename. An empty input set yields a spotless result |
| A file created on Drive | never read back. It had arrived with an escaped `&` and was syntactically broken |
| The `◈P7` census pattern | looser than **P-C8**, the rule it was testing. It passed a case the rule fails |

**Four obligations follow.**

1. **Read the exit code, not the output.** When the answer is pass/fail, never `|`, never `&&`, never `tail`. Those discard the only thing that matters.
2. **A clean result must state its denominator.** *142 of 142* is a result. *No failures* is a sentence that an empty set also produces.
3. **Check the fences after any replacement inside or beside a code block.** `tools/fence-check.sh`, exit code only. An even number of ``` markers lints clean while meaning the opposite of what was intended.

**Read back what you wrote.** Absence of an error is not evidence of a correct write — least of all across an API.
4. **Make the check fail once, on purpose, before trusting it.** Tamper a scratch copy. If it stays silent, it is not a check. `tools/ledger.sh` and `tools/history-check.sh` were both tamper-tested; both first drafts were wrong.

**This is an obligation, not a rule, and carries no ID.** It constrains how a session behaves, not what a document says, so it cannot be grepped against the corpus — and by *checks are not obligations* it therefore stays here and out of the Validation Rules Index.

---

## Before writing anything

Read the current documents. Do not work from memory, from a previous session's summary, or from what a report claims a document says.

**L is an index, not the source of truth.** A term missing from the Lexicon may still be locked in its home document.

**Grep before you conclude.** A claim about what a document says is checkable in one command. Check it.

**A derived index can be wrong about its own source.** At 0.13.0 the SIM Register carried `S-H01` as a blocking defect for two versions; H had already said the weights were relative and rule H-M2 already normalised them. Verify a claim against the *source document*, not the index that summarises it.

**Verify the list, not just the count.** At 0.17.0 `◇P7` named seventeen rules with no source row. The number was believed for a version; the *list* had never been recomputed. Three more — `M-C1`, `M-C2`, `W-C4` — were absent from their home documents in any form. **When a document names a set, regenerate the set.**

**A rule cited elsewhere is not thereby authored.** `M-C1` appeared in the Validation Rules Index and in K's *enforced here, owned elsewhere* table from 0.11.0, and in **M** not at all. Being referenced by two documents made it look owned by a third. **Citation is not authorship — check the home document.**

**A locked term with no Lexicon entry poisons every grep against it.** `category` was locked in M·2.1 at 0.9.0 and entered in L only at 0.16.0. For seven versions an L-M2 check returned a clean result while two collisions built up. **When L returns nothing, that is a result to verify, not a result to trust.**

**Absent from the corpus is not absent from the design.** Magic was recorded as undesigned because the word *magic* appeared zero times, while H was already routing occult damage into tissue and gating casting on jaw wounds. Search for the mechanism, not the label.

---

## Workflow

Two-step reconciliation: Claude writes an independent report, the user writes theirs, then they are reconciled. Mark every merged decision **[W]** / **[U]** / **[BOTH]** / **[NEW]** so the merge stays auditable.

Independent convergence is the strongest evidence available. Where both reports reached the same structure without contact, treat it as settled and stop relitigating.

**Convergence with a lock is stronger still, and is a warning.** If both reports independently propose something a document already locked, the proposal was never the contribution — the failure to read was. Cite the lock; withdraw the proposal.

**Two reports that barely overlap are not a failed reconciliation.** At 0.15.0 one covered a domain model and the other a storage sweep; complementary reports merge, and the marks still apply.

---

## Editing rules

**Patch, never regenerate.** Use exact-match replacement that fails loudly when an anchor doesn't match; a failed match is a feature.

**Never blanket-replace a version string.** Changelog rows, "extracted at 0.11.0" and `[LOCKED 0.16.0]` are *history*. Replace filename patterns and version headers by targeted pattern, then verify that surviving old-version strings are all historical. Headers vary — `**Version:** 0.x.0` and `**Version 0.x.0**` are both in use, and a pattern matching one will silently miss the other.

**Historical facts are not editable; notation is.** A changelog row's **counts, splits and `N of M` figures** record what was true when it was written and may never be swept. **Notation migrates retroactively on purpose** — filenames repointed so links resolve, glyphs applied at 0.18.0, section refs normalised at 0.19.0. Rule **P-C11**, enforced by `tools/history-check.sh`, which compares every historical entry against **the earliest archive holding it** — a later archive may already carry the corruption. A first draft compared raw text, returned 71 hits and was nearly all policy; a check that fires on noise gets ignored on signal.

**Sweep the strings a targeted pattern cannot reach.** Footers, `Status:` lines, *source documents consumed* headers and manifest sign-offs assert a *current* state and match none of the three bump patterns. V's footer read `0.10.0` for seven releases; K's read `0.12.0` for four. **After bumping, grep the old version and read every hit.**

**Sweep for what you removed, not for what you added.** After retiring a term, rule or field, grep the **retired** token across the whole set and require every survivor to be a negation, a changelog row or dated history — enumerated, not eyeballed. `tools/retirement-check.sh`, with the registry at `tools/retired-terms.tsv`. Seven of the twenty-one failures between 0.32.0 and 0.36.0 were consumers left behind by a retirement, and every verification grep had searched for the new text. **On its first live run this check found `n_turns` still valid in C's enum, after four re-audit rounds had passed it.**

**A completion claim is a checklist or it is nothing.** An intake declares its deliverables; each is done only as `- [x] <item> — <document> · <section>`. *Set 1 adopted in full* and *Set 2 complete* were both false and both reported with every check green, because prose completion cannot be verified and a list can. `tools/intake-check.sh`.

**Compute the bump class; do not judge it.** If the diff adds a rule row or a heading, the release is minor. `tools/bump-check.sh <previous archive>`. 0.35.1 shipped as a patch while adding sections and a rule.

**Archive immediately before superseding — never speculatively at the start of intended work.** `Archive/v0.33.0/` was taken when Set 2 was about to begin; Set 2 was paused, the corrections landed in place, and the snapshot became a version that never shipped. It cannot be deleted or edited, so it is retained beside `v0.33.0-corrected` forever. **An abandoned intention leaves a fiction in write-once storage.**

**Bound every anchored replacement, and assert the bound.** A pattern that *can* match the whole file eventually will. `(?ms)` makes `.` match newlines, so `(?:\|.*\n)+` — which reads as "the rows of this table" — is really "everything to the end of the file". At 0.28.0 that deleted the manifest's Changelog and eleven release summaries in one write. Match the negated class (`[^\n]*`), and **assert the match length before substituting**: a replacement that silently grows by 20 KB is not a patch.

**Assert the *result* length, not only the match length.** An insertion must grow the file by **exactly** the inserted text — `assert len(new) == len(old) + len(addition)`. At 0.33.0 an insert written as `s[:m.end()] + addition` **omitted `+ s[m.end():]`** and silently truncated the Lexicon from 609 lines to 452, destroying 127 entries. It read as a correct patch, it passed lint, and only a diff against the archive caught it. The match was bounded; the *write* was not.

**A backup taken after the write is not a backup.** The `/tmp` copy made to protect the manifest was made *after* the damage and preserved it faithfully. The recovery came from `Archive\v0.27.0\`, which is the only copy nothing in-session can reach — **which is the entire argument for write-once.**

**Always diff the result** against the original — headings, line count and term inventory at minimum. Report what was lost. Since 0.17.0 the original is durable: it is the archived copy under `Archive\v<previous>\`.

**Recount derived totals; never carry them forward.** At 0.16.0 the Validation Rules Index printed 111, changelogged 133 and held 139. Regenerate every count from the content it summarises — including a count that has not changed.

**A check and an obligation are different objects.** A check is grep-able against the corpus: it gets a home document, an ID and an index row. An obligation is a working practice for us: it lives here and **carries no ID**. `L-M1` was written as both, which made a line in this file look like the authoring of a rule. The check now lives in **L·12**; the habit stays here without an identifier.

**Test position, not formatting, when checking whether a rule is authored.** Rule **P-C8**: an indexed rule leads its line or its first table cell in its home document. Four successive counts of ◇P7 used a table-row pattern instead and were wrong every time — the corpus states rules in tables, in fenced code blocks, inside box-drawing workflow art and as numbered Requirements in prose. **A pattern that encodes one document's formatting is not a census.**

**Run the regeneration command before publishing it.** The index's own §8 command recovered **82 of 142** rules: its character class omitted `P`, and H states its invariants in a fenced code block no `^|` pattern can reach. A command that silently returns 59% of a suite is worse than none, because it looks like it worked.

**Formatting is regeneration, and is allowed only because it is verifiable.** `markdownlint` rewrites whole files, which *patch, never regenerate* otherwise forbids. It is permitted because the output can be **proven** content-equivalent: diff against the archived copy with pipe padding and blank lines normalised away, and report every surviving difference. Never run a formatter without that diff. The config is `.markdownlint.jsonc`, tracked; **record the tool version in the manifest at every bump**, because two engines produce two corpora.

**An invalid config value disables a rule silently.** `MD060: { "style": "leading_and_trailing" }` is not a valid setting — that parameter belongs to MD055 — and it reported a clean run while checking nothing. Caught by counting separators on disk, not by reading the exit code. *Same failure as a regeneration command that matches zero files.*

**Never edit a derived artefact by hand** — the three indexes or `FOLDER-LEDGER.json`. Edit the marker in the source document and regenerate. If a document's rule IDs have no authored table in that document, the index is not derived for it — fix the source, not the index.

**Never edit anything under `Archive\`.** The archive is write-once. A repatched archive is a falsified history, which is the 0.12.0 failure with a longer reach.

---

## Coherence obligations

- **Close it where it was raised.** Resolving a question in document B does not close it in document A.
- **A cross-reference to an open item must resolve.** P·10.3 cited an `[OPEN]` in **M** that was never raised there; a reader checking M's table would have found nothing. **Grep the ID in the document you are citing.**
- **Propagate locks.** A rule locked in one document that constrains another must be written into the constrained document.
- **New locked term → Lexicon, same pass.** The check is **L-M1**, authored in L·12 — this line is the working practice, not the rule.
- **Check for collisions before naming** — by grep, against the whole set, before proposing. The check is **L-M2**, authored in L·12.
- **A census that is not acted on is not a check.** At 0.13.0 `focus` was censused, 26 uses were seen, and the word was used anyway.
- Mark every open question `[OPEN]`, every provisional number `[SIM]`, every unowned concern `[GAP]`.

### Reserved words

These are locked and must never be reused for another concept. Grep before naming anything.

**A qualified field may keep a reserved word only when it carries the reserved concept. Qualification cannot legalise a different meaning.** `surface_capacity` and `floor_shape` are legal — both mean the locked thing. `town_anchor` was not: it identified a town, not a Skill Anchor, and the prefix merely disguised the collision. Adopted 0.33.0 after four such fields were found **inside fenced code blocks**, where no reserved-word sweep had ever looked.

**The sweep must read fenced blocks.** Three of the four — `render.region`, `Surface` as a tile class, `shape: "floor"` — sat in schema examples in documents whose prose forbade exactly that use.

| Word | Locked sense |
| --- | --- |
| **floor** | The Triade barycentric floor. **Never dungeon geometry** — use `[Deck]` or `[Storey]` |
| **surface** | Environmental state channels and named reactions (W·11). Never traversable geometry |
| **region** | Triade regions (T). **Never a map area** — the geographic record is **Territory**, renamed at 0.38.0 (`◈W18`) |
| **Territory** | The formal geographic world record and its instances. **Capitalised in design prose** — including plurals, *per-Territory*, and compounds such as **Territory package** and **launch Territories**. Machine identifiers stay lowercase snake_case: `territory_id`, `ref_territories`. Lowercase *territory* only for ordinary non-model geography (L · 9D) |
| **zone** | The 2–4 combat zones (K·4). Never a tile grouping |
| **node** | `[Body Location]` (H) and mission-graph nodes. Ambiguous — avoid for new concepts |
| **lever** | The tempo lever (K-C8). The physical object is a `[Switch]` |
| **anchor** | Skill Anchors (T·A3.7) |
| **vault** | Climb/vault traversal (W·9 `vaultable`) |
| **Flux** | Currency only, never a field quantity (◇H11) |
| **capability** | The four-tier enemy capability ladder (E·F.0). The action source is `faculty` |
| **signature** | `[Signature Action]` (E·F.0). Trace use is **Trace Signature**; item use is **martial profile**. In P, a *signature* is a Trace Signature |
| **focus** | Mind-side — `+focus`, `Focus-broken`, the Will/focus tax. Aim quality is `aim_weight`. **A skill's target is `redistribution_target`** — `focus: Pierce` was retired 0.33.0. |
| **physique** | The enemy tag category (E·F.1). Never a characteristic bundle — use *profile* |
| **hook** | A `[Combo-Action]` delivery hook — `main_hand`, `off_hand`, `voice` (M·2A.10) |
| **ward** | The Occult mitigation state track (M·2A.4) |
| **extraction** | Zone extraction, the W§12 pipeline stage. Bands leave through a `[Band-End Portal]` |
| **storey** | The generated bundle *and* the pacing unit — 18 per career (M·9.1). Never dungeon geometry |
| **category** | The item classification (M·2.1, P·1.3) — seven values, `shield` among them. Enemy tag classes are **Enemy Tags**; a remedy's kind is `remedy_type`; a tile's is a **tile class** |
| **handedness** | The weapon pip budget — `1h` = 3 base pips, `2h` = 4 (M·2A.9, **M-C1**). Never a slot, an occupancy count or a delivery hook; those three stay separate |
| **archive** | The write-once version snapshot under `X:\Documentation-Archive\Archive`. Never in-game storage, stash or record-keeping |
| **ledger** | `FOLDER-LEDGER.json`, the folder integrity record. Never a Flux account, quest log or in-fiction book |
| **◇ ◈ ◉ ⇥ ⌬** | Identifier glyphs — live item, closed item, goal, phase, skill level (L·§0). Never decoration, never a bullet, never a UI symbol |
| **goal** | A standing test in a `◉` table, owned by its home document. Never an open item, never design intent stated in prose |
| **phase** | A sequencing step, `X⇥n` (M·6). Never a combat phase — that is a `[Beat]` |
| **C1/C2/C3** | Unavailable — every document carries `X-C1`/`C2`/`C3` rule IDs. Structural complexity is `N` (W·5.8) |

---

## Numbers

Numbers are the output of this process, not an input. Any value not listed as locked in the SIM Numbers Register is provisional.

Every `[SIM]` value needs a **basis** (derived / precedent / arbitrary), a **validating gate**, and a **stated failure path**.

**Prefer deriving to sweeping.** A number derived from locked geometry is not a `[SIM]` value at all. `AIM_CEILING` entered as `derived` because it mirrors A3.7's potency floor — an existing symmetry, not a new guess.

**"Must be fixed" is not a failure path.** If a register entry's failure path restates an existing rule, the entry is the error.

**Multiply the locked numbers before assuming one is missing.** The 18-storey career was the product of two values locked two versions earlier. Unmultiplied, the pacing unit looked undecided.

**Check a per-unit rate across every band before accepting a table.** The 0.14.0 terminal-band anomaly appeared three times and was visible each time by dividing by the segment count.

**A worked example is not a norm.** M·2A.9's one-handed sword carried four pips from the first draft. P·10.3 copied it into a locked fixture *and* flagged it as unverified in the same table. **One illustrative number became the rule for a whole weapon class because nobody asked what it was derived from.**

**A number that falls out of two locked numbers is `derived`, not `arbitrary`.** Say which, and why.

---

## House voice

- **Declarative.** State the decision, not the deliberation.
- **Reasons inline.** A rule without a reason gets relitigated.
- **Tables over prose for anything enumerable.**
- **Name the trade-off.** Where a decision closes an option, say what was given up.
- **Mark uncertainty explicitly** rather than hedging the prose. A count that cannot be verified is stated as a floor, not a total.
- **State negatives that would otherwise be assumed.** "There is no mana, and its absence is load-bearing" is a sentence worth its space.

---

## Version bumps

| Bump | When |
| --- | --- |
| **Minor** `0.x.0` | A new document, a new document class, or a new identifier namespace. Anything that changes the shape of the set. |
| **Patch** `0.x.y` | Additive work inside existing structure that **changes no rule, no number and no section**. Glyphing an existing namespace, extending an index, correcting notation. |

Adopted at 0.18.1. `⦻` was a patch because non-goals had existed since 0.9.0 — the namespace was not new, only its notation. If a change adds a rule or moves a section, it is minor regardless of how small it feels.

**Both take the full procedure below.** A patch archives, verifies and sweeps exactly as a minor does; the only difference is which digit moves.

### Step 0 — Archive the outgoing version

Before any content edit and before any rename, snapshot the current set.

1. Confirm the session-start ledger diff was **empty**. A bump does not begin over an unexplained change.
2. Create `X:\Documentation-Archive\Archive\v<current>\` — named for the version being **superseded**, not the one being written. A 0.17.0 → 0.18.0 bump creates `v0.17.0\`.
3. **If that folder already exists, stop.** A prior bump aborted or already ran. Reconcile with the user; never merge into an existing archive folder.
4. Copy the **entire documentation corpus** from `X:\Documentation` into it — design documents, technical documents, all three derived indexes, `VERSION-MANIFEST.md`, `A-ROADMAP.md`, `Z-Design_Stream_Project_Instructions_TRIADE-0_43_0.md`, `FOLDER-LEDGER.json`, `tools\`, and `Research\`. Exclude operational repository metadata under `.git\` and transient `__pycache__\` directories: neither is documentation content. Other unversioned files are included; a snapshot with holes is not a baseline.
5. **Verify the archive in two parts, before touching the source.** Ledger-tracked files against the ledger's hashes, file by file. **Ledger-excluded documentation — the `Research\` tree and any other included non-operational file — by direct source-to-archive hash comparison**, because the ledger cannot vouch for what it does not record. `.git\` and `__pycache__\` remain excluded from both the corpus and the comparison. Skipping the second part leaves part of a *complete snapshot* unverified. An unverified archive is not an archive, and every later step assumes it exists.

The archive is **write-once**. Nothing inside `Archive\v*` is edited, renamed or repatched. Each version folder carries its own ledger, so any archived version can be integrity-checked years later.

### Step 1 — Copy or move, decided per document

The archive is always a **full copy**; moving would make snapshot completeness depend on a judgement call, so an aborted bump could leave a partial archive undetectably. The copy/move decision therefore asks one thing about the *source* file: does it survive into the new version?

| Case | Action in `X:\Documentation` | When |
| --- | --- | --- |
| **Copy** — default | Source stays and is patched in place | The new version is written *into* the current document. The normal case, and the one *patch, never regenerate* requires. |
| **Move** | Source deleted, after the archive verifies | The rewrite is substantial enough that anchored patching of the old text is wasted effort. |

**A move is a per-document decision, recorded in that document's changelog with its reason.** Never the default, never applied set-wide. What a move gives up is the anchor text every editing rule here depends on — so a rewritten document is still diffed against its archived copy for headings, line count and term inventory, and the losses still reported. The obligation does not lapse because the file moved; it points at the archive instead.

### Step 2 — The bump

1. Rename every file — **including both instruction documents**, whose filenames carry the design-set version
2. Update every internal cross-reference
3. Add a changelog row to each changed document — including the copy/move mark for any moved document
4. Update `VERSION-MANIFEST.md`, including `last_archive` in the handoff block
5. Regenerate all three indexes — **including their counts, by counting**
6. Update `A-ROADMAP.md` exit conditions
7. Grep the old version string and confirm every survivor is history
7a. **Run `tools/version-check.sh`.** Step 7 is a human reading greps; this is the test. Eight claims sat at 0.21.0 for four releases because each bump swept a *literal* string that no longer matched — a sweep that misses is silent
8. Regenerate `FOLDER-LEDGER.json` — last, after every rename and edit
9. **Produce replacement project instructions** (below)
10. **Report Drive-backup status.** If a backup is requested, perform it only after the final local checks and as the last action of the session. A bump renames every file, so the backup diverges completely: each rename is a create plus a trash, and **every create needs the user**. Expect the largest manual step of any session here

**Bump once, at the end.** Two stages shipping in one version rename once, after all content edits land. The 0.12.0 falsified-history failure came from rewriting version strings twice.

---

## Keeping these instructions current

Whenever the documentation **structure** changes, produce a **complete replacement** `Z-Design_Stream_Project_Instructions_TRIADE-0_43_0.md`, bump its instructions version, and tell the user to paste it manually.

**Claude cannot update project instructions directly.** Producing the file and flagging it is the whole of the obligation; do not describe it as done.

**Keep this document short enough to be read.** Adding a line means considering which line to cut.

---

## How to engage

Disagree when you disagree, and say why. State what you did not verify. When a source document contradicts a decision, say so rather than reconciling it silently. Flag your own errors when you find them — including in work produced earlier in the same session.

**Re-evaluate on request without defending the prior position.** At 0.13.0 four of five proposed `signature` renames were withdrawn on inspection.

**A patch record is a proposal, not a finding.** At 0.17.0 a patch document instructed *"extend M-C1 in its source row"*; there was no source row. Verify a patch's premises against the corpus before applying it — including a patch you wrote yourself.

Uncertainty stated is more useful here than confidence performed.

---

## Why these rules exist

Each was earned by a failure in this project.

| Rule | Failure it prevents |
| --- | --- |
| L is an index, not the source of truth | `[Location Grounding]` was locked in W§21, never propagated to L; a Lexicon check returned a false negative and a real term was briefly struck as drift |
| A derived index can be wrong about its source | `S-H01` blocked a branch for two versions as a defect that rule H-M2 had already handled |
| Project memory has no authority | Memory carried v0.16.0 / instructions v1.5 while the set stood at v0.17.0 / v1.6 |
| Verify the list, not just the count | `◇P7` named seventeen orphan rules; three more were absent and the list had never been recomputed |
| Citation is not authorship | `M-C1` sat in the index and in K's enforced-elsewhere table for five versions with no row in M |
| Run the command before publishing it | The index's regeneration command recovered 82 of 142 rules and looked like it worked |
| Absent label ≠ absent design | Magic was recorded as undesigned; H had already built its routing, gating and economy |
| Patch, never regenerate | A regenerated 44 KB Lexicon silently dropped ten rows, including four agent specs with hard gates |
| Never blanket-replace a version string | The first 0.12.0 attempt rewrote changelog rows, falsifying two versions of history in one command |
| Sweep what the pattern cannot reach | V's footer read `0.10.0` for seven releases; K's read `0.12.0` for four |
| A cross-reference must resolve | P·10.3 cited an `[OPEN]` in M that had never been raised |
| A worked example is not a norm | A four-pip one-handed sword became the class norm because one illustration was never questioned |
| Close it where it was raised | Eight questions in T·Part K sat open for two versions after K17 had answered them |
| Propagate locks | ◈W2f was Steward-locked with an explicit propagation note and sat unpropagated while H depended on it |
| Mark everything | ◈H1 and ◈W6 were the same question asked independently in two documents. Found by accident |
| Grep before you conclude | A 0.12.0-basis report asserted seven changes to documents that had not changed |
| Check reserved words | `[Walk Surface]` shadowed *surface*; `[Dungeon Floor]` shadowed *floor*; `[Signs]` shadowed *signature* |
| Act on the census | `focus` was censused at 0.13.0, 26 uses were seen, and the word was used anyway |
| Every source resolves to a record | `capability` was a `sources` enum value with no record for three versions. Rule **T-C12** now forbids it |
| Multiply the locked numbers | The 18-storey career was the product of two values locked two versions earlier |
| Write the exemption | Band C contradicted W·5.4's mutual exclusivity. An unstated contradiction inside a locked section is what ◈T6 was |
| Reserved words get re-proposed | `extraction` was proposed three times across two versions by both authors |
| Verify a clean Lexicon result | `category` was locked for seven versions with no L entry, so every L-M2 grep returned a false negative |
| Recount, never carry forward | The Validation Rules Index printed 111, changelogged 133 and contained 139 |
| Declare the coverage gap | P·10.7 lists five things the fixture set cannot measure. Undeclared gaps read as complete coverage |
| A patch record is a proposal | A 0.17.0 patch instructed an edit to a source row that did not exist |
| A sweep is not harmless in someone else's document | Repointing two references in the technical instructions put them **220 characters over an 8,000 limit that had five spare**. The "mechanical sweep" exception was withdrawn in the release that invented it |
| Historical facts are not editable | Blanket count sweeps at 0.19.0–0.21.0 overwrote 5 changelog rows and 8 release summaries, so documents asserted figures never true when written. The rule had existed in prose since 0.12.0 with nothing enforcing it |
| Compare against the earliest archive | A later archive can already hold the corruption. The v0.20.0 copy of the 0.19.0 row was itself wrong |
| Scope a check to signal | The first `history-check` compared raw text and returned 71 hits, nearly all deliberate notation migration |
| A check that cannot fail has not run | Six instances in one session: a stop piped into `tail`, a failure hidden behind `&&`, an invalid lint value, a glob matching zero files, an unverified API write, and a census looser than its own rule |
| State the denominator | *"no failures"* is what an empty input set reports. *"142 of 142"* is a measurement |
| An authored design decision is not a rule until it is authored | The technical stream resolved the shield integrity path to proceed and marked it non-authoritative. **P-C10** held it there until M·2A.6 stated it at 0.23.0 |
| Read the source, not the report | The M10 handoff called `medium` an unmapped weight class. **M·2A.7 defines three classes and `medium` is not among them** — an undefined value in use, not a missing mapping |
| The identity already written is evidence | Medium armour was first derived as damping `[Dot Dynamics]` — *dynamic*, in a section that opens by calling armour **positional**, and situational where M·2A.11 had said **balanced** since 0.9.0. The contradiction with a word already in the document was the signal, and it was read as a trade-off instead |
| Do not report an edit you have not made | A failures row was described as added and did not exist. *Read back what you wrote* applies to the report as much as to the file |
| A literal sweep is silent when it misses | Footers, status and aligned-to lines sat at 0.21.0 for **four** releases while every bump "swept" them, because each sweep matched the previous literal. Now `tools/version-check.sh` |
| A balanced fence count is not a correct one | An orphan `}` and ``` left by a replacement made 224 lines of W render as code. `markdownlint` passed — the count was even. Only semantic inspection found it, and `tools/fence-check.sh` now blocks on an unclosed fence |
| A completion report is not completion | Set 1 was reported adopted "in full" with four checks green. Review found a hidden fence, a lifecycle claimed in a changelog and never authored, eight omitted boundaries, and twelve reserved-word violations **in the adoption text itself** |
| A retirement leaves consumers | `base_AP_pool` survived two releases past the pool; W·907 was rewritten to `world_tick` **with the old clause left in the same sentence**; K·132 kept a locked constraint on an abolished resource. Seven instances in six releases, every one found by an audit rather than a check |
| A speculative archive is a fiction | `v0.33.0` was snapshotted at the start of work that was then abandoned, leaving a permanent archive of a version that never shipped |
| A regex that can match the file, will | `(?ms)` turned a table-bounded patch into "everything after this heading". 21 KB of `VERSION-MANIFEST.md` — the Changelog and eleven release summaries — was overwritten by eighteen archive rows. **The identical bug had failed loudly two commands earlier**, which is the only reason it was recognised |
| An insertion that drops the tail is silent | `s[:m.end()] + addition` without `+ s[m.end():]` cut 127 Lexicon entries and left a file that linted clean. Bounding the match does nothing if the write discards the remainder — assert the resulting length |
| The archive is the only durable copy | The in-session backup was taken after the damaging write. Write-once storage outside the working folder is not ceremony; it was the recovery path |
| A Drive copy is not the corpus | A stream report was accurate about Drive and false about `X:\Documentation`; the ledger cannot see Drive |
| Price the request against the receiving document | A counter-patch that ignores a stated size limit cannot be adopted, and the requesting process is the one holding the arithmetic |
| One token, one meaning | `H3` was a goal *and* a live open item in one document; `G4` was a W goal *and* a G item; `P1` was an M phase *and* a P item, twice in one sentence |
| Disambiguate the container first | Prefixing before the headings were deletterd would have meant guessing on 1,662 tokens |
| A register is not the home document | `◇E11` and `◇W17` were live `[OPEN]` in E and W and absent from the Open Items Index for four versions |
| A closed item does not leave the index by itself | `◈M10` closed at 0.15.0 and sat in the live Gap row for three versions |
| Regenerate the list, not the count — again | `◇P7` was seventeen, then nineteen, then thirty. Each figure was recounted; the list was never regenerated |
| A repointed filename hides in the header | 145 of 159 stale filenames were in the documents' own *source documents consumed* blocks, not the manifest |
| Finish the namespace sweep in one pass | Non-goals were left unglyphed at 0.18.0 and needed a second release. Five of six is not a convention |
| A dash is not a marker | `—` in a table cell had been reading as *unknown*. An undeclared gap reads as complete coverage |
| Measure, do not recount | ◇P7 was 17, then 19, then 30, then — measured — 5. Each figure was derived from the last |
| A census tests position, not shape | The pattern behind every wrong ◇P7 figure could only see bolded table rows |
| Sweep every depth of a convention | 0.18.0 deletterd `## Part Xn` and left 80 `### Xn.n` headings |
| "No source row" is not one problem | Of thirty, twenty-five needed tagging, five were mis-homed or mis-searched, **none** needed writing |
| An accepted decision needs a legal home | `L-M1`/`L-M2` were accepted in an implementation stream and left for a process that did not exist. Eight versions in a file with no authority |
| The index must not issue identifiers | Two rules had IDs and no author. The source column said so — it named a document and no section — and that was the only signal |
| A clean lint run can mean nothing ran | An invalid `MD060` style value reported zero findings while checking nothing |
| Search harder before declaring a gap | `M-C3`, `M-C5` and `M-H4` were called *never written*. All three were stated in M and simply carried no ID |

**Not yet earned.** The archive rules (1.7) and the ledger rules (1.8) were policy, not lessons — no incident stood behind them. Stated as absent from the table on purpose: a rule with no failure behind it is weaker evidence and should be easier to revise than one that cost a version to learn.

**Earned on first run (1.9, resolved 1.10).** The rows below are not policy. The ledger's first pass found the manifest declaring fifteen filenames that resolved to nothing and an Archive table listing four versions that do not exist while omitting five that do — both standing since 0.13.0, four versions in which no check existed that could notice.

| Rule | Failure it prevents |
| --- | --- |
| Check declared paths resolve | `VERSION-MANIFEST.md` named fifteen files under a convention the disk abandoned at 0.13.0; every path it published was unresolvable for four versions |
| A hand-maintained table of disk state goes stale silently | The manifest's Archive table listed 0.8.0–0.11.0; disk held 0.11.0–0.16.0. Regenerate it from disk at every bump |
