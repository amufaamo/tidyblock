pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)
library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(shinyjqui)
# library(shinyAce) # Uncomment if shinyAce functions are used directly in app.R

shiny::shinyApp(
    ui = app_ui,
    server = app_server
)
