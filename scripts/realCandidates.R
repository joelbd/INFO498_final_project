# real candidates twitter counts

library(dplyr)
library(plotly)

realCandidates <- function(candidate) {
  file <- paste0('csv_data/', candidate, ".csv")
  timeline <- read.csv(file, stringsAsFactors=FALSE)
  timeline$created <- as.Date(timeline$created)
  timeline <- group_by(timeline, created) %>%
    summarise( 
      #sum tweets created on the same day
      n = n())
  plot_ly(timeline, x = created, y = n, name = "daily trends")
}

