#Sunburst

library(readxl)
library(dplyr)
library(tidyr)
library(plotly)

# Load the dataset
df <- read_excel(here::here("sub_pro_4_radial_hierarchy_app", 
                            "processed_tables", "micro_census_processed.xlsx"))

# Split the full_name into up to 6 hierarchy levels
df_clean <- df %>%
  mutate(full_name = strsplit(full_name, ",")) %>%
  unnest_wider(full_name, names_sep = "_") %>%
  rename_with(~ paste0("level_", seq_along(.)), starts_with("full_name")) %>%
  mutate(across(starts_with("level_"), trimws)) %>%
  select(starts_with("level_"), total)

# Replace NAs with "Unknown" to avoid breaking the hierarchy
df_clean <- df_clean %>%
  mutate(across(everything(), ~ ifelse(is.na(.), "Unknown", .)))

# Create ids and parent ids for hierarchy
df_hierarchy <- df_clean %>%
  mutate(
    id = apply(select(., starts_with("level_")), 1, function(x) paste(x[!is.na(x)], collapse = "/")),
    parent = apply(select(., starts_with("level_")), 1, function(x) {
      x <- x[!is.na(x)]
      if (length(x) <= 1) return(NA)
      paste(x[1:(length(x)-1)], collapse = "/")
    }),
    label = level_6
  )

# Fix labels if level_6 is missing
df_hierarchy$label[is.na(df_hierarchy$label)] <- df_hierarchy$level_5[is.na(df_hierarchy$label)]

# Build sunburst chart
plot_ly(
  data = df_hierarchy,
  ids = ~id,
  labels = ~label,
  parents = ~parent,
  values = ~total,
  type = 'sunburst',
  branchvalues = 'total'
) %>%
  layout(title = "Population Distribution Across Hierarchical Levels")
