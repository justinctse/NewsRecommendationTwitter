# News Recommendation Based on Twitter Profiles
The goal for this project is to use a Twitter user’s tweets to recommend news articles that they would be interested in. I will be working with data collected using the Twitter API. The data will consist of tweets representing different types of news topics. Using this data, I will build a model that can predict the topic of a tweet. I will use this model to analyze users and generate New York Times articles based off of the user’s interests.  

I have created two online apps to run the entire news recommendation system. The first app can be accessed at this link
https://justintse.shinyapps.io/newsrectwitter/. This is the app created with RShiny. I have also made an alternate app using Python and Dash that can be accessed by running **News_Recommender_Dash_GUI.py**. 

**Note:** Since github is public, I have blocked out my Twitter, News API, and New York Times API keys. To run the files, input your own API keys in the variables in the setup portions of each file. 

Files: 

* DataCollection.R - *Code to pull raw twitter data using Twitter API.*

* DataCompilation.R - *Code to compile/process the data from different topics into a single file.* 

* newsRecommender.R - *Code to use a model and recommend news articles to a specific user.*

* bagOfWords.R - *Code for the Bag of Words Model, Also contains code to get training and test error.*

* newsReccomendationGUI_FastVersion.R - *The RShiny version of the News Recommendation GUI. It loads a pre saved bag of words model so there is no training necessary.* 

* bowModel_Apr9_2018.RData - *Saved version of the bag of words model from data gathered in April.* 

* Visualization.R - *Code to produce visualizations.* 

* alternate_models.py - *Code containing three other models: MultinomialNB, Logistic Regression, SVM*

* SVM_model_5_24_2018.sav - *The SVM model to classify the topic of a Tweet.*

* count_vec_5_24_2018.sav - *The word vectorizer object for classifying Tweets. This is necessary to input a Tweet into a model. 

* News_Recommender_Dash_GUI.py - *The Python version of the News Recommendation GUI. It loads a pre saved SVM model. It also generates a graph of user interests in addition to recommending news articles.*
* 
![GUI for the recommendation system](https://i.imgur.com/YHoRPLO.png)
*The Python version of the News Recommendation System*
