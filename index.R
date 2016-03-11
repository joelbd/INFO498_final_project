# index.R

library(shiny)
library(dplyr)
library(streamR)

# This program collects data from the Twitter APIs and outputs the information in a table, map,
# and graph. The filters are dependent on user input and are full reactive.

setwd("~/src/INFO_498F/final/INFO498_final_project")
source("scripts/collect.R")
source("scripts/build_map.R")
source("scripts/build_plot.R")
source("scripts/realCandidates.R")
source("scripts/tags.R")
source("scripts/getStates.R")

# Create json file to hold tweet data.
file.create("tweets.json")

# BEGIN SHINY APP
thisHappened <- shinyApp(
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
                Social media has become an increasingly important aspect of campaigning.
                We seek to make the process of analyzing the candidates and available
                political options easier."
              ),

              tags$p(
                "Through the use of this project, you can analyze many of the aspects of the
                elections. Our real-time, streaming tweets allow you to sample the content of
                the digital correspondence surrounding the election. Our map allows you to see
                the relative geological spread of the tweets from the 25th of Februrary to today.
                Our holistic data in the form of a line chart reveals mentions and social activity
                around and after significant events like Super Tuesday and the other primaries
                and caucuses."
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
            ),
            dateInput(
              "dateSelect",
              "Select a date",
              value = "2016-02-28",
              min = "2016-02-24",
              max = "2016-03-10"
            ),
            actionButton("updateMap", "Change Candidate"),
            tags$p(
            "Use this map to see the concentration of tweets surrounding the selected candidate based on the
            date and the geographic data embedded within the tweet's data. By toggling the individual tweet
            data over the map, it will become even more apparent where the tweets are coming from. "
          )
        ),
        column(8, offset = 3,
          plotlyOutput("tweetMap")
          )
        )
      ),
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
            actionButton("updateMap", "Change Candidate"),
            tags$p(
              "Use this plot to see the number of tweets over a range of days about a specific candidate."
            )
          ),
          column(9, offset = 2,
          plotlyOutput("tweetPlot")
        )
      )
    ) #,
#    tabPanel("Chart of Candidates Tweets",
#     fluidRow(
#       column(2,
#         selectInput("plotSelect",
#             "Pick a Candidate",
#           choices = list(
#               "Bernie Sanders" = "csv_data/@BernieSanders.csv",
#               "Hillary Clinton" = "csv_data/@HillaryClinton.csv",
#               "Ted Cruz" = "csv_data/@tedcruz.csv",
#               "Donald Trump" = "csv_data/@realDonaldTrump.csv",
#               "Ben Carson" = "csv_data/@RealBenCarson.csv",
#               "Marco Rubio" = "csv_data/@marcoRubio.csv"
#           ),
#           selected = "@BernieSanders"
#         ),
#         actionButton("updatePlot", "Change Candidate"),
#         tags$p(
#           "Use this plot to see the number of tweets over a range of days tweeted by a specific candidate."
#         )
#       ),
#       column(9, offset = 2,
#       plotlyOutput("candidatePlot")
#       )
#     )
#     )
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
  loadMap <- eventReactive(input$updateMap, {
    withProgress(message = "Loading map.", value = 0, {
    })
  })

  output$tweetMap <- renderPlotly({
    loadMap()
    p <- build_map(input$mapSelect, input$dateSelect)
    p
  })
  # END MAP SECTION

  # BEING PLOT SECTION
  loadPlot <- eventReactive(input$updatePlot, {
    withProgress(message = "Loading plot.", value = 0, {
    })
  })

  output$tweetPlot <- renderPlotly({
    loadPlot()
    p <- build_plot(input$plotSelect)
    p
  })
  # END PLOT SECTION

#   # BEING CANDIDATE PLOT SECTION
#   loadCandidatePlot <- eventReactive(input$updatePlot, {
#     withProgress(message = "Loading plot.", value = 0, {
#     })
#   })
#
#   output$candidatePlot <- renderPlotly({
#     loadCandidatePlot()
#     p <- realCandidates(input$plotSelect)
#     #p <- realCandidates('csv_data/@BernieSanders.csv')
#     p
#   })
#   # END CANDIDATE PLOT SECTION

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
