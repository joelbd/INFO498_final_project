# tweetOutput.R

library(shiny)
library(dplyr)

source("scripts/collect.R")
source("scripts/parseJSON.R")
source("scripts/tags.R")

collect_tweets("Election", 2)

runApp(list(
  ui = pageWithSidebar(    
    
    headerPanel("Tweets about stuff"),
    
    sidebarPanel(
      selectInput("candidate", 
        "Pick a Candidate", 
        choices = list(
          "Bernie Sanders" = "TAGS_BERNIE",
          "Hillary Clinton" = "TAGS_HILLARY",
          "Ted Cruz" = "TAGS_CRUZ",
          "Donald Trump" = "TAGS_TRUMP",
          "Ben Carson" = "TAGS_CARSON",
          "Marco Rubio" = "TAGS_RUBIO"
        ),
        selected = NULL
      ),
      actionButton("update", "Change Candidate")
    ),
    
    mainPanel(
      dataTableOutput("tweetTable")
    )
  ),
  server = function(input, output, session) {
    
    gotweet <- eventReactive(input$update, {
      withProgress(message = 'Fetching tweets.', value = 0, {
          collect_tweets(eval(parse(text = input$candidate)), 1)
      })
    })
    
    autoInvalidate <- reactiveTimer(10000, session)
    
    output$tweetTable <- renderDataTable({
      gotweet()
      # autoInvalidate()
      filter_tweets()
    }, options = list(ordering = FALSE, searching = FALSE)
    )
  }
))
