library(shiny)
library(bslib)
ui <- page_navbar(
  navset_tab(
    id = "tabs",
    nav_panel("A", "This is A")
  ),
  actionButton("btn", "Add B")
)
server <- function(input, output, session) {
  observeEvent(input$btn, {
    nav_append("tabs", nav_panel("B", "This is B"), select = TRUE)
    cat("Tab appended!\n")
  })
}
shinyApp(ui, server)
