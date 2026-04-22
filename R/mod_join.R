#' Join UI Function
#'
#' @noRd
#' @importFrom shiny NS tagList selectInput selectizeInput actionButton icon
#' @importFrom bslib card card_header card_body
#' @importFrom shinyjqui jqui_resizable
mod_join_ui <- function(id) {
    ns <- NS(id)
    div(
        id = id,
        class = "module-card",
        jqui_resizable(
            card(
                full_screen = TRUE,
                class = "mb-3",
                card_header(
                    class = "bg-secondary text-white",
                    div(
                        "Join",
                        actionButton(ns("remove_ui"), "", icon = icon("trash"), class = "btn-danger btn-sm float-end", style = "margin-left: 10px;"),
                        span(class = "float-end", icon("object-group"))
                    )
                ),
                card_body(
                    selectInput(ns("right_data"), "Right Dataset", choices = NULL),
                    selectInput(ns("type"), "Join Type",
                        choices = c(
                            "Left Join" = "left_join",
                            "Inner Join" = "inner_join",
                            "Right Join" = "right_join",
                            "Full Join" = "full_join"
                        )
                    ),
                    selectizeInput(ns("by"), "Join By (Key)", choices = NULL, multiple = TRUE, options = list(create = TRUE))
                )
            )
        )
    )
}

#' Join Server Function
#'
#' @noRd
mod_join_server <- function(id, state) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        observe({
            req(state$datasets)
            choices <- names(state$datasets)
            updateSelectInput(session, "right_data", choices = choices)
        })

        observe({
            req(state$raw_data)
            # Suggest columns for 'by' from current data
            vars <- names(state$raw_data)

            # If right data is selected, try to find common columns
            common <- vars
            if (!is.null(input$right_data) && input$right_data != "") {
                right_df <- state$datasets[[input$right_data]]
                if (!is.null(right_df)) {
                    right_vars <- names(right_df)
                    common <- intersect(vars, right_vars)
                }
            }

            updateSelectizeInput(session, "by", choices = common, selected = common)
        })

        observeEvent(input$remove_ui, {
            removeUI(selector = paste0("#", id))
            state$pipeline[[id]] <- NULL
            state$pipeline_code[[id]] <- NULL
        })

        return(reactive({
            if (!shiny::isTruthy(input$right_data) || !shiny::isTruthy(input$type)) {
                return(NULL)
            }

            by_clause <- ""
            if (!is.null(input$by) && length(input$by) > 0) {
                # Handle quoted strings for join keys
                keys <- paste0("\"", input$by, "\"")
                by_clause <- glue::glue(", by = c({paste(keys, collapse = ', ')})")
            }

            glue::glue("{input$type}({input$right_data}{by_clause})")
        }))
    })
}
