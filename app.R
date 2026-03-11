library(shiny)
library(bslib)
library(readr)
library(readxl)
library(dplyr)
library(rlang)
library(rhandsontable)
library(DT)
library(ggplot2)
library(stringr)
library(forcats)
library(lubridate)
library(tidyr)
library(scales)
# ==============================================================================
# PLOT MODULE
# ==============================================================================
plotTabUI <- function(id, cols) {
  ns <- NS(id)

  geom_choices <- c(
    "None", "geom_point", "geom_line", "geom_histogram", "geom_density",
    "geom_dotplot", "geom_boxplot", "geom_violin", "geom_jitter",
    "geom_col", "geom_bin_2d", "geom_errorbar", "geom_smooth",
    "geom_ribbon", "geom_qq", "geom_text", "geom_label",
    "geom_hline", "geom_vline", "geom_sf"
  )
  stat_choices <- c("default", "identity", "count", "density", "bin", "summary", "boxplot")

  layout_sidebar(
    sidebar = sidebar(
      width = 400,
      title = "Plot Builder",
      accordion(
        id = ns("plot_accordion"),
        multiple = TRUE,
        accordion_panel(
          "1. Aesthetics (Aes)",
          icon = icon("palette"),
          selectInput(ns("x"), "X Axis", choices = c("None", cols)),
          selectInput(ns("y"), "Y Axis", choices = c("None", cols)),
          selectInput(ns("color"), "Color", choices = c("None", cols)),
          selectInput(ns("fill"), "Fill", choices = c("None", cols)),
          selectInput(ns("group"), "Group", choices = c("None", cols)),
          selectInput(ns("size"), "Size", choices = c("None", cols)),
          selectInput(ns("alpha"), "Alpha", choices = c("None", cols)),
          selectInput(ns("shape"), "Shape", choices = c("None", cols)),
          selectInput(ns("linetype"), "Linetype", choices = c("None", cols)),
          selectInput(ns("label"), "Label (geom_text/label)", choices = c("None", cols)),
          textInput(ns("adv_mapping"), "Delayed / Adv. Aes", placeholder = "e.g., y = after_stat(density)")
        ),
        accordion_panel(
          "2. Layers (Geoms & Stats)",
          icon = icon("layer-group"),
          tags$strong("Layer 1 (Base)"),
          selectInput(ns("geom_1"), NULL, choices = geom_choices, selected = "geom_point"),
          selectInput(ns("stat_1"), "Stat override", choices = stat_choices),
          tags$hr(),
          tags$strong("Layer 2"),
          selectInput(ns("geom_2"), NULL, choices = geom_choices, selected = "None"),
          selectInput(ns("stat_2"), "Stat override", choices = stat_choices),
          tags$hr(),
          tags$strong("Layer 3"),
          selectInput(ns("geom_3"), NULL, choices = geom_choices, selected = "None"),
          selectInput(ns("stat_3"), "Stat override", choices = stat_choices),
          tags$hr(),
          tags$strong("Annotation (Static)"),
          numericInput(ns("hline_y"), "geom_hline yintercept", value = NA),
          numericInput(ns("vline_x"), "geom_vline xintercept", value = NA)
        ),
        accordion_panel(
          "3. Scales & Coordinates",
          icon = icon("ruler-combined"),
          selectInput(ns("coord"), "Coordinate System", choices = c("coord_cartesian", "coord_fixed", "coord_polar", "coord_radial", "coord_trans")),
          checkboxInput(ns("scale_x_log10"), "Log10 Transform X Axis", value = FALSE),
          checkboxInput(ns("scale_y_log10"), "Log10 Transform Y Axis", value = FALSE),
          textInput(ns("xlim"), "X Limit (min, max)", placeholder = "e.g., 0, 100"),
          textInput(ns("ylim"), "Y Limit (min, max)", placeholder = "e.g., 0, 100"),
          selectInput(ns("oob"), "Out-of-Bounds Rule", choices = c("scales::censor", "scales::squish", "scales::keep"), selected = "scales::censor"),
          selectInput(ns("color_scale"), "Color/Fill Scale", choices = c(
            "default", "scale_colour_brewer", "scale_colour_viridis_d",
            "scale_colour_viridis_c", "scale_colour_gradient"
          ))
        ),
        accordion_panel(
          "4. Facets",
          icon = icon("table-cells"),
          selectInput(ns("facet_type"), "Facet Type", choices = c("None", "facet_wrap", "facet_grid")),
          selectInput(ns("facet_var1"), "Facet Var 1 (Row/Wrap)", choices = c("None", cols)),
          selectInput(ns("facet_var2"), "Facet Var 2 (Col for grid)", choices = c("None", cols)),
          selectInput(ns("facet_scales"), "Scales", choices = c("fixed", "free", "free_x", "free_y"))
        ),
        accordion_panel(
          "5. Themes & Labels",
          icon = icon("paintbrush"),
          selectInput(ns("theme"), "Base Theme", choices = c("theme_minimal", "theme_bw", "theme_classic", "theme_light", "theme_dark", "theme_void", "theme_grey")),
          sliderInput(ns("base_size"), "Base Font Size", min = 8, max = 24, value = 14),
          tags$hr(),
          tags$strong("Element Control"),
          selectInput(ns("legend_position"), "Legend Position", choices = c("right", "left", "top", "bottom", "none")),
          selectInput(ns("theme_bg"), "Panel Background", choices = c("default", "white", "gray92", "black", "transparent")),
          checkboxInput(ns("theme_grid_major"), "Show Major Grid Lines", value = TRUE),
          checkboxInput(ns("theme_grid_minor"), "Show Minor Grid Lines", value = TRUE),
          tags$hr(),
          textInput(ns("title"), "Plot Title", value = ""),
          textInput(ns("x_label"), "X Axis Label", value = ""),
          textInput(ns("y_label"), "Y Axis Label", value = "")
        )
      )
    ),
    div(
      class = "p-4 h-100 w-100 d-flex flex-column justify-content-center align-items-center bg-white",
      plotOutput(ns("plot"), height = "700px", width = "100%")
    )
  )
}

