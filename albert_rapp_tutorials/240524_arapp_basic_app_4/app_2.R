# Creating apps with R-Shiny by Albert Rapp
# Website: https://3mw.albert-rapp.de/p/shiny-dynamic-ui

# Dynamic UI with R-Shiny

# Insert and remove UI (Part 2)

# Depending on if “Yes” or “No” is selected, you want to throw in some specific 
# part into your user interface. In these cases, you can use the insertUI() function

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
    if (input$yesno == 'Yes') {
      insertUI(
        # Place new UI after the radio button
        # (the element with the id 'yesno')
        selector = '#yesno', 
        where = 'afterEnd',
        # What ui to insert
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
