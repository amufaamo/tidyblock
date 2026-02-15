#' Import UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList fileInput
#' @importFrom bslib card card_header card_body
#' @importFrom shinyjqui jqui_resizable
mod_import_ui <- function(id) {
    ns <- NS(id)
    tagList(
        fileInput(ns("file"), "Upload CSV", accept = ".csv"),
        actionButton(ns("demo"), "Load Demo Data (Iris)", icon = icon("table"), class = "btn-outline-secondary w-100")
    )
}

#' Import Output UI Function
#' @noRd
mod_import_output_ui <- function(id) {
    ns <- NS(id)
    jqui_resizable(
        card(
            full_screen = TRUE,
            card_header("Data Preview / Result"),
            card_body(
                uiOutput(ns("result_ui"))
            )
        )
    )
}

#' Import Server Function
#'
#' @noRd
#' @importFrom readr read_csv
#' @importFrom DT renderDT datatable DTOutput
#' @importFrom shiny renderPlot plotOutput
mod_import_server <- function(id, state) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        observeEvent(input$file, {
            message("[DEBUG] File input triggered")
            req(input$file)
            message("[DEBUG] File detected: ", input$file$name)
            tryCatch(
                {
                    # Iterate over uploaded files (if multiple) or just single
                    # For now assume one file upload at a time adds to the list
                    name <- tools::file_path_sans_ext(input$file$name)
                    # Clean name to be valid variable name
                    name <- make.names(name)
                    message("[DEBUG] Dataset name: ", name)

                    df <- readr::read_csv(input$file$datapath)
                    message("[DEBUG] CSV read successfully, rows: ", nrow(df), ", cols: ", ncol(df))

                    if (is.null(state$datasets)) state$datasets <- list()
                    state$datasets[[name]] <- df
                    message("[DEBUG] Dataset added to state$datasets")

                    # If this is the first dataset or raw_data is NULL, set it as active
                    if (is.null(state$raw_data)) {
                        state$raw_data <- df
                        state$last_valid_df <- df
                        state$active_dataset <- name
                        message("[DEBUG] Set as active dataset: ", name)
                    }

                    showNotification(paste("Loaded dataset:", name), type = "message")
                    message("[DEBUG] File import completed successfully")
                },
                error = function(e) {
                    message("[ERROR] Failed to read file: ", e$message)
                    showNotification(paste("Error reading file:", e$message), type = "error")
                }
            )
        })

        observeEvent(input$demo, {
            message("[DEBUG] Demo data button clicked")
            tryCatch(
                {
                    if (is.null(state$datasets)) state$datasets <- list()
                    state$datasets[["iris"]] <- iris
                    state$raw_data <- iris
                    state$last_valid_df <- iris
                    state$active_dataset <- "iris"
                    message("[DEBUG] Iris dataset loaded successfully")
                    message("[DEBUG] state$raw_data set: ", !is.null(state$raw_data))
                    message("[DEBUG] state$active_dataset: ", state$active_dataset)
                    showNotification("Loaded demo data (iris)", type = "message")
                },
                error = function(e) {
                    message("[ERROR] Failed to load demo data: ", e$message)
                    showNotification(paste("Error loading demo data:", e$message), type = "error")
                }
            )
        })

        output$result_ui <- renderUI({
            d <- if (!is.null(state$current_data)) state$current_data else state$raw_data

            if (inherits(d, "gg") || inherits(d, "ggplot")) {
                plotOutput(ns("plot"))
            } else {
                DT::DTOutput(ns("table"))
            }
        })

        output$table <- DT::renderDT(
            {
                d <- if (!is.null(state$current_data)) state$current_data else state$raw_data
                req(d)
                if (inherits(d, "data.frame")) {
                    DT::datatable(d, options = list(pageLength = 5, scrollX = TRUE))
                } else {
                    NULL
                }
            },
            server = TRUE
        )

        output$plot <- renderPlot({
            d <- if (!is.null(state$current_data)) state$current_data else state$raw_data
            req(d)
            if (inherits(d, "gg") || inherits(d, "ggplot")) {
                d
            }
        })
    })
}
