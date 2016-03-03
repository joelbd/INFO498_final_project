# tweetOutput.R

library(shiny)
library(dplyr)

source("scripts/collect.R")
bernie <- collect_tweets(TAGS_BERNIE)

runApp(list(
  ui = pageWithSidebar(    
    
    headerPanel("Tweets about stuff"),
    
    sidebarPanel(
      sliderInput("obs", 
        "Number of Tweets:", 
        min = 1,
        max = 100, 
        value = 20
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
      bernie <- collect_tweets(TAGS_BERNIE)
      tweets <- bernie %>% select(text, screen_name) %>% arrange(-row_number())
      
    })
  }
))
