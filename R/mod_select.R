#' Select UI Function
#'
#' @noRd
#' @importFrom shiny NS tagList selectInput uiOutput actionButton icon
#' @importFrom bslib card card_header card_body
#' @importFrom shinyjqui jqui_resizable
mod_select_ui <- function(id) {
    ns <- NS(id)
    div(
        id = id,
        class = "module-card",
        jqui_resizable(
            card(
                full_screen = TRUE,
                class = "mb-3",
                card_header(
                    class = "bg-primary text-white",
                    div(
                        "Select",
                        actionButton(ns("remove_ui"), "", icon = icon("trash"), class = "btn-danger btn-sm float-end", style = "margin-left: 10px;"),
                        span(class = "float-end", icon("check-square"))
                    )
                ),
                card_body(
                    selectInput(ns("cols"), "Columns", choices = NULL, multiple = TRUE)
                )
            )
        )
    )
}

#' Select Server Function
#'
#' @noRd
mod_select_server <- function(id, state) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        observe({
            data_src <- if (!is.null(state$last_valid_df)) state$last_valid_df else state$raw_data
            req(data_src)
            updateSelectInput(session, "cols", choices = names(data_src), selected = input$cols)
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
            generate_select_code(input$cols)
        }))
    })
}
