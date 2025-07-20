# Universities in Kenya

library(tidyverse)
library(readr)
library(readxl)

# Load the data

kenya_university <- read_excel(here::here("university_kenya_app",
                                          "processed_tables",
                                          "kenya_universities_list.xlsx"))

# Save as RDS