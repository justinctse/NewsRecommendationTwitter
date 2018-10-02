# News Recommendation Based on Twitter Profiles
The goal for this project is to use a Twitter user’s tweets to recommend news articles that they would be interested in. I will be working with data collected using the Twitter API. The data will consist of tweets representing different types of news topics. Using this data, I will build a model that can predict the topic of a tweet. I will use this model to analyze users and generate New York Times articles based off of the user’s interests.  

I have created two online apps to run the entire news recommendation system. The first app can be accessed at this link
https://justintse.shinyapps.io/newsrectwitter/. This is the app created with RShiny. I have also made an alternate app using Python and Dash that can be accessed by running **News_Recommender_Dash_GUI.py**. 

**Note:** Since github is public, I have blocked out my Twitter, News API, and New York Times API keys. To run the files, input your own API keys in the variables in the setup portions of each file. 

Folders: 
* Apps - *Contains everything needed to run both GUIs.*

* Data_Preparation - *Contains scripts to download and process raw Twitter data.*

* Models - *Contains files to train classification models.*

* Visualizations - *Contains visualizations of the data.*



![GUI for the recommendation system](https://i.imgur.com/YHoRPLO.png)
*The Python version of the News Recommendation System*
