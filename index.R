# index.R

library(shiny)
library(dplyr)
library(streamR)

# This program collects data from the Twitter APIs and outputs the information in a table, map,
# and graph. The filters are dependent on user input and are fully reactive.

setwd("~/src/INFO_498F/final/INFO498_final_project")
source("scripts/collect.R")
source("scripts/build_map.R")
source("scripts/build_plot.R")
source("scripts/realCandidates.R")
source("scripts/tags.R")

# Create initial json file to hold tweet data.
file.create("tweets.json")

# BEGIN SHINY APP
thisHappened <- shinyApp(
# BEGIN UI SECTION
  ui = navbarPage(
    # Include custom CSS for stylizing.
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
              img(src = "http://thishappened.net/images/header2.png")
            )
          )
        )
      ),
      fluidRow(
        column(8, offset = 2,
          withTags(
            div(class = "about",
              tags$p(
                "This Happened is a final project for INFO 498F at the University of Washington."
              ),

              tags$p(
                "The goal of this project is to allow anyone to easily get a holistic and
                revealing view on political and social trends during this election period.
                Social media has become an increasingly important aspect of campaigning in recent
                years and we seek to make the process of analyzing the candidates and the impact
                of social media easier."
              ),

              tags$p(
                "Through the use of this program, you can analyze many of the aspects of the
                elections. Our real-time, streaming tweets allow you to sample the content of
                the digital correspondence surrounding the election. Our map allows you to see
                the relative geological spread of the tweets from the 25th of Februrary to today.
                We've also included a line chart which reveals total mentions and social activity
                around and after significant events like Super Tuesday and the other primaries
                and caucuses. This report is not just about the people's interactions, we've also 
                included a graph outlining the daily twitter interactions of the various
                candidates official Twitter handles."
              ),

              tags$p(
                "Using Twitters APIs, we were able to compile the tweet data and segregate by each
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
    navbarMenu("Daily Trends",
      tabPanel("Map of Trends",
        fluidRow(
          column(2,
                 offset = 1,
            selectInput("mapSelect",
                "Pick a Candidate",
              choices = list(
                  "Bernie Sanders" = "csv_data/sanders.csv",
                  "Hillary Clinton" = "csv_data/clinton.csv",
                  "Ted Cruz" = "csv_data/cruz.csv",
                  "Donald Trump" = "csv_data/trump.csv",
                  "Ben Carson" = "csv_data/carson.csv",
                  "Marco Rubio" = "csv_data/rubio.csv"
                ),
              selected = "csv_data/sanders.csv"
            )
          ),
          column(2,
            offset = 1,
            dateInput(
              "dateSelect",
              "Select a date",
              value = "2016-02-28",
              min = "2016-02-25",
              max = "2016-03-11"
            )
          ),
          column(3,
            offset = 1,
            tags$p(
            "Use this map to see the geographical concentration of tweets about your candidate 
            by date. By toggling the individual tweet data over the map, it will become even more 
            apparent where the tweets are coming from."
          )
        )
      ),
      fluidRow(
        column(10, offset = 1,
          plotlyOutput("tweetMap")
        ) 
      )
    ),
      
      # BEGIN THE CHART UI SECTION
    tabPanel("Chart of Trends",
      fluidRow(
        column(2,
          selectInput("plotSelect",
            "Pick a Candidate",
            choices = list(
              "Bernie Sanders" = "csv_data/sanders.csv",
              "Hillary Clinton" = "csv_data/clinton.csv",
              "Ted Cruz" = "csv_data/cruz.csv",
              "Donald Trump" = "csv_data/trump.csv",
              "Ben Carson" = "csv_data/carson.csv",
              "Marco Rubio" = "csv_data/rubio.csv"
            ),
            selected = "csv_data/sanders.csv"
          ),
          tags$p(
            "This table shows you the cumulative tweets about your candidate day to day. This
            can be used in conjunction with the Candidate Tweets graph to analyze the social
            engagement of your candidate and their followers."
          )
        ),
        column(9, offset = 2,
          plotlyOutput("tweetPlot")
        )
      )
    )
  ),
  
  
  # BEGIN CHART OF CANDIDATE TWEETS UI  
  tabPanel("Chart of Candidates Tweets",
    fluidRow(
      column(2,
        selectInput("candidateSelect",
            "Pick a Candidate",
          choices = list(
              "Bernie Sanders" = "csv_data/@BernieSanders.csv",
              "Hillary Clinton" = "csv_data/@HillaryClinton.csv",
              "Ted Cruz" = "csv_data/@tedcruz.csv",
              "Donald Trump" = "csv_data/@realDonaldTrump.csv",
              "Ben Carson" = "csv_data/@RealBenCarson.csv",
              "Marco Rubio" = "csv_data/@marcoRubio.csv"
          ),
          selected = "@BernieSanders"
        ),
        tags$p(
          "This chart illustrates how active with social media a candidate is. This chart in 
          conjunction with the previous paint a good picture of their social engagement"
        )
      ),
      column(9, offset = 2,
      plotlyOutput("candidatePlot")
      )
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
        actionButton("update", "Update Tweets")
      ),
      column(4, offset = 2,
        sliderInput("numSeconds", "How long do you want to listen for tweets? ",
          min = 5, max = 30, value = 5, step = 1
        )
      )
    ),
    fluidRow(
      column(12,
        dataTableOutput("tweetTable")
      )
    )
  )
),
# END OF UI SECTION

# BEGINNING OF SERVER SECTION
server = function(input, output, session) {

  # BEGIN MAP SECTION
  output$tweetMap <- renderPlotly({
    p <- build_map(input$mapSelect, input$dateSelect)
    p
  })
  # END MAP SECTION

  # BEING PLOT SECTION
  output$tweetPlot <- renderPlotly({
    p <- build_plot(input$plotSelect)
    p
  })
  # END PLOT SECTION

#   # BEING CANDIDATE PLOT SECTION
  output$candidatePlot <- renderPlotly({
    p <- realCandidates(input$candidateSelect)
    p
  })
  # END CANDIDATE PLOT SECTION

  # BEGIN STREAMING TWEETS SECTION
  old_tags <- ""

  gotweet <- eventReactive(input$update, {
    curr_tags <- input$candidate

    if (old_tags != curr_tags) {
      file.remove("tweets.json")
    }

    withProgress(message = 'Fetching tweets.', value = 0, {
      old_tags <<- curr_tags
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
  thisHappened,
  host = "0.0.0.0",
  port = 8080
)
