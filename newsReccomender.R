#Justin Tse
#File to reccomend news to a user
#Bag of Words Model
#Justin Tse
#testAnalysis
rm(list=ls())
library(tm)
library(qdap)
words <- c(stopwords("en"),"rt")
dt <- read.csv("compiledData.csv")
labels <- c("politics", "business", "tech", "science", "sports", "style", "health")
#Set up Twitter Connection
library(twitteR)
consumer_key <- ""
consumer_secret <- ""
access_token <- ""
access_secret <- ""
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
#Set up NYT connection
apikey <- paste0("NYTIMES_KEY=", "")
file <- file.path(path.expand("~"), ".Renviron")
cat(apikey, file = file, append = TRUE, fill = TRUE)

#Function to train the bag of words model. 
trainBOW <- function(train, nTerms){
  #print(nTerms)
  #Train the model 
  freqListTemp <- list()
  for(i in 1:7){
    freqListTemp[[i]] <- freq_terms(train[train$label == labels[i],]$processedText, nTerms)
    freqListTemp[[i]]$prob <- freqListTemp[[i]]$FREQ/sum(train$label == labels[i])
  }
  return(freqListTemp)
}
#Function to get the probability of a processed text 
#Inputs: Text, labelID, freqList
#Outputs: The rough probability getting those words from the bag with label labelID
getProb2 <- function(Text, labelID, freqList){
  if(Text == ""){
    return(0)
  }
  #Split the text
  TextSplit <- strsplit(Text, split = " ")[[1]]
  #Calculate the probability of getting the rawText
  prob <- 1
  minProb <- min(freqList[[labelID]]$prob)
  for(i in 1:length(TextSplit)){
    if(TextSplit[i] %in% freqList[[labelID]]$WORD){
      #Update prob
      prob <- prob * freqList[[labelID]]$prob[which(freqList[[labelID]]$WORD == TextSplit[i])]
    }
    else{
      #if the word is not in the bag, then multiply it by the lowest probability, we do this so we do not multiply by 0 
      prob <- prob * minProb
    }
  }
  return(prob)
}
#Classifies a text based on the bag of words model 
#Note: If all probabilities are 0 ((That is Text = "") then we return "UNCERTAIN"
classifyText <- function(rawText, freqList){
  #Process the text
  rawText <- gsub(pattern = "https\\S*", replacement = "", rawText) #remove the links
  rawText <- gsub(pattern = "#", replacement = "", rawText) #remove the hash symbol
  rawText <- gsub(pattern = "@\\S*", replacement = "", rawText) #remove twitter handle
  rawText <- gsub("\\n", " ", rawText)
  rawText <- gsub(pattern = "[^a-zA-Z0-9]+'[^a-zA-Z0-9]+", replacement = " ", rawText) #non words
  rawText <- gsub("[^[:alnum:][:space:]'']", "", rawText) #remove symbols, except for ' 
  rawText <- tolower(rawText)
  rawText <- removeWords(rawText,words)
  rawText<- stripWhitespace(rawText)
  rawText<- stemDocument(rawText)
  #Get the probabilitys
  probVec <- c()
  for(i in 1:7){
    probVec[i] <- getProb2(rawText, i, freqList)
  }
  #Get which probability is the maximum 
  #Check if the probs are all 0 
  if(mean(probVec) == 0){
    return("UNCERTAIN")
  }
  maxProb <- max(probVec)
  #return the correct label
  return(labels[which(probVec == maxProb)])
  
}
#Function to download tweets from a user 
#Returns all of the predicted labels
getUserTweet <- function(user, numTweet, freqList){
  tlDT <- userTimeline(user, n = numTweet)
  tlDT <- twListToDF(tlDT)
  #Classify text, the classify text function takes in RAW text
  pred <- sapply(tlDT$text, classifyText,freqList = freqList,  simplify = TRUE)
  return(pred)
}
#Classifies a users interests 
classifyUser <- function(user,numTweet, freqList){
  pred <- getUserTweet(user,numTweet, freqList)
  names(pred) <- NULL
  predDT <- freq_terms(pred)
  predDT$prob <- predDT$FREQ/length(pred)
  predDT <- predDT[predDT$WORD %in% labels,] #Filter out unceratin,... i have no idea where ctech comes from
  sum <- sum(predDT$prob)
  predDT$prob <- predDT$prob/sum #Normalize
  return(predDT)
}

#Train The Model
bowModel <- trainBOW(dt, 15000)

classifyUser("mkbhd", 500,bowModel)
classifyUser("BarackObama",200,bowModel)
classifyUser("stephencurry",200,bowModel)
classifyUser("AveryGinsberg",200,bowModel)
classifyUser("chingyung", 200,bowModel)
classifyUser("sangiev",200,bowModel)

library(nytimes)
NYTIMES_KEY <- ""
#Note the api does not allow politics, use U.S. instead
#labels = c("politics", "business", "tech", "science", "sports", "style", "health")
#NYTlab = c("U.S., "business", "Technology", "Science", "Sports", "Style", "Health)
articles <- as.data.frame(nyt_mostpopular(metric = "mostviewed",section = "health", apikey = NYTIMES_KEY, days = 1)) #Note that days does not refer to when the article is published

#Reccomend news function
#Inputs:
# User - Twitter user handle
# nTweet - Number of tweets to classify
# model - the model to use
# numArticle - the number of articles to reccomend
reccomendNews <- function(user, nTweet, model, numArticle, NYTIMES_KEY){
  res <- classifyUser(user,nTweet,model)
  res$WORD[res$WORD == "politics"] <- "U.S."
  res$WORD[res$WORD == "tech"] <- "Technology"
  res$WORD[res$WORD == "business"] <- "business"
  #Get a list of news article that you want to reccomend
  articleSamp <- sample(res$WORD, size=numArticle, replace=T, prob=res$prob)
  #Convert to frequency list
  articleSamp <- as.data.frame(table(unlist(articleSamp)))
  articleSamp <- articleSamp[order(articleSamp$Freq, decreasing = T),]
  
  recommendedArticles <- data.frame()
  #Go through each of the articleSamp values and get articles
  for(i in 1:nrow(articleSamp)){
    print(articleSamp$Var1[i])
    articles <- as.data.frame(nyt_mostpopular(metric = "mostviewed",section = articleSamp$Var1[i], apikey = NYTIMES_KEY, days = 1))
    #Get the top x rows
    recommendedArticles <- rbind(recommendedArticles,articles[1:articleSamp[i,]$Freq,])
  }
  return(recommendedArticles)
  
}
result <- reccomendNews("BarackObama",100,bowModel, 5, NYTIMES_KEY)

