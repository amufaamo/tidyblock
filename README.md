# TidyBlock 🧱📊
**A Spreadsheet-like GUI for Tidyverse Data Wrangling and ggplot2 Visualization**

TidyBlock is an intuitive, open-source `R Shiny` application designed to bring the power of the `tidyverse` and `ggplot2` to users who prefer a graphical, spreadsheet-like interface over scripting. It bridges the gap between traditional manual tools like Microsoft Excel and robust, reproducible R-based pipelines.

![TidyBlock Plot Builder UI](logo.png)

## ✅ Features

### 1. Spreadsheet Interaction
Built on top of `rhandsontable`, TidyBlock offers an intuitive Excel-like experience inside your browser. Navigate cells, drop down columns, sort tables on the fly with a click, and manually verify data just as you would in standard spreadsheet software.

### 2. Core Data Wrangling (Dplyr & Tidyr)
Transform your data without writing code. A modern top-navigation toolbar organizes operations logically into Rows, Columns, and Reshape functions, including:
- **Filtering & Distinct (`filter`, `distinct`)**
- **Column Operations (`select`, `rename`)**
- **Dynamic Variable Creation (`mutate` with helpers from `stringr` and `lubridate` APIs)**
- **Grouping and Aggregation (`group_by %>% summarise`)**
- **Table Combination (`left_join`, `inner_join`)**
- **Reshaping (`pivot_longer`, `pivot_wider`)**

### 3. Advanced ggplot2 Builder (Layer by Layer)
Eliminate the steep learning curve of R data visualization. TidyBlock includes an integrated "Plot Explorer" mode that spins off complex visualizations. Using a side-by-side builder, users can:
- **Aesthetic Mapping:** Assign global traits like `x`, `y`, `color`, `fill`, `alpha`, and advanced mappings (e.g., `y = after_stat(density)`).
- **Multiple Layers:** Synthesize and overlap geometries (`geom_point`, `geom_smooth`, `geom_density`, `geom_boxplot`, and over 15 others).
- **Annotations:** Draw direct statistical baselines with inputs like `geom_hline` intercepts.
- **Scales & Coordinates:** Adjust axis limits intuitively, compress out-of-bounds outliers (`oob_squish`), and transform views entirely via log10 scalers or `coord_radial/polar` spatial views.
- **Grids & Themes:** Instantly apply `theme_minimal`, modify base grid grids, or inject rich ColorBrewer palettes.

### 4. Non-Destructive Workflows
Every fundamental change you make—like aggregating the data or reshaping its dimensions—does *not* overwrite your base document. Instead, actions spawn brand **new tabs**, preserving the original spreadsheet while visually logging a sequential state history.

## 🛠 Installation / Setup

You can deploy TidyBlock using `R` and standard packages.

### Prerequisites

Ensure you have R (>= 4.3.0) installed. We recommend using `renv` or the included `environment.yml` for Conda to handle the `shiny` and `tidyverse` requirements safely.

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/amufaamo/tidyblock.git
   cd tidyblock
   ```

2. Open R and install the necessary dependencies from CRAN:
   ```R
   install.packages(c(
     "shiny", "bslib", "dplyr", "tidyr", "ggplot2", 
     "rhandsontable", "DT", "forcats", "stringr", "lubridate", "scales"
   ))
   ```

3. Start the application:
   ```R
   shiny::runApp('app.R')
   ```

## 🧪 Testing

TidyBlock incorporates `testthat` for automatic validation of its UI-driven data wrangling logic. Tests cover core operations from parsing raw UI logic filters down to validating structural `pivot` actions.
Run tests via:
```R
library(testthat)
test_dir("tests/")
```
GitHub Actions ensures unit testing validates every commit to `master/main`.

## 📄 Submission to JOSS
This tool is formulated for submission to the **Journal of Open Source Software (JOSS)**. The associated paper draft is located in `paper.md`, documenting the underlying framework, educational viability, and need for the software across empirical research domains. 

## 👨‍💻 Contributing
Pull requests, feature suggestions, and bug reports are heavily encouraged.

## License
MIT License.
