# Creating apps with R-Shiny by Albert Rapp
# Website: https://3mw.albert-rapp.de/p/shiny-dynamic-ui

# Dynamic UI with R-Shiny

# Update your UI

# In that case, you could use a sliderInput and inside your server function, use
# the updateSliderInput function and tie all of that to an observer.

# Compared to renderUI(), the updateSliderInput() approach is more efficient 
# because it updates the value of the slider on the user’s 
# computer (client-side). If you use renderUI(), everything will first go to 
# the server, be rendered there, and then go back to the user, which is slower.

library(shiny)

ui <- bslib::page_fluid(
  actionButton('button', 'Move slider to 5'),
  sliderInput(
    'slider', 
    'Move me!', 
    min = 1, 
    max = 10, 
    value = 1
  )
)

server <- function(input, output, session) {
  observeEvent(input$button, {
    updateSliderInput(
      session, 
      'slider', 
      value = 5
    )
  })
}

shinyApp(ui, server)
