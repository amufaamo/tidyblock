#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @noRd
app_ui <- function(request) {
    tagList(
        # Leave this function for adding external resources
        # golem_add_external_resources(),
        page_sidebar(
            theme = bs_theme(preset = "zephyr"),
            title = "TidyBlock",
            sidebar = sidebar(
                width = 300,
                title = "Toolbox",
                mod_import_ui("import_1"),
                hr(),
                "Pipeline Tools",
                actionButton("add_filter", "Filter", icon = icon("filter"), class = "btn-info w-100 mb-2"),
                actionButton("add_select", "Select", icon = icon("check-square"), class = "btn-primary w-100 mb-2"),
                actionButton("add_mutate", "Mutate", icon = icon("calculator"), class = "btn-success w-100 mb-2"),
                actionButton("add_group_by", "Group By", icon = icon("layer-group"), class = "btn-warning w-100 mb-2"),
                actionButton("add_summarize", "Summarize", icon = icon("compress-arrows-alt"), class = "btn-warning w-100 mb-2"),
                actionButton("add_arrange", "Arrange", icon = icon("sort"), class = "btn-primary w-100 mb-2"),
                actionButton("add_join", "Join", icon = icon("object-group"), class = "btn-secondary w-100 mb-2"),
                hr(),
                "Visualization",
                actionButton("add_plot", "Plot", icon = icon("chart-bar"), class = "btn-dark w-100 mb-2")
            ),
            layout_column_wrap(
                width = 1 / 2,
                heights_equal = "row",
                fill = FALSE,

                # Import Data (Fixed at top)
                mod_import_output_ui("import_1"),

                # Sortable Pipeline Area
                div(
                    id = "pipeline_container",
                    class = "d-flex flex-column gap-3 w-100",
                    # 高さと枠線を確保
                    style = "min-height: 200px; padding: 10px; border: 2px dashed #e9ecef; border-radius: 5px;"
                ),

                # Code Preview
                card(
                    full_screen = TRUE,
                    card_header("R Code Preview"),
                    card_body(
                        verbatimTextOutput("code_preview")
                    )
                )
            )
        )
    )
}
