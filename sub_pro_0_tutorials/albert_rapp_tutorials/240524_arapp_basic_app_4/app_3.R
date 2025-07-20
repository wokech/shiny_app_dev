# Creating apps with R-Shiny by Albert Rapp
# Website: https://3mw.albert-rapp.de/p/shiny-dynamic-ui

# Dynamic UI with R-Shiny

# Insert and remove UI (Part 3)

# In that case, you will have to use the removeUI() function to remove the 
# previously added content.

# Requires: 
# 1) isTruthy() function to check if one of the additional inputs exists.
# 2) The selector of the element you want to remove.


library(shiny)

ui <- bslib::page_fluid(
  radioButtons(
    'yesno', 
    'Do you like this? ', 
    c('Yes', 'No'),
    selected = character(0) # no selection at first
  )
)

server <- function(input, output, session) {
  observe({
    if (isTruthy(input$slider) | isTruthy(input$textinput)) {
      removeUI(
        selector = 'div.form-group.shiny-input-container:last-of-type'
      )
    }
    
    if (input$yesno == 'Yes') {
      insertUI(
        selector = '#yesno', 
        where = 'afterEnd',
        ui = sliderInput(
          'slider', 
          'How much do you like this (10 = very)', 
          min = 1, 
          max = 10, 
          value = 5
        )
      )
    } else {
      insertUI(
        selector = '#yesno',
        where = 'afterEnd',
        ui = textInput('textinput', 'Why not?')
      )
    }
  }) |> bindEvent(input$yesno)
}

shinyApp(ui, server)