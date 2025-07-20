# Creating apps with R-Shiny by Albert Rapp
# Website: https://3mw.albert-rapp.de/p/r-shiny-events

# Reactive expressions in R-Shiny

# Setting up a simple shiny app

# 1) Use reactiveValues() function if you don't like the syntax of 
#    reactiveVal()

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
  # Intialize list
  r_list <- reactiveValues()
  observe({
    dat <- palmerpenguins::penguins |> 
      filter(
        !is.na(sex),
        species == input$species,
        island == input$island
      )
    r_list$filtered_data <- dat # update 
  })
  
  output$plot <- renderPlot({
    # use data from list (without parantheses)
    r_list$filtered_data |>
      ggplot(aes(x = flipper_length_mm, y = bill_depth_mm)) +
      geom_point(size = 3)
  }) 
  
  output$tbl <- DT::renderDT({
    # use data from list (without parantheses)
    r_list$filtered_data
  })
}

shinyApp(ui, server)
