library(shiny)
library(bslib)
library(rhandsontable)
ui <- page_fillable(
  tags$head(tags$style(HTML("
    /* Force the rhandsontable container to scroll */
    .handsontable { height: calc(100vh - 100px) !important; overflow: hidden !important; }
  "))),
  navset_tab(
    id = "tabs",
    tabPanel("Test", 
      rHandsontableOutput("hot")
    )
  )
)
server <- function(input, output) {
  output$hot <- renderRHandsontable({
    rhandsontable(data.frame(x=1:100, y=runif(100)), stretchH="all", height=600)
  })
}
shinyApp(ui, server)
