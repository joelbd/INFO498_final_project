# tweetOutput.R

library(shiny)
library(dplyr)

source("scripts/collect.R")

tweets <- data.frame(
  Tweet = character(),
  User = character(),
  Time = as.Date(character()),
  stringsAsFactors = FALSE
)

runApp(list(
  ui = pageWithSidebar(    
    
    headerPanel("Tweets about stuff"),
    
    sidebarPanel(
      selectInput("candidate", 
        "Pick a Candidate", 
        choices = list(
          "Bernie Sanders" = "TAGS_BERNIE"
        ),
        selected = "TAGS_BERNIE"
      )
    ),
    
    mainPanel(
      dataTableOutput("tweetTable")
    )
  ),
  server =function(input, output, session) {
    autoInvalidate <- reactiveTimer(12000, session)
    output$tweetTable <- renderDataTable({
      autoInvalidate()
      tweets <- collect_tweets(input$candidate) %>% 
                select(text, screen_name) %>% 
                arrange(-row_number())
    }, options = list(bSort=0)
    )
  }
))
