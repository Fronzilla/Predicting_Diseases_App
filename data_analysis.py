# -*- coding: utf-8 -*-
"""

"""
import pandas as pd
import os
import seaborn
import matplotlib.pyplot as plt
from sklearn.naive_bayes import MultinomialNB
from sklearn.model_selection import train_test_split

__author__ = 'av.nikitin'

file_dir = os.path.dirname(__file__)

# read in ISO-8859-1
data = pd.read_csv(
    os.path.join(file_dir, 'data', 'data_set_cleaned.csv'),
    names=['Source', 'Target', 'Weight'],
    encoding="ISO-8859-1"
)

data.head()

# examine unique values
print(
    len(data['Source'].unique()),
    len(data['Target'].unique())
)

df = pd.DataFrame(data)
df_1 = pd.get_dummies(df.Target)

# source column
df_s = df['Source']
df_pivoted = pd.concat([df_1, df_s], axis=1)
df_pivoted.drop_duplicates(keep='first', inplace=True)
print(df_pivoted[:5])

cols = df_pivoted.columns
cols = cols[1:]
print(cols)

df_pivoted = df_pivoted.groupby('Source').sum().reset_index()
print(df_pivoted[:5], len(df_pivoted))

# dump pivoted data to csv file
if not os.path.exists(os.path.join(file_dir, 'data', 'df_pivoted.csv')):
    df_pivoted.to_csv(os.path.join(file_dir, 'data', 'df_pivoted.csv'))

# trying out our classifier to learn diseases from the symptoms
x, y = df_pivoted[cols], df_pivoted['Source']

# splitting the data
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.30, random_state=42)
mnb = MultinomialNB()
mnb = mnb.fit(x_train, y_train)
print(mnb)
