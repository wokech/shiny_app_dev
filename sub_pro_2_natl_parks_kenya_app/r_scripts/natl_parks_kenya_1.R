# 1) Load the relevant packages and libraries

library(readxl)
library(tidyverse)
library(janitor)

# 2) Load the data

# Set the appropriate working directory

nat_parks_ke <- read_excel("natl_parks_kenya_app/processed_tables/parks.xlsx")

# 3) Wrangle data

nat_parks_ke <- nat_parks_ke[1:32,]

nat_parks_ke[1] <- lapply(nat_parks_ke[1], as.character)
nat_parks_ke[2:6] <- lapply(nat_parks_ke[2:6], as.numeric)

str(nat_parks_ke)

# Clean data
nat_parks_ke_clean <- nat_parks_ke %>%
  clean_names()

# Change column names

nat_parks_ke_clean <- nat_parks_ke_clean %>%
  rename(
    "2018" = "x2018",
    "2019" = "x2019",
    "2020" = "x2020",
    "2021" = "x2021",
    "2022" = "x2022"
  )

# Replace dashes with zeros

nat_parks_ke_clean <- nat_parks_ke_clean %>%
  mutate(across(everything(), ~ replace_na(., 0)))

# Make a pivot longer table

nat_parks_ke_clean_longer <- nat_parks_ke_clean |>
  pivot_longer(cols = c("2018", "2019", "2020", "2021", "2022"),
               names_to = "year",
               values_to = "visitors") %>%
  mutate(year = as.numeric(year),
         visitors = as.integer(visitors))

saveRDS(nat_parks_ke_clean_longer, "natl_parks_kenya_app/natl_parks_kenya_app/nat_parks_ke_data.rds")
readRDS("natl_parks_kenya_app/natl_parks_kenya_app/nat_parks_ke_data.rds")
