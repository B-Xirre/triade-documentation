# Failure reconciliation — 0.32.0 → 0.36.0

**Scope:** six releases (0.33.0, 0.33.1, 0.34.0, 0.35.0, 0.35.1, 0.36.0), spanning Set 1 adoption, CR-11 adoption and four technical re-audit rounds.
**Method:** reconstructed from archives `v0.32.0`–`v0.35.0`, manifest release summaries, changelog rows and the technical stream's four audit reports. **Not from memory.**
**Author:** the design stream, about itself.

---

## 1. The headline number

**Twenty-one distinct failures.** Of these:

| Found by | Count |
| ---: | --- |
| The technical stream's audits | **11** |
| Me, unprompted | 6 |
| An automated check | **4** |

**The checks found the fewest.** Every one of the four they caught was mechanical — a hash, an exit code, a count. **Not one semantic failure was ever caught by a check**, and every failure that reached a release did so through a run in which all checks passed.

---

## 2. Categories

### A — Partial propagation *(7 instances, the dominant class)*

Editing the thing named and leaving its consumers, its context, or the sentence around it.

| # | Failure | Release | Found by |
| ---: | --- | --- | --- |
| A1 | `deck_role` note said "coexistence temporary" after the field was already gone | 0.33.0 | me |
| A2 | Progression placement amended in L, its authoritative W source left object-only | 0.33.0 | stream |
| A3 | W's progression headings prefixed "amended", the object-only sentences beneath left standing | 0.35.1 | stream |
| A4 | Seven `-H` rules inserted into R anchored on the preceding row, never checking its section | 0.30.0–0.35.0 | stream |
| A5 | AP pool retired in K·3.1/3.4; `base_AP_pool`, elapsed-AP integration and Pass left consuming it | 0.34.0 | stream |
| A6 | W·907 rewritten to `world_tick` pulses **with the old clause left in the same sentence** | 0.36.0 | stream |
| A7 | K·132's locked "one corner may modify the AP *pool*" survived two releases past the pool | 0.36.0 | stream |

**Root cause.** Verification greps searched for the text I had **added**. A patch that asserts its own new text proves nothing about what it left behind.

### B — Unbounded or malformed writes *(4 instances)*

| # | Failure | Release | Found by |
| ---: | --- | --- | --- |
| B1 | `(?ms)` DOTALL matched to end-of-file; **21 KB of the manifest destroyed** — changelog and eleven release summaries | 0.33.0 | check (exception) |
| B2 | `s[:m.end()] + addition` without the tail; **Lexicon truncated 609 → 452 lines, 127 entries lost** | 0.33.0 | archive diff |
| B3 | Blanket `\b0.35.1\b` sweep rewrote 0.35.1's **own changelog row** | 0.36.0 | me |
| B4 | Table text appended **past the closing pipe** — three separate occurrences | 0.30.0, 0.33.1, 0.36.0 | lint |

**Root cause.** Bounding the *match* without asserting the *result*. B1 and B2 were recoverable only because the archive is write-once and outside the working folder.

### C — Claims stated beyond evidence *(5 instances)*

| # | Failure | Release | Found by |
| ---: | --- | --- | --- |
| C1 | "Set 1 adopted **in full**" — TD-CR-05's lifecycle and TD-CR-08's boundaries were absent | 0.33.0 | stream |
| C2 | "Set 2 **complete**" — P, G, T, E untouched; W's turn ticks unconverted | 0.35.0 | stream |
| C3 | Severity split published five releases running, measured on **one axis of two** | 0.30.0–0.35.0 | stream |
| C4 | `signed_off: Approved` written while the baseline was under prevalidation | 0.35.1 | stream |
| C5 | Manifest asserted Z aligned v0.30.0; it was v0.34.0 — never measured | 0.36.0 | stream |

**Root cause.** Reporting completion for **the sections I wrote** rather than for **the work that was asked**.

### D — Reserved-word and namespace violations *(3 instances)*

| # | Failure | Release | Found by |
| ---: | --- | --- | --- |
| D1 | `tactical region`, `fill region`, `protected region` — **12 violations authored while enforcing the same lock on others** | 0.33.0 | stream |
| D2 | `◇P1`–`◇P5` on W's design pillars — a 0.18.0 glyph migration colliding with P's real items for 18 releases | 0.34.0 | me, prompted |
| D3 | Register misclassified C's `ref_regions` and T·C.5 as geographic — would have renamed **Triade** regions to Territory | 0.33.1 | stream |

