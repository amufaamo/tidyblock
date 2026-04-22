---
title: 'TidyBlock: A Spreadsheet-based GUI for Tidyverse Data Wrangling and ggplot2 Visualization'
tags:
  - R
  - Shiny
  - tidyverse
  - ggplot2
  - data wrangling
  - visualization
  - GUI
  - reproducibility
  - spreadsheet
authors:
  - name: Masakazu Kagawa
    orcid: 0000-0000-0000-0000
    affiliation: 1
affiliations:
 - name: Independent Researcher
   index: 1
date: 15 March 2026
bibliography: paper.bib
---

# Summary

Data manipulation and visualization are central to virtually every empirical research workflow. In the R ecosystem, the tidyverse [@tidyverse2019] and ggplot2 [@ggplot2] have become the dominant frameworks for these tasks, offering expressive, composable, and reproducible pipelines through a code-based interface. However, the programming prerequisites of these tools exclude a large population of domain researchers — in life sciences, social sciences, economics, and education — who are comfortable working with tabular data in spreadsheet applications but lack formal programming training.

`TidyBlock` is an open-source R Shiny [@shiny] web application that provides a modern, spreadsheet-based graphical user interface (GUI) over the core tidyverse and ggplot2 functionality. Users can import, clean, reshape, aggregate, join, and visualize datasets entirely through point-and-click interactions without writing any R code. The interface is centered on an interactive spreadsheet canvas powered by `rhandsontable` [@rhandsontable], with all data operations translated internally into well-formed `dplyr` [@tidyverse2019] and `tidyr` calls. A dedicated Plot Builder — exposed through a guided accordion sidebar — covers chart types, aesthetic mappings, coordinate systems, scales, faceting, and themes, providing access to the full grammar of graphics [@ggplot2] without requiring users to learn the ggplot2 syntax.

# Statement of Need

In empirical research, data cleaning and exploratory analysis are frequently performed in spreadsheet software such as Microsoft Excel or Google Sheets. While approachable, these tools fundamentally undermine reproducibility: operations are applied in-place with no audit trail, are difficult to automate, and cannot be shared or verified by collaborators [@nature_reproducibility]. Transitioning to R's tidyverse ecosystem addresses these issues, but the programming barrier excludes a large fraction of researchers.

Existing GUI-based approaches in R partially address this problem, but each targets a different segment of the workflow. `Rcmdr` [@rcmdr] provides a menu-driven front-end for classical statistics but does not expose tidyverse pipelines or ggplot2. `radiant` [@radiant] focuses on business analytics and lacks the spreadsheet-centric paradigm familiar to most researchers. `esquisse` [@esquisse] is a drag-and-drop ggplot2 builder but does not support data wrangling. No existing solution provides a unified, spreadsheet-first environment covering the full breadth of tidyverse operations from data import through complex visualization.

`TidyBlock` is designed to fill this gap. Its primary audience is researchers and students who understand their data in a tabular, cell-oriented format and need to perform the full analytical pipeline — import, clean, reshape, aggregate, join, and visualize — without scripting. It is equally valuable as a teaching aid in data science courses, allowing instructors to demonstrate tidyverse concepts interactively before students write their own code.

# State of the Field

Several R packages and applications have been developed to lower the barrier to R-based data analysis. \autoref{tab:comparison} compares TidyBlock's coverage against existing tools across four key dimensions.

| Tool | Data Wrangling | ggplot2 GUI | Spreadsheet UI | Tidyverse-native |
|------|:-------------:|:-----------:|:--------------:|:----------------:|
| Rcmdr [@rcmdr] | Partial | No | No | No |
| radiant [@radiant] | Yes | Partial | No | Partial |
| esquisse [@esquisse] | No | Yes | No | Yes |
| ggplotgui [@ggplotgui] | No | Yes | No | Yes |
| **TidyBlock** | **Full** | **Full** | **Yes** | **Yes** |

: Comparison of R-based GUI tools for data analysis. \label{tab:comparison}

`TidyBlock` is the only tool that combines a spreadsheet-style data canvas with comprehensive tidyverse wrangling *and* a full-featured ggplot2 builder in a single, integrated application. Unlike `esquisse` or `ggplotgui`, which are standalone plot builders, `TidyBlock` supports the complete analytical pipeline from raw data import to final visualization. Unlike `radiant`, it adheres strictly to tidyverse idioms and exposes user-friendly labels rather than R function names, making it accessible to non-programmers while maintaining the full power of the underlying R ecosystem.

The decision to build a new application rather than contribute to an existing project was driven by the observation that no current tool combines all four dimensions in \autoref{tab:comparison}. Extending any single existing tool to cover all four would require fundamental architectural changes incompatible with their current designs.

# Software Design

