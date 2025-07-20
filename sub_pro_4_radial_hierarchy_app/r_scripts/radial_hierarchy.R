# Convert data to RDS

library(tidyverse)
library(readxl)
library(readr)
library(openxlsx) # preserve original features

# Convert excel to RDS

# Load data

micro_census <- read.xlsx(here::here("sub_pro_4_radial_hierarchy_app",
                                         "processed_tables", 
                                         "micro_census_processed.xlsx"))

View(micro_census)

# Save as RDS

saveRDS(micro_census, here::here("sub_pro_4_radial_hierarchy_app",
                                 "radial_hierarchy_app", 
                                 "micro_census_processed.rds"))

