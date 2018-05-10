# NewsRecommendationTwitter
Github for Justin Tse and Cindy Xu's final project.

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

