# INFO498_final_project
The final group project for INFO 498.


###Project Description: 

A web application that lets a user search for any topic and view a map of all locations from which that topic has been mentioned. For the proof of concept we will focus on mentions of political candidates as a way to gauge interest.

Data sources:
* Twitter Search API
* Google Maps API

Target Audience: Any person or group looking to analyze and understand the spread of a trending topic on a geographical scale. 

Questions to answer:
* How do tweet content trends of political candidates change geographically?
* How does the geographical data change over time?
* Where are the different candidates most popular?


###Technical description:
  
Format: The final product should be an HTML page that is easily accessible from any desktop browser.

Data: The data will be read into data frames from the JSON response received from Twitter API.

Data-wrangling: Sort information by mentions, hashtag, location.

Libraries: Knitr, JSON, dplyr, plotly

Challenges:
* Readability of the responses.
* Require OAUTH for each twitter handle to analyze?
* What’s publicly available and what requires OAUTH?
* Running out of time. If the feature set is too ambitious for the time available this may not be realistic. We’ll need to make sure we keep it in scope.


###Project Setup
* create repository
* create issues (5 minimum)
* create slack channel and automatically post in channel anytime someone pushes to repository



