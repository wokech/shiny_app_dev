library(shiny)
library(tidyverse)
library(httr)
library(jsonlite)

# Define the African country capital city data
african_capitals <- data.frame(
  country = c("Algeria", "Angola", "Benin", "Botswana", "Burkina Faso", "Burundi", "Cabo Verde", "Cameroon", "Central African Republic", "Chad", "Comoros", "Congo (Democratic Republic of the)", "Congo (Republic of the)", "Côte d'Ivoire", "Djibouti", "Egypt", "Equatorial Guinea", "Eritrea", "Eswatini", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea", "Guinea-Bissau", "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius", "Morocco", "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda", "São Tomé and Príncipe", "Senegal", "Seychelles", "Sierra Leone", "Somalia", "South Africa", "South Sudan", "Sudan", "Tanzania", "Togo", "Tunisia", "Uganda", "Zambia", "Zimbabwe"),
  capital = c("Algiers", "Luanda", "Porto-Novo", "Gaborone", "Ouagadougou", "Gitega", "Praia", "Yaoundé", "Bangui", "N'Djamena", "Moroni", "Kinshasa", "Brazzaville", "Yamoussoukro", "Djibouti", "Cairo", "Malabo", "Asmara", "Mbabane", "Addis Ababa", "Libreville", "Banjul", "Accra", "Conakry", "Bissau", "Nairobi", "Maseru", "Monrovia", "Tripoli", "Antananarivo", "Lilongwe", "Bamako", "Nouakchott", "Port Louis", "Rabat", "Maputo", "Windhoek", "Niamey", "Abuja", "Kigali", "São Tomé", "Dakar", "Victoria", "Freetown", "Mogadishu", "Pretoria", "Juba", "Khartoum", "Dodoma", "Lomé", "Tunis", "Kampala", "Lusaka", "Harare")
)

# Define the UI
ui <- fluidPage(
  titlePanel("African Capital Weather"),
  sidebarLayout(
    sidebarPanel(
      selectInput("country", "Select a country:", choices = african_capitals$country)
    ),
    mainPanel(
      textOutput("weather_info")
    )
  )
)

# Define the server
server <- function(input, output) {
  output$weather_info <- renderText({
    # Get the weather data for the selected capital city
    country <- input$country
    capital <- african_capitals$capital[african_capitals$country == country]
    
    # API endpoint and your API key
    api_key <- "4e5eeaec857a4605b8f39e30eb93ebf6"
    base_url <- "http://api.openweathermap.org/data/3.6/weather"
    
    params <- list(
      q = capital,
      appid = api_key,
      units = "metric"
    )
    
    response <- GET(base_url, query = params)
    
    if (response$status_code == 200) {
      data <- fromJSON(content(response, "text"))
      
      # Extract the relevant weather information
      temperature <- data$main$temp
      description <- data$weather[[1]]$description
      icon <- data$weather[[1]]$icon
      
      # Format the weather information
      weather_info <- sprintf("Current weather in %s, %s:\nTemperature: %.1f°C\nDescription: %s\nIcon: http://openweathermap.org/img/w/%s.png", capital, country, temperature, description, icon)
      
      return(weather_info)
    } else {
      return("Failed to retrieve weather data.")
    }
  })
}

# Run the app
shinyApp(ui = ui, server = server)