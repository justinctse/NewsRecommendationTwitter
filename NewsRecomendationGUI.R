#Justin Tse
rm(list=ls())
library(tm)
library(qdap)
library(nytimes)
library(shiny)
library(twitteR)
words <- c(stopwords("en"),"rt")
dt <- read.csv("compiledData.csv")
labels <- c("politics", "business", "tech", "science", "sports", "style", "health")
#Set up Twitter Connection
consumer_key <- ""
consumer_secret <- ""
access_token <- ""
access_secret <- ""
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
#Set up NYT Connection
NYTIMES_KEY <- ""


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
#Reccomend news function
#Inputs:
# User - Twitter user handle
# nTweet - Number of tweets to classify
# model - the model to use
# numArticle - the number of articles to reccomend
reccomendNews <- function(user, nTweet, model, numArticle, NYTIMES_KEY){
  res <- classifyUser(user,nTweet,model)
  #res$WORD[res$WORD == "politics"] <- "U.S."
  res$WORD[res$WORD == "tech"] <- "Technology"
  res$WORD[res$WORD == "business"] <- "business"
  #Get a list of news article that you want to reccomend
  articleSamp <- sample(res$WORD, size=numArticle, replace=T, prob=res$prob)
  #Convert to frequency list
  articleSamp <- as.data.frame(table(unlist(articleSamp)))
  articleSamp <- articleSamp[order(articleSamp$Freq, decreasing = T),]
  articleSamp$Var1 <- as.character(articleSamp$Var1)
  recommendedArticles <- data.frame()
  #Go through each of the articleSamp values and get articles
  for(i in 1:nrow(articleSamp)){
    articles <- as.data.frame(nyt_mostpopular(metric = "mostviewed",section = articleSamp$Var1[i], apikey = NYTIMES_KEY, days = 1))
    #Get the top x rows
    recommendedArticles <- rbind(recommendedArticles,articles[1:articleSamp[i,]$Freq,])
  }
  return(recommendedArticles)
  
}


#Train the bag of words model
bowModel <- trainBOW(dt, 15000) #About 16 seconds to train on a 15000 freq bow model
#result <- reccomendNews("mkbhd",50,bowModel, 7, NYTIMES_KEY)

#Function to turn a url into a link
linkFN <- function(url) {
  #temp <- paste('<a href="',url,'" target="_blank" class="btn btn-primary">Link</a>')
  temp <- paste('<a href="',url,'" target="_blank" class="one">',url,'</a>')
  sprintf(temp,url)
}

# Define UI for dataset viewer app ----
# Define UI for dataset viewer app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("News Recommendation Based on Twitter"),
  
  # Sidebar layout with a input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Selector for choosing dataset ----
      # selectInput(inputId = "dataset",
      #             label = "Choose a dataset:",
      #             choices = c("rock", "pressure", "cars")),
      
      textInput(inputId = "user", label = "Input a Twitter User:", value = ""),
      textInput(inputId = "nTweet", label = "Number of Tweets to Train From: ", value = "100")
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Verbatim text for data summary ----
      #verbatimTextOutput("summary"),
      
      # Output: HTML table with requested number of observations ----
      #tableOutput("view")
      verbatimTextOutput('view'),
      dataTableOutput('table1')
      
    )
    
  )
  
)

server <- function(input, output) {
  output$view <-
  renderText({
    paste("User:", paste("@",input$user, sep = ""))
  })
  
  output$table1 <- renderDataTable({
    res <- reccomendNews(input$user,as.integer(input$nTweet),bowModel, 7, NYTIMES_KEY)[,c("title","section", "url")]
    colnames(res) <- c("Title", "Section","Link")
    res$Link <- linkFN(res$Link)
    return(res)
  }, escape = FALSE)
  
  
  # output$table1 <- renderDataTable({
  #   res <- reccomendNews("mkbhd",400,bowModel, 7, NYTIMES_KEY)[,c("title","section", "url")]
  #   colnames(res) <- c("Title", "Section","URL")
  #   res$link <- createLink(res$URL)
  #   return(res)
  #   
  # }, escape = FALSE)
  
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
