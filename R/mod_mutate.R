#' Mutate UI Function
#'
#' @noRd
#' @importFrom shiny NS tagList textInput selectInput actionButton icon uiOutput
#' @importFrom bslib card card_header card_body accordion accordion_panel
#' @importFrom shinyjqui jqui_resizable
mod_mutate_ui <- function(id) {
    ns <- NS(id)
    div(
        id = id,
        class = "module-card",
        jqui_resizable(
            card(
                full_screen = TRUE,
                class = "mb-3",
                card_header(
                    class = "bg-success text-white",
                    div(
                        "Mutate",
                        actionButton(ns("remove_ui"), "", icon = icon("trash"), class = "btn-danger btn-sm float-end", style = "margin-left: 10px;"),
                        span(class = "float-end", icon("calculator"))
                    )
                ),
                card_body(
                    textInput(ns("new_col"), "New Column Name", placeholder = "new_var"),
                    textInput(ns("expr"), "Expression", placeholder = "Sepal.Length * 10"),
                    accordion(
                        open = FALSE,
                        accordion_panel(
                            "Helpers",
                            selectInput(ns("helper_type"), "Type", choices = c("Arithmetic", "String (stringr)", "Factor (forcats)")),
                            uiOutput(ns("helper_ui")),
                            actionButton(ns("insert"), "Insert Template", class = "btn-sm btn-outline-secondary")
                        )
                    )
                )
            )
        )
    )
}

#' Mutate Server Function
#'
#' @noRd
mod_mutate_server <- function(id, state) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        output$helper_ui <- renderUI({
            type <- input$helper_type
            if (type == "String (stringr)") {
                selectInput(ns("template"), "Template",
                    choices = c(
                        "Detect Pattern" = "str_detect(col, 'pattern')",
                        "Replace Pattern" = "str_replace(col, 'pattern', 'replacement')",
                        "Extract Pattern" = "str_extract(col, 'pattern')"
                    )
                )
            } else if (type == "Factor (forcats)") {
                selectInput(ns("template"), "Template",
                    choices = c(
                        "Reorder Factor" = "fct_reorder(fct_col, num_col)",
                        "Lump Rare" = "fct_lump(col, n = 5)"
                    )
                )
            } else {
                # Arithmetic
                selectInput(ns("template"), "Template",
                    choices = c(
                        "Log" = "log(col)",
                        "Round" = "round(col, 2)",
                        "Case When" = "case_when(cond ~ val, TRUE ~ other)"
                    )
                )
            }
        })

        observeEvent(input$insert, {
            req(input$template)
            updateTextInput(session, "expr", value = input$template)
        })

        observeEvent(input$remove_ui, {
            removeUI(selector = paste0("#", id))
            state$pipeline[[id]] <- NULL
            state$pipeline_code[[id]] <- NULL
        })

        return(reactive({
            if (!shiny::isTruthy(input$new_col) || !shiny::isTruthy(input$expr)) {
                return(NULL)
            }
            generate_mutate_code(input$new_col, input$expr)
        }))
    })
}
