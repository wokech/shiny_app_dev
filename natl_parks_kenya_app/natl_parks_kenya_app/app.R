# Load necessary libraries
library(shiny)
library(leaflet)
library(plotly)
library(dplyr)
library(readr)
library(DT)
library(shinythemes)

# Load the processed data
parks_data <- readRDS("nat_parks_ke_data.rds")

# Define UI with a fluidPage, navbarPage, and multiple tabPanels
ui <- fluidPage(
  theme = shinytheme("flatly"),  # Use a modern and clean theme
  
  # Navbar with multiple pages
  navbarPage(
    "Kenya National Parks Visitor Data",
    
    # Page 1: Introduction
    tabPanel(
      "Introduction",
      fluidPage(
        titlePanel("Project Introduction"),
        h3("Overview"),
        p("This Shiny app provides insights into visitor trends in Kenya's National Parks from 2018 to 2022."),
        p("Explore different parks, visualize their visitor data, and compare trends over the years. The interactive map displays park locations, and you can analyze the data in a user-friendly table format.")
      )
    ),
    
    # Page 2: Interactive App
    tabPanel(
      "Interactive Visualization",
      fluidPage(
        titlePanel("Explore Kenya's National Parks"),
        
        sidebarLayout(
          sidebarPanel(
            # Checkbox group input to select multiple parks
            checkboxGroupInput(
              inputId = "park_names",
              label = "Select Parks:",
              choices = unique(parks_data$park),
              selected = unique(parks_data$park)[1]
            )
          ),
          
          mainPanel(
            
            # Display the plot with plotly for interactivity
            plotlyOutput(outputId = "visitors_plot", height = "400px"),
            
            # Display the map with an initial view of Kenya
            leafletOutput(outputId = "parks_map", height = "400px")
          )
        )
      )
    ),
    
    # Page 3: Data Table
    tabPanel(
      "Data Table",
      fluidPage(
        titlePanel("Parks Data Table"),
        DTOutput("parks_table")  # Display the data table
      )
    )
  )
)

# Server
server <- function(input, output) {
  
  # Reactive data filtered by selected parks
  selected_parks_data <- reactive({
    parks_data %>%
      filter(park %in% input$park_names)
  })
  
  # Render the map showing the selected parks' locations
  output$parks_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 37.9062, lat = -1.2921, zoom = 6) %>%  # Center on Kenya
      addMarkers(
        data = selected_parks_data(),
        lng = ~longitude,
        lat = ~latitude,
        popup = ~paste("<b>Park:</b>", park)
      )
  })
  
  # Render the interactive plot using plotly with proper tooltip settings
  output$visitors_plot <- renderPlotly({
    # Create the ggplot object
    p <- ggplot(selected_parks_data(), aes(x = year, y = visitors, color = park, group = park, 
                                           text = paste("Park:", park, "<br>Year:", year, "<br>Visitors:", visitors))) +
      geom_line(size = 1.2) +
      geom_point(size = 3) +
      labs(
        title = "Visitors Over Time - Selected Parks",
        x = "Year",
        y = "Number of Visitors",
        color = "Park"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5, color = "#007aff"),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12)
      )
    
    # Convert ggplot to plotly with specified tooltip content
    ggplotly(p, tooltip = "text")
  })
  
  # Render the data table using DT
  output$parks_table <- renderDT({
    datatable(
      parks_data,
      options = list(
        pageLength = 10,
        autoWidth = TRUE,
        dom = 'ftip',
        class = 'cell-border stripe'
      ),
      rownames = FALSE
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
