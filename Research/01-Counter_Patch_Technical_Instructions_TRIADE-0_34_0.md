# Counter-patch — Technical Stream Project Instructions

**Raised by:** design stream · **Aligned to:** Triade v0.33.1 · **Date:** 12 August 2026
**Target:** `Z-Technical_Stream_Project_Instructions_TRIADE-[V_e_r].md`
**Authority:** request only. This process does not edit that document, for any change, including this one.

## Items

| # | Section | Requested change | Reason | Cost |
| --- | --- | --- | --- | ---: |
| **CP-2** | Header, line 4 | the `Aligned to Triade` value: `v0.30.0` → **`v0.33.1`** | The design set is at 0.33.1. *Superseded target, updated in place at 0.32.0 — the request was raised against 0.31.0 and the stream had not yet delivered when the next release landed, so CP-2 now names the current version rather than a version already behind.* Reported by `version-check.sh` as a **WARN**, which never blocks and is never repaired here | **0** |

## Budget

| | Characters |
| --- | ---: |
| Current file | 7,857 |
| Limit | 8,000 |
| Headroom | 143 |
| This counter-patch | **0** — the two version strings are the same length |
| Resulting total | **7,857** |

**No cuts required.**

## Note

This is now the fourth consecutive release to raise a single zero-cost alignment item. If the stream would rather repoint that line as part of its own bump routine, the counter-patch record disappears with it — the request exists because the line is theirs to change, not because the change is difficult.

## Retirement — closed 14 August 2026

**CP-2 fulfilled.** A replacement landed in the tracked store carrying the alignment repoint to **v0.34.0**, at **7,857 characters** with **143** of headroom, and no other content changed — verified by diffing every line except line 4 against the archived copy: **byte-identical**.

**Verified against the tracked store, not the report.** The stream reported fulfilment and the claim was checked against the corpus before retirement, as it was for CP-1 — where the bytes arrived a turn after the report did.

**One measurement note.** The stream reported 7,857; `wc -c` says 7,889. Both are correct: **7,857 characters, 7,889 bytes**, the difference being multibyte em dashes and middots. The limit is stated in *characters*, so headroom is **143**. Recorded because a byte-based check against a character-based limit reads more conservative than reality — harmless here, misleading at the margin.

**Fourth consecutive release carrying a zero-cost alignment item.** If the stream repoints that line inside its own bump routine, this record disappears entirely.

Retired to Research.
