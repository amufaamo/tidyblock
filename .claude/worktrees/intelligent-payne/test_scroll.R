library(shiny)
library(bslib)
library(rhandsontable)
ui <- page_fillable(
  navset_tab(
    id = "tabs",
    tabPanel("Test", 
      # Handsontable stretching demo v2
      div(class="d-flex flex-column", style="height: calc(100vh - 50px);",
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
