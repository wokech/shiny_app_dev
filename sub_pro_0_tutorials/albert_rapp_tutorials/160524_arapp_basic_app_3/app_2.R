# Creating apps with R-Shiny by Albert Rapp
# Website: https://3mw.albert-rapp.de/p/r-shiny-events

# Reactive expressions in R-Shiny

# Setting up a simple shiny app

# 1) Avoid code repetition.
# 2) The easiest way to do that is the reactive() function.

library(shiny)

ui <- bslib::page_fluid(
  bslib::layout_column_wrap(
    selectInput(
      'species', 
      'Choose your species', 
      unique(palmerpenguins::penguins$species)
    ),
    selectInput(
      'island', 
      'Choose your island', 
      unique(palmerpenguins::penguins$island)
    )
  ),
  bslib::layout_column_wrap(
    plotOutput('plot'),
    DT::dataTableOutput('tbl')
  )
)

server <- function(input, output, session) {
  filtered_data <- reactive({
    palmerpenguins::penguins |> 
      filter(
        !is.na(sex),
        species == input$species,
        island == input$island
      )
  })
  
  output$plot <- renderPlot({
    # CALL the reactive
    filtered_data() |>
      ggplot(aes(x = flipper_length_mm, y = bill_depth_mm)) +
      geom_point(size = 3)
  }) 
  
  output$tbl <- DT::renderDT({
    # CALL the reactive
    filtered_data()
  })
}

shinyApp(ui, server)
