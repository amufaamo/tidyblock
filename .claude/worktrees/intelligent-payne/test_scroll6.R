library(shiny)
library(bslib)
library(rhandsontable)
ui <- page_navbar(
  title = "Test",
  fillable = TRUE,
  nav_panel("Data",
    tags$head(tags$style(HTML("
      /* Use fixed height strictly and let rhandsontable handle inside scrolling */
      .handsontable { overflow: hidden !important; }
    "))),
    div(style = "height: 80vh;", 
      rHandsontableOutput("hot", height = "100%")
    )
  )
)
server <- function(input, output) {
  output$hot <- renderRHandsontable({
    rhandsontable(data.frame(x=1:100, y=runif(100)), stretchH="all")
  })
}
shinyApp(ui, server)
