import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
import pandas as pd
import plotly.graph_objs as go
#%%
#Justin Tse
#Python implementation of the news recommender
#Setup
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import tweepy
import re
import requests
import json
import pickle

from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.svm import LinearSVC

from nltk.corpus import stopwords
from nltk.stem import PorterStemmer

from collections import Counter

ps = PorterStemmer()
stopwords_pattern = re.compile(r'\b(' + r'|'.join(stopwords.words('english')) + r')\b\s*')
plt.style.use("seaborn-whitegrid")
sns.set_style("whitegrid")
#Setup twitter connection
# Consumer keys and access tokens, used for OAuth
consumer_key = 'aWN6m8w6EuPlAblQ3e9PYMZjn'
consumer_secret = '7ac3dL0reDqIlRvfHF4Z9WolDz3MIupPXiTdLvtV2P7PB6dJOT'
access_token = '978782739892711430-Zubs11aTOeOPDLyN3lEev01F5dnclHe'
access_token_secret = 'H4lgkewLsvYK49HS6KZCJlE9Pl6XCo52YcVrVtsm3fj1n'

# OAuth process, using the keys and tokens
auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
 
# Creation of the actual interface, using authentication
twitter_api = tweepy.API(auth)

#Set up News API connections
NYT_API_key= "cf47130e83d242dc94f82f4d8387635b"
NEWSAPI_key = "ba98f232f1954f67ae9d6bede3b5e9e1"
# load the model from disk
SVM_model = pickle.load(open("SVM_model_5_24_2018.sav", 'rb'))
count_vec = pickle.load(open("count_vec_5_24_2018.sav", 'rb'))

#%%
#Function to extract tweets from a Tweepy object
#Inputs: json_file - A Tweepy object containg Tweet data
#Outputs: tweets - a list containing the text for each Tweet
def extract_text(json_file):
    my_dicts = []
    tweets = []
    for json_tweet in json_file:
        my_dicts.append(json_tweet._json)
    for each_dictionary in my_dicts:
        tweets.append(each_dictionary["text"])
    return(tweets)

#Function to clean a tweet for processing
#Inputs: text - raw text
#Outputs: text - processed text
def clean_text(text):
    text = re.sub(r"https\S*", "", text)
    text = re.sub(r"RT ", "", text)
    text = re.sub(r"#", "", text)
    text = re.sub(r"@\S*", "", text)
    text = re.sub(r"\n", "", text)
    text = re.sub(r"[^a-zA-Z0-9]+'[^a-zA-Z0-9]+", "", text)
    text = re.sub(r"[^[:alnum:][:space:]'']", "", text)
    #Remove stop words
    text = stopwords_pattern.sub('', text)
    text = text.strip().lower()
    #Stem the words
    text = ps.stem(text)
    return text

#Function to classify a user's interests
#Inputs: 
#   user_handle - Twitter user handle
#   num_tweets - The number of tweets to analyze
#   twitter_api - Tweepy API object
#   model - The model used to classify tweets
#   count_vec - A CountVectorizer object
#Outputs:
#   to_return - A dataframe containing the frequency, and proportion of each topic for the user
def classify_user(user_handle, num_tweets, twitter_api, model,count_vec):
    user_tweets = twitter_api.user_timeline(id = user_handle, count = num_tweets)
    user_tweets = extract_text(user_tweets)
    user_tweets = [clean_text(s) for s in user_tweets]
    predictions = model.predict(count_vec.transform(user_tweets))
    prediction_freq = Counter(predictions)
    to_return = pd.DataFrame()
    to_return["label"] = list(prediction_freq.keys())
    to_return["frequency"] = list(prediction_freq.values())
    to_return["proportion"] = to_return["frequency"]/np.sum(to_return["frequency"])
    to_return = to_return.sort_values("frequency", ascending = False)
    return(to_return)

#health, style, tech, sports, politics, business, science
#Function to visualize a user's interests
#Colorscheme based on most prevalent section
def plot_interests(user_handle, res):
    #health - Reds
    #style - RdPu
    #tech - Spectral
    #sports - YlOrRd
    #politics - RdYlBu
    #business - YlGnBu
    #science - GnBu
    res = res.reset_index(drop = True)
    #Get row with max proportion
    most_section = res["label"][res["proportion"].idxmax()]
    #most_section = max(set(topics), key=topics.count)
    sections = ["health", "style", "tech", "sports", "politics", "business", "science"]
    cmaps = ["Reds", "RdPu", "Spectral", "YlOrRd", "RdYlBu", "YlGnBu", "GnBu"]
    colormap = cmaps[sections.index(most_section)]
    temp = res.sort_values("label")
    sns.barplot(x = temp["label"], y = temp["proportion"], palette=colormap).set(xlabel = "Topic", ylabel = "Proportion",title = "Interests of " + user_handle + " Based on Twitter Profile")
    plt.show()

