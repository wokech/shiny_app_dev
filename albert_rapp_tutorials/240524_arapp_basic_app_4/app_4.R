# Creating apps with R-Shiny by Albert Rapp
# Website: https://3mw.albert-rapp.de/p/shiny-dynamic-ui

# Dynamic UI with R-Shiny

# Render a placeholder 

# As we’ve just seen, insertUI() and removeUI() give you great powers but can be 
# quite complicated to use. If you only want to show different UI elements in a 
# specific place, the renderUI() and uiOutput() pair have everything you need.

# This gives the same output as before but with simpler code.

library(shiny)

ui <- bslib::page_fluid(
  radioButtons(
    'yesno', 
    'Do you like this? ', 
    c('Yes', 'No'),
    selected = character(0) # no selection at first
  ),
  uiOutput('dynamic_ui')
)

server <- function(input, output, session) {
  output$dynamic_ui <- renderUI({
    if (input$yesno == 'Yes') {
      sliderInput(
        'slider', 
        'How much do you like this (10 = very)', 
        min = 1, 
        max = 10, 
        value = 5
      )
    } else {
      textInput('textinput', 'Why not?')
    }
  }) |> bindEvent(input$yesno)
}

shinyApp(ui, server)