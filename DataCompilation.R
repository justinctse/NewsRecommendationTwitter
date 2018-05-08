#Justin Tse
#Data Compilation for Final Project
#This file compiles all of the data into a single file
rm(list=ls())
library(stopwords)
library(tm)

#politics,business,tech,science,sports,style, health
politics <- read.csv("politics1.csv")
business <- read.csv("business1.csv")
tech <- read.csv("technology1.csv")
science <- read.csv("science1.csv")
sports <- read.csv("sports1.csv")
style <- read.csv("style1.csv")
health <- read.csv("health1.csv")

politics$label <- rep("politics",nrow(politics))
business$label <- rep("business",nrow(business))
tech$label <- rep("tech",nrow(tech))
science$label <- rep("science",nrow(science))
sports$label <- rep("sports",nrow(sports))
style$label <- rep("style",nrow(style))
health$label <- rep("health",nrow(health))

dt <- rbind(politics,business,tech,science,sports,style,health)

#Do some final processing of the text
dt$processedText <- tolower(dt$processedText)
words <- c(stopwords("en"),"rt")
dt$processedText <- removeWords(dt$processedText,words)
dt$processedText <- stripWhitespace(dt$processedText)
dt$processedText <- stemDocument(dt$processedText)
write.csv(dt, "compiledData.csv", row.names = F)
