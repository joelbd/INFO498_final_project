# real candidates twitter counts

library(dplyr)
library(plotly)

#realCandidates accepts csv file as parameter
realCandidates <- function(file) {
  #read in data from file
  timeline <- read.csv(file, stringsAsFactors=FALSE)
  #change created column to date objects instead of characters
  timeline$created <- as.Date(timeline$created)
  #group data by date created
  timeline <- group_by(timeline, created) %>%
    summarise( 
      #sum tweets created on the same day
      n = n())
  #create plot
  p <- plot_ly(timeline, x = created, y = n, name = "daily trends")
  return(p)
}

