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
  data$created <- as.Date(data$created)
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


  p2 <- plot_ly(
    dataSum, 
    z = sumTweets, 
    text = sumTweets, 
    locations = code, 
    type = 'choropleth',
    locationmode = 'USA-states', 
    color = sumTweets,
    opacity = .2,
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
    add_trace(
      data, 
      lat = data$latitude, 
      lon = data$longitude, 
      text = text,
      mode='markers', 
      marker = list(
        size = 7, 
        symbol = 'circle', 
        opacity = 0.5
      ), 
      hoverinfo = 'none', 
      type="scattergeo",
      locationmode='USA-states') %>% 
    layout(geo = g, paper_bgcolor = "222222", plot_bgcolor = "rgba(34, 34, 34, 1)")
  return(p2)
}

