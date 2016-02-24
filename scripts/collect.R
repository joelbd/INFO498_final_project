# collect.R

library(streamR)
source("scripts/tags.R")
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
