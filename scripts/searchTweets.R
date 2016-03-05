# Search
library(dplyr)
library(twitteR)

source("scripts/tags.R")
source("scripts/credentials.R")
load("my_oauth.Rdata")
setup_twitter_oauth(my_oauth$consumerKey, my_oauth$consumerSecret, my_oauth$oauthKey, my_oauth$oauthSecret)

TAGS_CARSON <- c(TAGS_CARSON[1], TAGS_CARSON[3])
TAGS_CRUZ <- c(TAGS_CRUZ[1], TAGS_CRUZ[3])
# initialize files
init <- function(candidate, query) {
  tweets = searchTwitter(query, n=500, since = '2016-02-01', geocode="38,-95,2000mi", retryOnRateLimit=0)
  tweets = do.call("rbind",lapply(tweets, as.data.frame))
  tweets = select(tweets, text, created, isRetweet, longitude, latitude)
  #write csv file
  write.csv(tweets, file = candidate)
}

# Clinton
init('clinton.csv', TAGS_HILLARY[1])
# Sanders
init('sanders.csv', TAGS_BERNIE[1])
# Carson 
init('carson.csv', TAGS_CARSON[1])
# Cruz
init('cruz.csv', TAGS_CRUZ[1])
# Rubio
init('rubio.csv', TAGS_RUBIO[1])
# Trump
init('trump.csv', TAGS_TRUMP[1])

#read in old tweets and join with new tweets
searchTweets <- function(fileName, query) {
  tweetsOld <- read.csv(fileName, stringsAsFactors = FALSE)
  #get rid of funky column
  tweetsOld <- tweetsOld[, 2:6]
  #Search twitter
  # ?filter out retweets?
  tweets = searchTwitter(query, n=500, since = '2016-02-01', geocode="38,-95,2000mi", retryOnRateLimit=0)
  tweets = do.call("rbind",lapply(tweets, as.data.frame))
  tweets = select(tweets, text, created, isRetweet, longitude, latitude)
  #write csv file to change date format to be the same as tweetsOld
  write.csv(tweets, file = fileName)
  tweetsNew <- read.csv(fileName, stringsAsFactors=FALSE)
  tweetsNew <- tweetsNew[, 2:6]
  #join all tweets into one data frame
  joined <- full_join(tweetsOld, tweetsNew, by = c("text", 'created', 'isRetweet', 
                                                   'longitude', 'latitude'))
  #write back into file
  write.csv(joined, file = fileName)
}

#reset tags
TAGS_BERNIE <- TAGS_BERNIE[2:7]
TAGS_CARSON <- TAGS_CARSON[2:2]
TAGS_CRUZ <- TAGS_CRUZ[2]
TAGS_HILLARY <- TAGS_HILLARY[2:5]
TAGS_RUBIO <- TAGS_RUBIO[2:3]
TAGS_TRUMP <- TAGS_TRUMP[2:5]

#run searchTweets to compile file of tweets for each candidate
for(i in TAGS_BERNIE) {
  searchTweets('sanders.csv', i)
}
for(i in TAGS_CARSON) {
  searchTweets('carson.csv', i)
}
for(i in TAGS_CRUZ) {
  searchTweets('cruz.csv', i)
}
for(i in TAGS_HILLARY) {
  searchTweets('clinton.csv', i)
}
for(i in TAGS_RUBIO) {
  searchTweets('rubio.csv', i)
}
for(i in TAGS_TRUMP) {
  searchTweets('trump.csv', i)
}



for(i in TAGS_CARSON) {
  searchTweets('carson.csv', i)
}

tweetsOld <- read.csv('carson.csv', stringsAsFactors = FALSE)
#get rid of funky column
tweetsOld <- tweetsOld[, 2:6]
#Search twitter
# ?filter out retweets?
tweets = searchTwitter(TAGS_CARSON[2], n=500, since = '2016-02-01', geocode="38,-95,2000mi", retryOnRateLimit=0)
tweets = do.call("rbind",lapply(tweets, as.data.frame))
tweets = select(tweets, text, created, isRetweet, longitude, latitude)
#write csv file to change date format to be the same as tweetsOld
write.csv(tweets, file = 'carson.csv')
tweetsNew <- read.csv('carson.csv', stringsAsFactors=FALSE)
tweetsNew <- tweetsNew[, 2:6]
#join all tweets into one data frame
joined <- full_join(tweetsOld, tweetsNew, by = c("text", 'created', 'isRetweet', 
                                                 'longitude', 'latitude'))
#write back into file
write.csv(joined, file = 'carson.csv')