#%%
#Function to get #count news articles about a section
def get_news(section, count):
    num_articles_collected = 0
    to_return = pd.DataFrame(columns = ["title", "url", "date", "source", "section"])
    if section == "style":
        pop_request = "http://api.nytimes.com/svc/mostpopular/v2/mostviewed/style/7.json?api-key=" + NYT_API_key
        pop = requests.get(pop_request)
        #store just the content
        pop_content = pop._content
        #as the object is currently a string, need to convert to dictionary (for easy field extraction)
        pop_content = json.loads(pop_content)
        for k, v in pop_content.items():
            if(k == "results"):
                for a in v:
                    to_return.loc[num_articles_collected] = [a["title"], a["url"], a["published_date"], "New York Times", "style"]
                    num_articles_collected += 1
                    if num_articles_collected >= count:
                        return(to_return)
    else:
        pop_request = "https://newsapi.org/v2/top-headlines?country=us&category="+ section + "&apiKey=" + NEWSAPI_key
        pop = requests.get(pop_request)
        #store just the content
        pop_content = pop._content
        #as the object is currently a string, need to convert to dictionary (for easy field extraction)
        pop_content = json.loads(pop_content)
        for k, v in pop_content.items():
            if(k == "articles"):
                for a in v:
                    to_return.loc[num_articles_collected] = [a["title"], a["url"], a["publishedAt"], a["source"]["name"], section]
                    num_articles_collected += 1
                    if num_articles_collected >= count:
                        return(to_return)

#%%
#Get unique elements while preserving order
def get_unique_elements(list):
    seen = set()
    seen_add = seen.add
    return [x for x in list if not (x in seen or seen_add(x))]

#FN to recommend_news
#Algorithm is non random
#   1. Get topic with maximal proportion
#   2. Update proportion value by subtracting sub_amt from it
#   3. Repeat
#Adjust sub_amt, if its less then topics with more proportion will appear more
#Ex. If we select 10 articles then default sub_amt is 1/10, then if politics appears 5/10 of the time it should
#Be selected 5/10 of the time
# If sub_amt is 1/10 * .75 Politics will appear much more
def recommend_news(res, num_articles, adjuster=1):
    to_return = pd.DataFrame(columns = ["title", "url", "date", "source", "section"])
    i = 0 #Index to count number of articles collected
    sub_amt = (1/num_articles) * adjuster
    res = res.reset_index(drop = True)
    topics = []
    for i in range(0,num_articles):
        #Find the label with maximal proportion
        ind = res["proportion"].idxmax()     
        #Update the dataframe
        res.iloc[ind,2] = res.iloc[ind,2] - sub_amt
        topics.append(res.iloc[ind,0])
    #Sort topics by frequency
    counts = Counter(topics)
    topics = sorted(topics, key=lambda x: -counts[x])
    #Get a list of unique topics
    unique_topics = get_unique_elements(topics)
    topics = pd.Series(topics)
    #Get news for each topic in topics
    #remember to change tech
    for section in unique_topics:
        #Find how many times this section occurs
        num_articles_to_collect = np.sum(topics == section)
        if section == "tech":
            section = "technology"
        #print(get_news(section, num_articles_to_collect))
        to_return = to_return.append(get_news(section, num_articles_to_collect))
    return(to_return)
#Function of colors
COLORS = [
    {
        'background': '#F0F0F0',
        'text': 'rgb(30, 30, 30)'
    },
    {
        'background': '#DCDCDC',
        'text': 'rgb(0, 0, 0)'
    },
    {
        'background': '#C8C8C8',
        'text': 'rgb(0, 0, 0)'
    },
]

#Generate_table function that colors based on the column index 
def cell_style(index):
    style = {}
    if index == 0:
        style = {
                'backgroundColor': COLORS[0]['background'],
                'color': COLORS[0]['text'],
                'border-bottom': '1px solid black',
                'border-top': '1px solid black',
                'border-left': '1px solid black'
            }
    elif index == 1:
        style = {
                'backgroundColor': COLORS[1]['background'],
                'color': COLORS[1]['text'],
                'fontSize': 12,
                'font-family' : 'Arial',
                'border-bottom': '1px solid black',
                'border-top': '1px solid black'
            }
    elif index == 2:
            style = {
                'backgroundColor': COLORS[2]['background'],
                'color': COLORS[2]['text'],
                'fontSize' : 12,
                'font-family' : 'Arial',
                'border-bottom': '1px solid black',
                'border-top': '1px solid black',
                'border-right': '1px solid black'
            }
    return style


