# Universities in Kenya

library(tidyverse)
library(readr)
library(readxl)
library(janitor)

# Load the data

kenya_university <- read_excel(here::here("sub_pro_3_university_kenya_app",
                                          "processed_tables",
                                          "kenya_universities_list.xlsx"))

# Clean the data
kenya_university_clean <- kenya_university |>
  clean_names()

# Save as RDS
saveRDS(kenya_university_clean, "sub_pro_3_university_kenya_app/university_kenya_app/kenya_universities_list.rds")
readRDS("sub_pro_3_university_kenya_app/university_kenya_app/kenya_universities_list.rds")
