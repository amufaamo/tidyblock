library(shiny)
library(bslib)
library(rhandsontable)
ui <- page_fillable(
  navset_tab(
    id = "tabs",
    tabPanel("Test", 
      # Setting vh explicitly inside the rhandsontable call might be the only way.
      rHandsontableOutput("hot")
    )
  )
)
server <- function(input, output) {
  output$hot <- renderRHandsontable({
    # We can pass an absolute pixel height directly to rhandsontable
    rhandsontable(data.frame(x=1:100, y=runif(100)), stretchH="all", height=600)
  })
}
shinyApp(ui, server)
