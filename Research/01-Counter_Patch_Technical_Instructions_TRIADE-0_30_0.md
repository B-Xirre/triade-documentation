# Counter-patch — Technical Stream Project Instructions

**Raised by:** design stream · **Aligned to:** Triade v0.30.0 · **Date:** 12 August 2026
**Target:** `Z-Technical_Stream_Project_Instructions_TRIADE-[V_e_r].md`
**Authority:** request only. **This process does not edit that document, for any change, including this one.**

## Why a counter-patch and not an edit

The 0.21.0 exception for "mechanical" sweeps was withdrawn in the release that invented it: repointing two references pushed the file **220 characters over an 8,000 limit that had five spare**. A change that is harmless in a document this process authors is not harmless in one it does not.

## Items

| # | Section | Requested change | Reason | Cost |
| --- | --- | --- | --- | ---: |
| **CP-1** | Header, line 4 | the `Aligned to Triade` value: `v0.29.0` → `v0.30.0` | The design set is at 0.30.0. Reported by `version-check.sh` as a **WARN**, which by the 0.30.0 rule never blocks and is never repaired here | **0** |

## Budget

| | Characters |
| --- | ---: |
| Current file | 7,889 |
| Limit | 8,000 |
| Headroom | 111 |
| This counter-patch | **0** — `v0.29.0` and `v0.30.0` are the same length |
| Resulting total | **7,889** |

**No cuts required.** Stated explicitly because pricing the request is the requesting process's job, not the adopting one's.

## Note on how this was found

Until 0.30.0 no `version-check.sh` pattern matched the `Aligned to Triade` wording — the `EXEMPT` entry named a label no pattern produced, so the claim was never read. The line sat at **v0.25.0 for four bumps**.

**Note on quoting.** This record deliberately does *not* restate the header verbatim: `version-check.sh` reads any occurrence of that literal as a current-state claim and cannot tell a quotation from an assertion. Quoting it here would make every counter-patch record fail the check it exists to answer. The stream corrected it independently in the 0.29.0 replacement; the check now reports it rather than relying on that.

## Retirement — closed 12 August 2026

**CP-1 fulfilled.** A replacement file landed in `X:\Documentation` carrying the change: one line, `v0.29.0` → `v0.30.0`, at **7,889 characters** with 111 of headroom, exactly as priced. Instructions version stayed 1.2 — the stream treated it as an alignment repoint, not a content revision, which is the correct reading.

**Verified against the tracked store, not against a report.** The stream reported CP-1 fulfilled one turn before the file arrived; the tracked copy still read `v0.29.0` at that moment and `version-check.sh` was still warning. The claim was true of the stream's own copy and false of the corpus — the 0.21.0 failure exactly, caught this time because the WARN kept saying so. Retirement waited for the bytes.

Retired to `Research\`.
