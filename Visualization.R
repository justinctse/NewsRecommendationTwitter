#Justin Tse
#Visualizing Results
accDT <- read.csv("BOWData.csv")[,1:3]
library(ggplot2)

BOWAccPlot <- ggplot(accDT, aes(nTerms)) + 
  geom_line(aes(y = Train.Acc, colour = "Training Accuracy"), size = 1) + 
  geom_line(aes(y = TestAcc, colour = "Testing Accuracy"), size = 1)+
  ylab("Accuracy") + xlab("Number of Terms in the Bag of Words Model") + 
  ggtitle("Accuracy of Bag of Words Model")+
  theme(legend.position="bottom",legend.direction="vertical")

library(cairoDevice) 
ggsave(plot = BOWAccPlot, "BagOfWordsAccuracyPlot.png", h = 6, w = 9, type = "cairo-png")

stephclass <- classifyUser("stephencurry", 100, bowModel)
names(stephclass) <- c("Topic", "Frequency", "Proportion")
stephClass <- ggplot(data=stephclass, aes(x=Topic, y=Proportion, fill = Topic)) +
  geom_bar(stat="identity", width=.75) + ggtitle("Interests of Stephen Curry Based On His Last 100 Tweets")+
  scale_fill_brewer(palette="YlGnBu")+
  theme(legend.position="bottom",legend.direction="horizontal")
ggsave(plot = stephClass, "StephenCurryInterests2.png", h = 8, w = 8, type = "cairo-png")

margielaclass <- classifyUser("margiela", 100, bowModel)
names(margielaclass) <- c("Topic", "Frequency", "Proportion")
margielaClass <- ggplot(data=margielaclass, aes(x=Topic, y=Proportion, fill = Topic)) +
  geom_bar(stat="identity", width=.75) + ggtitle("Interests of Martin Margiela Based On His Last 100 Tweets")+
  scale_fill_brewer(palette="RdPu")+
  theme(legend.position="bottom",legend.direction="horizontal")
ggsave(plot = margielaClass, "margielaInterests.png", h = 8, w = 8, type = "cairo-png")
