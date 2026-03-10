# test-dplyr_logic.R
library(testthat)
library(dplyr)
library(rlang)

test_that("Filter expressions parse and evaluate correctly", {
  df <- data.frame(a = 1:5, b = letters[1:5])
  
  # Simulate the logic in app.R (parse_expr)
  expr_str <- "a > 2 & b %in% c('c', 'd')"
  expr <- parse_expr(expr_str)
  
  result <- df %>% filter(!!expr)
  
  expect_equal(nrow(result), 2)
  expect_equal(result$a, c(3, 4))
  expect_equal(result$b, c("c", "d"))
})

test_that("Mutate expressions parse and evaluate correctly", {
  df <- data.frame(x = 1:3)
  
  # Simulate mutate
  expr_str <- "x * 2"
  expr <- parse_expr(expr_str)
  
  result <- df %>% mutate(y = !!expr)
  
  expect_true("y" %in% names(result))
  expect_equal(result$y, c(2, 4, 6))
})

test_that("Summarise logic works with dynamic inputs", {
  df <- data.frame(
    group = c("A", "A", "B", "B"),
    value = c(10, 20, 30, 40)
  )
  
  # Simulate group_by and summarise mean
  group_col <- "group"
  sum_col <- sym("value")
  
  result <- df %>%
    group_by(across(all_of(group_col))) %>%
    summarise(mean_val = mean(!!sum_col, na.rm = TRUE), .groups = "drop")
  
  expect_equal(nrow(result), 2)
  expect_equal(result$mean_val, c(15, 35))
})

test_that("Join logic works dynamically", {
  df1 <- data.frame(id = 1:2, val1 = c("A", "B"))
  df2 <- data.frame(id = 1:2, val2 = c("X", "Y"))
  
  # Simulate dynamic join
  join_by <- "id"
  result <- left_join(df1, df2, by = join_by)
  
  expect_equal(ncol(result), 3)
  expect_equal(nrow(result), 2)
  expect_equal(result$val2, c("X", "Y"))
})
