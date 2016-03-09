# build_plot

library(dplyr)
library(plotly)

build_chart <- function(file) {
  data <- read.csv(file, stringsAsFactors=FALSE)
  data$created <- as.Date(data$created)
  data <- group_by(data, created) %>%
    summarise( 
      n = n())
  
  plot_ly(data, x = created, y = n, name = "daily trends")
}

