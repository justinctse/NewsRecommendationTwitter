# NewsRecommendationTwitter
The goal for this project is to use a Twitter user’s tweets to recommend news articles that they would be interested in. I will be working with data collected using the Twitter API. The data will consist of tweets representing different types of news topics. Using this data, I will build a model that can predict the topic of a tweet. I will use this model to analyze users and generate New York Times articles based off of the user’s interests.  

I have created an online app to run the entire news recommendation system. The app can be accessed at this link
https://justintse.shinyapps.io/newsrectwitter/

NOTE: SINCE GITHUB IS PUBLIC I HAVE BLOCKED OUT MY TWITTER AND NYT API KEYS. IF THEY ARE NEEDED TO GRADE THE PROJECT, MESSAGE Justin Tse. 

Files: 

newsReccomendationGUI_FastVersion.R - Fast version of the news recommendation GUI. It loads a pre saved bag of words model so there is no training necessary. 

bowModel_Apr9_2018.RData - Saved version of the bag of words model from data gathered in April. 

bagOfWords.R - Code for the Bag of Words Model, Also contains code to get training and test error.

DataCollection.R - Code to pull raw twitter data using Twitter API.

DataCompilation.R - Code to compile/process the data from different topics into a single file. 

NewsReccomendationGUI.R - Contains RShiny code that produces a GUI to recommend news articles to twitter users.

newsReccomender.R - Code to use a model and recommend news articles to a specific user.

Visualization.R - Code to produce visualizations. 

alternateModels.py - Code containing three other models: MultinomialNB, Logistic Regression, SVM

![GUI for the recommendation system](https://i.imgur.com/YHoRPLO.png)
