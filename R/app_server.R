#' The application server-side
#'
#' @param input,output,session Internal parameters for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import dplyr
#' @noRd
app_server <- function(input, output, session) {
    # Your application server logic
    message("[DEBUG] ========================================")
    message("[DEBUG] TidyBlock app_server initializing...")
    message("[DEBUG] ========================================")

    # Reactive state for the application
    state <- reactiveValues(
        raw_data = NULL,
        last_valid_df = NULL, # Holds the last successful dataframe (not plot) for schema inspection
        active_dataset = "data", # Default name if nothing loaded
        datasets = list(), # list(name = df)
        pipeline = list(), # list(id = types)
        pipeline_code = list(), # list(id = reactive_code)
        modules = list() # List of module IDs to maintain order if needed
    )
    message("[DEBUG] Reactive state initialized")

    # Call the import module
    mod_import_server("import_1", state)
    message("[DEBUG] Import module server initialized")

    # Module counter
    mod_counter <- reactiveVal(0)
    message("[DEBUG] Module counter initialized")

    # Helper to add module
    observeEvent(input$add_filter, {
        message("[DEBUG] Filter button clicked") # Console log
        tryCatch(
            {
                showNotification("Adding Filter module...", duration = 1, type = "message")
                mod_counter(mod_counter() + 1)
                id <- paste0("filter_", mod_counter())
                message("[DEBUG] Creating filter module with id: ", id)
                state$pipeline[[id]] <- "filter"

                insertUI(
                    selector = "#pipeline_container",
                    where = "beforeEnd",
                    ui = mod_filter_ui(id)
                )
                message("[DEBUG] Filter UI inserted for id: ", id)

                state$pipeline_code[[id]] <- mod_filter_server(id, state)
                message("[DEBUG] Filter server initialized for id: ", id)
            },
            error = function(e) {
                message("[ERROR] Failed to add filter module: ", e$message)
                showNotification(paste("Error adding Filter:", e$message), type = "error", duration = 5)
            }
        )
    })

    observeEvent(input$add_select, {
        message("[DEBUG] Select button clicked")
        tryCatch(
            {
                showNotification("Adding Select module...", duration = 1, type = "message")
                mod_counter(mod_counter() + 1)
                id <- paste0("select_", mod_counter())
                message("[DEBUG] Creating select module with id: ", id)
                state$pipeline[[id]] <- "select"

                insertUI(
                    selector = "#pipeline_container",
                    where = "beforeEnd",
                    ui = mod_select_ui(id)
                )
                message("[DEBUG] Select UI inserted for id: ", id)

                state$pipeline_code[[id]] <- mod_select_server(id, state)
                message("[DEBUG] Select server initialized for id: ", id)
            },
            error = function(e) {
                message("[ERROR] Failed to add select module: ", e$message)
                showNotification(paste("Error adding Select:", e$message), type = "error", duration = 5)
            }
        )
    })

    observeEvent(input$add_mutate, {
        message("[DEBUG] Mutate button clicked")
        tryCatch(
            {
                showNotification("Adding Mutate module...", duration = 1, type = "message")
                mod_counter(mod_counter() + 1)
                id <- paste0("mutate_", mod_counter())
                message("[DEBUG] Creating mutate module with id: ", id)
                state$pipeline[[id]] <- "mutate"

                insertUI(
                    selector = "#pipeline_container",
                    where = "beforeEnd",
                    ui = mod_mutate_ui(id)
                )
                message("[DEBUG] Mutate UI inserted for id: ", id)

                state$pipeline_code[[id]] <- mod_mutate_server(id, state)
                message("[DEBUG] Mutate server initialized for id: ", id)
            },
            error = function(e) {
                message("[ERROR] Failed to add mutate module: ", e$message)
                showNotification(paste("Error adding Mutate:", e$message), type = "error", duration = 5)
            }
        )
    })

    observeEvent(input$add_group_by, {
        message("[DEBUG] Group By button clicked")
        tryCatch(
            {
                showNotification("Adding Group By module...", duration = 1, type = "message")
                mod_counter(mod_counter() + 1)
                id <- paste0("group_by_", mod_counter())
                message("[DEBUG] Creating group_by module with id: ", id)
                state$pipeline[[id]] <- "group_by"

                insertUI(
                    selector = "#pipeline_container",
                    where = "beforeEnd",
                    ui = mod_group_by_ui(id)
                )
                message("[DEBUG] Group By UI inserted for id: ", id)

                state$pipeline_code[[id]] <- mod_group_by_server(id, state)
                message("[DEBUG] Group By server initialized for id: ", id)
            },
            error = function(e) {
                message("[ERROR] Failed to add group_by module: ", e$message)
                showNotification(paste("Error adding Group By:", e$message), type = "error", duration = 5)
            }
        )
    })

    observeEvent(input$add_summarize, {
        message("[DEBUG] Summarize button clicked")
        tryCatch(
            {
                showNotification("Adding Summarize module...", duration = 1, type = "message")
                mod_counter(mod_counter() + 1)
                id <- paste0("summarize_", mod_counter())
                message("[DEBUG] Creating summarize module with id: ", id)
                state$pipeline[[id]] <- "summarize"

                insertUI(
                    selector = "#pipeline_container",
                    where = "beforeEnd",
                    ui = mod_summarize_ui(id)
                )
                message("[DEBUG] Summarize UI inserted for id: ", id)

                state$pipeline_code[[id]] <- mod_summarize_server(id, state)
                message("[DEBUG] Summarize server initialized for id: ", id)
            },
            error = function(e) {
                message("[ERROR] Failed to add summarize module: ", e$message)
                showNotification(paste("Error adding Summarize:", e$message), type = "error", duration = 5)
            }
        )
    })

    observeEvent(input$add_arrange, {
        message("[DEBUG] Arrange button clicked")
        tryCatch(
            {
                showNotification("Adding Arrange module...", duration = 1, type = "message")
                mod_counter(mod_counter() + 1)
                id <- paste0("arrange_", mod_counter())
                message("[DEBUG] Creating arrange module with id: ", id)
                state$pipeline[[id]] <- "arrange"

                insertUI(
                    selector = "#pipeline_container",
                    where = "beforeEnd",
                    ui = mod_arrange_ui(id)
                )
                message("[DEBUG] Arrange UI inserted for id: ", id)

                state$pipeline_code[[id]] <- mod_arrange_server(id, state)
                message("[DEBUG] Arrange server initialized for id: ", id)
            },
            error = function(e) {
                message("[ERROR] Failed to add arrange module: ", e$message)
                showNotification(paste("Error adding Arrange:", e$message), type = "error", duration = 5)
            }
        )
    })

    observeEvent(input$add_join, {
        message("[DEBUG] Join button clicked")
        tryCatch(
            {
                showNotification("Adding Join module...", duration = 1, type = "message")
                mod_counter(mod_counter() + 1)
                id <- paste0("join_", mod_counter())
                message("[DEBUG] Creating join module with id: ", id)
                state$pipeline[[id]] <- "join"

                insertUI(
                    selector = "#pipeline_container",
                    where = "beforeEnd",
                    ui = mod_join_ui(id)
                )
                message("[DEBUG] Join UI inserted for id: ", id)

                state$pipeline_code[[id]] <- mod_join_server(id, state)
                message("[DEBUG] Join server initialized for id: ", id)
            },
            error = function(e) {
                message("[ERROR] Failed to add join module: ", e$message)
                showNotification(paste("Error adding Join:", e$message), type = "error", duration = 5)
            }
        )
    })

    observeEvent(input$add_plot, {
        message("[DEBUG] Plot button clicked")
        tryCatch(
            {
                showNotification("Adding Plot module...", duration = 1, type = "message")
                mod_counter(mod_counter() + 1)
                id <- paste0("plot_", mod_counter())
                message("[DEBUG] Creating plot module with id: ", id)
                state$pipeline[[id]] <- "plot"

                insertUI(
                    selector = "#pipeline_container",
                    where = "beforeEnd",
                    ui = mod_plot_ui(id)
                )
                message("[DEBUG] Plot UI inserted for id: ", id)

                state$pipeline_code[[id]] <- mod_plot_server(id, state)
                message("[DEBUG] Plot server initialized for id: ", id)
            },
            error = function(e) {
                message("[ERROR] Failed to add plot module: ", e$message)
                showNotification(paste("Error adding Plot:", e$message), type = "error", duration = 5)
            }
        )
    })

    # Render Pipeline UI
    # output$pipeline_ui Removed in favor of insertUI

    # Code Preview (Console)
    # Code Preview (Console)
    # Pipeline Logic
    pipeline_steps <- reactive({
        # Determine order from UI or state
        ui_ids <- input$pipeline_container_order
        state_ids <- names(state$pipeline)

        if (is.null(ui_ids)) {
            ids <- state_ids
        } else {
            # Filter UI ids to only valid ones
            current_ui_ids <- ui_ids[ui_ids %in% state_ids]
            # Find any new IDs not yet in UI order (e.g. just added)
            new_ids <- setdiff(state_ids, current_ui_ids)
            # Append new IDs
            ids <- c(current_ui_ids, new_ids)
        }

        # Collect all code chunks in order
        codes <- lapply(ids, function(id) {
            if (!is.null(state$pipeline_code[[id]])) {
                state$pipeline_code[[id]]()
            } else {
                NULL
            }
        })

        # Use the variable name of the active dataset
        start_data <- if (!is.null(state$active_dataset)) state$active_dataset else "data"
        list(data = start_data, steps = codes, ids = ids)
    })

    # Generated Code Text (for preview)
    generated_code <- reactive({
        ps <- pipeline_steps()
        construct_pipeline(ps$data, ps$steps)
    })

    # Execute Pipeline
    # Use a debounced trigger to avoid infinite reactive loops.
    # The problem: this observe reads pipeline_steps() which depends on pipeline_code reactives,
    # which depend on module inputs. Module inputs get updated by observe()s that watch
    # state$last_valid_df / state$upstream_cols. Writing those inside THIS observe creates a cycle.
    # Solution: collect upstream_cols in a plain environment (not reactive), and only write
    # state$current_data / state$last_valid_df at the very end, guarding against no-op updates.

    # A plain (non-reactive) environment to hold upstream column info
    .upstream_env <- new.env(parent = emptyenv())
    .upstream_env$cols <- list()

    observe({
        ps <- pipeline_steps()
        # Isolate raw_data read so that setting raw_data alone doesn't re-trigger this
        # (pipeline_steps() already captures the dependency we need)
        raw <- isolate(state$raw_data)
        datasets <- isolate(state$datasets)
        req(ps$data, raw)

        message("[DEBUG] Pipeline execution triggered")

        # Track valid dataframe in a mutable environment to access it in error handler
        tracker <- new.env()
        tracker$valid_df <- NULL

        tryCatch(
            {
                # Create a specific environment for evaluation
                eval_env <- new.env(parent = globalenv())

                if (!is.null(datasets)) {
                    list2env(datasets, envir = eval_env)
                }

                # Start execution
                current_res <- get(ps$data, envir = eval_env)

                # Initial validity check
                if (inherits(current_res, "data.frame")) {
                    tracker$valid_df <- current_res
                }

                # Prepare upstream columns tracking (plain env, NOT reactive)
                new_upstream <- list()

                # Initial columns from the starting data
                initial_cols <- if (inherits(current_res, "data.frame")) names(current_res) else character(0)

                # Initialize loop
                current_cols <- initial_cols

                for (i in seq_along(ps$steps)) {
                    step_code <- ps$steps[[i]]
                    step_id <- ps$ids[[i]]

                    # Store UPSTREAM columns (in plain list, not reactive state)
                    new_upstream[[step_id]] <- current_cols

                    if (is.null(step_code)) next

                    message(paste("[DEBUG] Executing Step:", step_code))

                    # Store current result in temp variable for piping
                    assign(".val", current_res, envir = eval_env)
                    cmd <- paste(".val |>", step_code)

                    # Execute the step
                    current_res <- eval(parse(text = cmd), envir = eval_env)

                    if (inherits(current_res, "data.frame")) {
                        message(paste("[DEBUG] Step result cols:", paste(names(current_res), collapse = ", ")))
                        tracker$valid_df <- current_res
                        current_cols <- names(current_res)
                    }
                }

                # Only write to reactive state if something actually changed, to avoid re-triggering
                isolate({
                    state$current_data <- current_res

                    # Update upstream cols
                    .upstream_env$cols <- new_upstream
                    state$upstream_cols <- new_upstream

                    # Update last valid dataframe for modules to use (schema inspection)
                    if (!is.null(tracker$valid_df)) {
                        old_names <- if (!is.null(state$last_valid_df)) names(state$last_valid_df) else NULL
                        new_names <- names(tracker$valid_df)
                        if (!identical(old_names, new_names)) {
                            state$last_valid_df <- tracker$valid_df
                        }
                    }
                })

                message("[DEBUG] Pipeline execution completed successfully")
            },
            error = function(e) {
                isolate({
                    # If valid_df is available from partial execution, update state!
                    if (!is.null(tracker$valid_df)) {
                        if (is.null(state$last_valid_df) || !identical(names(state$last_valid_df), names(tracker$valid_df))) {
                            state$last_valid_df <- tracker$valid_df
                        }
                        state$current_data <- tracker$valid_df
                    }
                })

                # Show error to user so they know why the plot/result isn't updating
                showNotification(paste("Pipeline Error:", e$message), type = "error", duration = 3)
                warning(paste("Pipeline Eval Error:", e$message))
            }
        )
    })

    # Code Preview (Console)
    output$code_preview <- renderText({
        generated_code()
    })
}
