library(shiny)
library(bslib)
ui <- page_fillable(
  actionButton("add", "Add Tab"),
  navset_tab(id = "tabs", nav_panel("Welcome", "Hello"))
)
server <- function(input, output) {
  observeEvent(input$add, {
    cat("Adding tab!\n")
    nav_append(id = "tabs", nav = nav_panel("New", "A new tab!"), select = TRUE)
  })
}
# Can't easily test the frontend from here, but I can check if it throws an error.
# Let's run it headless and simulate a click.
shiny::testServer(server, {
  session$setInputs(add = 1)
})
