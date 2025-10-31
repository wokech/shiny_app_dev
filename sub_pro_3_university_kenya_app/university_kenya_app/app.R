# Load necessary libraries
library(shiny)
library(shinythemes)
library(leaflet)
library(dplyr)
library(stringr)
library(plotly)

# Load the processed data
universities <- readRDS("kenya_universities_list.rds")

# UI
ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("Kenyan Universities Map Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      tags$h4("Filters"),
      selectInput("county", "Filter by County:",
                  choices = c("All", sort(unique(universities$county))),
                  selected = "All"),
      
      selectInput("governance", "Filter by Governance:",
                  choices = c("All", sort(unique(universities$governance))),
                  selected = "All"),
      
      checkboxInput("show_all", "Show All Universities on Map", value = TRUE),
      
      conditionalPanel(
        condition = "!input.show_all",
        selectInput("selected_uni", "Select a University:",
                    choices = universities$university)
      ),
      
      hr(),
      tags$p("Click a marker to see details, including linked website.")
    ),
    
    mainPanel(
      leafletOutput("university_map", height = "600px"),
      br(),
      plotlyOutput("faculty_plot", height = "250px")
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Reactive: Filtered dataset
  filtered_data <- reactive({
    data <- universities
    
    if (input$county != "All") {
      data <- data %>% filter(county == input$county)
    }
    
    if (input$governance != "All") {
      data <- data %>% filter(governance == input$governance)
    }
    
    data
  })
  
  # Update university list dynamically
  observe({
    updateSelectInput(session, "selected_uni",
                      choices = filtered_data()$university)
  })
  
  # Render map
  output$university_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 37, lat = 0.5, zoom = 6)
  })
  
  # Add markers (all or selected)
  observe({
    data <- filtered_data()
    leafletProxy("university_map") %>% clearMarkers() %>% clearMarkerClusters()
    
    if (input$show_all) {
      leafletProxy("university_map") %>%
        addMarkers(
          data = data,
          lng = ~longitude,
          lat = ~latitude,
          clusterOptions = markerClusterOptions(),
          popup = ~paste0(
            "<b>University:</b> ", university, "<br>",
            "<b><a href='", website, "' target='_blank'>", "Website", "</a></b><br>",
            "<b>County:</b> ", county, "<br>",
            "<b>Governance:</b> ", governance, "<br>"
            )
        )
    } else {
      selected <- data %>% filter(university == input$selected_uni)
      if (nrow(selected) > 0) {
        popup <- paste0(
          "<b><a href='", selected$website, "' target='_blank'>", selected$university, "</a></b><br>",
          "<b>County:</b> ", selected$county, "<br>",
          "<b>Governance:</b> ", selected$governance, "<br>"
          )
        leafletProxy("university_map") %>%
          addMarkers(
            lng = selected$longitude,
            lat = selected$latitude,
            popup = popup
          )
      }
    }
  })
  
}

# Run App
shinyApp(ui, server)