plotTabServer <- function(id, rv, ds_id, selected_rows) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      df <- rv$datasets[[ds_id]]
      req(df)
      if (!is.null(selected_rows) && length(selected_rows) > 0) {
        df <- df[selected_rows, , drop = FALSE]
      }

      # 1. Base Aesthetics Mapping
      aes_args <- list()
      get_sym_if_valid <- function(val) {
        if (isTruthy(val) && val != "None" && val %in% names(df)) sym(val) else NULL
      }

      if (!is.null(v <- get_sym_if_valid(input$x))) aes_args$x <- v
      if (!is.null(v <- get_sym_if_valid(input$y))) aes_args$y <- v
      if (!is.null(v <- get_sym_if_valid(input$color))) aes_args$color <- v
      if (!is.null(v <- get_sym_if_valid(input$fill))) aes_args$fill <- v
      if (!is.null(v <- get_sym_if_valid(input$group))) aes_args$group <- v
      if (!is.null(v <- get_sym_if_valid(input$size))) aes_args$size <- v
      if (!is.null(v <- get_sym_if_valid(input$alpha))) aes_args$alpha <- v
      if (!is.null(v <- get_sym_if_valid(input$shape))) aes_args$shape <- v
      if (!is.null(v <- get_sym_if_valid(input$linetype))) aes_args$linetype <- v
      if (!is.null(v <- get_sym_if_valid(input$label))) aes_args$label <- v

      # Advanced (Delayed) Mapping support
      if (isTruthy(input$adv_mapping)) {
        tryCatch(
          {
            adv_exprs <- rlang::parse_exprs(paste0("list(", input$adv_mapping, ")"))[[1]]
            adv_args <- as.list(adv_exprs)[-1]
            for (n in names(adv_args)) aes_args[[n]] <- adv_args[[n]]
          },
          error = function(e) {
            warning("Invalid adv_mapping expression")
          }
        )
      }

      if (length(aes_args) == 0) {
        return(ggplot() +
          theme_void() +
          ggtitle("Please specify at least X or Y mapping"))
      }

      p <- ggplot(df, do.call(aes, aes_args))

      # 2. Layers (Geoms & Stats)
      add_layer <- function(p, geom_name, stat_override) {
        if (isTruthy(geom_name) && geom_name != "None") {
          tryCatch(
            {
              geom_func <- get(geom_name, asNamespace("ggplot2"))
              args <- list()
              if (stat_override != "default") {
                args$stat <- stat_override
              }
              if (geom_name == "geom_hline" && !is.na(input$hline_y)) args$yintercept <- input$hline_y
              if (geom_name == "geom_vline" && !is.na(input$vline_x)) args$xintercept <- input$vline_x

              p <<- p + do.call(geom_func, args)
            },
            error = function(e) {
              warning(paste("Could not add", geom_name))
            }
          )
        }
      }

      add_layer(p, input$geom_1, input$stat_1)
      add_layer(p, input$geom_2, input$stat_2)
      add_layer(p, input$geom_3, input$stat_3)

      # 3. Scales & Coordinates
      oob_func <- get(sub("scales::", "", input$oob), asNamespace("scales"))
      lim_x <- if (isTruthy(input$xlim)) as.numeric(unlist(strsplit(input$xlim, "[, ]+"))) else NULL
      lim_y <- if (isTruthy(input$ylim)) as.numeric(unlist(strsplit(input$ylim, "[, ]+"))) else NULL

      if (length(lim_x) == 2) {
        if (input$scale_x_log10) {
          p <- p + scale_x_log10(limits = lim_x, oob = oob_func)
        } else {
          p <- p + scale_x_continuous(limits = lim_x, oob = oob_func)
        }
      } else if (input$scale_x_log10) {
        p <- p + scale_x_log10()
      }

      if (length(lim_y) == 2) {
        if (input$scale_y_log10) {
          p <- p + scale_y_log10(limits = lim_y, oob = oob_func)
        } else {
          p <- p + scale_y_continuous(limits = lim_y, oob = oob_func)
        }
      } else if (input$scale_y_log10) {
        p <- p + scale_y_log10()
      }

      if (isTruthy(input$coord) && input$coord != "coord_cartesian") {
        tryCatch(
          {
            coord_func <- get(input$coord, asNamespace("ggplot2"))
            p <- p + coord_func()
          },
          error = function(e) {
            warning("Coord function not found")
          }
        )
      }

      if (input$color_scale != "default") {
        tryCatch(
          {
            if (input$color_scale == "scale_colour_brewer") {
              p <- p + scale_colour_brewer() + scale_fill_brewer()
            } else if (input$color_scale == "scale_colour_viridis_d") {
              p <- p + scale_colour_viridis_d() + scale_fill_viridis_d()
            } else if (input$color_scale == "scale_colour_viridis_c") {
              p <- p + scale_colour_viridis_c() + scale_fill_viridis_c()
            } else if (input$color_scale == "scale_colour_gradient") {
              p <- p + scale_colour_gradient() + scale_fill_gradient()
            }
          },
          error = function(e) {
            warning("Scale function issue")
          }
        )
      }

      # 4. Facets
      if (input$facet_type != "None") {
        f_scales <- input$facet_scales
        var1 <- get_sym_if_valid(input$facet_var1)
        var2 <- get_sym_if_valid(input$facet_var2)

        tryCatch(
          {
            if (input$facet_type == "facet_wrap" && !is.null(var1)) {
              p <- p + facet_wrap(vars(!!var1), scales = f_scales)
            } else if (input$facet_type == "facet_grid") {
              if (!is.null(var1) && !is.null(var2)) {
                p <- p + facet_grid(rows = vars(!!var1), cols = vars(!!var2), scales = f_scales)
              } else if (!is.null(var1)) {
                p <- p + facet_grid(rows = vars(!!var1), scales = f_scales)
              } else if (!is.null(var2)) {
                p <- p + facet_grid(cols = vars(!!var2), scales = f_scales)
              }
            }
          },
          error = function(e) {
            warning("Facet issue")
          }
        )
      }

      # 5. Themes & Labels
      theme_func <- get(input$theme, asNamespace("ggplot2"))
      p <- p + theme_func(base_size = input$base_size)

      theme_args <- list()
      if (input$legend_position != "right") theme_args$legend.position <- input$legend_position
      if (input$theme_bg != "default") theme_args$panel.background <- element_rect(fill = input$theme_bg, colour = NA)
      if (!input$theme_grid_major) theme_args$panel.grid.major <- element_blank()
      if (!input$theme_grid_minor) theme_args$panel.grid.minor <- element_blank()

      if (length(theme_args) > 0) {
        p <- p + do.call(theme, theme_args)
      }

      if (isTruthy(input$title)) p <- p + ggtitle(input$title)
      if (isTruthy(input$x_label)) p <- p + xlab(input$x_label)
      if (isTruthy(input$y_label)) p <- p + ylab(input$y_label)

      p
    })
  })
}

