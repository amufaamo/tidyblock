library(shiny)
library(bslib)
library(rhandsontable)
ui <- page_fillable(
  navset_tab(
    id = "tabs",
    tabPanel("Test", 
      # Handsontable stretching demo. Using explicit style to restrict size
      div(
        style = "height: 600px; width: 100%; overflow: hidden;",
        rHandsontableOutput("hot")
      )
    )
  )
)
server <- function(input, output) {
  output$hot <- renderRHandsontable({
    rhandsontable(data.frame(x=1:100, y=runif(100)), stretchH="all", height=600)
  })
}
shinyApp(ui, server)
