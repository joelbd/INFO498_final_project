# real candidates twitter counts

library(dplyr)
library(twitteR)
library(plotly)
load("my_oauth.Rdata")
setup_twitter_oauth(my_oauth$consumerKey, my_oauth$consumerSecret, my_oauth$oauthKey, my_oauth$oauthSecret)

clinton <- "@HillaryClinton"
rubio <- "@marcorubio"
carson <- "@RealBenCarson"
trump <- "@realDonaldTrump"
cruz <- "@tedcruz"
sanders <- "@BernieSanders"
realCandidates <- function(candidate) {
  timeline <- userTimeline(candidate, n=300)
  timeline = do.call("rbind",lapply(timeline, as.data.frame))
  timeline$created <- as.Date(timeline$created)
  timeline <- group_by(timeline, created) %>%
    summarise( 
      #sum tweets created on the same day
      n = n())
  plot_ly(timeline, x = created, y = n, name = "daily trends")
}

