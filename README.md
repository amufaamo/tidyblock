<p align="center">
  <img src="logo.png" alt="TidyBlock Logo" width="300">
  <h1 align="center">🧱 TidyBlock</h1>
  <p align="center">
    <strong>A Visual, Node-Based GUI for dplyr Data Wrangling</strong>
  </p>
  <p align="center">
    Build tidyverse pipelines by dragging and clicking — no coding required.
  </p>
  <p align="center">
    <img src="https://img.shields.io/badge/version-1.0.0-blue" alt="Version">
    <img src="https://img.shields.io/badge/R-%3E%3D%204.3.0-blue?logo=r" alt="R Version">
    <img src="https://img.shields.io/badge/Shiny-1.9+-green?logo=r" alt="Shiny">
    <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
  </p>
</p>

---

## 📖 Overview

**TidyBlock** is an R Shiny application that lets you visually construct `dplyr` data-wrangling pipelines through an intuitive, block-based interface. Instead of writing R code manually, you add pipeline modules (Filter, Select, Mutate, etc.) as visual cards and configure them through dropdowns and inputs. TidyBlock generates the equivalent R code in real time.

### ✨ Key Features

| Feature | Description |
|---------|------------|
| 🔍 **Advanced Filter** | Build complex filter conditions with AND/OR groups and nested logic |
| 📋 **Select** | Choose which columns to keep |
| ➕ **Mutate** | Create new columns with custom R expressions |
| 📊 **Group By** | Group data by one or more variables |
| 📈 **Summarize** | Aggregate data with mean, sum, median, sd, min, max, n, n_distinct |
| ↕️ **Arrange** | Sort data ascending or descending |
| 🔗 **Join** | Left/Inner/Right/Full join with auto-detected keys |
| 📉 **Plot** | Create ggplot2 visualizations (Point, Bar, Line, Boxplot) with themes |
| 💻 **Live Code Preview** | See the generated dplyr pipeline code update in real time |
| 📊 **Live Data Preview** | Instantly see filtered/transformed data as you build |
| ↔️ **Resizable Cards** | Resize module cards with drag handles |

---

## 🖼️ Screenshots

> After launching the app, load the demo Iris dataset and add pipeline modules from the sidebar.

### Pipeline with Filter, Select, and Mutate
```
┌─────────────────────────────────────────────────────┐
│  TidyBlock                                          │
├──────────┬──────────────────┬────────────────────────┤
│ Toolbox  │ Data Preview     │ Filter (Advanced)      │
│          │                  │  [AND ▼] [+ Rule]      │
│ ▶ Filter │  Sepal.Length... │  Sepal.Length == 5.1    │
│ ▶ Select │                  ├────────────────────────┤
│ ▶ Mutate │                  │ Select                 │
│ ▶ GroupBy│                  │  [Sepal.Length, ...]    │
│ ▶ Summ.  │ R Code Preview   ├────────────────────────┤
│ ▶ Arrange│  iris |>         │ Mutate                 │
│ ▶ Join   │   filter(...) |> │  new_var = log(...)    │
│          │   select(...) |> │                        │
│ ▶ Plot   │   mutate(...)    │                        │
└──────────┴──────────────────┴────────────────────────┘
```

---

## 🚀 Getting Started

### Prerequisites

- **R** >= 4.3.0
- **Conda** (Miniconda or Anaconda) — recommended for reproducible environments

### Installation

#### Option 1: Using Conda (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/amufaamo/tidyblock.git
cd tidyblock

# 2. Create the Conda environment
conda env create -f environment.yml

# 3. Activate the environment
conda activate void

# 4. Launch the app
R -e "shiny::runApp()"
```

#### Option 2: Manual R Package Installation

```bash
# 1. Clone the repository
git clone https://github.com/amufaamo/tidyblock.git
cd tidyblock

# 2. Install dependencies in R
R -e "install.packages(c('shiny', 'bslib', 'tidyverse', 'rlang', 'DT', 'shinyAce', 'shinyjqui', 'bsicons', 'glue', 'pkgload'))"

# 3. Launch the app
R -e "shiny::runApp()"
```

The app will open at `http://127.0.0.1:xxxx` (port is shown in the console).

### Quick Start Guide

1. **Load Data** — Click "Load Demo Data (Iris)" in the sidebar, or upload your own CSV file.
2. **Add Modules** — Click any button under "Pipeline Tools" (Filter, Select, Mutate, etc.) to add a module card.
3. **Configure** — Set options in each module card (e.g., select columns, set filter conditions).
4. **View Results** — The "Data Preview / Result" table and "R Code Preview" update in real time.
5. **Copy Code** — Copy the generated R code from the preview panel to use in your own scripts.

---

## 📦 Project Structure

