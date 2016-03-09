# collect.R

setwd("~/src/INFO_498F/final/INFO498_final_project")
source("scripts/credentials.R")
load("my_oauth.Rdata")

collect_tweets <- function(tags, timeout) {
  file.name <- "tweets.json"

  # WRITING FUNCTION
  tweetsSeen <- 0

  ## write the JSON tweets from Streaming API to a text file
  message("Capturing tweets...")

  jsonFile <- file(description = file.name, open = "a")
  write.tweets <- function(tweet) {
    # writes output of stream to a file
    if (nchar(tweet) > 0) {
      tweetsSeen <<- tweetsSeen + 1
      writeLines(tweet, jsonFile, sep="")
    }
  }

  # building parameter lists
  params <- list()
  params[["track"]] <- paste(tags, collapse=",")
  params[["language"]] <- paste(as.character("en"), collapse=",")

  init <- Sys.time()
  # connecting to Streaming API
  output <- tryCatch(
    my_oauth$OAuthRequest(
      URL = "https://stream.twitter.com/1.1/statuses/filter.json",
      params = params,
      method = "POST",
      customHeader = NULL,
      timeout = timeout,
      writefunction = write.tweets,
      cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")
    ),
    error = function(e) e
  )

  # housekeeping...
  close(jsonFile)

  # information messages
  seconds <- round(as.numeric(difftime(Sys.time(), init, units="secs")),0)
  message("Connection to Twitter stream was closed after ", seconds,
          " seconds with up to ", tweetsSeen, " tweets downloaded.")
}
