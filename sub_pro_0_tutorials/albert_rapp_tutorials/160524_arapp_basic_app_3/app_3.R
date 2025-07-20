# Creating apps with R-Shiny by Albert Rapp
# Website: https://3mw.albert-rapp.de/p/r-shiny-events

# Reactive expressions in R-Shiny

# Setting up a simple shiny app

# 1) reactiveVal() vs reactive()
# 2) There are other ways to create reactive values. 
# 3) For example, there’s also reactiveVal(). 
#    This function lets you assign values more manually.
# 4) Requires an observer for input values
#    - define the reactiveVal() outside the observe() code, and
#    - update the reactiveVal() inside of observe().

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
  # Intialize reactiveVal()
  filtered_data <- reactiveVal()
  observe({
    dat <- palmerpenguins::penguins |> 
      filter(
        !is.na(sex),
        species == input$species,
        island == input$island
      )
    filtered_data(dat) # update the reactiveVal()
  })
  
  output$plot <- renderPlot({
    filtered_data() |>
      ggplot(aes(x = flipper_length_mm, y = bill_depth_mm)) +
      geom_point(size = 3)
  }) 
  
  output$tbl <- DT::renderDT({
    filtered_data()
  })
}


shinyApp(ui, server)
