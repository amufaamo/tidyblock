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
  - Reproducibility
authors:
  - name: Masakazu Kagawa
    orcid: 0000-0000-0000-0000  # TODO: Replace with your actual ORCID before submission
    affiliation: 1
affiliations:
 - name: Independent Researcher
   index: 1
date: 10 March 2026
bibliography: paper.bib
---

# Summary

The tidyverse [@tidyverse2019] ecosystem and `ggplot2` [@ggplot2] constitute the dominant framework for data manipulation and visualization in R, offering expressive, composable, and reproducible pipelines. However, their reliance on a textual programming interface presents a significant barrier for researchers in life sciences, social sciences, economics, and related fields who are comfortable with spreadsheet tools such as Microsoft Excel but lack formal programming training.

`TidyBlock` is an open-source `R Shiny` [@shiny] application that provides a modern spreadsheet-like Graphical User Interface (GUI) over the core functionalities of the tidyverse. It allows users to filter, reshape, aggregate, and visualize datasets through intuitive point-and-click interactions — without writing a single line of R code. The interface is built on `rhandsontable` [@rhandsontable] and `bslib`, providing an Excel-like spreadsheet canvas at the center of the workflow. All data operations are internally translated into well-formed `dplyr` and `tidyr` calls, and the generated R code is displayed live so users can gradually learn the underlying language. Furthermore, `TidyBlock` includes a comprehensive multi-layer `ggplot2` Plot Builder covering geoms, statistical transformations, coordinate systems, scales, faceting, and themes — exposing the full grammar of graphics through a guided accordion interface.

# Statement of Need

In empirical research, data cleaning and exploratory analysis are frequently performed in spreadsheet software such as Microsoft Excel or Google Sheets. While approachable, these tools fundamentally undermine reproducibility: operations are applied in-place with no audit trail, are difficult to automate, and cannot be shared or verified by collaborators. Transitioning to R's tidyverse ecosystem would address these issues, but the programming prerequisites exclude a large fraction of researchers.

Existing GUI-based approaches in R — such as `Rcmdr` [@rcmdr], `radiant` [@radiant], and `esquisse` [@esquisse] — partially address this problem, but each targets a different stratum of the workflow. `Rcmdr` provides a menu-driven front-end for classical statistics but does not expose the tidyverse or `ggplot2` pipelines. `radiant` focuses on business analytics and lacks the spreadsheet-centric paradigm familiar to most researchers. `esquisse` is an excellent drag-and-drop `ggplot2` builder but is limited to visualization and does not support data wrangling. No existing solution provides a unified, spreadsheet-first environment covering the full breadth of tidyverse operations from data import through complex visualization.

`TidyBlock` is designed explicitly to fill this gap. Its primary audience is researchers and students who understand their data intuitively in a tabular, cell-oriented format and need to perform the full analytical pipeline — import, clean, reshape, aggregate, join, and visualize — without scripting. It is equally valuable as a teaching aid in courses introducing students to reproducible data analysis, allowing instructors to demonstrate tidyverse concepts interactively before students write their own code.

# State of the Field

Several R packages and applications have been developed to lower the barrier to R-based data analysis. \autoref{tab:comparison} provides a structured comparison.

| Tool | Data Wrangling | ggplot2 GUI | Spreadsheet UI | Tidyverse-native |
|------|---------------|-------------|----------------|-----------------|
| `Rcmdr` [@rcmdr] | Partial | No | No | No |
| `radiant` [@radiant] | Yes | Partial | No | Partial |
| `esquisse` [@esquisse] | No | Yes | No | Yes |
| `ggplotgui` [@ggplotgui] | No | Yes | No | Yes |
| `mplot` | No | Partial | No | No |
| **TidyBlock** | **Full** | **Full** | **Yes** | **Yes** |

`TidyBlock` is uniquely positioned as the only tool that combines a spreadsheet-style data canvas with comprehensive tidyverse wrangling and a full-featured multi-layer `ggplot2` builder in a single, integrated application. Unlike `esquisse` or `ggplotgui`, which are standalone plot builders, `TidyBlock` supports the complete analytical pipeline from raw import to final visualization. Unlike `radiant`, it adheres strictly to the tidyverse idioms and exposes the generated R code to facilitate learning.

