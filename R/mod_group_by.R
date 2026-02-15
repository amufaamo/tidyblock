#' Group By UI Function
#'
#' @noRd
#' @importFrom shiny NS tagList selectInput actionButton icon uiOutput
#' @importFrom bslib card card_header card_body
#' @importFrom shinyjqui jqui_resizable
mod_group_by_ui <- function(id) {
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
                        "Group By",
                        actionButton(ns("remove_ui"), "", icon = icon("trash"), class = "btn-danger btn-sm float-end", style = "margin-left: 10px;"),
                        span(class = "float-end", icon("layer-group"))
                    )
                ),
                card_body(
                    selectInput(ns("cols"), "Group By", choices = NULL, multiple = TRUE)
                )
            )
        )
    )
}

#' Group By Server Function
#'
#' @noRd
mod_group_by_server <- function(id, state) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        observe({
            # Try to get upstream columns for this specific module
            up_cols <- state$upstream_cols[[id]]

            choices <- if (!is.null(up_cols)) {
                up_cols
            } else if (!is.null(state$last_valid_df)) {
                names(state$last_valid_df)
            } else {
                names(state$raw_data)
            }

            req(choices)
            # Update choices but keep selection if possible (updateSelectInput behavior)
            updateSelectInput(session, "cols", choices = choices, selected = input$cols)
        })

        observeEvent(input$remove_ui, {
            removeUI(selector = paste0("#", id))
            state$pipeline[[id]] <- NULL
            state$pipeline_code[[id]] <- NULL
        })

        return(reactive({
            if (!shiny::isTruthy(input$cols)) {
                return(NULL)
            }
            cols_str <- paste(paste0("`", input$cols, "`"), collapse = ", ")
            glue::glue("group_by({cols_str})")
        }))
    })
}
