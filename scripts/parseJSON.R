# parseTweets.R

library(dplyr)
library(streamR)
library(twitteR)

setwd("~/src/INFO_498F/final/INFO498_final_project")
source("scripts/collect.R")

filter_tweets <- function(){
  tweets_df <- 
    parseTweets("tweets.json", simplify = TRUE) %>%
    select(text, screen_name) %>%
    arrange(-row_number())
  return(tweets_df)
}
