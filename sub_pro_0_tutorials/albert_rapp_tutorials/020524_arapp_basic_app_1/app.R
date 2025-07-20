# Creating apps with R-Shiny by Albert Rapp

# Anatomy of a Shiny App

# 1) User Interface (UI): What your user sees in the app.
# 2) Server function: The brains behind the operation (more on that later).
# 3) ShinyApp() function call that ties UI & server together.

# As you’ve seen in the code, every input function needs three things:

# 1) First an ID,
# 2) A label of that UI element,
# 3) Followed by input-specific arguments

library(shiny)

ui <- bslib::page_fluid(
  # A slider
  sliderInput(
    'my_slider',
    'Select your number',
    
    min = 0,
    max = 1,
    value = 0.5,
    step = 0.1
  ),

  # A dropdown menu
  selectInput(
    'my_dropdown_menu',
    'Pick your color',
    
    choices = c('red', 'green', 'blue')
  ),
  
  # Add a text output
  textOutput('my_generated_text')
)

server <- function(input, output, session){
  output$my_generated_text <- renderText({
    paste(
      input$my_dropdown_menu,
      input$my_slider
    )
  })
}

shinyApp(ui, server)
