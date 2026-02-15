#' Arrange UI Function
#'
#' @noRd
#' @importFrom shiny NS tagList selectInput checkboxInput actionButton icon
#' @importFrom bslib card card_header card_body
#' @importFrom shinyjqui jqui_resizable
mod_arrange_ui <- function(id) {
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
                        "Arrange",
                        actionButton(ns("remove_ui"), "", icon = icon("trash"), class = "btn-danger btn-sm float-end", style = "margin-left: 10px;"),
                        span(class = "float-end", icon("sort"))
                    )
                ),
                card_body(
                    selectInput(ns("col"), "Sort By", choices = NULL),
                    checkboxInput(ns("desc"), "Descending", value = FALSE)
                )
            )
        )
    )
}

#' Arrange Server Function
#'
#' @noRd
mod_arrange_server <- function(id, state) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        observe({
            data_src <- if (!is.null(state$last_valid_df)) state$last_valid_df else state$raw_data
            req(data_src)
            updateSelectInput(session, "col", choices = names(data_src))
        })

        observeEvent(input$remove_ui, {
            removeUI(selector = paste0("#", id))
            state$pipeline[[id]] <- NULL
            state$pipeline_code[[id]] <- NULL
        })

        return(reactive({
            if (!shiny::isTruthy(input$col)) {
                return(NULL)
            }
            val <- if (input$desc) glue::glue("desc(`{input$col}`)") else glue::glue("`{input$col}`")
            glue::glue("arrange({val})")
        }))
    })
}
