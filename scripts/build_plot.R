# build_plot

library(dplyr)
library(plotly)

# function to build chart accepts a csv file as a parameter
build_plot <- function(file) {
  #read in data from file
  data <- read.csv(file, stringsAsFactors=FALSE)
  #change created column to date objects instead of characters
  data$created <- as.Date(data$created)
  #group data by date created
  data <- group_by(data, created) %>%
    summarise( 
      #sum tweets created on the same day
      n = n())
  #create plot
  plot_ly(data, x = created, y = n, name = "daily trends")
}

