library(shiny)
library(bslib)
ui <- page_fillable(
  theme = bs_theme(version = 5),
  tags$head(tags$style(".spreadsheet-menu { padding: 4px 12px; border: none; background: transparent; } .spreadsheet-menu:hover { background-color: #e9ecef; }")),
  div(class = "d-flex gap-1",
    div(class = "dropdown",
      tags$button("File", class = "spreadsheet-menu", `data-bs-toggle` = "dropdown"),
      tags$ul(class = "dropdown-menu",
        tags$li(actionLink("load_iris", "Load iris", class="dropdown-item")),
        tags$li(tags$div(class="px-3", "Test Static Item"))
      )
    ),
    div(class = "dropdown",
      tags$button("Data", class = "spreadsheet-menu", `data-bs-toggle` = "dropdown"),
      tags$ul(class = "dropdown-menu",
        tags$li(actionLink("menu_filter", "Filter...", class="dropdown-item")),
        tags$li(actionLink("menu_mutate", "Mutate...", class="dropdown-item"))
      )
    )
  ),
  div(class = "flex-grow-1 p-3", "Main Application Content here.")
)
server <- function(input, output, session) {
  observeEvent(input$load_iris, { print("Loaded Iris!") })
  observeEvent(input$menu_filter, { print("Filter clicked!") })
}
shinyApp(ui, server)
