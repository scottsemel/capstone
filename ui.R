library(shiny)
library(MASS)

# Define UI for dataset viewer application
shinyUI(fluidPage(
  
    # Application title.
    titlePanel("N-gram Predictor"),
  
    sidebarLayout(
        sidebarPanel(
            textInput("obs", "Enter Text:"),
            
            submitButton("Predict")
        ),
      
      mainPanel(
          
          h3("Most Likely Next Word:"),
          div(textOutput("BestGuess"), style = "color:blue"),
          br(),
          h3("Possible words are:"),
          tableOutput("view")
    )
  )
))