# Equipment data model — Reconciliation record

**Marks:** **[W]** Claude · **[U]** Bart · **[BOTH]** independent convergence · **[NEW]** emerged in discussion.

> **Retirement status — closed 9 Aug 2026, instructions 1.10. RETIRED to `Research\`.**
>
> All 25 items struck or assigned. Retained here as the provenance record for decisions now owned elsewhere; **it carries no authority and may not be cited as a source.**
>
> | Item | Disposition | Destination |
> |---|---|---|
> | 1–6 | Assigned | P·P4.1–P4.3 (engine, canonical JSON, Parquet, single-writer), H and M·2A.3 (damage taxonomy) |
> | 7–9, 16 | Assigned | P·P1 lifecycle objects, P·P2 authoring, M·2A |
> | 10 | Assigned | P·P3, technical specification `_q` columns, W-C10 digest firewall |
> | 11–15 | Assigned | P·P2.3, P·P5 trace and telemetry, P·P7 validation |
> | 17–21 | Assigned | P·P4 (v1.4 LTS pin), P·P7 (Pydantic / Pandera), P·P6 (read-only MCP path), P·P4.3 (git-LFS) |
> | **22** | **Assigned 9 Aug 2026** | **P·P4.2 and P·P8 `[OPEN] P9`** — Dolt as the cell-level versioning escalation, trigger unmeasured. The last item to land; it held this record in `Documentation\` on its own |
> | 23–25 | Assigned | M and H (`[Mudra]` carrier), E and P·P10 (canine chassis), **P** itself (item 25 — this record produced the tenth document) |
> | 63, 64 | Struck | `extraction` reserved to W§12 for the third time; the `Adept/Wand`-only fixture set superseded in discussion |
>
> Verified by grep against the 0.17.0 set, not by memory.

---

## Convergence — the storage layer

Written without contact, from opposite directions.

| # | Decision | Mark |
|---|---|---|
| 1 | **DuckDB** as the embedded analytical engine — MIT, in-process, Parquet/Arrow native, nested types | **[BOTH]** |
| 2 | **Canonical JSON is the source of truth; DuckDB is a rebuildable artefact** | **[BOTH]** |
| 3 | Traces to **partitioned Parquet**, queried through DuckDB views | **[BOTH]** |
| 4 | **Single-writer boundary** accepted, git as the collaboration layer | **[BOTH]** |
| 5 | SQLite viable for runtime metadata, wrong for trace analytics | **[BOTH]** |
| 6 | **Damage taxonomy** — 14 types in five groups, Structural through integrity, Occult through typed defence + ward | **[BOTH]**, and verified against M·2A.3 |

Convergence on point 2 matters most: it independently reproduces M·Part 4 item 1, *"content is data, never code. JSON/YAML under version control."* Neither report set out to satisfy that rule; both landed on it.

## Bart's report — the domain model

Claude's sweep was scoped to storage and had none of this.

| # | Contribution | Mark |
|---|---|---|
| 7 | **Five-object lifecycle** — definition → roll → instance → loadout snapshot → trace | **[U]** |
| 8 | **Five bounded domains** — Definition, Generation, Runtime, Fixture, Trace, with distinct mutability | **[U]** |
| 9 | **No giant nullable equipment table.** Small core identity + typed components, mirroring the five corpus item layers | **[U]** |
| 10 | **Fixed-point integer columns** (`_q`) for all persisted simulation state | **[U]** — ties directly to W-C10's digest firewall, which bars float-derived values from proof digests. Claude missed this entirely |
| 11 | **Revision immutability** + `content_hash` + `content_snapshot_hash` | **[U]** — a balance patch creates a revision; historical traces stay valid |
| 12 | **Per-delta attribution** — one row per state change, with `source_kind`, `contribution_role`, `rule_id`, `opening_provenance` | **[U]** |
| 13 | **`is_counterfactual`** for paired delta-signature runs | **[U]** |
| 14 | **`decision_origin`** carrying `[W]`/`[U]`/`[BOTH]`/`[NEW]` as a data field | **[U]** — the reconciliation marks become queryable provenance |
| 15 | **Telemetry capture levels** — full deterministic → full analytical → diagnostic → sampled → aggregate only | **[U]** |
| 16 | **Rarity is mechanical demand, not a magnitude multiplier** | **[U]** — correctly reads M·2A rather than importing genre habit |

## Claude's sweep — the operational layer

| # | Contribution | Mark |
|---|---|---|
| 17 | **Pin DuckDB v1.4 LTS** (supported to Sept 2026); v1.5.x is current and **v2.0 lands Sept 2026** | **[W]** — Bart's report names no version, and a design document that says "DuckDB" without a version is a hidden dependency |
| 18 | **Pydantic v2 (record) + Pandera (table)** as the validation stack, optionally `dbt-duckdb` for marts | **[W]** — Bart specifies validation *layers* but no tooling |
| 19 | **Read-only MCP server** for the agent's query path; writes go through the validated Python path only | **[W]** |
| 20 | **Text-to-SQL reliability is adequate but must be sandboxed** — ~94–95% under realistic review, ~76% on strict execution benchmarks, and those benchmarks are themselves contested | **[W]** |
| 21 | **Never commit raw Parquet to git.** Version seeds + config + sim code; they regenerate the data. git-LFS only for tracked samples | **[W]** |
| 22 | **Dolt** recorded as the staged escalation for cell-level content versioning, with two named game-studio adopters | **[W]** |

## Forks

| Question | Bart | Claude | Resolution |
|---|---|---|---|
| Multi-writer escalation | PostgreSQL | DuckLake + Postgres catalog, or Quack | **Bart's.** Postgres is proven; DuckLake v1.0 is four months old and Quack is beta. Recorded as later options |
| Nested vs normalised authoring | Normalised, one row per relation | DuckDB nested types are a strength | **No fork.** Bart is right for *authoring*; nesting belongs in analytical views and Parquet snapshots. Both stated this |

## Rejected

| Proposal | Why |
|---|---|
| `extraction` as a trace `outcome` value **[U]** | Reserved to Zone extraction (W§12) at 0.14.0 — *"Never a player exit."* Use `band_end_exit`. **Third time this word has been proposed and caught** |
| Fixture set as `Adept/Wand` only **[W]** | Superseded in discussion: any one-handed weapon with a free off-hand qualifies. Single-dagger trickster and mace-and-free-hand war priest are more idiomatic |

## New from discussion

| # | Decision | Mark |
|---|---|---|
| 23 | **One-handed weapon + free hand** is the general `[Mudra]` carrier; the wand is one option, not the only one | **[NEW]** |
| 24 | **Canine chassis** — quadruped, for `[Innate]` bite and forelimb attacks against a non-humanoid template | **[NEW]** |
| 25 | The model becomes a **tenth document, `P`** | **[NEW]** |
