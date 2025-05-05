# Hass Consult Nairobi Land Price Analysis

library(tidyverse)
#library(tidyr)
library(janitor)
library(readxl)
library(scales)
library(devtools)
#devtools::install_github('bbc/bbplot')
#library(bbplot)
#install.packages("wordcloud")
library(wordcloud)
# install.packages("ggwordcloud")
library(ggwordcloud)
# install.packages("treemapify")
library(treemapify)
library(treemapify)
# install.packages("ggrepel")
library(ggrepel)
library(zoo)
#install.packages("here")
library(here)
#install.packages("xlsx")
library(xlsx)
library(leaflet)

# 1) Load the required data

suburbs <- read_excel("hass_land_price_app/processed_tables/hass_suburbs_combined_2015_to_20XX.xlsx.xlsx")
satellite <- read_excel("hass_land_price_app/processed_tables/hass_satellite_combined_2015_to_20XX.xlsx.xlsx")
locations <- read_excel("hass_land_price_app/processed_tables/all_data_locations.xlsx")

# 2) Clean the data

suburbs <- suburbs %>%
  clean_names()

satellite <- satellite %>%
  clean_names()

all_data <- rbind(suburbs, satellite)

all_data <- all_data %>%
  mutate(quarter_double = 2 * quarter) %>%
  mutate(quarter_year = paste(year, quarter_double, sep = ".")) %>%
  mutate(quart_year_label = paste0("Q", quarter, " ", year))

all_data$average_price <- as.numeric(all_data$average_price)
all_data$x25th_percentile <- as.numeric(all_data$x25th_percentile)
all_data$x75th_percentile <- as.numeric(all_data$x75th_percentile)
all_data$quarter_year <- as.yearqtr(as.numeric(all_data$quarter_year))

# For the plot
all_data_avg_price <- all_data %>%
  select(location, quarter_year, year, quarter, average_price, quart_year_label)

all_data_percentile_price <- all_data %>%
  select(location, quarter_year, x25th_percentile, x75th_percentile, quart_year_label)

# For the data table
all_data_avg_price_data <- all_data %>%
  select(Location = location, Year = year, Quarter = quarter, "Average Price (KShs)" = average_price, quart_year_label)

# Check data types 

str(all_data_avg_price$quarter_year)
str(all_data_percentile_price)
str(all_data_avg_price_data)

# Store the dataset

write.xlsx(all_data_avg_price, "hass_land_price_app/hass_land_price_app/all_data_avg_price.xlsx")
write.xlsx(all_data_avg_price_data, "hass_land_price_app/hass_land_price_app/all_data_avg_price_data.xlsx")
write.xlsx(locations, "hass_land_price_app/hass_land_price_app/all_data_locations.xlsx")

saveRDS(all_data_avg_price, "hass_land_price_app/hass_land_price_app/all_data_avg_price.rds")
saveRDS(all_data_avg_price_data, "hass_land_price_app/hass_land_price_app/all_data_avg_price_data.rds")
saveRDS(locations, "hass_land_price_app/hass_land_price_app/all_data_locations.rds")

# 3) Plot  the data / EDA

# use max to figure out groupings by average price

max <- all_data_avg_price %>% 
  group_by(location) %>%
  summarize(max = max(average_price, na.rm = TRUE))

location_1 <- c("Kiserian", "Kitengela", "Athi River", "Juja", "Thika")
location_2 <- c("Limuru", "Ongata Rongai", "Syokimau", "Ruiru", "Ngong")

location_3 <- c("Tigoni", "Mlolongo", "Kiambu", "Karen", "Langata")
location_4 <- c("Donholm", "Ridgeways", "Runda", "Loresho", "Kitisuru", "Ruaka")

location_5 <- c("Nyari", "Muthaiga", "Spring Valley", "Lavington", "Gigiri", "Eastleigh")
location_6 <- c("Kileleshwa", "Riverside", "Parklands", "Kilimani", "Westlands", "Upper Hill")

all_data_avg_price %>%
  filter(location %in% location_1) %>%
  ggplot(aes(quarter_year, average_price, color = location)) +
  geom_line() +
  geom_point() +
  theme_classic() + 
  scale_y_continuous(labels = scales::comma) 
  
all_data_avg_price %>%
  filter(location %in% location_2) %>%
  ggplot(aes(quarter_year, average_price, color = location)) +
  geom_line() +
  geom_point() +
  theme_classic() + 
  scale_y_continuous(labels = scales::comma) 

all_data_avg_price %>%
  filter(location %in% location_3) %>%
  ggplot(aes(quarter_year, average_price, color = location)) +
  geom_line() +
  geom_point() +
  theme_classic() + 
  scale_y_continuous(labels = scales::comma) 

all_data_avg_price %>%
  filter(location %in% location_4) %>%
  ggplot(aes(quarter_year, average_price, color = location)) +
  geom_line() +
  geom_point() +
  theme_classic() + 
  scale_y_continuous(labels = scales::comma) 

all_data_avg_price %>%
  filter(location %in% location_5) %>%
  ggplot(aes(quarter_year, average_price, color = location)) +
  geom_line() +
  geom_point() +
  theme_classic() + 
  scale_y_continuous(labels = scales::comma) 

all_data_avg_price %>%
  filter(location %in% location_6) %>%
  ggplot(aes(quarter_year, average_price, color = location)) +
  geom_line(size=2) +
  theme_classic() + 
  scale_y_continuous(labels = scales::comma) +
  labs(color = "Location") +
  theme(legend.position="bottom",
        legend.title = element_text(size = 14),
        legend.text = element_text(size = 14),
        legend.background = element_rect(fill = "azure2"),
        panel.grid.major.x=element_blank(),
        panel.grid.minor.x=element_blank(),
        panel.grid.minor.y=element_blank(),
        axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 10),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16),
        plot.title = element_text(size = 24, face = "bold"),
        plot.subtitle = element_text(size = 18),
        plot.background = element_rect(fill = "azure2", color = "azure2"),
        panel.background = element_rect(fill = "azure2", color = "azure2"))

### TESTS FOR THE APP ###

land_price <- readRDS("hass_land_price_app/hass_land_price_app/all_data_avg_price.rds")
land_price_data <- readRDS("hass_land_price_app/hass_land_price_app/all_data_avg_price_data.rds")

land_price %>%
  group_by(location) %>%
  filter(quarter_year == max(quarter_year))


### Suburbs and Satellite Towns

## Suburbs
choices = c("Donholm", "Gigiri", "Karen", "Kileleshwa", "Kilimani", "Kitisuru",     
            "Langata", "Lavington", "Loresho", "Muthaiga", "Nyari", "Parklands",    
            "Ridgeways", "Riverside", "Runda", "Spring Valley", "Upperhill", 
            "Westlands", "Eastleigh")

## Satellite
choices = c("Athi River", "Juja", "Kiambu", "Kiserian",     
            "Kitengela", "Limuru", "Mlolongo", "Ngong", "Ongata Rongai",    
            "Ruaka", "Ruiru", "Syokimau", "Thika", "Tigoni")

all_data_avg_price_data %>%
  filter(Year == 2023)


