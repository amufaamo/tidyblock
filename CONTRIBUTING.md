# Contributing to TidyBlock

Thank you for considering contributing to TidyBlock! This document provides guidelines and instructions for contributing.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue on our [GitHub Issues](https://github.com/amufaamo/tidyblock/issues) page with:

- A clear, descriptive title
- Steps to reproduce the problem
- Expected vs. actual behavior
- Your R version and operating system
- Screenshots if applicable

### Suggesting Features

Feature requests are welcome! Please open an issue with:

- A clear description of the feature
- Why it would be useful for the target audience (non-programming researchers)
- Any examples or mockups

### Submitting Pull Requests

1. **Fork** the repository and create your branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** in `app.R` or test files.

3. **Test your changes**:
   ```R
   library(testthat)
   test_dir("tests/")
   ```

4. **Submit a pull request** with a clear description of your changes.

## Development Setup

### Prerequisites

- R >= 4.3.0
- The following R packages:
  ```R
  install.packages(c(
    "shiny", "bslib", "dplyr", "tidyr", "ggplot2",
    "rhandsontable", "DT", "rlang", "readr", "readxl",
    "forcats", "stringr", "lubridate", "scales"
  ))
  ```

### Running the Application

```R
shiny::runApp("app.R")
```

### Running Tests

```R
library(testthat)
test_dir("tests/")
```

## Code Style

- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use descriptive variable names
- Comment non-obvious logic
- Keep user-facing labels free of R-specific jargon (see `project.md` Section 7 for the naming convention)

## Code of Conduct

Please be respectful and constructive in all interactions. We are committed to providing a welcoming and inclusive environment for everyone.

## Getting Help

If you need help or have questions, please open an issue on GitHub with the label `question`.

## License

By contributing to TidyBlock, you agree that your contributions will be licensed under the MIT License.