# Software Design

`TidyBlock` is implemented as a modular R Shiny application structured around a reactive state manager (`reactiveValues`) that maintains datasets, operation history, and UI state across the session. The architecture separates concerns into distinct Shiny modules for each operation type: `mod_filter.R`, `mod_mutate.R`, `mod_select.R`, `mod_arrange.R`, `mod_summarize.R`, `mod_group_by.R`, `mod_join.R`, `mod_import.R`, and `mod_plot.R`. The central `app.R` orchestrates module lifecycle via dynamic `insertUI` calls, enabling a pipeline-oriented workflow where each operation step is represented as a draggable, color-coded card in the interface.

A key architectural decision is the **non-destructive operation model**: structural transformations such as `summarise`, `pivot_longer`, and `pivot_wider` spawn new dataset tabs rather than overwriting the source data. This provides an automatic audit trail and allows users to explore multiple branches of their analysis without risk. Users retain access to all intermediate states and can undo any in-place operation up to 20 steps deep.

The Plot Builder module implements the Grammar of Graphics [@ggplot2] layer-by-layer. Users compose plots by selecting geoms, mapping aesthetics (including delayed evaluations such as `after_stat(density)`), configuring coordinate systems, applying color and position scales, and controlling themes — all through a five-panel accordion interface rendered side-by-side with a live plot preview. The generated R code is displayed in real time, bridging the gap between GUI interaction and R programming literacy.

**Key capabilities include:**

- **Spreadsheet Canvas**: Full `rhandsontable` integration with cell editing, manual row/column reordering, right-click context menus for triggering dplyr operations, and column-level selection for targeted transforms.
- **Row Operations**: GUI-driven `filter` (with nested AND/OR logic builder), `arrange` (ascending/descending), and `distinct` (deduplication).
- **Column Operations**: `select` with checkbox-based column picker, `rename` with inline field editing, and `mutate` with expression input and helper buttons for `stringr`, `forcats`, and `lubridate` functions.
- **Reshape Operations**: Interactive modals for `pivot_longer` and `pivot_wider` with column selectors.
- **Aggregation**: `group_by` combined with `summarise`, outputting results as a new named tab.
- **Joins**: `left_join`, `inner_join`, `right_join`, and `full_join` across loaded datasets with automatic common-key detection.
- **ggplot2 Builder**: Support for 20+ geom types, 10 aesthetic mappings, 5 coordinate systems, multiple color palettes (Brewer, Viridis, gradient), `facet_wrap`/`facet_grid`, and granular theme controls.

# Research Impact Statement

`TidyBlock` addresses a documented reproducibility crisis in empirical research driven by over-reliance on manual spreadsheet workflows [@nature_reproducibility]. By providing a GUI that natively targets the tidyverse — the most widely used R data science framework — it lowers the activation energy for researchers to adopt reproducible, code-based workflows without requiring prior programming experience.

The application is released under the MIT License and hosted on GitHub with continuous integration via GitHub Actions. The test suite (`testthat`) validates all core data transformation logic. Future development roadmap includes export of the full operation pipeline as a standalone R script, enabling users to transition from GUI-driven to fully scripted workflows as their proficiency grows. The tool is designed to be used in university data science courses and research lab onboarding programs as a transitional learning environment.

# AI Usage Disclosure

Portions of the software architecture and documentation were developed with assistance from AI language model tools (Claude, Anthropic). All generated code was reviewed, tested, and validated by the author. The core algorithmic logic, architectural decisions, and scientific framing of the paper are the intellectual work of the author.

# Acknowledgements

We acknowledge the contributors and maintainers of the `tidyverse`, `ggplot2`, `shiny`, `bslib`, and `rhandsontable` packages, which form the technical foundation of this project. We also thank the JOSS editorial team and reviewers for their guidance.

# References
