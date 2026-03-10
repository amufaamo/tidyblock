library(shiny)
library(bslib)
library(rhandsontable)
ui <- page_fillable(
  navset_tab(
    id = "tabs",
    tabPanel("Test", 
      rHandsontableOutput("hot", height = "calc(100vh - 200px)")
    )
  )
)
server <- function(input, output) {
  output$hot <- renderRHandsontable({
    rhandsontable(data.frame(x=1:100, y=1:100, z=1:100), stretchH="all", height=600)
  })
}
shinyApp(ui, server)
