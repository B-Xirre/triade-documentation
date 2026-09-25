# Counter-patch — technical-stream instructions

**Aligned to:** Triade 0.38.0
**Authority:** request only. This process does not edit `Z-Technical_Stream_Project_Instructions_TRIADE-[V_e_r].md`.

## Why this exists

The 0.38.0 bump renamed every versioned file, including the technical instructions, because step 2.1 requires it — the filename carries the design-set version. During that sweep this process also rewrote the file's **aligned-to line**, which is a content edit to a document it does not author. **The file was restored byte-identical from `Archive/v0.37.0/`** and the change is raised here instead.

This is the 0.21.0 rule, held under the exact condition that produced the exception which was then withdrawn: a filename this process itself renamed.

## Items

| # | Section | Change | Reason | Character delta |
| --- | --- | --- | --- | ---: |
| CP-4.1 | Header, line 4 | `**Aligned to Triade:** v0.37.0` → `v0.38.0` | Current-state claim; `version-check.sh` reports it as `WARN` every session until adopted, by design, because stream drift is never repaired centrally | **0** |

## Pricing

Current size **7,887 of 8,000 characters — 113 headroom.** This request costs **0 characters** and needs no cuts. No further items are raised; internal filename references were checked and stand at **zero**.

## Retirement

Retires to `Research\` once a replacement technical-instructions file lands carrying CP-4.1.

- [x] CP-4.1 adopted — `Z-Technical_Stream_Project_Instructions_TRIADE-0_38_0.md` · header line 4 · verified `5aa9bb41…c157`, 7,887 characters, 0 delta
