---
title: 'TidyBlock: A Spreadsheet-like GUI for Tidyverse Data Wrangling and ggplot2 Visualization'
tags:
  - R
  - Shiny
  - Tidyverse
  - ggplot2
  - GUI
  - Data Wrangling
  - Visualization
authors:
  - name: Masakazu Kagawa
    orcid: 0000-0000-0000-0000 # <-- Replace with appropriate ORCID
    affiliation: 1
affiliations:
 - name: Independent Researcher
   index: 1
date: 10 March 2026
bibliography: paper.bib
---

# Summary

The tidyverse [@tidyverse2019] ecosystem and ggplot2 [@ggplot2] offer robust and powerful languages for data manipulation and visualization in R. However, their reliance on programming interfaces presents a steep learning curve for non-programmers or novices familiar mainly with spreadsheet tools like Microsoft Excel. 

`TidyBlock` bridges this gap by providing an open-source `Shiny` [@shiny] application that layers a modern spreadsheet-like Graphical User Interface (GUI) over the core functionalities of the tidyverse. By utilizing `rhandsontable` [@rhandsontable] and `bslib` for seamless interactivity, `TidyBlock` allows users to intuitively drag, edit, select, and reshape datasets while internally translating these interactions into robust `dplyr` and `tidyr` operations. Furthermore, the application provides an extensive "Layer Builder" that democratizes the creation of complex, multi-layered `ggplot2` graphics without the need to write a single line of code.

# Statement of need

In the life sciences, economics, and social sciences, researchers often rely on manual data cleaning in spreadsheets, which fundamentally breaks the reproducibility pipeline. While scripting in R provides complete reproducibility, many researchers lack the time or foundational skills to translate their immediate spatial understanding of data into chained commands.

`TidyBlock` addresses this need by functioning as an educational and transitional environment. It enables reproducible data wrangling with non-destructive operations: each transformational step (like `summarise` or `pivot_longer`) generates a distinct dataset, automatically creating a traceable operational tab history. 

Furthermore, researchers can conduct exploratory data analysis instantly via a deeply integrated multi-layered `ggplot2` builder. This plot engine exposes aesthetic mappings (including `after_stat` delayed evaluation), multiple static/dynamic geometries, coordinate system overrides (e.g. `coord_radial`, `coord_trans`), faceting (`facet_wrap`, `facet_grid`), and granular non-data-ink controls via `theme()`.

# Architecture and Key Capabilities

TidyBlock is designed using an R package-ready architecture encapsulated in a modular Shiny (`app.R`) framework that dynamically constructs its interface based on dataset and history states.

**Key capabilities include:**
- **Interactive Data Entry & Navigation**: A complete spreadsheet emulation with `rhandsontable` allowing manual fixes alongside dynamic toolbars for row (`filter`, `distinct`), column (`select`, `rename`, `mutate` with stringr/lubridate helpers), and join operations.
- **Tidyr Data Reshaping**: Interactive graphical modals to perform structural data modifications such as `pivot_longer` and `pivot_wider`.
- **Advanced ggplot2 GUI Engine**: An accordion-based Plot Builder for layering Geoms, setting statistical overrides (`stat_summary`, `stat_boxplot`, etc.), and fine-tuning limits and out-of-bounds scales configuration (e.g. `scales::oob_squish`).
- **Non-destructive States**: All structural dataset mutations spawn new accessible tabs, preventing irreversible damage to raw inputs.

# Acknowledgements

We acknowledge the contributors and main maintainers of the `tidyverse`, `ggplot2`, `shiny`, and `bslib` packages which serve as the foundation of this project.

# References