```
tidyblock/
├── app.R                  # Entry point — launches the Shiny app
├── DESCRIPTION            # R package metadata (version, dependencies)
├── NAMESPACE              # R namespace declarations
├── CHANGELOG.md           # Version history
├── environment.yml        # Conda environment definition
├── iris.csv               # Demo dataset
├── R/
│   ├── app_ui.R           # Main UI layout (sidebar + main panel)
│   ├── app_server.R       # Main server logic (pipeline execution engine)
│   ├── mod_import.R       # Data import module (CSV upload, demo data, preview)
│   ├── mod_filter.R       # Advanced filter module (AND/OR groups, rules)
│   ├── mod_select.R       # Column selection module
│   ├── mod_mutate.R       # Column creation module
│   ├── mod_group_by.R     # Group-by module
│   ├── mod_summarize.R    # Summarize/aggregate module
│   ├── mod_arrange.R      # Sort/arrange module
│   ├── mod_join.R         # Join module (left, inner, right, full)
│   ├── mod_plot.R         # ggplot2 visualization module
│   └── utils_codegen.R    # Pipeline code generation utilities
├── man/                   # R documentation (auto-generated)
├── tests/                 # Unit tests (testthat)
└── DEBUGGING.md           # Debugging guide for developers
```

---

## 🔧 Module Reference

### Filter (Advanced)
Build complex filter conditions with nested AND/OR logic.

```r
# Example generated code:
iris |>
  filter((Sepal.Length > 5 & Species == 'setosa') | Petal.Width < 0.3)
```

- **AND/OR Groups**: Combine conditions with logical operators
- **Nested Groups**: Create sub-groups for complex logic (e.g., `A AND (B OR C)`)
- **Operators**: `==`, `!=`, `>`, `<`, `>=`, `<=`, `%in%`

### Select
Choose columns to keep in the dataset.

```r
iris |> select(`Sepal.Length`, `Sepal.Width`, `Species`)
```

### Mutate
Create new columns with R expressions.

```r
iris |> mutate(`sepal_ratio` = `Sepal.Length` / `Sepal.Width`)
```

- **Helper Functions**: Quick insert for `log()`, `sqrt()`, `abs()`, `round()`, `paste0()`, `as.numeric()`, `as.character()`, `ifelse()`

### Group By + Summarize
Group data and compute aggregations.

```r
iris |>
  group_by(`Species`) |>
  summarize(`mean_sl` = mean(`Sepal.Length`), .groups = 'drop')
```

- **Functions**: `mean`, `sum`, `median`, `sd`, `min`, `max`, `n`, `n_distinct`
- **Optional Secondary Statistic**: Add a second aggregation (e.g., mean ± sd)

### Arrange
Sort data by a column.

```r
iris |> arrange(desc(`Sepal.Length`))
```

### Join
Combine datasets with dplyr join functions.

```r
iris |> left_join(other_data, by = c("Species"))
```

- **Join Types**: Left, Inner, Right, Full
- **Auto-detected Keys**: Common columns between datasets are automatically suggested

### Plot
Create ggplot2 visualizations.

```r
iris |>
  ggplot(aes(x = `Sepal.Length`, y = `Sepal.Width`, color = `Species`)) +
  geom_point() +
  theme_minimal()
```

- **Geometries**: Point, Bar (auto-switches to `geom_col`), Line, Boxplot
- **Optional Error Bars**: `geom_errorbar()` with ymin/ymax
- **Themes**: gray, bw, linedraw, light, dark, minimal, classic, void

---

## 🏷️ Version History

### v1.0.0 (2026-02-15) — Initial Stable Release

The first public release with all core data-wrangling modules fully functional.

**What's included:**
- ✅ All 8 pipeline modules (Filter, Select, Mutate, Group By, Summarize, Arrange, Join, Plot)
- ✅ Advanced Filter with AND/OR nested group logic
- ✅ Real-time code generation and data preview
- ✅ Resizable module cards (`shinyjqui`)
- ✅ Reactive pipeline execution with error handling
- ✅ Server-side DataTable rendering for performance
- ✅ Conda environment for reproducible setup

**Bug Fixes from Development:**
- Fixed reactive circular dependency that caused UI to freeze after loading data
- Fixed `DT::renderDT(server = FALSE)` blocking the Shiny event loop
- Re-enabled `jqui_resizable()` on all module cards
- Restored full Filter (Advanced) UI from test placeholder

### v0.1.0 (2026-02-04) — Development Preview

Internal development version. Not publicly released.

**What was included:**
- ⚠️ Basic project scaffolding
- ⚠️ Import module with CSV upload and demo data
- ⚠️ Placeholder module files (not fully functional)
- ❌ Pipeline tools did not work after loading data (reactive loop bug)
- ❌ Module cards were not resizable (`jqui_resizable` commented out)
- ❌ Filter UI was a test placeholder

> For the full changelog, see [CHANGELOG.md](./CHANGELOG.md).

---

## 🛠️ Development

### Running in Development Mode

```bash
conda activate void
R -e "shiny::runApp(port=5100)"
```

### Running Tests

```bash
conda activate void
R -e "devtools::test()"
```

### Regenerating Documentation

```bash
conda activate void
R -e "devtools::document()"
```

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Shiny](https://shiny.posit.co/) — Web application framework for R
- [bslib](https://rstudio.github.io/bslib/) — Bootstrap 5 for Shiny
- [dplyr](https://dplyr.tidyverse.org/) — Data manipulation grammar
- [ggplot2](https://ggplot2.tidyverse.org/) — Data visualization grammar
- [shinyjqui](https://yang-tang.github.io/shinyjqui/) — jQuery UI interactions for Shiny
- [DT](https://rstudio.github.io/DT/) — Interactive data tables
