# Load necessary libraries
library(shiny)
library(shinythemes)
library(leaflet)
library(dplyr)
library(stringr)
library(plotly)

# Load the processed data
universities <- readRDS("------.rds")

# UI
ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("Kenyan Universities Map Explorer"),
  
  sidebarLayout(
    sidebarPanel(
      tags$h4("Filters"),
      selectInput("county", "Filter by County:",
                  choices = c("All", sort(unique(universities$County))),
                  selected = "All"),
      
      selectInput("governance", "Filter by Governance:",
                  choices = c("All", sort(unique(universities$Governance))),
                  selected = "All"),
      
      checkboxInput("show_all", "Show All Universities on Map", value = TRUE),
      
      conditionalPanel(
        condition = "!input.show_all",
        selectInput("selected_uni", "Select a University:",
                    choices = universities$University)
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
      data <- data %>% filter(County == input$county)
    }
    
    if (input$governance != "All") {
      data <- data %>% filter(Governance == input$governance)
    }
    
    data
  })
  
  # Update university list dynamically
  observe({
    updateSelectInput(session, "selected_uni",
                      choices = filtered_data()$University)
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
          lng = ~Longitude,
          lat = ~Latitude,
          clusterOptions = markerClusterOptions(),
          popup = ~paste0(
            "<b><a href='", Website, "' target='_blank'>", University, "</a></b><br>",
            "<b>County:</b> ", County, "<br>",
            "<b>Governance:</b> ", Governance, "<br>",
            "<b>Schools / Faculties:</b><br>",
            "<ul>", paste0("<li>", str_trim(unlist(str_split(Schools_Faculties, ","))), collapse = "</li><li>"), "</li></ul>"
          )
        )
    } else {
      selected <- data %>% filter(University == input$selected_uni)
      if (nrow(selected) > 0) {
        popup <- paste0(
          "<b><a href='", selected$Website, "' target='_blank'>", selected$University, "</a></b><br>",
          "<b>County:</b> ", selected$County, "<br>",
          "<b>Governance:</b> ", selected$Governance, "<br>",
          "<b>Schools / Faculties:</b><br>",
          "<ul>", paste0("<li>", str_trim(unlist(str_split(selected$Schools_Faculties, ","))), collapse = "</li><li>"), "</li></ul>"
        )
        leafletProxy("university_map") %>%
          addMarkers(
            lng = selected$Longitude,
            lat = selected$Latitude,
            popup = popup
          )
      }
    }
  })
  
}

# Run App
shinyApp(ui, server)
