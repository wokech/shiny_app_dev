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
  theme = shinytheme("sandstone"),  # Use a modern and clean theme
  
  # Navbar with multiple pages
  navbarPage(
    "Kenya National Parks Visitor Data",
    
    # Page 1: Introduction
    tabPanel(
      "Introduction",
      fluidPage(
        titlePanel("Project Introduction"),
        h3("Background"),
        p("The Kenya Wildlife Service manages all of Kenya's National Parks, 
           Reserves, Sanctuaries, and Stations. Its mission is 'to sustainably 
           manage Kenya's wildlife and its habitats for the benefit of nature 
           and humanity' and its vision is 'conserve Kenya's wildlife and 
           its habitats for posterity"),
        
        p("This app was developed to provide insights into the visitor 
           number data over a specified period of time. Using the interactive 
           map one can view the park locations. Additionally, the graphs and 
           data table allow the user to visualize visitor numbers, and
           compare trends over multiple years."),
        h3("Data Source"),
        p("Kenya Parks Investments Prospectus 2023"),
        tags$a(href="https://www.kws.go.ke/", "Website"),
        p(""),
        p("Economic Surveys (2009 - 2024)"),
        tags$a(href="https://www.knbs.or.ke/", "Website")
        
      )
    ),
    
    # Page 2: Interactive App
    tabPanel(
      "Visitor Numbers",
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
            h3("Visitor Numbers"),
            # Display the plot with plotly for interactivity
            plotlyOutput(outputId = "visitors_plot", height = "300px"),
            h3("A map of the selected locations"),
            # Display the map with an initial view of Kenya
            leafletOutput(outputId = "parks_map", height = "300px")
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
      geom_line(linewidth = 1.2) +
      geom_point(size = 3) +
      labs(
        title = "",
        x = "Year",
        y = "Number of Visitors",
        color = "Park"
      ) +
      theme_classic() +
      theme(
        legend.position = "bottom",
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5, color = "#007aff"),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12)
        
      )
    
    # Convert ggplot to plotly with specified tooltip content
    ggplotly(p, tooltip = "text") |>
      layout(legend = list(orientation = "h", # horizontal layout
                           xanchor = "center", # use center as anchor
                           x = 0.5, # center horizontally
                           y = -0.5)) # move below the plot
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
