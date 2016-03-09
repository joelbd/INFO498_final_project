# index.R

library(shiny)
library(dplyr)
library(streamR)

# This program collects data from the Twitter APIs and outputs the information in a table, map,
# and graph. The filters are dependent on user input and are full reactive.

setwd("~/src/INFO_498F/final/INFO498_final_project")
source("scripts/collect.R")
source("scripts/tags.R")

# Create json file to hold tweet data.
file.create("tweets.json")

# BEGIN SHINY APP
stream <- shinyApp(
# BEGIN UI SECTION 
  ui = navbarPage(
    includeCSS("www/style.css"),
    fluid = TRUE,
    inverse = TRUE,
    windowTitle = "This Happened",
    
    # BEGIN ABOUT UI SECTION
    tabPanel("About This Happened",
      fluidRow(
        column(6, offset = 2,
          withTags(
            div(class = "splash",
              img(src = "http://thishappened.net/images/header.png")
            )
          )
        )
      ),
      fluidRow(
        column(8, offset = 2,
          withTags(
            div(class = "about",
              tags$p(
                "This Happened is the final project for INFO 498F at the University of Washington."
              ),

              tags$p(
                "The goal of this project is to allow anyone to easily get a holistic view on 
                political social trends during this election period. Social media has become and 
                increasingly important aspect of the campaigning process. We seek to make the 
                process of analyzing that easier within the scope of our project."
              ),

              tags$p(
                "Through the use of this project we can easily analyze for increased mentions and 
                social activity around and after significant events like Super Tuesday and the 
                other primaries and caucuses."
              ),

              tags$p(  
                "Using Twitters APIs we were able to compile the tweet data and segregate by each 
                candidate."
              ),

              tags$p("It was built using:"),
                tags$li("R"),
                tags$li("Shiny"),
                tags$li("Markdown"),
                tags$li("The Twitter Streaming & Search APIs"),

              tags$p(  
                "The source code can be found at"
              )  ,

              tags$a("https://github.com/joelbd/INFO498_final_project",
                        "https://github.com/joelbd/INFO498_final_project")
            )
          )
        )  
      )
    ),
    
    # BEGIN MAP UI SECTION
    tabPanel("Map of Trends",
      fluidRow(
        
      )
    ),
    
    # BEGIN STREAMING UI SECTION
    tabPanel("Real-Time Streaming Tweets",
      fluidRow(
        column(2, offset = 1,
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
        column(4, offset = 2,
          sliderInput("numSeconds", "How long do you want to listen for tweets? ", 
            min = 5, max = 30, value = 10, step = 1
          )
        )
      ),
      fluidRow(
        column(10, offset = 1,
          dataTableOutput("tweetTable")
        )
      )  
    )
  ),
# END OF UI SECTION

# BEGINNING OF SERVER SECTION
server = function(input, output, session) {

  # BEGIN STREAMING TWEETS SECTION
  gotweet <- eventReactive(input$update, {
    if (input$candidate != curr_tags) {
      curr_tags <<- input$candidate
      file.remove("tweets.json")
    }
    
    withProgress(message = 'Fetching tweets.', value = 0, {
      collect_tweets(eval(parse(text = input$candidate)), input$numSeconds)
    })
  })
  
  output$tweetTable <- renderDataTable({
    gotweet()
    
    tweets_df <-
      parseTweets("tweets.json", simplify = TRUE) %>%
      select(text, screen_name, id_str) %>%
      arrange(-row_number())
    
    tweets_df$id_str <- paste0('<a href="https://twitter.com/statuses/', 
                               tweets_df$id_str, '">View Tweet</a>')
    colnames(tweets_df) <- c("Tweet", "User", "Link")
    
    tweets_df
  }, 
    options = list(ordering = FALSE, searching = FALSE),
    escape = c(-3)  
  )
  # END STREAMING TWEETS SECTION
  
}
)
# END SHINY APP

# Run Shiny App with specific port and host.
runApp(
  stream,
  host = "0.0.0.0",
  port = 8080
)