library(testthat)
library(readr)
library(tools)

context("File Import Logic")

test_that("CSV with comments starting with # is read correctly", {
    # Create a temporary CSV with comments
    tmp_csv <- tempfile(fileext = ".csv")
    writeLines(c(
        "# This is a comment line",
        "# This is another comment",
        "col1,col2",
        "1,2",
        "3,4"
    ), tmp_csv)

    # Read the CSV with comment = "#"
    df <- readr::read_csv(tmp_csv, comment = "#", show_col_types = FALSE)

    # Verify columns and rows
    expect_equal(names(df), c("col1", "col2"))
    expect_equal(nrow(df), 2)
    expect_equal(df$col1, c(1, 3))
    expect_equal(df$col2, c(2, 4))

    # Clean up
    unlink(tmp_csv)
})

test_that("TSV with comments starting with # is read correctly", {
    # Create a temporary TSV with comments
    tmp_tsv <- tempfile(fileext = ".tsv")
    writeLines(c(
        "# This is a TSV comment",
        "col1\tcol2",
        "1\t2",
        "3\t4"
    ), tmp_tsv)

    # Read the TSV with comment = "#"
    df <- readr::read_tsv(tmp_tsv, comment = "#", show_col_types = FALSE)

    # Verify columns and rows
    expect_equal(names(df), c("col1", "col2"))
    expect_equal(nrow(df), 2)
    expect_equal(df$col1, c(1, 3))
    expect_equal(df$col2, c(2, 4))

    # Clean up
    unlink(tmp_tsv)
})
