# collect.R

library(streamR)
source("scripts/tags.R")

load("my_oauth.Rdata")
collect_tweets <- function() {
  filterStream(file.name = "tweets.json",
     track = c("Bernie Sanders", "Single Payer Healthcare", "FeelTheBern"),
     language = "en",
     timeout = 60,
     oauth = my_oauth)

  tweets.df <- parseTweets("tweets.json", simplify = FALSE)
  return(tweets.df)
}

collect_tweets()
