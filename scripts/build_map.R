# build_map.R

library(dplyr)
library(plotly)
library(stringr)
source("scripts/getStates.R")
#function to build map takes csv file as parameter


build_map <- function(file, day) {
  #read in data from file
  data <- read.csv(file, stringsAsFactors = FALSE) %>% filter(!is.na(latitude))
  data$code <- getStates(data)
  data$code <- str_to_title(data$code)
  data$code <- state.abb[match(data$code, state.name)]

  #filter to select tweets from day selected
  ifelse(file == 'csv_data/clinton.csv', 
         data$created <- as.Date(data$created, '%m/%d/%y'), 
         data$created <- as.Date(data$created))
  
  data <- filter(data, created %in% as.Date(day))

  # Create DF to be used for Chorpleth.
  dataSum <- data %>% group_by(code) %>% summarise(sumTweets = n())
  #setup geo plotly parameter
  l <- list(color = "FFB247", width = 2)
  g <- list(
    scope = 'usa',
    projection = list(type = 'albers usa'),
    showland = TRUE,
    landcolor = "d3d3d3d3",
    bgcolor = "222222",
    subunitwidth = 1,
    countrywidth = 1,
    subunitcolor = "FFB247",
    countrycolor = "FFB247"
  )
  # plot data using longitude and latitude data columns

  p <- plot_ly(
    data,
    lon = longitude,
    lat = latitude,
    # text = "hover",
    marker = list(size = 7),
    color = "222222",
    type = 'scattergeo',
    locationmode = 'USA-states') %>%
  add_trace(
    dataSum,
    z = dataSum$sumTweets,
    text = dataSum$sumTweets,
    locations = dataSum$code,
    type = 'choropleth',
    locationmode = 'USA-states',
    color = dataSum$sumTweets,
    opacity = 1,
    colors = 'Blues',
    marker = list(line = l),
    colorbar = list(
      title = "Number of Tweets",
      tickcolor = "2a9fd6",
      titlefont = list(
        color = "2a9fd6"),
      tickfont = list(
        color = "2a9fd6")
    )
  ) %>%
  layout(geo = g, paper_bgcolor = "222222", plot_bgcolor = "rgba(34, 34, 34, 1)")
  return(p)
}