def generate_table(dataframe, max_rows=100):
    rows = []
    col_num = 0 #Counter to track column number
    for i in range(min(len(dataframe), max_rows)):
        row = []
        for col in dataframe.columns:
            value = dataframe.iloc[i][col]
            style = cell_style(col_num)
            row.append(html.Td(value, style=style))
            col_num += 1
        col_num = 0 
        rows.append(html.Tr(row))

    return html.Table(
        # Header
        [html.Tr([html.Th(col, style = {'font-family' : 'Arial'}) for col in dataframe.columns])] +

        # Body
        rows,
        style = {'border-spacing': '1px'})

#%%

#Spectral
spectral_color = np.array(['rgb(200,81,68)', 'rgb(228,148,103)', 'rgb(239,208,148)', 'rgb(247,247,200)', 'rgb(214,234,240)', 'rgb(152,191,210)', 'rgb(93,130,173)'])

app = dash.Dash()

app.layout = html.Div([
    #Title Text
    html.Div('News Recommendation From Twitter', style={'color': 'black', 'fontSize': 18, 'font-family' : 'Arial', 'font-weight': 'bold'}),
    #Horizontal Bar
    html.Hr(),
    html.Div([        
        html.Div([
            #Text box to input twitter user
            html.Div('Input Twitter User', style={'color': 'black', 'fontSize': 14, 'font-family' : 'Arial', 'font-weight': 'bold'}),  
            dcc.Input(id='user-name-input', value='BarackObama', type='text', size = 55),
        ],
        style={'width': '35%', 'display': 'inline-block'}), #48%

        html.Div([
            #Slider to input the number of tweets to train on 
            html.Div('Number of Tweets to Train On', style={'color': 'black', 'fontSize': 14, 'font-family' : 'Arial', 'font-weight': 'bold'}),  
            dcc.Slider(
                id='slider-updatemode',
                marks={50* i: '{}'.format(50 * i) for i in range(5)},
                min=0,
                max=200,
                step=1,
                value=50,
                )
        ],style={'width': '61%', 'float': 'right', 'display': 'inline-block'}) #48%
    ]),
    html.Br(),
    #Graph of twitter user's interests
    html.Div([
        html.Div([
            dcc.Graph(id='interests-graph'),
        ],style={'width' : '35%', 'display':'inline-block'}),
        #Table containing all of the recommended news articles
        html.Div([
            html.Div(id='news-recommendations-table'),
        ],style={'width': '61%', 'float': 'right', 'display': 'inline-block'})
    ]),
    html.Div([
        html.Div([
                #Required footer crediting the APIs used. 
                html.Div('Powered by News API & New York Times API', style={'color': 'black', 'fontSize': 8, 'font-family' : 'Arial', 'font-style': 'italic'}),
        ],style={'width': '61%', 'float': 'right', 'display': 'inline-block'})
    ])
])
    
#Function to create the graph of user interests
#Current color scheme used is a manually created spectral color scheme
@app.callback(
    Output('interests-graph', 'figure'),
    [Input('user-name-input', 'value'),
     Input('slider-updatemode','value')])
def update_graph(user, num_tweet):
    res = classify_user(user, num_tweet, twitter_api, SVM_model, count_vec)
    res = res.sort_values("label")
    trace1 = go.Bar(x=res["label"], y=res["proportion"], name='Declined', marker=dict(color=spectral_color.tolist())) #marker is the key to changing colors
    return {
        'data': [trace1],
        'layout':
        go.Layout(
            title='Interests of @{}'.format(user),
            barmode='stack',
        yaxis=dict(
        title='Proportion',
        titlefont=dict(
            size=14,
            color='rgb(0, 0, 0)')
            ),
        xaxis=dict(
        title = 'Topic',
        titlefont=dict(
            size = 14,
            color = 'rgb(0,0,0)')
            )
    )
    }       
#Table
@app.callback(
        Output('news-recommendations-table', 'children'),
        [Input('interests-graph','figure'),
         Input('user-name-input', 'value'),
         Input('slider-updatemode', 'value')])
def update_table(fig, user_name, num_tweets):
    temp = classify_user(user_name, num_tweets, twitter_api, SVM_model, count_vec)
    new_result = recommend_news(temp, 20, .85)
    #Create a column containing links to the articles
    links = []
    for i in range(0,len(new_result)):
        links.append(html.A(new_result.iloc[i,:]['title'], href = new_result.iloc[i,:]['url'], style ={'color': 'rgb(54,132,201)', 'fontSize': 12, 'font-family' : 'Arial', 'text-decoration':'none'}))

    #new_result['links'] = links
    #return generate_table(new_result[["links", "source", "section"]])  
    new_result['Article Title'] = links
    new_result['Source'] = new_result['source']
    new_result['Section'] = new_result['section']
    return generate_table(new_result[['Article Title','Source','Section']])

if __name__ == '__main__':
    app.run_server()
    


