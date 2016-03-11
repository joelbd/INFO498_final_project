# build_plot

library(dplyr)
library(plotly)

# function to build chart accepts a csv file as a parameter
build_plot <- function(file) {
  #read in data from file
  data <- read.csv(file, stringsAsFactors=FALSE)
  
  ifelse(file == 'csv_data/clinton.csv',
         data$created <- as.Date(data$created, '%m/%d/%y'),
         data$created <- as.Date(data$created))
  
  #change created column to date objects instead of characters
  data$created <- as.Date(data$created)
  #group data by date created
  data <- group_by(data, created) %>%
    summarise( 
      #sum tweets created on the same day
      n = n())
  
  blankRow <- data.frame(created = paste0("2016-02-24"), n = 0)
  
  ifelse(nrow(data) != 17,
         data <- data %>% rbind(blankRow) %>% arrange(created),
         nrow(data))
  
  #added text to the days, detailing some of the events
  data$events <- c("Feb24", "NV Primary", "Feb 26", "SC Primary", "Feb 28", "Feb 29", 
                   "Super Tuesday", "Mar 2", "[R] Presidential Debate (MI)", "Ben Carson ends campaign", 
                   "KA, KT, LA, MA Primaries", "ME, PR Primaries", "Mar 7", "MI, MS Primaries", 
                   "[D] Presidential Debate (FL)", "[R] Presidential Debate (FL)", "Mar 11")
  #create plot
  plot_ly(
    data, 
    x = created, 
    y = n, 
    name = "Daily trends", 
    text = events) %>%
  layout(
    title = "Daily Total Tweets",
    xaxis = list(
      title = "Days"
    ),
    yaxis = list(
      title = "Total Tweets",
      gridcolor = "333333"
    ),
    font = list(color = "2a9fd6"),
    plot_bgcolor = "222222",
    paper_bgcolor = "222222"
  )  
}

