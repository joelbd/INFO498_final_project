
library(devtools)
library(plotly)
library(twitteR)
load("my_oauth.Rdata")

setup_twitter_oauth(my_oauth$consumerKey, my_oauth$consumerSecret, my_oauth$oauthKey, 
                    my_oauth$oauthSecret)

#map 1
tweets = searchTwitter("election+us+2016",n=50, geocode="38,-95,2000mi")
tweets.df = do.call("rbind",lapply(tweets,as.data.frame))
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showland = TRUE,
  landcolor = toRGB("gray85"),
  subunitwidth = 1,
  countrywidth = 1,
  subunitcolor = toRGB("white"),
  countrycolor = toRGB("white")
)
tweets.df$q <- with(tweets.df, cut(created, 4))
plot_ly(tweets.df, lat=latitude, lon=longitude, text=text, mode='markers', marker = 
          list(size = 10, symbol = 'circle'), color=q, type="scattergeo", 
        locationmode='USA-states')%>%layout(width = 900, height = 700, geo=g)

#map 2
twitterMap <- function(searchtext,locations,radius){
  require(ggplot2)
  require(maps)
  require(twitteR)
  #radius from randomly chosen location
  radius=radius
  lat<-runif(n=locations,min=24.446667, max=49.384472)
  long<-runif(n=locations,min=-124.733056, max=-66.949778)
  #generate data fram with random longitude, latitude and chosen radius
  coordinates<-as.data.frame(cbind(lat,long,radius))
  coordinates$lat<-lat
  coordinates$long<-long
  #create a string of the lat, long, and radius for entry into searchTwitter()
  for(i in 1:length(coordinates$lat)){
    coordinates$search.twitter.entry[i]<-toString(c(coordinates$lat[i],
                                                    coordinates$long[i],radius))
  }
  # take out spaces in the string
  coordinates$search.twitter.entry<-gsub(" ","", coordinates$search.twitter.entry ,
                                         fixed=TRUE)
  
  #Search twitter at each location, check how many tweets and put into dataframe
  for(i in 1:length(coordinates$lat)){
    coordinates$number.of.tweets[i]<-
      length(searchTwitter(searchString=searchtext,n=1000,geocode=coordinates$search.twitter.entry[i]))
  }
  #making the US map
  all_states <- map_data("state")
  #plot all points on the map
  p <- ggplot()
  p <- p + geom_polygon( data=all_states, aes(x=long, y=lat, group = group),colour="grey",     fill=NA )
  
  p<-p + geom_point( data=coordinates, aes(x=long, y=lat,color=number.of.tweets
  )) + scale_size(name="# of tweets")
  p
}
# Example
twitterMap('trump', 50, '2mi')
searchTwitter('election+2016', n=50, lang='en')

