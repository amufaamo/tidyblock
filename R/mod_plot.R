#' Plot UI Function
#'
#' @noRd
#' @importFrom shiny NS tagList selectInput actionButton icon
#' @importFrom bslib card card_header card_body
#' @importFrom shinyjqui jqui_resizable
mod_plot_ui <- function(id) {
    ns <- NS(id)
    div(
        id = id,
        class = "module-card",
        jqui_resizable(
            card(
                full_screen = TRUE,
                class = "mb-3",
                card_header(
                    class = "bg-dark text-white",
                    div(
                        "Plot",
                        actionButton(ns("remove_ui"), "", icon = icon("trash"), class = "btn-danger btn-sm float-end", style = "margin-left: 10px;"),
                        span(class = "float-end", icon("chart-bar"))
                    )
                ),
                card_body(
                    selectInput(ns("geom"), "Geometry",
                        choices = c(
                            "Point" = "geom_point",
                            "Bar" = "geom_bar",
                            "Line" = "geom_line",
                            "Boxplot" = "geom_boxplot"
                        )
                    ),
                    selectInput(ns("x_col"), "X Axis", choices = NULL),
                    selectInput(ns("y_col"), "Y Axis", choices = NULL),
                    selectInput(ns("color_col"), "Color (Optional)", choices = NULL),
                    hr(),
                    checkboxInput(ns("show_error"), "Show Error Bars", value = FALSE),
                    conditionalPanel(
                        condition = paste0("input['", ns("show_error"), "'] == true"),
                        selectInput(ns("ymin_col"), "Y Min", choices = NULL),
                        selectInput(ns("ymax_col"), "Y Max", choices = NULL)
                    ),
                    selectInput(ns("theme"), "Theme",
                        choices = c(
                            "Gray (Default)" = "theme_gray",
                            "Black & White" = "theme_bw",
                            "Linedraw" = "theme_linedraw",
                            "Light" = "theme_light",
                            "Dark" = "theme_dark",
                            "Minimal" = "theme_minimal",
                            "Classic" = "theme_classic",
                            "Void" = "theme_void"
                        )
                    )
                )
            )
        )
    )
}

#' Plot Server Function
#'
#' @noRd
mod_plot_server <- function(id, state) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        observe({
            # Try to get upstream columns for this specific module
            up_cols <- state$upstream_cols[[id]]

            vars <- if (!is.null(up_cols)) {
                up_cols
            } else if (!is.null(state$last_valid_df)) {
                names(state$last_valid_df)
            } else {
                names(state$raw_data)
            }

            req(vars)
            # Add "None" for color
            vars_opt <- c("None", vars)

            updateSelectInput(session, "x_col", choices = vars, selected = input$x_col)
            updateSelectInput(session, "y_col", choices = vars, selected = input$y_col)
            updateSelectInput(session, "color_col", choices = vars_opt, selected = input$color_col)

            updateSelectInput(session, "ymin_col", choices = vars, selected = input$ymin_col)
            updateSelectInput(session, "ymax_col", choices = vars, selected = input$ymax_col)
        })

        observeEvent(input$remove_ui, {
            removeUI(selector = paste0("#", id))
            state$pipeline[[id]] <- NULL
            state$pipeline_code[[id]] <- NULL
        })

        return(reactive({
            if (!shiny::isTruthy(input$geom) || !shiny::isTruthy(input$x_col)) {
                return(NULL)
            }

            aes_args <- list(glue::glue("x = `{input$x_col}`"))

            if (!is.null(input$y_col) && input$y_col != "") {
                aes_args <- c(aes_args, glue::glue("y = `{input$y_col}`"))
            }

            if (!is.null(input$color_col) && input$color_col != "None" && input$color_col != "") {
                aes_args <- c(aes_args, glue::glue("color = `{input$color_col}`"))
                aes_args <- c(aes_args, glue::glue("fill = `{input$color_col}`")) # Often bar need fill
            }

            aes_str <- paste(aes_args, collapse = ", ")

            theme_call <- if (!is.null(input$theme)) paste0(" + ", input$theme, "()") else ""

            # Check if geom_bar is selected but Y is present (use geom_col instead)
            geom_cmd <- input$geom
            if (geom_cmd == "geom_bar" && !is.null(input$y_col) && input$y_col != "") {
                geom_cmd <- "geom_col"
            }

            base_plot <- glue::glue("ggplot(aes({aes_str})) + {geom_cmd}()")

            # Add Error Bars if requested
            if (isTruthy(input$show_error) && isTruthy(input$ymin_col) && isTruthy(input$ymax_col)) {
                base_plot <- paste0(base_plot, glue::glue(" + geom_errorbar(aes(ymin = `{input$ymin_col}`, ymax = `{input$ymax_col}`), width = 0.2)"))
            }

            paste0(base_plot, theme_call)
        }))
    })
}
