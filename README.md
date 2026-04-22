# TidyBlock 🧱📊

**A Spreadsheet-based GUI for Tidyverse Data Wrangling and ggplot2 Visualization**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

TidyBlock is an open-source R Shiny application that provides a modern, spreadsheet-like graphical interface for data analysis. It brings the full power of the tidyverse and ggplot2 to researchers, students, and analysts who prefer point-and-click interactions over scripting.

![TidyBlock Screenshot](logo.png)

## ✨ Features

### Spreadsheet Canvas
An interactive, Excel-like data grid (powered by `rhandsontable`) with direct cell editing, drag-and-drop row/column reordering, and right-click context menus for quick access to data operations.

### Data Operations (No Code Required)
All operations are accessible through toolbar buttons, dropdown menus, and right-click context menus:

| Category | Operations |
|---|---|
| **Row Operations** | Filter (with AND/OR logic), Sort (A→Z / Z→A), Remove Duplicates |
| **Column Operations** | Select columns, Rename, Add/Compute Column (with helpers for text, date, and category functions) |
| **Reshape** | Unpivot (Wide → Long), Pivot (Long → Wide) |
| **Aggregation** | Group By + Summarize (Average, Sum, Min, Max, Count) — results open in a new tab |
| **Table Joins** | Left, Inner, Right, Full Join with automatic key detection and Left/Right swap |

### Chart Builder (ggplot2-based)
A guided, side-by-side Plot Builder with live preview:

- **19 chart types**: Scatter, Line, Histogram, Box Plot, Violin, Bar Chart, Density, Trend Line, and more
- **Data mapping**: X/Y axes, Color, Fill, Opacity, Size, Shape, Line Style, Group
- **Scales & Coordinates**: Standard, Polar, Radial, Fixed Ratio; Log10 transforms; Color Brewer, Viridis, Gradient palettes
- **Split by Group (Facets)**: Flexible grid or wrap layouts with independent axis scaling
- **Themes**: Minimal, Classic, Dark, Light, Black & White, and more — with font size, grid, and legend controls
- **Plot Merging**: Overlay compatible plots (matching X/Y axes) to create composite visualizations

### Non-Destructive Workflows
Structural transformations (summarization, reshaping, joins) create **new tabs** rather than overwriting the original data. All in-place operations support multi-step undo.

## 🛠 Installation

### Prerequisites

- R (>= 4.3.0)

### Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/amufaamo/tidyblock.git
   cd tidyblock
   ```

2. Install dependencies:
   ```R
   install.packages(c(
     "shiny", "bslib", "dplyr", "tidyr", "ggplot2",
     "rhandsontable", "DT", "rlang", "readr", "readxl",
     "forcats", "stringr", "lubridate", "scales"
   ))
   ```

3. Run the application:
   ```R
   shiny::runApp("app.R")
   ```

### Using Conda

```bash
conda env create -f environment.yml
conda activate void
Rscript -e "shiny::runApp('app.R')"
```

## 🧪 Testing

TidyBlock uses `testthat` for automated testing of core data transformation logic.

```R
library(testthat)
test_dir("tests/")
```

GitHub Actions validates every push to the main branch.

## 📄 JOSS Paper

This software is submitted to the **Journal of Open Source Software (JOSS)**. The associated paper is located in [`paper.md`](paper.md).

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:

- Reporting bugs
- Suggesting features
- Submitting pull requests

## 📝 License

MIT License. See [LICENSE](LICENSE) for details.

## 📖 Citation

If you use TidyBlock in your research, please cite:

```
Kagawa, M., (2026). TidyBlock: A Spreadsheet-based GUI for Tidyverse Data Wrangling
and ggplot2 Visualization. Journal of Open Source Software.
```
