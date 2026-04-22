#' Code Generation Utilities
#'
#' @description Helper functions to generate tidyverse code from module inputs.
#' @noRd
#' @importFrom rlang expr expr_text sym
#' @importFrom glue glue

#' Generate filter code
#' @param data_name Name of the dataset (usually "data")
#' @param col Column name
#' @param operator Logical operator (e.g., "==", ">")
#' @param val Value to compare against
generate_filter_code <- function(col, operator, val) {
    if (is.null(col) || is.null(operator) || is.null(val)) {
        return(NULL)
    }

    # Handle string values
    if (is.character(val) && !is.numeric(val)) {
        val <- paste0("'", val, "'")
    }

    glue::glue("filter({col} {operator} {val})")
}

#' Generate select code
#' @param cols Vector of column names
generate_select_code <- function(cols) {
    if (is.null(cols) || length(cols) == 0) {
        return(NULL)
    }
    cols_str <- paste(paste0("`", cols, "`"), collapse = ", ")
    glue::glue("select({cols_str})")
}

#' Generate mutate code
#' @param new_col Name of the new column
#' @param expression Expression string
generate_mutate_code <- function(new_col, expression) {
    if (is.null(new_col) || new_col == "" || is.null(expression) || expression == "") {
        return(NULL)
    }
    glue::glue("mutate(`{new_col}` = {expression})")
}

#' Construct full pipeline code
#' @param raw_data_name Name of the starting dataframe
#' @param steps List of code strings from modules
construct_pipeline <- function(raw_data_name, steps) {
    if (length(steps) == 0) {
        return(raw_data_name)
    }

    # Remove NULLs
    steps <- steps[!sapply(steps, is.null)]
    if (length(steps) == 0) {
        return(raw_data_name)
    }

    pipeline <- paste(steps, collapse = " |>\n  ")
    paste0(raw_data_name, " |>\n  ", pipeline)
}