`TidyBlock` is implemented as a single-file R Shiny application (`app.R`) with a modular internal architecture structured around a reactive state manager (`reactiveValues`). The state manager maintains all loaded datasets, operation history (for multi-step undo), plot objects, and UI state across the session.

The architecture follows three key design principles:

**1. Spreadsheet-first interaction model.** The primary interface is a full-width `rhandsontable` canvas that supports direct cell editing, drag-and-drop row/column reordering, and right-click context menus. Context menus provide direct access to data operations (sorting, filtering, adding columns, joining tables, and creating charts), mirroring the workflow of spreadsheet applications rather than imposing a programming paradigm.

**2. Non-destructive operation model.** Structural transformations such as summarization, unpivoting (pivot_longer), pivoting (pivot_wider), and joins create new dataset tabs rather than overwriting the source data. This provides an automatic audit trail and allows users to explore multiple analytical branches without risk. In-place operations (filter, sort, rename) support multi-step undo via a per-tab history stack.

**3. Separation of display labels from internal logic.** All user-facing UI elements use descriptive, non-technical labels (e.g., "Scatter (Points)" instead of `geom_point`, "Trend Line (Smooth)" instead of `geom_smooth`, "Add Column" instead of `Mutate`). Internally, the application maps these labels to the correct R function calls using named vectors, ensuring that the full power of the tidyverse and ggplot2 is preserved while eliminating R-specific jargon from the interface.

The Plot Builder is implemented as a Shiny module (`plotTabUI` / `plotTabServer`) that renders a side-by-side layout: a configuration sidebar with five accordion panels (Chart Type, Data Mapping, Scales & Coordinates, Split by Group, Themes & Labels) alongside a live plot preview. Each plot tab stores its ggplot2 object and axis metadata in the shared reactive state, enabling plot merging — users can overlay compatible plots (those sharing the same X and Y variables) to create composite visualizations.

Key capabilities include:

- **Data import**: CSV, TSV, and Excel files, plus built-in sample datasets.
- **Row operations**: Filtering with a nested AND/OR logic builder, sorting, and duplicate removal.
- **Column operations**: Column selection, renaming, and computed columns (with helper templates for `stringr`, `forcats`, and `lubridate` functions).
- **Reshape operations**: Unpivot (Wide → Long) and Pivot (Long → Wide) with interactive column selectors.
- **Aggregation**: Group-by combined with summary functions (average, sum, min, max, count), outputting results as a new tab.
- **Joins**: Left, Inner, Right, and Full joins across loaded datasets with automatic common-key detection and Left/Right swap.
- **Visualization**: 19 chart types, 10 aesthetic mappings, 5 coordinate systems, multiple color palettes (Brewer, Viridis, Gradient), split layouts (wrap and grid faceting), and comprehensive theme controls.
- **Plot merging**: Overlay layers from multiple compatible plots into a single composite chart.

# Research Impact Statement

`TidyBlock` addresses a well-documented reproducibility challenge in empirical research driven by over-reliance on manual spreadsheet workflows [@nature_reproducibility]. By providing a GUI that natively targets the tidyverse — the most widely adopted R data science framework — it lowers the activation energy for researchers to adopt reproducible, code-based workflows without requiring prior programming experience.

The application is designed for deployment in three primary contexts: (1) individual researchers performing exploratory data analysis without programming, (2) university data science courses as a transitional learning environment where students interact with tidyverse concepts through a GUI before writing R code, and (3) research lab onboarding programs where new members need to quickly analyze datasets without extensive R training.

`TidyBlock` is released under the MIT License and hosted on GitHub with continuous integration via GitHub Actions. The test suite (`testthat`) validates core data transformation logic. The roadmap includes export of the full operation pipeline as a standalone R script, enabling users to transition from GUI-driven to fully scripted workflows as their proficiency grows.

# AI Usage Disclosure

Portions of the software implementation and documentation were developed with assistance from generative AI tools. Specifically:

- **Tools used**: Claude (Anthropic, 2025–2026 versions) was used throughout development for code generation, refactoring, documentation drafting, and paper authoring assistance.
- **Nature and scope**: AI assistance was used for R/Shiny code generation and refactoring, UI design iteration, writing initial drafts of documentation (README.md, paper.md), and debugging. AI was not used for any evaluative decisions regarding software design or research framing.
- **Human review**: All AI-generated code was reviewed, tested, and validated by the author. The core architectural decisions (spreadsheet-first paradigm, non-destructive operation model, label–function separation pattern), scientific framing, and research context are the intellectual work of the author.

# Acknowledgements

We acknowledge the developers and maintainers of the `tidyverse`, `ggplot2`, `shiny`, `bslib` [@bslib], and `rhandsontable` packages, which form the technical foundation of this project.

# References
