library(shiny)
library(bslib)
ui <- page_navbar(
  navset_tab(id = "tabs", nav_panel("Empty", "Nothing here yet")),
  actionButton("add", "Add Tab")
)
server <- function(input, output) {
  observeEvent(input$add, {
    nav_append(id = "tabs", nav = nav_panel("New", "A new tab!"), select = TRUE)
  })
}
# Run purely to see if syntax is valid
