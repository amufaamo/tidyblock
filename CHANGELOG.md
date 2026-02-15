# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-15

### 🎉 Initial Stable Release

First public release of TidyBlock — a visual, node-based GUI for `dplyr` data wrangling built with R Shiny.

### Added

- **Data Import Module** (`mod_import`)
  - CSV file upload with `readr::read_csv`
  - Built-in "Load Demo Data (Iris)" button for quick testing
  - Data Preview table with pagination and search (powered by `DT`)
  - Dynamic switching between data table and ggplot plot output

- **Filter Module** (`mod_filter`) — Advanced Filtering
  - AND / OR group logic with nested sub-groups
  - Dynamic rule builder: Column selector, Operator (`==`, `!=`, `>`, `<`, `>=`, `<=`, `%in%`), and Value input
  - Add / remove individual rules or entire groups
  - Real-time `dplyr::filter()` code generation with correct quoting

- **Select Module** (`mod_select`)
  - Multi-column selector for `dplyr::select()`
  - Upstream-aware column choices

- **Mutate Module** (`mod_mutate`)
  - Create new columns with custom R expressions
  - Helper function selector (e.g., `log()`, `sqrt()`, `paste0()`)
  - Generates `dplyr::mutate()` code

- **Group By Module** (`mod_group_by`)
  - Multi-column group-by selector
  - Generates `dplyr::group_by()` code

- **Summarize Module** (`mod_summarize`)
  - Primary and optional secondary aggregation
  - Supported functions: `mean`, `sum`, `median`, `sd`, `min`, `max`, `n`, `n_distinct`
  - Numeric column validation with user warnings
  - Generates `dplyr::summarize()` code with `.groups = 'drop'`

- **Arrange Module** (`mod_arrange`)
  - Single-column sort with ascending/descending toggle
  - Generates `dplyr::arrange()` / `dplyr::arrange(desc())` code

- **Join Module** (`mod_join`)
  - Support for `left_join`, `inner_join`, `right_join`, `full_join`
  - Auto-detection of common key columns between datasets
  - Generates `dplyr::*_join()` code

- **Plot Module** (`mod_plot`)
  - Geometries: Point, Bar (auto-switches to `geom_col` when Y is provided), Line, Boxplot
  - Aesthetic mappings: X axis, Y axis, Color/Fill
  - Optional error bars (`geom_errorbar`)
  - 8 built-in `ggplot2` themes
  - Generates full `ggplot2` code

- **Pipeline Architecture**
  - Dynamic module insertion/removal with `insertUI` / `removeUI`
  - Real-time R code preview showing the complete `dplyr` pipeline
  - Live data preview that updates as modules are added/modified
  - Reactive pipeline execution with error handling and partial results
  - Upstream column propagation for context-aware module inputs

- **UI/UX Features**
  - `bslib` dark navbar with responsive sidebar layout
  - Resizable module cards via `shinyjqui::jqui_resizable()`
  - Module removal with trash button on each card
  - Color-coded module headers (blue=Filter, teal=Select, green=Mutate, yellow=GroupBy/Summarize, blue=Arrange, gray=Join, dark=Plot)

### Technical

- Solved reactive circular dependency issue in pipeline execution (`observe` + `isolate` pattern)
- Server-side DataTable rendering (`server = TRUE`) for performance
- Conda environment (`void`) for reproducible R package management
- R package structure with `DESCRIPTION`, `NAMESPACE`, and modular `R/` directory

---

## [0.1.0] - 2026-02-04

### 🧪 Development Preview (Internal)

Initial development version. Not publicly released.

### Added

- Basic project scaffolding with R package structure
- `app_ui.R` and `app_server.R` skeleton
- `mod_import.R` with CSV upload and demo data loader
- Placeholder module files for Filter, Select, Mutate
- `environment.yml` for Conda-based dependency management
- `DEBUGGING.md` with troubleshooting guide

### Known Issues

- Pipeline tool buttons did not work after loading data (reactive loop)
- `jqui_resizable()` was commented out in all modules
- Filter module UI was incomplete (test placeholder)
- `DT::renderDT(server = FALSE)` caused UI blocking with large datasets