# UI
ui <- page_fillable(
  title = "TidyBlock - Data Wrangler",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#2c3e50"
  ),
  tags$head(
    tags$style(HTML("
      /* Menubar and Toolbar Styles */
      .spreadsheet-menu { padding: 4px 12px; color: #333; cursor: pointer; border-radius: 4px; border: none; background: transparent; font-weight: 500; font-size: 14px; text-decoration: none; display: inline-block; }
      .spreadsheet-menu:hover { background-color: #e9ecef; color: #000; }
      .menu-bar { background-color: #f8f9fa; border-bottom: 1px solid #dee2e6; padding: 2px 8px; }
      .toolbar-bar { background-color: #ffffff; border-bottom: 1px solid #dee2e6; padding: 4px 12px; }
      .toolbar-btn { margin-right: 4px; }
      /* Remove default button appearance for actionLinks */
      a.spreadsheet-menu { color: #333; }
      .dropdown-toggle::after { display: none; } /* Hide dropdown arrow for cleaner look */
    "))
  ),

  # Unified Toolbar
  div(
    class = "d-flex align-items-center bg-white border-bottom px-2 py-2 gap-1 flex-wrap",
    div(
      class = "dropdown",
      tags$button(
        class = "btn btn-sm btn-light dropdown-toggle text-dark fw-bold", `data-bs-toggle` = "dropdown",
        icon("folder-open"), " File"
      ),
      tags$ul(
        class = "dropdown-menu shadow-sm",
        tags$li(actionLink("load_iris", "Load iris dataset", icon = icon("leaf"), class = "dropdown-item")),
        tags$li(actionLink("load_iris_info", "Load iris info (for join)", icon = icon("info-circle"), class = "dropdown-item")),
        tags$li(tags$hr(class = "dropdown-divider")),
        tags$li(tags$div(
          class = "px-3 py-1",
          fileInput("file_upload", "",
            accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv", ".tsv", ".xlsx", ".xls"),
            width = "250px"
          )
        ))
      )
    ),
    tags$div(class = "border-start mx-1", style = "height:20px;"),
    actionButton("tb_undo", "Undo", icon = icon("undo"), class = "btn btn-sm btn-light text-dark"),
    actionButton("tb_save", "Save", icon = icon("save"), class = "btn btn-sm btn-light text-dark"),
    tags$div(class = "border-start mx-1", style = "height:20px;"),
    div(
      class = "dropdown",
      tags$button(
        class = "btn btn-sm btn-light dropdown-toggle text-dark", `data-bs-toggle` = "dropdown",
        icon("sort"), " Sort"
      ),
      tags$ul(
        class = "dropdown-menu shadow-sm",
        tags$li(actionLink("menu_arrange_asc", "Sort A-Z (Ascending)", icon = icon("sort-alpha-down"), class = "dropdown-item")),
        tags$li(actionLink("menu_arrange_desc", "Sort Z-A (Descending)", icon = icon("sort-alpha-up"), class = "dropdown-item"))
      )
    ),
    div(
      class = "dropdown",
      tags$button(class = "btn btn-sm btn-light dropdown-toggle text-dark", `data-bs-toggle` = "dropdown", icon("filter"), " Rows"),
      tags$ul(
        class = "dropdown-menu shadow-sm",
        tags$li(actionLink("tb_filter", "Filter", icon = icon("filter"), class = "dropdown-item")),
        tags$li(actionLink("tb_distinct", "Distinct", icon = icon("fingerprint"), class = "dropdown-item"))
      )
    ),
    div(
      class = "dropdown",
      tags$button(class = "btn btn-sm btn-light dropdown-toggle text-dark", `data-bs-toggle` = "dropdown", icon("columns"), " Columns"),
      tags$ul(
        class = "dropdown-menu shadow-sm",
        tags$li(actionLink("tb_select", "Select", icon = icon("tasks"), class = "dropdown-item")),
        tags$li(actionLink("tb_rename", "Rename", icon = icon("edit"), class = "dropdown-item")),
        tags$li(actionLink("tb_mutate", "Mutate", icon = icon("calculator"), class = "dropdown-item"))
      )
    ),
    div(
      class = "dropdown",
      tags$button(class = "btn btn-sm btn-light dropdown-toggle text-dark", `data-bs-toggle` = "dropdown", icon("compress"), " Reshape"),
      tags$ul(
        class = "dropdown-menu shadow-sm",
        tags$li(actionLink("tb_pivot_longer", "Pivot Longer", icon = icon("arrows-alt-v"), class = "dropdown-item")),
        tags$li(actionLink("tb_pivot_wider", "Pivot Wider", icon = icon("arrows-alt-h"), class = "dropdown-item"))
      )
    ),
    tags$div(class = "border-start mx-1", style = "height:20px;"),
    actionButton("tb_join", "Join", icon = icon("object-group"), class = "btn btn-sm btn-light text-dark"),
    actionButton("tb_summarise", "Summarise", icon = icon("compress-arrows-alt"), class = "btn btn-sm btn-light text-dark"),
    tags$div(class = "border-start mx-1", style = "height:20px;"),
    actionButton("tb_plot", "Plot", icon = icon("chart-bar"), class = "btn btn-sm btn-light text-dark")
  ),

  # Action Status Bar
  div(
    class = "bg-white border-bottom px-3 py-1", style = "font-size: 13px;",
    tags$strong("Latest Action: ", class = "text-muted me-2"),
    textOutput("last_action_text", inline = TRUE)
  ),

  # Main Spread Canvas
  div(
    class = "flex-grow-1 p-0 position-relative", style = "background-color: #f1f3f4; overflow: hidden;",
    navset_tab(
      id = "dataset_tabs",
      nav_panel(
        title = "Welcome",
        div(
          class = "d-flex flex-column align-items-center justify-content-center h-100 p-5 text-muted",
          icon("table", class = "fa-4x mb-3 text-secondary"),
          h3(class = "fw-bold", "Welcome to TidyBlock"),
          p("Use the ", strong("File"), " menu above to load a dataset or import your own.")
        )
      )
    )
  )
)

# ==============================================================================
# SERVER LOGIC
# ==============================================================================
server <- function(input, output, session) {
  # ----------------------------------------------------------------------------
  # App Global State Management (Reactive Values)
  # ----------------------------------------------------------------------------
  # This stores the current state of datasets, their history for the Undo feature,
  # logs of operations, and tracks current selections across handsontable modules.
  # ----------------------------------------------------------------------------
  rv <- reactiveValues(
    datasets = list(), # Named list storing active dataset arrays corresponding to tabs
    dataset_names = list(), # Human readable names for each dataset ID
    history = list(), # Stores up to 20 past states per dataset ID for Undo functionality
    action_log = list(), # Stores the string tracking the last performed action on each dataset
    selected_cols = list(), # Active column selections from handsontable per dataset ID
    selected_rows = list(), # Active row selections from handsontable per dataset ID
    plots = list() # Saved ggplot objects attached to auto-generated plot tabs
  )

  # Text Output for Status Bar
  output$last_action_text <- renderText({
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return("Please load a dataset to begin.")
    }
    log <- rv$action_log[[input$dataset_tabs]]
    if (is.null(log)) {
      return("No operations applied yet.")
    }
    return(log)
  })

  # ----------------------------------------------------------------------------
  # CORE UTILITY FUNCTIONS
  # ----------------------------------------------------------------------------

  # Helper to save state before mutating action (enables 'Undo')
  save_history <- function() {
    req(input$dataset_tabs)
    id <- input$dataset_tabs
    curr_data <- rv$datasets[[id]]
    if (!is.null(curr_data) && nrow(curr_data) > 0) {
      if (is.null(rv$history[[id]])) rv$history[[id]] <- list()
      # Push current state to the top of the history list
      rv$history[[id]] <- c(list(curr_data), rv$history[[id]])
      # Cap history depth at 20 elements to prevent excessive memory usage
      if (length(rv$history[[id]]) > 20) rv$history[[id]] <- rv$history[[id]][1:20]
    }
  }

  # Orchestrates adding a new dataset to the environment and dynamically generating
  # a new editable rhandsontable widget tab component linked to its internal ID.
  add_dataset <- function(name, df) {
    id <- paste0("ds_", as.integer(Sys.time()), "_", sample.int(1000, 1))
    rv$datasets[[id]] <- df
    rv$dataset_names[[id]] <- name
    rv$history[[id]] <- list()
    rv$action_log[[id]] <- paste("Loaded dataset:", name)
    rv$selected_cols[[id]] <- NULL

    appendTab(
      inputId = "dataset_tabs",
      tab = tabPanel(
        title = name,
        value = id,
        rHandsontableOutput(paste0("hot_", id), height = "calc(100vh - 190px)")
      ),
      select = TRUE
    )

    local({
      local_id <- id
      output[[paste0("hot_", local_id)]] <- renderRHandsontable({
        req(rv$datasets[[local_id]])
        rhandsontable(rv$datasets[[local_id]],
          useTypes = TRUE, stretchH = "all",
          manualRowMove = TRUE, manualColumnMove = TRUE,
          manualColumnResize = TRUE, manualRowResize = TRUE,
          selectCallback = TRUE
        ) %>%
          hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
          hot_context_menu(
            allowRowEdit = TRUE,
            allowColEdit = TRUE,
            customOpts = list(
              arrange_asc = list(name = "Dplyr: Arrange (Asc)", callback = htmlwidgets::JS(paste0("function() { Shiny.setInputValue('cm_arrange_asc', '", local_id, "', {priority: 'event'}); }"))),
              arrange_desc = list(name = "Dplyr: Arrange (Desc)", callback = htmlwidgets::JS(paste0("function() { Shiny.setInputValue('cm_arrange_desc', '", local_id, "', {priority: 'event'}); }"))),
              filter = list(name = "Dplyr: Filter", callback = htmlwidgets::JS("function() { Shiny.setInputValue('cm_filter', Math.random()); }")),
              mutate = list(name = "Dplyr: Mutate", callback = htmlwidgets::JS("function() { Shiny.setInputValue('cm_mutate', Math.random()); }")),
              join = list(name = "Dplyr: Join", callback = htmlwidgets::JS("function() { Shiny.setInputValue('cm_join', Math.random()); }")),
              plot = list(name = "Visualize: Plot", callback = htmlwidgets::JS("function() { Shiny.setInputValue('cm_plot', Math.random()); }"))
            )
          )
      })

      observe({
        sel <- input[[paste0("hot_", local_id, "_select")]]$select
        if (!is.null(sel) && !is.null(sel$c) && !is.null(sel$c2) && !is.null(rv$datasets[[local_id]])) {
          col_indices <- sel$c:sel$c2
          row_indices <- sel$r:sel$r2
          rv$selected_cols[[local_id]] <- names(rv$datasets[[local_id]])[col_indices]
          rv$selected_rows[[local_id]] <- row_indices
        }
      })
    })
  }

  create_plot_tab <- function(from_cm = FALSE) {
    req(input$dataset_tabs)
    id <- input$dataset_tabs
    if (id == "Welcome" || startsWith(id, "plot_")) {
      return(showNotification("Please select a valid dataset tab.", type = "warning"))
    }

    df <- rv$datasets[[id]]
    req(df)
    cols <- names(df)

    plot_id <- paste0("plot_", as.integer(Sys.time()), "_", sample.int(1000, 1))

    selected_rows <- NULL
    if (from_cm && length(rv$selected_rows[[id]]) > 0) {
      selected_rows <- rv$selected_rows[[id]]
    }

    rv$action_log[[plot_id]] <- paste("Opened plot tab for:", rv$dataset_names[[id]])

    appendTab(
      inputId = "dataset_tabs",
      tab = tabPanel(
        title = tagList(icon("chart-bar"), paste("Plot:", rv$dataset_names[[id]])),
        value = plot_id,
        plotTabUI(plot_id, cols)
      ),
      select = TRUE
    )

    plotTabServer(plot_id, rv, id, selected_rows)
  }

  # Rollback data to the immediate previous state
  do_undo <- function() {
    req(input$dataset_tabs)
    id <- input$dataset_tabs
    if (length(rv$history[[id]]) > 0) {
      rv$datasets[[id]] <- rv$history[[id]][[1]]
      rv$history[[id]] <- rv$history[[id]][-1]
      rv$action_log[[id]] <- paste("Undo completed at", format(Sys.time(), "%H:%M:%S"))
      showNotification("Undo successful.", type = "message")
    } else {
      showNotification("No more history to undo.", type = "warning")
    }
  }
  observeEvent(input$undo_btn, do_undo())
  observeEvent(input$tb_undo, do_undo())

  # Load iris
  observeEvent(input$load_iris, {
    add_dataset("iris", iris)
    showNotification("Iris dataset loaded.", type = "message")
  })

  # Load iris info (for join demo)
  observeEvent(input$load_iris_info, {
    iris_info <- data.frame(
      Species = factor(c("setosa", "versicolor", "virginica")),
      Region = c("Arctic", "Temperate", "Tropical"),
      Discovered_Year = c(1879, 1838, 1936),
      stringsAsFactors = FALSE
    )
    add_dataset("iris_info", iris_info)
    showNotification("Iris info dataset loaded.", type = "message")
  })

  # Load uploaded file
  observeEvent(input$file_upload, {
    req(input$file_upload)
    ext <- tools::file_ext(input$file_upload$name)
    fname <- input$file_upload$name

    tryCatch(
      {
        df <- NULL
        if (ext %in% c("csv")) {
          df <- readr::read_csv(input$file_upload$datapath)
        } else if (ext %in% c("tsv")) {
          df <- readr::read_tsv(input$file_upload$datapath)
        } else if (ext %in% c("xlsx", "xls")) {
          df <- readxl::read_excel(input$file_upload$datapath)
        } else {
          showNotification("Unsupported file format.", type = "error")
          return()
        }
        add_dataset(fname, df)
        showNotification("File loaded successfully.", type = "message")
      },
      error = function(e) {
        showNotification(paste("Error loading file:", e$message), type = "error")
      }
    )
  })

  do_save_table <- function() {
    req(input$dataset_tabs)
    id <- input$dataset_tabs
    hot_input <- input[[paste0("hot_", id)]]
    req(hot_input)
    save_history()
    new_data <- hot_to_r(hot_input)
    if (nrow(new_data) > 0 || ncol(new_data) > 0) {
      rv$datasets[[id]] <- new_data
      rv$action_log[[id]] <- paste("Manual table edits saved at", format(Sys.time(), "%H:%M:%S"))
      showNotification("Table changes saved.", type = "message")
    }
  }
  observeEvent(input$save_table, do_save_table())
  observeEvent(input$tb_save, do_save_table())

  # Arrange interactions
  do_arrange <- function(desc = FALSE, id = NULL) {
    if (is.null(id) || !is.character(id)) id <- input$dataset_tabs
    req(id)
    cols <- rv$selected_cols[[id]]
    if (is.null(cols) || length(cols) == 0) {
      return(showNotification("Please select a column in the table first.", type = "warning"))
    }
    save_history()
    col <- sym(cols[1])
    if (desc) {
      rv$datasets[[id]] <- rv$datasets[[id]] %>% arrange(desc(!!col))
      rv$action_log[[id]] <- paste("Arranged by", cols[1], "(Desc)")
      showNotification(paste("Sorted by", cols[1], "(Desc)"), type = "message")
    } else {
      rv$datasets[[id]] <- rv$datasets[[id]] %>% arrange(!!col)
      rv$action_log[[id]] <- paste("Arranged by", cols[1], "(Asc)")
      showNotification(paste("Sorted by", cols[1], "(Asc)"), type = "message")
    }
  }

  observeEvent(input$cm_arrange_asc, do_arrange(FALSE, input$cm_arrange_asc))
  observeEvent(input$cm_arrange_desc, do_arrange(TRUE, input$cm_arrange_desc))
  observeEvent(input$menu_arrange_asc, do_arrange(FALSE))
  observeEvent(input$menu_arrange_desc, do_arrange(TRUE))

  # Dplyr Operation Modals
  open_filter_modal <- function() {
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return(showNotification("Please load a dataset.", type = "warning"))
    }
    showModal(modalDialog(
      title = "Filter Operations",
      textInput("filter_expr", "Filter Expression", width = "100%", placeholder = "e.g., Species == \"setosa\" & (Sepal.Length > 5 | Sepal.Width < 3)"),
      layout_columns(
        col_widths = c(4, 3, 3, 2),
        uiOutput("ui_filter_col"),
        selectInput("filter_op", "Operator", choices = c("==", "!=", ">", "<", ">=", "<=", "%in%")),
        textInput("filter_val", "Value"),
        div(class = "d-flex align-items-end pb-3", actionButton("add_cond", "Add", class = "btn-info w-100"))
      ),
      div(
        class = "btn-group mb-3",
        actionButton("btn_and", "AND (&)", class = "btn-outline-secondary"),
        actionButton("btn_or", "OR (|)", class = "btn-outline-secondary"),
        actionButton("btn_lparen", "(", class = "btn-outline-secondary"),
        actionButton("btn_rparen", ")", class = "btn-outline-secondary"),
        actionButton("btn_clear", "Clear", class = "btn-outline-danger")
      ),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_filter", "Apply Filter", class = "btn-primary")
      ),
      size = "l"
    ))
  }

  open_mutate_modal <- function() {
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return(showNotification("Please load a dataset.", type = "warning"))
    }
    showModal(modalDialog(
      title = "Mutate (Compute Column)",
      textInput("mutate_name", "New Column Name"),
      textInput("mutate_expr", "Expression"),
      tags$hr(),
      tags$b("Helpers (Click to insert):"),
      div(
        class = "d-flex gap-2 mt-2 flex-wrap",
        actionButton("mut_help_log", "log(col)", class = "btn-sm btn-outline-secondary"),
        actionButton("mut_help_detect", "str_detect()", class = "btn-sm btn-outline-secondary", title = "str_detect(col, 'pattern')"),
        actionButton("mut_help_replace", "str_replace()", class = "btn-sm btn-outline-secondary", title = "str_replace(col, 'pattern', 'replacement')"),
        actionButton("mut_help_fct", "fct_reorder()", class = "btn-sm btn-outline-secondary", title = "fct_reorder(fct_col, num_col)"),
        actionButton("mut_help_case", "case_when()", class = "btn-sm btn-outline-secondary", title = "case_when(cond ~ val, TRUE ~ other)"),
        actionButton("mut_help_ymd", "ymd()", class = "btn-sm btn-outline-secondary", title = "ymd(col) from lubridate")
      ),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_mutate", "Apply Mutate", class = "btn-primary")
      )
    ))
  }

  open_join_modal <- function() {
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return(showNotification("Please load a dataset.", type = "warning"))
    }

    current_id <- input$dataset_tabs
    valid_right <- setdiff(names(rv$datasets), current_id)
    right_labels <- vapply(valid_right, function(x) rv$dataset_names[[x]], character(1))
    right_choices <- setNames(valid_right, right_labels)

    left_df <- rv$datasets[[current_id]]
    default_right <- if (length(valid_right) > 0) valid_right[1] else NULL
    right_df <- if (!is.null(default_right)) rv$datasets[[default_right]] else NULL

    common_cols <- if (!is.null(right_df)) intersect(names(left_df), names(right_df)) else character(0)

    showModal(modalDialog(
      title = "Join Datasets",
      selectInput("join_right", "Right Dataset", choices = right_choices, selected = default_right),
      selectInput("join_type", "Join Type", choices = c("left_join", "inner_join", "right_join", "full_join")),
      selectInput("join_by", "Join By (Key)", choices = common_cols, selected = common_cols, multiple = TRUE),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_join", "Apply Join", class = "btn-primary")
      )
    ))
  }


  open_summarise_modal <- function() {
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return(showNotification("Please load a dataset.", type = "warning"))
    }
    showModal(modalDialog(
      title = "Summarise",
      uiOutput("ui_group_col"),
      uiOutput("ui_sum_col"),
      selectInput("sum_func", "Function", choices = c("mean", "sum", "min", "max", "count")),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_summarise", "Apply Summarise", class = "btn-primary")
      )
    ))
  }

  open_select_modal <- function() {
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return(showNotification("Please load a dataset.", type = "warning"))
    }
    df <- rv$datasets[[input$dataset_tabs]]
    showModal(modalDialog(
      title = "Select Columns",
      checkboxGroupInput("select_cols", "Choose columns to keep:", choices = names(df), selected = names(df), inline = TRUE),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_select", "Apply Select", class = "btn-primary")
      )
    ))
  }

  open_rename_modal <- function() {
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return(showNotification("Please load a dataset.", type = "warning"))
    }
    df <- rv$datasets[[input$dataset_tabs]]
    showModal(modalDialog(
      title = "Rename Column",
      selectInput("rename_col_old", "Target Column", choices = names(df)),
      textInput("rename_col_new", "New Name"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_rename", "Apply Rename", class = "btn-primary")
      )
    ))
  }

  open_distinct_modal <- function() {
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return(showNotification("Please load a dataset.", type = "warning"))
    }
    df <- rv$datasets[[input$dataset_tabs]]
    showModal(modalDialog(
      title = "Distinct (Remove Duplicated Rows)",
      selectInput("distinct_cols", "Columns to check for uniqueness (leave empty for all)", choices = names(df), multiple = TRUE),
      checkboxInput("distinct_keep_all", "Keep other columns (.keep_all = TRUE)", value = TRUE),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_distinct", "Apply Distinct", class = "btn-primary")
      )
    ))
  }

  open_pivot_longer_modal <- function() {
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return(showNotification("Please load a dataset.", type = "warning"))
    }
    df <- rv$datasets[[input$dataset_tabs]]
    showModal(modalDialog(
      title = "Pivot Longer",
      selectInput("pivot_l_cols", "Columns to pivot into longer format", choices = names(df), multiple = TRUE),
      textInput("pivot_l_names_to", "names_to (New category column name)", value = "name"),
      textInput("pivot_l_values_to", "values_to (New value column name)", value = "value"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_pivot_longer", "Pivot Longer", class = "btn-primary")
      )
    ))
  }

  open_pivot_wider_modal <- function() {
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return(showNotification("Please load a dataset.", type = "warning"))
    }
    df <- rv$datasets[[input$dataset_tabs]]
    showModal(modalDialog(
      title = "Pivot Wider",
      selectInput("pivot_w_id_cols", "ID Columns (Optional, leave empty to use all others)", choices = c("None", names(df)), multiple = TRUE, selected = "None"),
      selectInput("pivot_w_names_from", "names_from (Column containing new names)", choices = names(df)),
      selectInput("pivot_w_values_from", "values_from (Column containing new values)", choices = names(df)),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_pivot_wider", "Pivot Wider", class = "btn-primary")
      )
    ))
  }

  observeEvent(input$cm_filter, open_filter_modal())
  observeEvent(input$menu_filter, open_filter_modal())
  observeEvent(input$tb_filter, open_filter_modal())

  observeEvent(input$cm_mutate, open_mutate_modal())
  observeEvent(input$menu_mutate, open_mutate_modal())
  observeEvent(input$tb_mutate, open_mutate_modal())

  observeEvent(input$cm_join, open_join_modal())
  observeEvent(input$menu_join, open_join_modal())
  observeEvent(input$tb_join, open_join_modal())

  observeEvent(input$cm_plot, create_plot_tab(TRUE))
  observeEvent(input$menu_plot, create_plot_tab(FALSE))
  observeEvent(input$tb_plot, create_plot_tab(FALSE))

  observeEvent(input$menu_summarise, open_summarise_modal())
  observeEvent(input$tb_summarise, open_summarise_modal())

  observeEvent(input$mut_help_log, {
    updateTextInput(session, "mutate_expr", value = "log(col)")
  })
  observeEvent(input$mut_help_detect, {
    updateTextInput(session, "mutate_expr", value = "str_detect(col, 'pattern')")
  })
  observeEvent(input$mut_help_replace, {
    updateTextInput(session, "mutate_expr", value = "str_replace(col, 'pattern', 'replacement')")
  })
  observeEvent(input$mut_help_fct, {
    updateTextInput(session, "mutate_expr", value = "fct_reorder(fct_col, num_col)")
  })
  observeEvent(input$mut_help_case, {
    updateTextInput(session, "mutate_expr", value = "case_when(cond ~ val, TRUE ~ other)")
  })
  observeEvent(input$mut_help_ymd, {
    updateTextInput(session, "mutate_expr", value = "ymd(col)")
  })

  observeEvent(input$tb_select, open_select_modal())
  observeEvent(input$tb_rename, open_rename_modal())
  observeEvent(input$tb_distinct, open_distinct_modal())
  observeEvent(input$tb_pivot_longer, open_pivot_longer_modal())
  observeEvent(input$tb_pivot_wider, open_pivot_wider_modal())

  # -------------------------------------------------------------
  # Dplyr Dynamic UIs
  # -------------------------------------------------------------

  col_choices <- reactive({
    req(input$dataset_tabs)
    id <- input$dataset_tabs
    req(rv$datasets[[id]])
    names(rv$datasets[[id]])
  })

  current_sel_cols <- reactive({
    req(input$dataset_tabs)
    rv$selected_cols[[input$dataset_tabs]]
  })

  output$ui_filter_col <- renderUI({
    sel <- if (!is.null(current_sel_cols())) current_sel_cols()[1] else col_choices()[1]
    selectInput("filter_col", "Column", choices = col_choices(), selected = sel)
  })

  output$ui_group_col <- renderUI({
    sel <- if (!is.null(current_sel_cols())) intersect(current_sel_cols(), col_choices()) else NULL
    selectInput("group_col", "Group By", choices = col_choices(), selected = sel, multiple = TRUE)
  })

  output$ui_sum_col <- renderUI({
    req(input$dataset_tabs)
    df <- rv$datasets[[input$dataset_tabs]]
    req(df)
    nums <- names(Filter(is.numeric, df))
    sel <- if (!is.null(current_sel_cols())) intersect(current_sel_cols(), nums)[1] else nums[1]
    selectInput("sum_col", "Target Column", choices = nums, selected = sel)
  })

  # Dynamic update for Join & Plot UI
  observe({
    req(input$dataset_tabs)
    id <- input$dataset_tabs
    if (id == "Welcome") {
      return()
    }
    df <- rv$datasets[[id]]
    req(df)
    cols <- names(df)

    # For Join
    ds_names <- names(rv$datasets)
    valid_right <- setdiff(ds_names, id)
    right_labels <- vapply(valid_right, function(x) rv$dataset_names[[x]], character(1))
    right_choices <- setNames(valid_right, right_labels)
    updateSelectInput(session, "join_right", choices = right_choices)
  })


  observe({
    req(input$join_right, input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return()
    }
    left_df <- rv$datasets[[input$dataset_tabs]]
    right_df <- rv$datasets[[input$join_right]]
    req(left_df, right_df)
    common_cols <- intersect(names(left_df), names(right_df))
    updateSelectInput(session, "join_by", choices = common_cols, selected = common_cols)
  })

  # -------------------------------------------------------------
  # Dplyr Actions
  # -------------------------------------------------------------

  observeEvent(input$add_cond, {
    req(input$filter_col, input$filter_op, input$filter_val)
    val <- input$filter_val
    if (is.na(suppressWarnings(as.numeric(val))) && input$filter_op != "%in%") {
      val <- paste0("\"", val, "\"")
    }

    col <- input$filter_col
    if (!grepl("^[A-Za-z_][A-Za-z0-9_]*$", col)) {
      col <- paste0("`", col, "`")
    }

    cond <- paste(col, input$filter_op, val)
    curr <- input$filter_expr
    new_expr <- if (is.null(curr) || trimws(curr) == "") cond else paste(curr, cond)
    updateTextInput(session, "filter_expr", value = new_expr)
  })

  observeEvent(input$btn_and, {
    updateTextInput(session, "filter_expr", value = paste(input$filter_expr, "& "))
  })
  observeEvent(input$btn_or, {
    updateTextInput(session, "filter_expr", value = paste(input$filter_expr, "| "))
  })
  observeEvent(input$btn_lparen, {
    updateTextInput(session, "filter_expr", value = paste0(input$filter_expr, "("))
  })
  observeEvent(input$btn_rparen, {
    updateTextInput(session, "filter_expr", value = paste0(input$filter_expr, ")"))
  })
  observeEvent(input$btn_clear, {
    updateTextInput(session, "filter_expr", value = "")
  })

  observeEvent(input$apply_filter, {
    req(input$dataset_tabs, input$filter_expr)
    if (trimws(input$filter_expr) == "") {
      return()
    }
    id <- input$dataset_tabs
    df <- rv$datasets[[id]]
    req(df)
    save_history()
    tryCatch(
      {
        expr <- parse_expr(input$filter_expr)
        rv$datasets[[id]] <- df %>% filter(!!expr)
        rv$action_log[[id]] <- paste("Filter applied:", input$filter_expr)
        showNotification("Filter applied.", type = "message")
        removeModal()
      },
      error = function(e) {
        showNotification(paste("Error:", e$message), type = "error")
      }
    )
  })

  observeEvent(input$apply_mutate, {
    req(input$dataset_tabs, input$mutate_name, input$mutate_expr != "")
    id <- input$dataset_tabs
    df <- rv$datasets[[id]]
    req(df)
    save_history()
    tryCatch(
      {
        expr <- parse_expr(input$mutate_expr)
        rv$datasets[[id]] <- df %>% mutate(!!input$mutate_name := !!expr)
        rv$action_log[[id]] <- paste("Mutate applied:", input$mutate_name, "=", input$mutate_expr)
        showNotification("Mutate applied.", type = "message")
        removeModal()
      },
      error = function(e) {
        showNotification(paste("Error:", e$message), type = "error")
      }
    )
  })

  observeEvent(input$apply_summarise, {
    req(input$dataset_tabs)
    id <- input$dataset_tabs
    df <- rv$datasets[[id]]
    req(df)
    save_history()
    tryCatch(
      {
        if (!is.null(input$group_col) && length(input$group_col) > 0) {
          df <- df %>% group_by(across(all_of(input$group_col)))
        }

        if (input$sum_func == "count") {
          df <- df %>% summarise(count = n(), .groups = "drop")
        } else {
          req(input$sum_col)
          t_col <- sym(input$sum_col)
          df <- switch(input$sum_func,
            "mean" = df %>% summarise(mean_val = mean(!!t_col, na.rm = TRUE), .groups = "drop"),
            "sum"  = df %>% summarise(sum_val = sum(!!t_col, na.rm = TRUE), .groups = "drop"),
            "min"  = df %>% summarise(min_val = min(!!t_col, na.rm = TRUE), .groups = "drop"),
            "max"  = df %>% summarise(max_val = max(!!t_col, na.rm = TRUE), .groups = "drop")
          )
        }

        # Add the summarised dataframe as a completely new tab
        new_name <- paste0("Summarised_", format(Sys.time(), "%H%M%S"))
        add_dataset(new_name, df)

        showNotification("Summarise completed in new tab.", type = "message")
        removeModal()
      },
      error = function(e) {
        showNotification(paste("Error:", e$message), type = "error")
      }
    )
  })

  # Execute Join
  observeEvent(input$apply_join, {
    req(input$dataset_tabs, input$join_right, input$join_type)
    left_id <- input$dataset_tabs
    left_df <- rv$datasets[[left_id]]
    right_df <- rv$datasets[[input$join_right]]
    req(left_df, right_df)

    save_history()
    tryCatch(
      {
        join_func <- get(input$join_type, asNamespace("dplyr"))

        if (length(input$join_by) > 0) {
          res_df <- join_func(left_df, right_df, by = input$join_by)
        } else {
          res_df <- join_func(left_df, right_df)
        }

        new_name <- paste0("Joined_", format(Sys.time(), "%H%M%S"))
        add_dataset(new_name, res_df)

        showNotification("Join completed in new tab.", type = "message")
        removeModal()
      },
      error = function(e) {
        showNotification(paste("Error:", e$message), type = "error")
      }
    )
  })

  # Phase 3 Actions
  observeEvent(input$apply_select, {
    req(input$dataset_tabs, input$select_cols)
    id <- input$dataset_tabs
    df <- rv$datasets[[id]]
    req(df)
    save_history()
    tryCatch(
      {
        rv$datasets[[id]] <- df %>% select(all_of(input$select_cols))
        rv$action_log[[id]] <- "Select applied"
        showNotification("Select applied.", type = "message")
        removeModal()
      },
      error = function(e) showNotification(e$message, type = "error")
    )
  })

  observeEvent(input$apply_rename, {
    req(input$dataset_tabs, input$rename_col_old, input$rename_col_new != "")
    id <- input$dataset_tabs
    df <- rv$datasets[[id]]
    req(df)
    save_history()
    tryCatch(
      {
        rv$datasets[[id]] <- df %>% rename(!!input$rename_col_new := !!sym(input$rename_col_old))
        rv$action_log[[id]] <- paste("Renamed", input$rename_col_old, "to", input$rename_col_new)
        showNotification("Rename applied.", type = "message")
        removeModal()
      },
      error = function(e) showNotification(e$message, type = "error")
    )
  })

  observeEvent(input$apply_distinct, {
    req(input$dataset_tabs)
    id <- input$dataset_tabs
    df <- rv$datasets[[id]]
    req(df)
    save_history()
    tryCatch(
      {
        if (length(input$distinct_cols) > 0) {
          rv$datasets[[id]] <- df %>% distinct(across(all_of(input$distinct_cols)), .keep_all = input$distinct_keep_all)
        } else {
          rv$datasets[[id]] <- df %>% distinct()
        }
        rv$action_log[[id]] <- "Distinct applied"
        showNotification("Distinct applied.", type = "message")
        removeModal()
      },
      error = function(e) showNotification(e$message, type = "error")
    )
  })

  observeEvent(input$apply_pivot_longer, {
    req(input$dataset_tabs, input$pivot_l_cols)
    id <- input$dataset_tabs
    df <- rv$datasets[[id]]
    req(df)
    save_history()
    tryCatch(
      {
        res_df <- df %>% pivot_longer(cols = all_of(input$pivot_l_cols), names_to = input$pivot_l_names_to, values_to = input$pivot_l_values_to)
        new_name <- paste0("Long_", format(Sys.time(), "%H%M%S"))
        add_dataset(new_name, res_df)
        showNotification("Pivot Longer completed in new tab.", type = "message")
        removeModal()
      },
      error = function(e) showNotification(e$message, type = "error")
    )
  })

  observeEvent(input$apply_pivot_wider, {
    req(input$dataset_tabs, input$pivot_w_names_from, input$pivot_w_values_from)
    id <- input$dataset_tabs
    df <- rv$datasets[[id]]
    req(df)
    save_history()
    tryCatch(
      {
        args <- list(data = df, names_from = input$pivot_w_names_from, values_from = input$pivot_w_values_from)
        id_cols_sel <- setdiff(input$pivot_w_id_cols, "None")
        if (length(id_cols_sel) > 0) {
          args$id_cols <- all_of(id_cols_sel)
        }
        res_df <- do.call(pivot_wider, args)
        new_name <- paste0("Wide_", format(Sys.time(), "%H%M%S"))
        add_dataset(new_name, res_df)
        showNotification("Pivot Wider completed in new tab.", type = "message")
        removeModal()
      },
      error = function(e) showNotification(e$message, type = "error")
    )
  })
}

shinyApp(ui, server)