### E — Process and sequencing *(2 instances)*

| # | Failure | Release | Found by |
| ---: | --- | --- | --- |
| E1 | Archived `v0.33.0` **speculatively**, at the start of intended work rather than before superseding; the work was abandoned and the snapshot became a fiction | 0.33.0 | me |
| E2 | Released 0.35.1 as a **patch** while it added sections and a rule | 0.35.1 | stream |

---

## 3. What the pattern actually is

**One error, five costumes.** In A, B and D alike I verified *the operation I performed* and not *the state I left*. The greps confirmed additions; the assertions bounded matches; the register confirmed a classifier ran. None asked the complementary question — **what did this touch that I did not look at?**

**And the checks cannot ask it.** A check reads syntax: an exit code, a hash, a fence count, a column count. Every failure that survived to a release was **semantically** wrong and **syntactically** clean. That is not a gap to be closed by adding checks; it is the boundary of what checking is.

---

## 4. Countermeasures

### Already built during the window

| Measure | Catches |
| --- | --- |
| **`fence-check.sh`** | B-class structural damage — an unclosed fence, after markdownlint passed 224 lines rendering as code |
| **`suite-check.sh`** | C3 and A4 — two severity axes, ID uniqueness, printed totals, by-document breakdown. It caught my own stale summaries **three times** while the release adding it was written |
| **`version-check.sh`** WARN_ONLY | C5 — stream-owned claims reported, never repaired here |
| **Result-length assertions** | B2 — `assert len(new) == len(old) + len(addition)` |
| **Instructions 1.19–1.21** | Five earned failure rows |

### Proposed, and honestly rated

| # | Countermeasure | Class | Confidence |
| ---: | --- | --- | --- |
| **1** | **Sweep-for-the-removed, not the added.** After retiring any term, rule or field, grep the *retired* token across the whole set and require every survivor be a negation, a changelog row or a historical statement — enumerated, not eyeballed. Automatable as `retirement-check.sh` taking a token and an allowlist | A | **High** — mechanical, and A5/A6/A7 would all have fired |
| **2** | **Diff-region review.** Before landing, re-read the *paragraph* containing every changed line, not the line. A1, A3, A6 and A7 were all visible within two lines of an edit I made | A | Medium — discipline, not enforcement |
| **3** | **Completion manifests.** An intake declares its deliverables as a checklist; the release cannot claim completion until every item is ticked with a section reference. C1 and C2 were both "I did the parts I did" | C | **High** — turns a claim into a checkable list |
| **4** | **No self-reported sign-off.** `signed_off` is only ever written on an explicit external statement, never inferred from an instruction to land | C | **High** — already applied at 0.36.0 |
| **5** | **Reserved-word check across fences and prose**, run against text *authored in the current diff*. D1 happened while I was enforcing the same lock on someone else | D | **High** — mechanical |
| **6** | **Archive only immediately before superseding.** Never speculatively at the start of intended work | E | **High** — E1 cost a permanent extra archive folder |
| **7** | **Bump-class assertion.** If a diff adds a rule ID or a heading, the version must be minor. Computable from the diff | E | **High** — E2 was detectable mechanically |
| **8** | **Adversarial read before release.** The strongest single measure: **an independent reader auditing against the intake rather than against the diff.** The technical stream found 11 of 21 — more than my own checks and my own review combined | all | **Highest, and it is not mine to build** |

---

## 5. The uncomfortable conclusion

**Checks did not make this corpus correct. Audits did.**

Six automated checks now run green on every release, and they are worth keeping — they make a whole class of damage impossible and they caught two catastrophic writes. But they passed **every single release that was later rejected**. Four re-audit rounds were needed on CR-11, and each round found real contradictions in a corpus that was, by every mechanical measure, clean.

The countermeasures above will reduce class A and E materially, because both are mechanical at heart. **Class C is a habit**, and the only reliable instrument found for it in this window was **someone else reading the work against the original request.**

*Written by the design stream about its own failures. The counts are reconstructed from the archives and the audit reports; where a failure was found by the technical stream, it is credited to them.*
