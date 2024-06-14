# Creating apps with R-Shiny by Albert Rapp
# Website: https://3mw.albert-rapp.de/p/r-shiny-events

# Event listeners with R-Shiny

# Setting up a simple shiny app

# First, let us set up a little Shiny app. Let’s throw in

# 1) A slider input using sliderInput(),
# 2) An action button using actionButton(), and
# 3) A text output using textOutput().

library(shiny)

ui <- bslib::page_fluid(
  sliderInput('slider', 'Slider', 
              min = 1, max = 100, value = 50),
  actionButton('button', 'Button'),
  textOutput('text')
)

# req() helps one control reactivity
# isolate() helps one to isolate inputs
#  bindEvent() is more useful than isolate() and observeEvent()

server <- function(input, output, session){
  output$text <- renderText({
    req(input$button >= 1)
    print(input$button)
    input$slider
  }) |> bindEvent(input$button)
}

shinyApp(ui, server)