#' Summarize UI Function
#'
#' @noRd
#' @importFrom shiny NS tagList selectInput textInput uiOutput actionButton icon
#' @importFrom bslib card card_header card_body
#' @importFrom shinyjqui jqui_resizable
mod_summarize_ui <- function(id) {
    ns <- NS(id)
    div(
        id = id,
        class = "module-card",
        jqui_resizable(
            card(
                full_screen = TRUE,
                class = "mb-3",
                card_header(
                    class = "bg-warning text-dark",
                    div(
                        "Summarize",
                        actionButton(ns("remove_ui"), "", icon = icon("trash"), class = "btn-danger btn-sm float-end", style = "margin-left: 10px;"),
                        span(class = "float-end", icon("compress-arrows-alt"))
                    )
                ),
                card_body(
                    textInput(ns("new_col"), "New Column Name", placeholder = "mean_val"),
                    selectInput(ns("fun"), "Function",
                        choices = c("mean", "sum", "median", "sd", "min", "max", "n", "n_distinct")
                    ),
                    selectInput(ns("var"), "Variable", choices = NULL),
                    hr(),
                    checkboxInput(ns("add_sec"), "Add Secondary Statistic (e.g. SD)", value = FALSE),
                    conditionalPanel(
                        condition = paste0("input['", ns("add_sec"), "'] == true"),
                        textInput(ns("sec_col"), "Second Column Name", placeholder = "sd_val"),
                        selectInput(ns("sec_fun"), "Second Function",
                            choices = c("sd", "mean", "median", "sum", "min", "max", "n")
                        ),
                        selectInput(ns("sec_var"), "Second Variable", choices = NULL)
                    ),
                    helpText("Creates: new_col = fun(var)")
                )
            )
        )
    )
}

#' Summarize Server Function
#'
#' @noRd
mod_summarize_server <- function(id, state) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        observe({
            # Try to get upstream columns for this specific module
            # If not available (first run), fall back to raw_data or last_valid
            up_cols <- state$upstream_cols[[id]]

            choices <- if (!is.null(up_cols)) {
                up_cols
            } else if (!is.null(state$last_valid_df)) {
                names(state$last_valid_df)
            } else {
                names(state$raw_data)
            }

            req(choices)
            # Update choices but prioritize keeping current selection
            updateSelectInput(session, "var", choices = choices, selected = input$var)
            updateSelectInput(session, "sec_var", choices = choices, selected = input$sec_var)
        })

        observeEvent(input$remove_ui, {
            removeUI(selector = paste0("#", id))
            state$pipeline[[id]] <- NULL
            state$pipeline_code[[id]] <- NULL
        })

        # Validator for numeric functions (merged for both inputs)
        observe({
            req(input$fun, input$var)
            # Get current data context
            data_src <- if (!is.null(state$last_valid_df)) state$last_valid_df else state$raw_data
            req(data_src)

            numeric_funs <- c("mean", "sum", "median", "sd", "min", "max")

            check_numeric <- function(fun, var, label) {
                if (fun %in% numeric_funs && var %in% names(data_src)) {
                    col_data <- data_src[[var]]
                    if (!is.numeric(col_data)) {
                        showNotification(
                            paste("Warning: Column '", var, "' is not numeric. '", fun, "' may return NA."),
                            type = "warning", duration = 5, id = paste0("warn_", id, "_", label)
                        )
                    } else {
                        removeNotification(paste0("warn_", id, "_", label))
                    }
                }
            }

            check_numeric(input$fun, input$var, "prim")
            if (isTruthy(input$add_sec) && isTruthy(input$sec_fun) && isTruthy(input$sec_var)) {
                check_numeric(input$sec_fun, input$sec_var, "sec")
            }
        })

        return(reactive({
            # Return NULL if inputs are not ready
            if (!shiny::isTruthy(input$new_col) || !shiny::isTruthy(input$fun)) {
                return(NULL)
            }

            # Primary Code
            code1 <- if (input$fun == "n") {
                glue::glue("`{input$new_col}` = n()")
            } else {
                if (!shiny::isTruthy(input$var)) {
                    return(NULL)
                }
                glue::glue("`{input$new_col}` = {input$fun}(`{input$var}`)") # Added backticks
            }

            # Secondary Code
            code2 <- NULL
            if (isTruthy(input$add_sec) && isTruthy(input$sec_col) && isTruthy(input$sec_fun)) {
                if (input$sec_fun == "n") {
                    code2 <- glue::glue("`{input$sec_col}` = n()")
                } else if (isTruthy(input$sec_var)) {
                    code2 <- glue::glue("`{input$sec_col}` = {input$sec_fun}(`{input$sec_var}`)") # Added backticks
                }
            }

            args <- paste(c(code1, code2), collapse = ", ")
            glue::glue("summarize({args}, .groups = 'drop')")
        }))
    })
}
