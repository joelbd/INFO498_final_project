# build_map

library(dplyr)
library(plotly)

build_map <- function(file) {
  data <- read.csv(file, stringsAsFactors = FALSE)
  g <- list(
    scope = 'usa',
    projection = list(type = 'albers usa'),
    showland = TRUE,
    landcolor = toRGB("gray85"),
    subunitwidth = 1,
    countrywidth = 1,
    subunitcolor = toRGB("white"),
    countrycolor = toRGB("white"),
  )
  
  plot_ly(data, lat=latitude, lon=longitude, text=text, mode='markers', marker = 
            list(size = 7, symbol = 'circle', opacity = 0.5), hoverinfo = 'none', type="scattergeo", 
          locationmode='USA-states') %>% layout(geo=g)
}

