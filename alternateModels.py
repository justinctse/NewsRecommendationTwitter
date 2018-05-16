#Justin Tse
#Testing alternative models for classifying tweets
#MultinomialNB, Logistic Regression, SVM

#Setup
import os

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.cross_validation import train_test_split
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer

from sklearn.naive_bayes import MultinomialNB
from sklearn.linear_model import LogisticRegression
from sklearn.svm import LinearSVC

#Set seed
np.random.seed(1)
#Set working directory
os.chdir("D:\\Documents\\BDAFinalProject")
#Read in the data\
dt = pd.read_csv("compiledData.csv", encoding = "ISO-8859-1")
#Split the data into train and test sets
X_train, X_test, Y_train, Y_test = train_test_split(dt.processedText, dt.label, test_size = .2)
#Set plot style
plt.style.use("ggplot")

#Prepare the text for analysis
X_train = [str(s).strip() for s in X_train]
count_vec = CountVectorizer(encoding = "latin-1")
X_train_counts = count_vec.fit_transform(X_train)
tfidf_transformer = TfidfTransformer()
X_train_tfidf = tfidf_transformer.fit_transform(X_train_counts)

#%%
#Multinomial Model 
mNB_model = MultinomialNB().fit(X_train_tfidf, Y_train)
#Get training accuracy
mNB_train_acc = np.mean(mNB_model.predict(X_train_tfidf) == Y_train)
#Get testing accuracy
mNB_test_acc = np.mean(mNB_model.predict(count_vec.transform(X_test.astype(str))) == Y_test)
mNB_acc = ["MultinomialNB",mNB_train_acc,mNB_test_acc]
#%%
#Logistic Regression Model
log_model = LogisticRegression().fit(X_train_tfidf, Y_train)
#Get training accuracy
log_train_acc = np.mean(log_model.predict(X_train_tfidf) == Y_train)
#Get testing accuracy
log_test_acc = np.mean(log_model.predict(count_vec.transform(X_test.astype(str))) == Y_test)
log_acc = ["Logistic Regression",log_train_acc,log_test_acc]
#%%
#Linear SVM
SVM_model = LinearSVC().fit(X_train_tfidf, Y_train)
#Get training accuracy
SVM_train_acc = np.mean(SVM_model.predict(X_train_tfidf) == Y_train)
#Get testing accuracy
SVM_test_acc = np.mean(SVM_model.predict(count_vec.transform(X_test.astype(str))) == Y_test)
SVM_acc = ["SVM", SVM_train_acc,SVM_test_acc]
#%%
#Visualize the results
#Make a grouped bar plot of the errors 
acc_df = pd.DataFrame(mNB_acc).transpose()
acc_df = acc_df.append(pd.DataFrame(log_acc).transpose())
acc_df = acc_df.append(pd.DataFrame(SVM_acc).transpose())
acc_df.columns = ["Model", "Training Accuracy", "Testing Accuracy"]
#Get number of rows
acc_df.index = list(range(acc_df.shape[0]))

#Create a grouped bar plot
fig,ax = plt.subplots(figsize=(10,5.5))
ind = np.arange(acc_df.shape[0])    # the x locations for the groups [0,1,2]
width = 0.35         # the width of the bars
p1 = ax.bar(ind, acc_df.iloc[:,1], width, color='#3E6170')
p2 = ax.bar(ind + width, acc_df.iloc[:,2], width, color='#C9283E')
ax.set_title('Accuracies of the Different Models')
ax.set_xticks(ind + width / 2)
ax.set_xticklabels((acc_df["Model"]))
ax.legend((p1[0], p2[0]), ('Training Accuracy', 'Testing Accuracy'))
ax.autoscale_view()
plt.show()
plt.close()