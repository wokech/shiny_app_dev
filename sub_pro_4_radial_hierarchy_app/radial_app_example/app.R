# Load required libraries
library(shiny)
library(readxl)
library(dplyr)
library(tidyr)
library(plotly)

# Define UI
ui <- fluidPage(
  titlePanel("Kenya Population by Administrative Hierarchy"),
  plotlyOutput("sunburstPlot", height = "800px")
)

# Define Server
server <- function(input, output, session) {
  
  output$sunburstPlot <- renderPlotly({
    
    # Load and process the dataset
    df <- read_excel(here::here("sub_pro_4_radial_hierarchy_app", 
                            "processed_tables", "micro_census_processed.xlsx"))
    
    # Split full_name into hierarchical levels
    df_clean <- df %>%
      mutate(full_name = strsplit(full_name, ",")) %>%
      unnest_wider(full_name, names_sep = "_") %>%
      rename_with(~ paste0("level_", seq_along(.)), starts_with("full_name")) %>%
      mutate(across(starts_with("level_"), ~ trimws(as.character(.)))) %>%
      select(starts_with("level_"), total)
    
    # Replace NA with "Unknown"
    df_clean <- df_clean %>%
      mutate(across(everything(), ~ ifelse(is.na(.), "Unknown", .)))
    
    # Create id and parent
    df_clean <- df_clean %>%
      mutate(
        id = apply(select(., starts_with("level_")), 1, function(x) paste(x, collapse = "/")),
        parent = apply(select(., starts_with("level_")), 1, function(x) {
          x <- x[!is.na(x)]
          if (length(x) <= 1) return(NA)
          paste(x[1:(length(x)-1)], collapse = "/")
        }),
        label = coalesce(level_6, level_5, level_4, level_3, level_2, level_1)
      )
    
    # Create the sunburst chart
    plot_ly(
      data = df_clean,
      type = "sunburst",
      ids = ~id,
      labels = ~label,
      parents = ~parent,
      values = ~total,
      branchvalues = "total"
    ) %>%
      layout(title = "Kenya Population by Administrative Hierarchy")
  })
}

# Run the app
shinyApp(ui, server)
