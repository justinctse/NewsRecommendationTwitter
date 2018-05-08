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

#Split the data
set.seed(1)
ind <- sample(1:289107, .8 * nrow(dt))
train <- dt[ind, ]
test <- dt[-ind,]
train$labelString <- as.character(train$label)
test$labelString <- as.character(test$label)


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

#Function to get the training and test Accuracy
#It also prints out the time to get the training Accuracy
AccFunction <- function(train, test, freqList){
  start_time <- Sys.time()
  trainPred <- sapply(train$processedText, classifyText, freqList = freqList, simplify = TRUE)
  end_time <- Sys.time()
  print(end_time - start_time)
  print(freq_terms(trainPred, 7))
  trainAcc <- mean(trainPred == train$labelString) 
  testPred <- sapply(test$processedText, classifyText, freqList = freqList, simplify = TRUE)
  print(freq_terms(testPred, 7))
  testAcc <- mean(testPred == test$labelString)
  return(c("TrainAcc" = trainAcc, "TestAcc" = testAcc))
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
  return(predDT)
}

#Code to train the model and Get Accuracy
bowModel <- trainBOW(train, 15000)
AccFunction(train, test, bowModel)

classifyUser("mkbhd", 200,bowModel)
classifyUser("BarackObama",200,bowModel)
classifyUser("stephencurry",200,bowModel)
classifyUser("AveryGinsberg",200,bowModel)
classifyUser("chingyung", 200,bowModel)
classifyUser("sangiev",200,bowModel)
classifyUser("Margiela",200,bowModel)
classifyUser("cvssucksass", 200, bowModel)


classifyText("hello there how are you", bowModel)
classifyText("I did well on my test today", bowModel)
