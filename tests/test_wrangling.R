library(testthat)
library(dplyr)
library(tidyr)
library(rlang)

context("Data Wrangling Logic Simulation")

# Simulate filter expression logic from UI
test_that("Filter expressions parse and filter correctly", {
    df <- iris
    filter_expr <- "Species == 'setosa' & Sepal.Length > 5"
    expr <- parse_expr(filter_expr)
    res <- df %>% filter(!!expr)

    expect_true(all(res$Species == "setosa"))
    expect_true(all(res$Sepal.Length > 5))
    expect_equal(nrow(res), 22)
})

# Simulate mutate logic from UI
test_that("Mutate expressions parse and update correctly", {
    df <- data.frame(a = 1:5)
    mutate_expr <- "a * 2"
    expr <- parse_expr(mutate_expr)

    res <- df %>% mutate(b = !!expr)
    expect_equal(res$b, c(2, 4, 6, 8, 10))

    # Stringr / Forcats Simulation
    library(stringr)
    df2 <- data.frame(str = c("apple", "banana"))
    res2 <- df2 %>% mutate(str_new = !!parse_expr("str_replace(str, 'a', 'x')"))
    expect_equal(res2$str_new, c("xpple", "bxnana"))
})

# Simulate Distinct logic
test_that("Distinct function applies correctly", {
    df <- data.frame(id = c(1, 1, 2), val = c("a", "b", "c"))

    # Without .keep_all
    res1 <- df %>% distinct(id)
    expect_equal(nrow(res1), 2)
    expect_equal(names(res1), "id")

    # With .keep_all (Default UI behavior)
    res2 <- df %>% distinct(id, .keep_all = TRUE)
    expect_equal(nrow(res2), 2)
    expect_true("val" %in% names(res2))
    expect_equal(res2$val, c("a", "c"))
})

# Simulate Pivot Longer logic
test_that("Pivot Longer transforms Wide to Long format", {
    df <- data.frame(id = 1:2, v1 = c(10, 20), v2 = c(30, 40))

    res <- df %>% pivot_longer(cols = c(v1, v2), names_to = "name", values_to = "value")
    expect_equal(nrow(res), 4)
    expect_equal(res$name, c("v1", "v2", "v1", "v2"))
    expect_equal(res$value, c(10, 30, 20, 40))
})

# Simulate Pivot Wider logic
test_that("Pivot Wider transforms Long to Wide format", {
    df <- data.frame(id = c(1, 1, 2, 2), name = c("A", "B", "A", "B"), value = c(10, 20, 30, 40))

    res <- df %>% pivot_wider(id_cols = id, names_from = name, values_from = value)
    expect_equal(nrow(res), 2)
    expect_true(all(c("A", "B") %in% names(res)))
    expect_equal(res$A, c(10, 30))
})
