# MCVL Codebase — Development Log

## Session 1 — 2026-05-21
### Structural audit and redesign discussion

---

## 1. Codebase audit

Full read of all do files. The pipeline has five stages:

1. **Ingestion** — `format_all*.do` + `rawfiles/` helpers: reads raw `.trs`/`.txt` files into per-year `.dta` files
2. **Assembly** — Patchwork family: appends annual files, merges personal/pension, cleans, counts spells
3. **Unemployment consolidation** — `coru_*.do`: three flavours for handling administrative gaps
4. **Panelisation** — `panel/`: converts spell data to quarterly/monthly observation-per-row panel
5. **Fiscal merge** — `merge_fiscal*.do`: matches wage/tax records to work histories

---

## 2. File-by-file decisions

### `format_all.do` vs `format_all_21.do`
- **`format_all.do` is the canonical ingestion file** covering all years (2006–present)
- It has three blocks: 2006–2008 (old style, `.trs`, 3 files), 2009–2012 (new style, 3 files), 2013–`${end_year}` (new style, 4 files)
- The third block was temporarily hardcoded to `2021/2021` for a one-off project; now restored to `2013/${end_year}` using a local macro workaround (`local ey = ${end_year}` then `forvalues yy=2013/\`ey'`)
- **`format_all_21.do`** is the single-year equivalent — it formats personal, pension and affiliation in one go for `${end_year}` only. Kept for the single-year retro path.

### `format_all_fiscal_old.do` (root) vs `archive/format_all_fiscal_old.do`
- They are **not the same file**. The archive version is truly old (year-by-year blocks, no loops, 2005–2013 only). The root version is a later iteration with loops but superseded by `format_all_fiscal.do`.
- **Decision:** root `format_all_fiscal_old.do` is redundant — `format_all_fiscal.do` already produces all income types; a wages-only extract is just a `keep` downstream. Move root version to archive or delete when reorganising.

### `format_all_fiscal.do` vs `format_all_fiscal_old.do` (root)
- Current version reshapes wide → one row per `id × year × firmID` with one column per income type + `total_income`, saves `wages_panel_{end_year}.dta`
- Old root version kept only key=="A" (wages), computed `sevpay`, saved `wages_only_panel_{end_year}.dta`
- **Decision:** consolidate — current version is the keeper; wages-only extract does not need a separate file

### `format_all_fiscal.do` + `merge_fiscal_panel.do` consolidation
- `format_all_fiscal.do` already formats AND appends all years
- **Decision:** add a global flag `save_wages_panel` at the top; the appending/saving section runs conditionally. No need for a separate join file.

### Patchwork family — legacy cleanup
- `Patchwork_prelim.do`, `Patchwork_panel.do` (old 2005–2013 panel), `Patchwork_ltu.do`, `Patchwork_stu.do`, `Patchwork_none.do` — all **moved to archive**
- Canonical files going forward: **`Patchwork.do`** (panel) and **`Patchwork_retro.do`** (working histories)

### Two fundamental data structures
- **`Patchwork.do`** → `id × year × spell` — panel, one observation per person per year per spell; needed for merging with annual fiscal data
- **`Patchwork_retro.do`** → `id × spell` — working histories, one observation per spell regardless of duration; suitable for duration analysis

### `cma.do` vs `cma_panel.do`
- These solve genuinely different problems and must remain separate:
  - `cma.do` — splits spells on contract changes using raw `dtin`/`dtout`
  - `cma_panel.do` — same but accounts for the `year` dimension (checks modification date falls within current year, handles multi-year spells)

### Unemployment consolidation — renaming
- `coru_*.do` renamed to `uc_*.do` (unemployment consolidation, not correction):
  - `uc_none.do` — registered unemployment only
  - `uc_ltu.do` — extends incomplete U spells to next employment spell
  - `uc_stu.do` — LTU + treats gaps >15 days as unregistered unemployment (`hidden_u`)
  - `coru_stu_retro.do` → merged into `uc_stu.do` (retro vs panel difference handled internally)

### `coru_stu_stats.do` → `uc_diagnostics.do`
- Kept and **extended** into a proper diagnostic tool covering all three consolidation flavours
- Reports: `mod_u` composition, `hidden_u` breakdown by type (short tenure / quit / self-employment), duration distributions, before/after unemployment rates, recall rates, transition matrices
- Run optionally via `run_diagnostics` global in master files

### Fiscal merge files
- `merge_fiscal.do` (oldest, hardcoded years) → **archive**
- `merge_fiscal_retro.do` (WIP, tried to do expand+merge+collapse in one shot) → **superseded** by panel merge + new collapse file
- `merge_fiscal_panel.do` → **keep and complete** as the main wage merge file
- **New file needed:** `collapse_to_spell.do` — aggregates income from `id × year × spell` to `id × spell`, keeping first-year wage, mean wage, and last-year wage per spell

---

## 3. Proposed new architecture

