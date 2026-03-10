library(shiny)
library(bslib)
library(rhandsontable)
ui <- page_fillable(
  navset_tab(
    id = "tabs",
    tabPanel("Test", 
      # Handsontable stretching demo v3 - simple approach
      tags$div(
        style = "position: absolute; top: 50px; bottom: 0; left: 0; right: 0; overflow: auto;",
        rHandsontableOutput("hot", height = "100%")
      )
    )
  )
)
server <- function(input, output) {
  output$hot <- renderRHandsontable({
    rhandsontable(data.frame(x=1:100, y=runif(100)), stretchH="all")
  })
}
shinyApp(ui, server)
