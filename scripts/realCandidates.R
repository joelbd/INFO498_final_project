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
  
  p <- plot_ly(
    timeline, 
    x = created, 
    y = n,
    marker = list(color = "2a9fd6", size = 10),
    line = list(color = "2a9fd6", opacity = .5)
    ) %>%
    layout(
      title = "Daily Tweets From The Candidate's Official Twitter",
      font = list(
        color = "2a9fd6"
      ),
      height = "600px",
      xaxis = list(
        title = "Days",
        gridcolor = "333333"
      ),
      yaxis = list(
        title = "Number of Tweets",
        gridcolor = "333333"
      ),
      plot_bgcolor = "222222",
      paper_bgcolor = "222222"
    )
  p
  return(p)
}

