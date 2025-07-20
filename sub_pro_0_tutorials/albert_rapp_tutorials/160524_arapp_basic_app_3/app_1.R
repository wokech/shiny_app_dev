# Creating apps with R-Shiny by Albert Rapp
# Website: https://3mw.albert-rapp.de/p/r-shiny-events

# Reactive expressions in R-Shiny

# Setting up a simple shiny app

# 1) bslib::layout_column_wrap() to place things next to each other.
# 2) {DT} packages to create a table output.

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


library(tidyverse)
server <- function(input, output, session) {
  output$plot <- renderPlot({
    palmerpenguins::penguins |> 
      filter(
        !is.na(sex),
        species == input$species,
        island == input$island
      ) |>
      ggplot(aes(x = flipper_length_mm, y = bill_depth_mm)) +
      geom_point(size = 3)
  }) 
  
  output$tbl <- DT::renderDT({
    palmerpenguins::penguins |> 
      filter(
        !is.na(sex),
        species == input$species,
        island == input$island
      ) 
  })
}

shinyApp(ui, server)
