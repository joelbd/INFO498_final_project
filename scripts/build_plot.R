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
  #added text to the days, detailing some of the events
  data$events <- c("Feb 24", "NV Primary", "Feb 26", "SC Primary", "Feb 28", "Feb 29", 
                   "Super Tuesday", "Mar 2", "[R] Presidential Debate (MI)", "Ben Carson ends campaign", 
                   "KA, KT, LA, MA Primaries", "ME, PR Primaries", "Mar 7", "MI, MS Primaries", 
                   "[D] Presidential Debate (FL)", "[R] Presidential Debate (FL)", "Mar 11")
  #create plot
  plot_ly(data, x = created, y = n, name = "Daily trends", text = events) 
  # adds grey bars underneath blue line
  #add_trace(p, type="bar", hoverinfo = "none", opacity = 0.5, marker = list(color = "grey"), showlegend = FALSE)
  
}