### File structure

```
master_panel.do          ← user runs this for panel output
master_retro.do          ← user runs this for working histories output

patchwork.do             ← link and assemble annual files → baseline_{end_year}.dta
patchwork_panel.do       ← clean + cma_panel → id×year×spell
patchwork_retro.do       ← clean + cma → id×spell (single year or all years)

uc_none.do               ← unemployment consolidation: registered only
uc_ltu.do                ← unemployment consolidation: LTU extension
uc_stu.do                ← unemployment consolidation: LTU + hidden gaps
uc_diagnostics.do        ← optional: full diagnostic report on consolidation

format_all.do            ← ingest affiliation files, all years (2006–end_year)
format_all_21.do         ← ingest all files, single year only
format_all_personal.do   ← ingest personal files, all years
format_all_pension.do    ← ingest pension files, all years
format_all_fiscal.do     ← ingest + append fiscal files (optional save of wages panel)

merge_fiscal_panel.do    ← merge wages into panel → id×year×spell with income
collapse_to_spell.do     ← NEW: aggregate income to spell level (first/mean/last wage)

cma.do                   ← contract modification adjustment (retro/single-year)
cma_panel.do             ← contract modification adjustment (panel)

rawfiles/                ← low-level formatting helpers (unchanged)
panel/                   ← panelisation helpers (unchanged)
robustness/              ← robustness variants (unchanged)
archive/                 ← superseded files
fiscal_dictionaries/     ← reference PDFs
```

### `master_panel.do` structure

```stata
* USER OPTIONS
global start_year        = 2006
global end_year          = 2021
global uc_flavour        = 3    // 1=none, 2=ltu, 3=stu
global run_diagnostics   = 1    // 0=skip, 1=run
global run_fiscal        = 1    // 0=skip, 1=format only, 2=format+merge
global collapse_to_spell = 0    // 0=keep panel, 1=collapse to id×spell

* FORMAT RAW FILES
do "format_all_personal.do"
do "format_all_pension.do"
do "format_all.do"
if ${run_fiscal} >= 1 { do "format_all_fiscal.do" }

* ASSEMBLE AND CLEAN
do "patchwork.do"
do "patchwork_panel.do"

* UNEMPLOYMENT CONSOLIDATION
if ${uc_flavour} == 1      { do "uc_none.do" }
else if ${uc_flavour} == 2 { do "uc_ltu.do"  }
else if ${uc_flavour} == 3 { do "uc_stu.do"  }

* DIAGNOSTICS (optional)
if ${run_diagnostics} == 1 { do "uc_diagnostics.do" }

* FISCAL MERGE (optional)
if ${run_fiscal} == 2 { do "merge_fiscal_panel.do" }

* COLLAPSE TO SPELL LEVEL (optional)
if ${collapse_to_spell} == 1 & ${run_fiscal} == 2 {
    do "collapse_to_spell.do"
}
```

### `master_retro.do` structure

```stata
* USER OPTIONS
global end_year        = 2021
global single_year     = 0    // 0=all years, 1=single year only
global start_year      = 2006 // ignored if single_year==1
global uc_flavour      = 3    // 1=none, 2=ltu, 3=stu
global run_diagnostics = 1

* FORMAT RAW FILES
if ${single_year} == 1 {
    do "format_all_21.do"
}
else {
    do "format_all_personal.do"
    do "format_all_pension.do"
    do "format_all.do"
}

* ASSEMBLE AND CLEAN
if ${single_year} == 0 { do "patchwork.do" }
do "patchwork_retro.do"

* UNEMPLOYMENT CONSOLIDATION
if ${uc_flavour} == 1      { do "uc_none.do" }
else if ${uc_flavour} == 2 { do "uc_ltu.do"  }
else if ${uc_flavour} == 3 { do "uc_stu.do"  }

* DIAGNOSTICS (optional)
if ${run_diagnostics} == 1 { do "uc_diagnostics.do" }
```

---

## 4. New files to write

| File | Status | Notes |
|---|---|---|
| `master_panel.do` | To write | |
| `master_retro.do` | To write | |
| `patchwork.do` | Refactor existing | Extract linking/assembly section from current `Patchwork.do` |
| `patchwork_panel.do` | Refactor existing | Remaining panel cleaning from current `Patchwork.do` |
| `patchwork_retro.do` | Refactor existing | Mirror structure of `patchwork_panel.do` |
| `uc_none.do` | Rename `coru_none.do` | Minor edits |
| `uc_ltu.do` | Rename `coru_ltu.do` | Minor edits |
| `uc_stu.do` | Rename `coru_stu.do` | Absorb retro variant |
| `uc_diagnostics.do` | Extend `coru_stu_stats.do` | Generalise to all flavours |
| `collapse_to_spell.do` | Write from scratch | Aggregates income: first/mean/last wage per spell |

---

## 5. Next steps

- Write the README
- Implement refactoring (only after README agreed)
