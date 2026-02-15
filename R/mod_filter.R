#' Filter UI Function
#'
#' @noRd
#' @importFrom shiny NS tagList div actionButton icon selectInput textInput uiOutput observeEvent reactiveVal moduleServer removeUI insertUI updateSelectInput observe is.reactive reactive
#' @importFrom bslib card card_header card_body
#' @importFrom shinyjqui jqui_resizable
#' @importFrom glue glue
mod_filter_ui <- function(id) {
    ns <- NS(id)

    # JavaScript to handle dynamic button clicks and pass ID to server
    js_script <- sprintf("
    $(document).on('click', '.add-rule-btn-%s', function() {
        var group_id = $(this).data('group-id');
        Shiny.setInputValue('%s', {group_id: group_id, nonce: Math.random()}, {priority: 'event'});
    });
    $(document).on('click', '.add-group-btn-%s', function() {
        var group_id = $(this).data('group-id');
        Shiny.setInputValue('%s', {group_id: group_id, nonce: Math.random()}, {priority: 'event'});
    });
    $(document).on('click', '.remove-btn-%s', function() {
        var node_id = $(this).data('node-id');
        Shiny.setInputValue('%s', {node_id: node_id, nonce: Math.random()}, {priority: 'event'});
    });
    ", id, ns("add_rule_click"), id, ns("add_group_click"), id, ns("remove_node_click"))

    tagList(
        tags$script(HTML(js_script)),
        tags$style(HTML(sprintf("
            .filter-group-%s {
                border-left: 3px solid #17a2b8;
                padding-left: 10px;
                margin-top: 10px;
                margin-bottom: 10px;
                background-color: rgba(23, 162, 184, 0.05);
                border-radius: 4px;
            }
            .filter-item-%s {
                margin-top: 5px;
                margin-bottom: 5px;
                display: flex;
                align-items: center;
                gap: 5px;
                padding: 5px;
                background-color: white;
                border: 1px solid #dee2e6;
                border-radius: 4px;
            }
            .group-header-%s {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 8px;
                background-color: #e9ecef;
                border-radius: 4px;
                margin-bottom: 5px;
            }
        ", id, id, id))),
        div(
            id = id,
            class = "module-card",
            jqui_resizable(
                card(
                    full_screen = TRUE,
                    class = "mb-3",
                    card_header(
                        class = "bg-info text-white",
                        div(
                            "Filter (Advanced)",
                            actionButton(ns("remove_ui"), "", icon = icon("trash"), class = "btn-danger btn-sm float-end", style = "margin-left: 10px;"),
                            span(class = "float-end", icon("filter"))
                        )
                    ),
                    card_body(
                        div(id = ns("filter_root"))
                    )
                )
            )
        )
    )
}

#' Filter Server Function
#'
#' @noRd
mod_filter_server <- function(id, state) {
    moduleServer(id, function(input, output, session) {
        ns <- session$ns

        # Helper to generate unique IDs
        get_uid <- function() {
            paste0(sample(c(letters, 0:9), 8, replace = TRUE), collapse = "")
        }

        # Helper to get current columns
        get_cols <- function() {
            data_src <- if (!is.null(state$last_valid_df)) state$last_valid_df else state$raw_data
            if (is.null(data_src)) {
                return(character(0))
            }
            names(data_src)
        }

        # Node structure: list of lists
        # nodes[[id]] <- list(id=id, type="group"|"rule", parent=id, children=c(), logic="AND"|NULL, ...)
        nodes <- reactiveVal(list())

        # Helper to render group UI
        create_group_ui <- function(group_id, logic = "AND", is_root = FALSE) {
            div(
                id = ns(paste0("node_", group_id)),
                class = sprintf("filter-group-%s", id),
                div(
                    class = sprintf("group-header-%s", id),
                    selectInput(ns(paste0("logic_", group_id)), NULL,
                        choices = c("AND", "OR"), selected = logic, width = "80px"
                    ),
                    tags$button(
                        class = sprintf("btn btn-sm btn-outline-primary add-rule-btn-%s", id),
                        `data-group-id` = group_id,
                        icon("plus"), "Rule"
                    ),
                    tags$button(
                        class = sprintf("btn btn-sm btn-outline-secondary add-group-btn-%s", id),
                        `data-group-id` = group_id,
                        icon("folder-plus"), "Group"
                    ),
                    if (!is_root) {
                        tags$button(
                            class = sprintf("btn btn-sm btn-outline-danger remove-btn-%s", id),
                            `data-node-id` = group_id,
                            icon("trash")
                        )
                    }
                ),
                div(id = ns(paste0("children_", group_id)))
            )
        }

        # Helper to render rule UI
        create_rule_ui <- function(rule_id) {
            cols <- get_cols()
            div(
                id = ns(paste0("node_", rule_id)),
                class = sprintf("filter-item-%s", id),
                selectInput(ns(paste0("col_", rule_id)), NULL, choices = cols, width = "120px"),
                selectInput(ns(paste0("op_", rule_id)), NULL,
                    choices = c("==", "!=", ">", "<", ">=", "<=", "%in%"), width = "80px"
                ),
                textInput(ns(paste0("val_", rule_id)), NULL, placeholder = "Value", width = "120px"),
                tags$button(
                    class = sprintf("btn btn-sm btn-outline-danger remove-btn-%s", id),
                    `data-node-id` = rule_id,
                    icon("times")
                )
            )
        }

        # Initialize Root
        observe({
            # Only init once if empty
            if (length(nodes()) == 0) {
                root_id <- "root"
                new_nodes <- list()
                new_nodes[[root_id]] <- list(id = root_id, type = "group", logic = "AND", parent = NULL, children = character(0))
                nodes(new_nodes)

                insertUI(
                    selector = paste0("#", ns("filter_root")),
                    ui = create_group_ui(root_id, "AND", is_root = TRUE)
                )
            }
        })

        # Add Rule Handler
        observeEvent(input$add_rule_click, {
            group_id <- input$add_rule_click$group_id
            rule_id <- get_uid()

            curr_nodes <- nodes()
            if (!is.null(curr_nodes[[group_id]])) {
                curr_nodes[[rule_id]] <- list(id = rule_id, type = "rule", parent = group_id)
                curr_nodes[[group_id]]$children <- c(curr_nodes[[group_id]]$children, rule_id)
                nodes(curr_nodes)

                insertUI(
                    selector = paste0("#", ns(paste0("children_", group_id))),
                    ui = create_rule_ui(rule_id)
                )
            }
        })

        # Add Group Handler
        observeEvent(input$add_group_click, {
            parent_id <- input$add_group_click$group_id
            new_group_id <- get_uid()

            curr_nodes <- nodes()
            if (!is.null(curr_nodes[[parent_id]])) {
                curr_nodes[[new_group_id]] <- list(id = new_group_id, type = "group", logic = "AND", parent = parent_id, children = character(0))
                curr_nodes[[parent_id]]$children <- c(curr_nodes[[parent_id]]$children, new_group_id)
                nodes(curr_nodes)

                insertUI(
                    selector = paste0("#", ns(paste0("children_", parent_id))),
                    ui = create_group_ui(new_group_id)
                )
            }
        })

        # Remove Node Handler
        observeEvent(input$remove_node_click, {
            node_id <- input$remove_node_click$node_id
            curr_nodes <- nodes()

            if (!is.null(curr_nodes[[node_id]])) {
                parent_id <- curr_nodes[[node_id]]$parent

                # Recursive delete function
                delete_rec <- function(n_id, node_list) {
                    if (is.null(node_list[[n_id]])) {
                        return(node_list)
                    }

                    if (node_list[[n_id]]$type == "group") {
                        for (child_id in node_list[[n_id]]$children) {
                            node_list <- delete_rec(child_id, node_list)
                        }
                    }
                    node_list[[n_id]] <- NULL
                    return(node_list)
                }

                # Update parent's children list
                if (!is.null(parent_id) && !is.null(curr_nodes[[parent_id]])) {
                    curr_nodes[[parent_id]]$children <- setdiff(curr_nodes[[parent_id]]$children, node_id)
                }

                # Update nodes list
                curr_nodes <- delete_rec(node_id, curr_nodes)
                nodes(curr_nodes)

                # Remove UI
                removeUI(selector = paste0("#", ns(paste0("node_", node_id))))
            }
        })

        # Remove Module Handler
        observeEvent(input$remove_ui, {
            removeUI(selector = paste0("#", id))
            state$pipeline[[id]] <- NULL
            state$pipeline_code[[id]] <- NULL
        })

        # Update columns when data changes
        observe({
            cols <- get_cols()
            req(cols)
            # Iterate over existing rule nodes and update their choices
            # Note: This might be expensive if many nodes, but usually filter logic is small
            # We specifically look for inputs that exist
            curr_nodes <- nodes()
            for (n_id in names(curr_nodes)) {
                if (curr_nodes[[n_id]]$type == "rule") {
                    updateSelectInput(session, paste0("col_", n_id), choices = cols, selected = input[[paste0("col_", n_id)]])
                }
            }
        })

        # Code Generation
        return(reactive({
            curr_nodes <- nodes()
            if (length(curr_nodes) == 0) {
                return(NULL)
            }

            generate_node_code <- function(node_id) {
                node <- curr_nodes[[node_id]]
                if (is.null(node)) {
                    return(NULL)
                }

                if (node$type == "rule") {
                    col <- input[[paste0("col_", node_id)]]
                    op <- input[[paste0("op_", node_id)]]
                    val <- input[[paste0("val_", node_id)]]

                    if (!shiny::isTruthy(col) || !shiny::isTruthy(op) || !shiny::isTruthy(val)) {
                        return(NULL)
                    }

                    # Wrap col in backticks to handle special chars
                    col <- paste0("`", col, "`")

                    # Handle string quotes
                    if (is.character(val) && !is.numeric(val) && !grepl("^[0-9.]+$", val)) {
                        # Simple heuristic: if it looks like a number, treat as number, else quote
                        # Check if user already added quotes
                        if (!grepl("^'.*'$", val) && !grepl('^".*"$', val)) {
                            val <- paste0("'", val, "'")
                        }
                    }
                    glue::glue("{col} {op} {val}")
                } else if (node$type == "group") {
                    logic <- input[[paste0("logic_", node_id)]] # AND/OR
                    if (!shiny::isTruthy(logic)) logic <- "AND"

                    op_sym <- if (logic == "AND") " & " else " | "

                    child_ids <- node$children
                    if (length(child_ids) == 0) {
                        return(NULL)
                    }

                    child_exprs <- c()
                    for (child_id in child_ids) {
                        expr <- generate_node_code(child_id)
                        if (!is.null(expr)) child_exprs <- c(child_exprs, expr)
                    }

                    if (length(child_exprs) == 0) {
                        return(NULL)
                    }
                    if (length(child_exprs) == 1) {
                        return(child_exprs)
                    }

                    joined <- paste(child_exprs, collapse = op_sym)
                    paste0("(", joined, ")")
                }
            }

            root_expr <- generate_node_code("root")
            if (is.null(root_expr)) {
                return(NULL)
            }

            glue::glue("filter({root_expr})")
        }))
    })
}
