# tweetOutput.R

library(shiny)
library(dplyr)
library(streamR)

source("scripts/collect.R")
source("scripts/tags.R")

curr_tags <- ""

file.create("tweets.json")

runApp(host = "0.0.0.0",
       port = 8080,
  list(
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
      if (input$candidate != curr_tags) {
        print(curr_tags)
        print(input$candidate)
        curr_tags <- input$candidate
        #file.remove("tweets.json")
      }

      withProgress(message = 'Fetching tweets.', value = 0, {
        collect_tweets(eval(parse(text = input$candidate)), 4)
      })
    })

    autoInvalidate <- reactiveTimer(10000, session)

    output$tweetTable <- renderDataTable({
      gotweet()
      # autoInvalidate()

      tweets_df <-
        parseTweets("tweets.json", simplify = TRUE) %>%
        select(text, screen_name, id_str) %>%
        arrange(-row_number())
      tweets_df$id_str <- paste0('<a href="https://twitter.com/statuses/', tweets_df$id_str, '">View Tweet</a>')
      colnames(tweets_df) <- c("Tweet", "User", "link")

      tweets_df
    }, 
      options = list(ordering = FALSE, searching = FALSE),
      escape = c(-3)
    )
  }
))
