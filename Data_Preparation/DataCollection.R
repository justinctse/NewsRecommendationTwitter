#Justin Tse
#The purpose of this file is to collect the raw twitter data and process the text

#Clear the workspace
rm(list=ls())
#Set up the twitter API
library(twitteR)
consumer_key <- ""
consumer_secret <- ""
access_token <- ""
access_secret <- ""
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

#processTweet Function
#Input: A string of text
#Output: A string of text with a modified Input
#Remove links
#Remove the specific Hashtag
#Remove the Hash symbols
#Remove the twitter handle
#Consider removing the "RT" string
#I cannot remove quotation marks for some reason
#Function has trouble with some apostraphes
processTweet <- function(inputText,hashtag="default"){
  temp <- inputText 
  temp <- gsub(pattern = "https\\S*", replacement = "", temp) #remove the links
  if(hashtag != "default"){
    temp <- gsub(pattern = hashtag, replacement = "", temp) #remove the specific hashtag
  }
  temp <- gsub(pattern = "#", replacement = "", temp) #remove the hash symbol
  temp <- gsub(pattern = "@\\S*", replacement = "", temp) #remove twitter handle
  temp <- gsub("\\n", " ", temp)
  temp <- gsub(pattern = "[^a-zA-Z0-9]+'[^a-zA-Z0-9]+", replacement = " ", temp) #non words
  temp <- gsub("[^[:alnum:][:space:]'']", "", temp) #remove symbols, except for ' 
  return(temp)
}

#Download data from a specific hashtag
hashtag <- "#health"
dt <- searchTwitter(hashtag, n = 40000, since = '2016-10-01', retryOnRateLimit = 1e3)
dt<- twListToDF(dt)
#Process the tweet, use the regex for the specific hashtag, I made sure that the regex accounts for different capitalizations
dt$processedText <- processTweet(dt$text, "#[h,H]ealth")

#Write the results to a csv file
?write.csv
write.csv(dt, "health1.csv", row.names = F)

#Sample code to pull tweets from a timeline
tlDT <- userTimeline("mkbhd", n = 15)
tlDT <- twListToDF(tlDT)
tlDT$text
processTweet(tlDT$text)
