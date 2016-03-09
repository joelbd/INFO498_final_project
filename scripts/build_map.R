# build_map.R

library(dplyr)
library(plotly)

#function to build map takes csv file as parameter
build_map <- function(file) {
  #read in data from file
  data <- read.csv(file, stringsAsFactors = FALSE)
  #setup geo plotly parameter
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
  #plot data using longitude and latitude data columns
  newMap <- plot_ly(data, lat=latitude, lon=longitude, text=text, mode='markers', marker = 
            list(size = 7, symbol = 'circle', opacity = 0.5), hoverinfo = 'none', type="scattergeo", 
          locationmode='USA-states') %>% layout(geo=g)
  return(newMap)
}

