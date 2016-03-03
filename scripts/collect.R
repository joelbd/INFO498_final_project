# collect.R

library(streamR)
library(twitteR)

setwd("~/src/INFO_498F/final/INFO498_final_project")
source("scripts/tags.R")
source("scripts/credentials.R")
load("my_oauth.Rdata")


collect_tweets <- function(tags) {
  filterStream(file.name = "tweets.json",
     track = tags,
     language = "en",
     timeout = 10,
     oauth = my_oauth)
  tweets_df <- parseTweets("tweets.json", simplify = FALSE)
  return(tweets_df)
}
