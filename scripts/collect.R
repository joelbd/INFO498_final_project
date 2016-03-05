# collect.R

library(streamR)

setwd("~/src/INFO_498F/final/INFO498_final_project")
source("scripts/credentials.R")
load("my_oauth.Rdata")



collect_tweets <- function(tags, interval) {
  tweets_json <-  filterStream(file.name = "tweets.json",
    track = tags,
    language = "en",
    timeout = interval,
    oauth = my_oauth)
  return(tweets_json)
}
