# Creating apps with R-Shiny by Albert Rapp
# Website: https://3mw.albert-rapp.de/p/shiny-dynamic-ui

# Dynamic UI with R-Shiny

# Insert and remove UI (Part 1)

# The first way to create a dynamic UI experience is pretty easy.

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
  
}

shinyApp(ui, server)
