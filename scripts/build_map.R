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
  l <- list(color = toRGB("white"), width = 2)
  g <- list(
    scope = 'usa',
    projection = list(type = 'albers usa'),
    showland = TRUE,
    landcolor = toRGB("gray85"),
    subunitwidth = 1,
    countrywidth = 1,
    subunitcolor = toRGB("white"),
    countrycolor = toRGB("white")
  )
  # plot data using longitude and latitude data columns
 

  p2 <- plot_ly(dataSum, z = sumTweets, text = sumTweets, locations = code, type = 'choropleth',
          locationmode = 'USA-states', color = sumTweets, colors = 'Purples',
          marker = list(line = l), colorbar = list(title = "Number of Tweets")) %>%
    layout(title = 'Tweets about the presidential candidates', geo = g) %>% 
    
    add_trace(data, lat=data$latitude, lon=data$longitude, text=text, mode='markers', marker = 
           list(size = 7, symbol = 'circle', opacity = 0.5), hoverinfo = 'none', type="scattergeo", 
   locationmode='USA-states') %>% layout(geo=g)
  return(p2)
}

