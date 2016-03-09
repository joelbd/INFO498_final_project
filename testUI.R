# testUI.R
library(shiny)
library(dplyr)
library(shinythemes)

setwd("~/src/INFO_498F/final/INFO498_final_project")
source("scripts/collect.R")
source("scripts/tags.R")


file.create("tweets.json")
curr_tags <- ""


# BEGIN SHINY APP
stream <- shinyApp(
# BEGIN UI SECTION 
  ui = navbarPage(
    includeCSS("www/style.css"),
    fluid = TRUE,
    inverse = TRUE,
    windowTitle = "This Happened",
    
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

              tags$a('href="https://github.com/joelbd/INFO498_final_project"',
                        "https://github.com/joelbd/INFO498_final_project")
            )
          )
        )  
      )
    ),
    
    tabPanel("Map of Trends",
      headerPanel("Maps of Tweets or whatever"),       
      sidebarLayout(
        sidebarPanel(
          radioButtons("plotType", "Plot type",
            c("Scatter"="p", "Line"="l")
          )
        ),
        mainPanel(
          plotOutput("plot")
        )
      )
    ),
    
    tabPanel("Real-Time Streaming Tweets",
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
    )
  ),
# END OF UI SECTION

# BEGINNING OF SERVER SECTION
server = function(input, output, session) {

  # BEGIN STREAMING TWEETS SECTION
  gotweet <- eventReactive(input$update, {
    if (input$candidate != curr_tags) {
      print(curr_tags)
      print(input$candidate)
      curr_tags <<- input$candidate
      file.remove("tweets.json")
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
      select(text, screen_name) %>%
      arrange(-row_number())
    
    colnames(tweets_df) <- c("Tweet", "User")
    
    tweets_df
  }, options = list(ordering = FALSE, searching = FALSE)
  )
}
)
# END SHINY APP

# Run Shiny App with specific port and host.
runApp(
  stream,
  host = "0.0.0.0",
  port = 8080
)
