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

  # Named vector: Display Name = internal R function name
  geom_choices <- c(
    "None" = "None",
    "Scatter (Points)" = "geom_point",
    "Line" = "geom_line",
    "Histogram" = "geom_histogram",
    "Density Curve" = "geom_density",
    "Dot Plot" = "geom_dotplot",
    "Box Plot" = "geom_boxplot",
    "Violin Plot" = "geom_violin",
    "Jitter (Scattered Points)" = "geom_jitter",
    "Bar Chart" = "geom_col",
    "2D Heatmap (Bin)" = "geom_bin_2d",
    "Error Bar" = "geom_errorbar",
    "Trend Line (Smooth)" = "geom_smooth",
    "Ribbon (Area Band)" = "geom_ribbon",
    "Q-Q Plot" = "geom_qq",
    "Text Label" = "geom_text",
    "Label (Boxed Text)" = "geom_label",
    "Horizontal Line" = "geom_hline",
    "Vertical Line" = "geom_vline",
    "Map (SF Geometry)" = "geom_sf"
  )
  stat_choices <- c(
    "Default" = "default",
    "As-is (Raw Values)" = "identity",
    "Count" = "count",
    "Density" = "density",
    "Binning" = "bin",
    "Summary" = "summary",
    "Box Plot Stats" = "boxplot"
  )
  coord_choices <- c(
    "Standard (Cartesian)" = "coord_cartesian",
    "Fixed Aspect Ratio" = "coord_fixed",
    "Polar" = "coord_polar",
    "Radial" = "coord_radial",
    "Transformed" = "coord_trans"
  )
  oob_choices <- c(
    "Hide (Censor)" = "scales::censor",
    "Compress (Squish)" = "scales::squish",
    "Keep All" = "scales::keep"
  )
  color_scale_choices <- c(
    "Default" = "default",
    "Color Brewer" = "scale_colour_brewer",
    "Viridis (Discrete)" = "scale_colour_viridis_d",
    "Viridis (Continuous)" = "scale_colour_viridis_c",
    "Gradient" = "scale_colour_gradient"
  )
  facet_type_choices <- c(
    "None" = "None",
    "Wrap (Flexible Grid)" = "facet_wrap",
    "Grid (Row × Column)" = "facet_grid"
  )
  facet_scale_choices <- c(
    "Fixed" = "fixed",
    "Independent" = "free",
    "Independent X" = "free_x",
    "Independent Y" = "free_y"
  )
  theme_choices <- c(
    "Minimal" = "theme_minimal",
    "Black & White" = "theme_bw",
    "Classic" = "theme_classic",
    "Light" = "theme_light",
    "Dark" = "theme_dark",
    "Blank (No Axes)" = "theme_void",
    "Grey" = "theme_grey"
  )

  layout_sidebar(
    sidebar = sidebar(
      width = 400,
      title = "Plot Builder",
      accordion(
        id = ns("plot_accordion"),
        multiple = TRUE,
        accordion_panel(
          "1. Chart Type",
          icon = icon("chart-bar"),
          selectInput(ns("geom_1"), "Chart Type", choices = geom_choices, selected = "geom_point"),
          selectInput(ns("stat_1"), "Statistical Transform", choices = stat_choices),
          tags$hr(),
          tags$strong("Reference Lines"),
          numericInput(ns("hline_y"), "Horizontal Line (Y value)", value = NA),
          numericInput(ns("vline_x"), "Vertical Line (X value)", value = NA)
        ),
        accordion_panel(
          "2. Data Mapping",
          icon = icon("palette"),
          selectInput(ns("x"), "X Axis", choices = c("None", cols), selected = if (length(cols) >= 1) cols[1] else "None"),
          selectInput(ns("y"), "Y Axis", choices = c("None", cols), selected = if (length(cols) >= 2) cols[2] else "None"),
          selectInput(ns("ymin"), "Y Min (Error Bar lower)", choices = c("None", cols)),
          selectInput(ns("ymax"), "Y Max (Error Bar upper)", choices = c("None", cols)),
          selectInput(ns("color"), "Color", choices = c("None", cols)),
          selectInput(ns("fill"), "Fill", choices = c("None", cols)),
          selectInput(ns("group"), "Group", choices = c("None", cols)),
          selectInput(ns("size"), "Size", choices = c("None", cols)),
          selectInput(ns("alpha"), "Opacity", choices = c("None", cols)),
          selectInput(ns("shape"), "Shape", choices = c("None", cols)),
          selectInput(ns("linetype"), "Line Style", choices = c("None", cols)),
          selectInput(ns("label"), "Text Label Column", choices = c("None", cols)),
          textInput(ns("adv_mapping"), "Advanced Mapping", placeholder = "e.g., y = after_stat(density)")
        ),
        accordion_panel(
          "3. Scales & Coordinates",
          icon = icon("ruler-combined"),
          selectInput(ns("coord"), "Coordinate System", choices = coord_choices),
          checkboxInput(ns("scale_x_log10"), "Log10 Transform X Axis", value = FALSE),
          checkboxInput(ns("scale_y_log10"), "Log10 Transform Y Axis", value = FALSE),
          textInput(ns("xlim"), "X Limit (min, max)", placeholder = "e.g., 0, 100"),
          textInput(ns("ylim"), "Y Limit (min, max)", placeholder = "e.g., 0, 100"),
          selectInput(ns("oob"), "Out-of-Bounds Rule", choices = oob_choices, selected = "scales::censor"),
          selectInput(ns("color_scale"), "Color/Fill Scale", choices = color_scale_choices)
        ),
        accordion_panel(
          "4. Split by Group (Facets)",
          icon = icon("table-cells"),
          selectInput(ns("facet_type"), "Split Layout", choices = facet_type_choices),
          selectInput(ns("facet_var1"), "Split Variable 1", choices = c("None", cols)),
          selectInput(ns("facet_var2"), "Split Variable 2", choices = c("None", cols)),
          selectInput(ns("facet_scales"), "Axis Scaling", choices = facet_scale_choices)
        ),
        accordion_panel(
          "5. Themes & Labels",
          icon = icon("paintbrush"),
          selectInput(ns("theme"), "Base Theme", choices = theme_choices),
          sliderInput(ns("base_size"), "Base Font Size", min = 8, max = 24, value = 14),
          tags$hr(),
          tags$strong("Element Control"),
          selectInput(ns("legend_position"), "Legend Position", choices = c("Right" = "right", "Left" = "left", "Top" = "top", "Bottom" = "bottom", "Hidden" = "none")),
          selectInput(ns("theme_bg"), "Panel Background", choices = c("Default" = "default", "White" = "white", "Gray" = "gray92", "Black" = "black", "Transparent" = "transparent")),
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
    # Build the ggplot object reactively so it can be reused for merge
    plot_reactive <- reactive({
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
      if (!is.null(v <- get_sym_if_valid(input$ymin))) aes_args$ymin <- v
      if (!is.null(v <- get_sym_if_valid(input$ymax))) aes_args$ymax <- v
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
        # Auto-select first two columns as fallback
        fallback_cols <- names(df)
        if (length(fallback_cols) >= 2) {
          aes_args$x <- sym(fallback_cols[1])
          aes_args$y <- sym(fallback_cols[2])
        } else if (length(fallback_cols) == 1) {
          aes_args$x <- sym(fallback_cols[1])
        } else {
          return(ggplot() +
            theme_void() +
            ggtitle("No columns available to plot"))
        }
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

    # Render the plot
    output$plot <- renderPlot({
      plot_reactive()
    })

    # Store the ggplot object and axis metadata for merge feature
    observe({
      p <- tryCatch(plot_reactive(), error = function(e) NULL)
      if (!is.null(p)) {
        rv$plots[[id]] <- p
        rv$plot_meta[[id]] <- list(
          x = if (isTruthy(input$x) && input$x != "None") input$x else NA_character_,
          y = if (isTruthy(input$y) && input$y != "None") input$y else NA_character_,
          ds_id = ds_id,
          name = rv$dataset_names[[ds_id]]
        )
      }
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
    tags$script(src = "https://cdn.jsdelivr.net/npm/sortablejs@latest/Sortable.min.js"),
    tags$script(HTML("
      $(document).on('shiny:connected', function() {
        // Function to initialize Sortable on all tab containers
        const initTabsSortable = () => {
          $('.nav-tabs').each(function() {
            if (!this._sortable) {
              this._sortable = Sortable.create(this, {
                animation: 150,
                ghostClass: 'sortable-ghost',
                onEnd: function (evt) {
                  // Notify Shiny of the new order
                  var containerId = $(evt.to).closest('.bslib-nav-spacing, div[id]').attr('id');
                  if (containerId) {
                    var order = [];
                    $(evt.to).find('.nav-link').each(function() {
                      order.push($(this).attr('data-value') || $(this).text().trim());
                    });
                    Shiny.setInputValue(containerId + '_order', order);
                  }
                }
              });
            }
          });
        };
        
        // Initial init
        initTabsSortable();
        
        // Watch for dynamically added tabs
        const observer = new MutationObserver(initTabsSortable);
        observer.observe(document.body, { childList: true, subtree: true });
      });
    ")),
    tags$style(HTML("
      /* Tab Draggability and Styling */
      .nav-tabs .nav-item { cursor: grab; }
      .nav-tabs .nav-item:active { cursor: grabbing; }
      .sortable-ghost { opacity: 0.4; background-color: #f8f9fa !important; border-radius: 4px; }
      
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
        tags$li(actionLink("tb_distinct", "Remove Duplicates", icon = icon("fingerprint"), class = "dropdown-item"))
      )
    ),
    div(
      class = "dropdown",
      tags$button(class = "btn btn-sm btn-light dropdown-toggle text-dark", `data-bs-toggle` = "dropdown", icon("columns"), " Columns"),
      tags$ul(
        class = "dropdown-menu shadow-sm",
        tags$li(actionLink("tb_select", "Select", icon = icon("tasks"), class = "dropdown-item")),
        tags$li(actionLink("tb_rename", "Rename", icon = icon("edit"), class = "dropdown-item")),
        tags$li(actionLink("tb_mutate", "Add Column", icon = icon("calculator"), class = "dropdown-item"))
      )
    ),
    div(
      class = "dropdown",
      tags$button(class = "btn btn-sm btn-light dropdown-toggle text-dark", `data-bs-toggle` = "dropdown", icon("compress"), " Reshape"),
      tags$ul(
        class = "dropdown-menu shadow-sm",
        tags$li(actionLink("tb_pivot_longer", "Unpivot (Wide → Long)", icon = icon("arrows-alt-v"), class = "dropdown-item")),
        tags$li(actionLink("tb_pivot_wider", "Pivot (Long → Wide)", icon = icon("arrows-alt-h"), class = "dropdown-item"))
      )
    ),
    tags$div(class = "border-start mx-1", style = "height:20px;"),
    actionButton("tb_join", "Join", icon = icon("object-group"), class = "btn btn-sm btn-light text-dark"),
    actionButton("tb_summarise", "Summarize", icon = icon("compress-arrows-alt"), class = "btn btn-sm btn-light text-dark"),
    tags$div(class = "border-start mx-1", style = "height:20px;"),
    actionButton("tb_plot", "Plot", icon = icon("chart-bar"), class = "btn btn-sm btn-light text-dark"),
    actionButton("tb_merge_plots", "Merge Plots", icon = icon("layer-group"), class = "btn btn-sm btn-light text-dark")
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
      ),
      nav_panel(
        title = tagList(icon("history"), "Command History"),
        value = "cmd_history",
        div(
          class = "p-3 h-100 bg-white",
          tags$pre(id = "history_text", class = "shiny-text-output h-100 w-100 p-3", style = "background-color: #2b2b2b; color: #a9b7c6; font-size: 14px; overflow-y: auto; border: none; font-family: 'Consolas', 'Courier New', monospace;")
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
    plots = list(), # Saved ggplot objects attached to auto-generated plot tabs
    plot_meta = list(), # Stores axis metadata (x, y, ds_id, name) for each plot tab
    command_history = character() # Stores executed R commands
  )

  # Text Output for Status Bar
  output$last_action_text <- renderText({
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome" || input$dataset_tabs == "cmd_history") {
      return("Please load a dataset to begin.")
    }
    log <- rv$action_log[[input$dataset_tabs]]
    if (is.null(log)) {
      return("No operations applied yet.")
    }
    return(log)
  })

  # History tab output
  log_command <- function(code) {
    rv$command_history <- c(rv$command_history, code)
  }

  output$history_text <- renderText({
    if (length(rv$command_history) == 0) return("# No commands executed yet.\n# Load a dataset to begin.")
    paste(rv$command_history, collapse = "\n\n")
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
              arrange_asc = list(name = "Sort A \u2192 Z", callback = htmlwidgets::JS(paste0("function() { Shiny.setInputValue('cm_arrange_asc', '", local_id, "', {priority: 'event'}); }"))),
              arrange_desc = list(name = "Sort Z \u2192 A", callback = htmlwidgets::JS(paste0("function() { Shiny.setInputValue('cm_arrange_desc', '", local_id, "', {priority: 'event'}); }"))),
              filter = list(name = "Filter Rows", callback = htmlwidgets::JS("function() { Shiny.setInputValue('cm_filter', Math.random()); }")),
              mutate = list(name = "Add Column", callback = htmlwidgets::JS("function() { Shiny.setInputValue('cm_mutate', Math.random()); }")),
              join = list(name = "Join Tables", callback = htmlwidgets::JS("function() { Shiny.setInputValue('cm_join', Math.random()); }")),
              plot = list(name = "Create Chart", callback = htmlwidgets::JS("function() { Shiny.setInputValue('cm_plot', Math.random()); }"))
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
    log_command("iris <- datasets::iris")
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
    log_command("iris_info <- data.frame(Species = factor(c('setosa', 'versicolor', 'virginica')), Region = c('Arctic', 'Temperate', 'Tropical'), Discovered_Year = c(1879, 1838, 1936))")
    showNotification("Iris info dataset loaded.", type = "message")
  })

  # Load uploaded file
  observeEvent(input$file_upload, {
    req(input$file_upload)
    ext <- tools::file_ext(input$file_upload$name)
    raw_fname <- tools::file_path_sans_ext(input$file_upload$name)
    
    # Create a valid R variable name
    base_name <- make.names(raw_fname)
    fname <- base_name
    
    # Handle duplicate names
    existing_names <- unlist(rv$dataset_names)
    counter <- 1
    while (fname %in% existing_names) {
      fname <- paste0(base_name, "_", counter)
      counter <- counter + 1
    }

    tryCatch(
      {
        df <- NULL
        if (ext %in% c("csv")) {
          df <- readr::read_csv(input$file_upload$datapath, comment = "#")
        } else if (ext %in% c("tsv")) {
          df <- readr::read_tsv(input$file_upload$datapath, comment = "#")
        } else if (ext %in% c("xlsx", "xls")) {
          df <- readxl::read_excel(input$file_upload$datapath)
        } else {
          showNotification("Unsupported file format.", type = "error")
          return()
        }
        add_dataset(fname, df)
        read_func <- if (ext %in% c("csv")) "read_csv" else if (ext %in% c("tsv")) "read_tsv" else "read_excel"
        
        # Use backticks for variable name in log if it's still not perfectly clean (though make.names helps)
        safe_fname <- if (make.names(fname) == fname) fname else paste0("`", fname, "`")
        
        if (read_func %in% c("read_csv", "read_tsv")) {
          log_command(sprintf("%s <- %s(\"%s\", comment = \"#\")", safe_fname, read_func, input$file_upload$name))
        } else {
          log_command(sprintf("%s <- %s(\"%s\")", safe_fname, read_func, input$file_upload$name))
        }
        showNotification(paste("File loaded as:", fname), type = "message")
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
      log_command(sprintf("%s <- %s %%>%% arrange(desc(%s))", rv$dataset_names[[id]], rv$dataset_names[[id]], cols[1]))
      showNotification(paste("Sorted by", cols[1], "(Desc)"), type = "message")
    } else {
      rv$datasets[[id]] <- rv$datasets[[id]] %>% arrange(!!col)
      rv$action_log[[id]] <- paste("Arranged by", cols[1], "(Asc)")
      log_command(sprintf("%s <- %s %%>%% arrange(%s)", rv$dataset_names[[id]], rv$dataset_names[[id]], cols[1]))
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
      title = "Add / Compute Column",
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
        actionButton("apply_mutate", "Apply", class = "btn-primary")
      )
    ))
  }

  open_join_modal <- function() {
    req(input$dataset_tabs)
    if (input$dataset_tabs == "Welcome") {
      return(showNotification("Please load a dataset.", type = "warning"))
    }

    # Require at least 2 datasets to perform a join
    all_ds_ids <- names(rv$datasets)
    if (length(all_ds_ids) < 2) {
      return(showNotification("Join requires at least 2 datasets. Please load another dataset.", type = "warning"))
    }

    # Build named choices: display name -> internal id
    all_labels <- vapply(all_ds_ids, function(x) rv$dataset_names[[x]], character(1))
    all_choices <- setNames(all_ds_ids, all_labels)

    # Default: current tab = Left, first other = Right
    current_id <- input$dataset_tabs
    default_left <- if (current_id %in% all_ds_ids) current_id else all_ds_ids[1]
    default_right <- setdiff(all_ds_ids, default_left)[1]

    left_df <- rv$datasets[[default_left]]
    right_df <- rv$datasets[[default_right]]
    common_cols <- intersect(names(left_df), names(right_df))

    showModal(modalDialog(
      title = "Join Datasets",
      layout_columns(
        col_widths = c(5, 2, 5),
        selectInput("join_left", "Left Dataset", choices = all_choices, selected = default_left),
        div(class = "d-flex align-items-end justify-content-center pb-3",
            actionButton("join_swap", icon("arrows-left-right"), class = "btn btn-outline-secondary btn-sm", title = "Swap Left / Right")
        ),
        selectInput("join_right", "Right Dataset", choices = all_choices, selected = default_right)
      ),
      selectInput("join_type", "Join Type", choices = c("Left Join" = "left_join", "Inner Join" = "inner_join", "Right Join" = "right_join", "Full Join" = "full_join")),
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
      selectInput("sum_func", "Function", choices = c(
        "Average (Mean)" = "mean",
        "Sum" = "sum",
        "Minimum" = "min",
        "Maximum" = "max",
        "Count" = "count",
        "S.D. (Standard Deviation)" = "sd",
        "S.E.M. (Standard Error)" = "sem",
        "95% C.I. (Confidence Interval)" = "ci"
      )),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_summarise", "Apply", class = "btn-primary")
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
      title = "Remove Duplicate Rows",
      selectInput("distinct_cols", "Columns to check for uniqueness (leave empty for all)", choices = names(df), multiple = TRUE),
      checkboxInput("distinct_keep_all", "Keep all other columns", value = TRUE),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_distinct", "Apply", class = "btn-primary")
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
      title = "Unpivot (Wide \u2192 Long)",
      selectInput("pivot_l_cols", "Columns to pivot into longer format", choices = names(df), multiple = TRUE),
      textInput("pivot_l_names_to", "New Category Column Name", value = "name"),
      textInput("pivot_l_values_to", "New Value Column Name", value = "value"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_pivot_longer", "Apply", class = "btn-primary")
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
      title = "Pivot (Long \u2192 Wide)",
      selectInput("pivot_w_id_cols", "ID Columns (Optional, leave empty to use all others)", choices = c("None", names(df)), multiple = TRUE, selected = "None"),
      selectInput("pivot_w_names_from", "Column for New Headers", choices = names(df)),
      selectInput("pivot_w_values_from", "Column for New Values", choices = names(df)),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_pivot_wider", "Apply", class = "btn-primary")
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

  observeEvent(input$tb_merge_plots, open_merge_plots_modal())

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

  # Dynamic update for Join key columns based on selected Left & Right datasets
  observe({
    req(input$join_left, input$join_right)
    left_df <- rv$datasets[[input$join_left]]
    right_df <- rv$datasets[[input$join_right]]
    req(left_df, right_df)
    common_cols <- intersect(names(left_df), names(right_df))
    updateSelectInput(session, "join_by", choices = common_cols, selected = common_cols)
  })

  # Swap Left <-> Right button
  observeEvent(input$join_swap, {
    cur_left <- input$join_left
    cur_right <- input$join_right
    updateSelectInput(session, "join_left", selected = cur_right)
    updateSelectInput(session, "join_right", selected = cur_left)
  })

  # ---- Merge Plots Modal & Logic ----
  open_merge_plots_modal <- function() {
    plot_ids <- names(rv$plot_meta)
    if (length(plot_ids) < 2) {
      return(showNotification("Merge requires at least 2 plot tabs. Please create more plots first.", type = "warning"))
    }

    # Build descriptive choices
    plot_labels <- vapply(plot_ids, function(pid) {
      meta <- rv$plot_meta[[pid]]
      paste0(meta$name, " (X: ", meta$x, ", Y: ", meta$y, ")")
    }, character(1))
    plot_choices <- setNames(plot_ids, plot_labels)

    # Default base = current tab if it is a plot tab, otherwise first plot
    default_base <- if (startsWith(input$dataset_tabs, "plot_") && input$dataset_tabs %in% plot_ids) {
      input$dataset_tabs
    } else {
      plot_ids[1]
    }

    showModal(modalDialog(
      title = "Merge Plots (Overlay)",
      selectInput("merge_base", "Base Plot", choices = plot_choices, selected = default_base),
      selectInput("merge_overlay", "Overlay Plot(s)", choices = NULL, multiple = TRUE),
      helpText("Only plots with matching X and Y axes are shown as overlay candidates."),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("apply_merge_plots", "Merge", class = "btn-primary")
      )
    ))
  }

  # Dynamically filter overlay choices to only show axis-compatible plots
  observe({
    req(input$merge_base)
    base_meta <- rv$plot_meta[[input$merge_base]]
    req(base_meta)

    plot_ids <- names(rv$plot_meta)
    compatible <- plot_ids[vapply(plot_ids, function(pid) {
      if (pid == input$merge_base) return(FALSE)
      meta <- rv$plot_meta[[pid]]
      # Both x and y must match (NA matches NA)
      x_match <- isTRUE(meta$x == base_meta$x) || (is.na(meta$x) && is.na(base_meta$x))
      y_match <- isTRUE(meta$y == base_meta$y) || (is.na(meta$y) && is.na(base_meta$y))
      x_match && y_match
    }, logical(1))]

    if (length(compatible) > 0) {
      comp_labels <- vapply(compatible, function(pid) {
        meta <- rv$plot_meta[[pid]]
        paste0(meta$name, " (X: ", meta$x, ", Y: ", meta$y, ")")
      }, character(1))
      comp_choices <- setNames(compatible, comp_labels)
    } else {
      comp_choices <- character(0)
    }
    updateSelectInput(session, "merge_overlay", choices = comp_choices)
  })

  # Execute Plot Merge: overlay layers from selected plots onto the base
  observeEvent(input$apply_merge_plots, {
    req(input$merge_base, input$merge_overlay)

    base_plot <- rv$plots[[input$merge_base]]
    req(base_plot)

    tryCatch({
      merged <- base_plot

      for (oid in input$merge_overlay) {
        overlay_plot <- rv$plots[[oid]]
        if (!is.null(overlay_plot)) {
          # Copy each layer from the overlay plot, binding its own data
          for (layer in overlay_plot$layers) {
            new_layer <- layer
            if (is.null(new_layer$data) || (is.data.frame(new_layer$data) && nrow(new_layer$data) == 0)) {
              new_layer$data <- overlay_plot$data
            }
            merged$layers <- c(merged$layers, list(new_layer))
          }
        }
      }

      # Create a new tab for the merged plot
      merge_id <- paste0("plot_", as.integer(Sys.time()), "_", sample.int(1000, 1))
      rv$plots[[merge_id]] <- merged
      rv$action_log[[merge_id]] <- "Merged plot created"

      # Copy base plot metadata for the merged plot so it can be further merged
      rv$plot_meta[[merge_id]] <- list(
        x = rv$plot_meta[[input$merge_base]]$x,
        y = rv$plot_meta[[input$merge_base]]$y,
        ds_id = rv$plot_meta[[input$merge_base]]$ds_id,
        name = "Merged"
      )

      appendTab(
        inputId = "dataset_tabs",
        tab = tabPanel(
          title = tagList(icon("layer-group"), "Merged Plot"),
          value = merge_id,
          div(
            class = "p-4 h-100 w-100 d-flex flex-column justify-content-center align-items-center bg-white",
            plotOutput(paste0("merged_plot_", merge_id), height = "700px", width = "100%")
          )
        ),
        select = TRUE
      )

      local({
        local_merge_id <- merge_id
        output[[paste0("merged_plot_", local_merge_id)]] <- renderPlot({
          rv$plots[[local_merge_id]]
        })
      })

      showNotification("Plots merged successfully.", type = "message")
      removeModal()
    },
    error = function(e) {
      showNotification(paste("Error merging plots:", e$message), type = "error")
    })
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
        log_command(sprintf("%s <- %s %%>%% filter(%s)", rv$dataset_names[[id]], rv$dataset_names[[id]], input$filter_expr))
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
        log_command(sprintf("%s <- %s %%>%% mutate(%s = %s)", rv$dataset_names[[id]], rv$dataset_names[[id]], input$mutate_name, input$mutate_expr))
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
            "mean" = df %>% summarise(mean = mean(!!t_col, na.rm = TRUE), .groups = "drop"),
            "sum"  = df %>% summarise(sum  = sum(!!t_col,  na.rm = TRUE), .groups = "drop"),
            "min"  = df %>% summarise(min  = min(!!t_col,  na.rm = TRUE), .groups = "drop"),
            "max"  = df %>% summarise(max  = max(!!t_col,  na.rm = TRUE), .groups = "drop"),
            "sd"   = df %>% summarise(sd   = sd(!!t_col,   na.rm = TRUE), .groups = "drop"),
            "sem"  = df %>% summarise(
              sem = sd(!!t_col, na.rm = TRUE) / sqrt(sum(!is.na(!!t_col))),
              .groups = "drop"
            ),
            "ci"   = df %>% summarise(
              mean     = mean(!!t_col, na.rm = TRUE),
              ci_lower = mean(!!t_col, na.rm = TRUE) -
                qt(0.975, df = sum(!is.na(!!t_col)) - 1) *
                sd(!!t_col, na.rm = TRUE) / sqrt(sum(!is.na(!!t_col))),
              ci_upper = mean(!!t_col, na.rm = TRUE) +
                qt(0.975, df = sum(!is.na(!!t_col)) - 1) *
                sd(!!t_col, na.rm = TRUE) / sqrt(sum(!is.na(!!t_col))),
              .groups = "drop"
            )
          )
        }

        # Add the summarised dataframe as a completely new tab
        new_name <- paste0("Summarised_", format(Sys.time(), "%H%M%S"))
        add_dataset(new_name, df)

        group_str <- if (!is.null(input$group_col) && length(input$group_col) > 0) {
          sprintf("group_by(%s) %%>%% ", paste(input$group_col, collapse = ", "))
        } else ""
        if (input$sum_func == "count") {
          sum_str <- "summarise(count = n(), .groups = 'drop')"
        } else {
          t_col <- input$sum_col
          sum_str <- switch(input$sum_func,
            "mean" = sprintf("summarise(mean = mean(%s, na.rm = TRUE), .groups = 'drop')", t_col),
            "sum"  = sprintf("summarise(sum = sum(%s, na.rm = TRUE), .groups = 'drop')", t_col),
            "min"  = sprintf("summarise(min = min(%s, na.rm = TRUE), .groups = 'drop')", t_col),
            "max"  = sprintf("summarise(max = max(%s, na.rm = TRUE), .groups = 'drop')", t_col),
            "sd"   = sprintf("summarise(sd = sd(%s, na.rm = TRUE), .groups = 'drop')", t_col),
            "sem"  = sprintf("summarise(sem = sd(%s, na.rm = TRUE) / sqrt(sum(!is.na(%s))), .groups = 'drop')", t_col, t_col),
            "ci"   = sprintf("summarise(mean = mean(%s, na.rm=T), ci_lower = mean - qt(0.975, n-1)*sem, ci_upper = mean + qt(0.975, n-1)*sem, .groups = 'drop')", t_col)
          )
        }
        log_command(sprintf("%s <- %s %%>%% %s%s", new_name, rv$dataset_names[[id]], group_str, sum_str))

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
    req(input$join_left, input$join_right, input$join_type)
    left_df <- rv$datasets[[input$join_left]]
    right_df <- rv$datasets[[input$join_right]]
    req(left_df, right_df)

    if (input$join_left == input$join_right) {
      return(showNotification("Left and Right datasets must be different.", type = "warning"))
    }

    save_history()
    tryCatch(
      {
        join_func <- get(input$join_type, asNamespace("dplyr"))

        if (length(input$join_by) > 0) {
          res_df <- join_func(left_df, right_df, by = input$join_by)
        } else {
          res_df <- join_func(left_df, right_df)
        }

        left_name <- rv$dataset_names[[input$join_left]]
        right_name <- rv$dataset_names[[input$join_right]]
        new_name <- paste0("Joined_", left_name, "_", right_name)
        add_dataset(new_name, res_df)

        if (length(input$join_by) > 0) {
          by_str <- paste0("c(", paste(sprintf("'%s'", input$join_by), collapse = ", "), ")")
          log_command(sprintf("%s <- %s(%s, %s, by = %s)", new_name, input$join_type, left_name, right_name, by_str))
        } else {
          log_command(sprintf("%s <- %s(%s, %s)", new_name, input$join_type, left_name, right_name))
        }

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
        sel_cols <- paste(input$select_cols, collapse = ", ")
        log_command(sprintf("%s <- %s %%>%% select(%s)", rv$dataset_names[[id]], rv$dataset_names[[id]], sel_cols))
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
        log_command(sprintf("%s <- %s %%>%% rename(%s = %s)", rv$dataset_names[[id]], rv$dataset_names[[id]], input$rename_col_new, input$rename_col_old))
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
          cols_str <- paste(input$distinct_cols, collapse = ", ")
          log_command(sprintf("%s <- %s %%>%% distinct(c(%s), .keep_all = %s)", rv$dataset_names[[id]], rv$dataset_names[[id]], cols_str, input$distinct_keep_all))
        } else {
          rv$datasets[[id]] <- df %>% distinct()
          log_command(sprintf("%s <- %s %%>%% distinct()", rv$dataset_names[[id]], rv$dataset_names[[id]]))
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
        
        cols_str <- paste(input$pivot_l_cols, collapse = ", ")
        log_command(sprintf("%s <- %s %%>%% pivot_longer(cols = c(%s), names_to = '%s', values_to = '%s')", new_name, rv$dataset_names[[id]], cols_str, input$pivot_l_names_to, input$pivot_l_values_to))
        
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
        
        id_cols_sel <- setdiff(input$pivot_w_id_cols, "None")
        id_cols_str <- if (length(id_cols_sel) > 0) sprintf(", id_cols = c(%s)", paste(id_cols_sel, collapse = ", ")) else ""
        log_command(sprintf("%s <- %s %%>%% pivot_wider(names_from = '%s', values_from = '%s'%s)", new_name, rv$dataset_names[[id]], input$pivot_w_names_from, input$pivot_w_values_from, id_cols_str))
        
        showNotification("Pivot Wider completed in new tab.", type = "message")
        removeModal()
      },
      error = function(e) showNotification(e$message, type = "error")
    )
  })
}

shinyApp(ui, server)
