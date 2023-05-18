# COMPLETE RANDOM FOREST RUNS ON ALL BETA DIVERSITY METRICS
# IN ACCORDANCE WITH BETA_DIVERSITY_ANALYSIS PROJECT
# AUTHORED BY: DAISY FRY BRUMIT

# Imports
import os
import pandas as pd
import numpy as np
#from skbio.stats import composition
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import accuracy_score
from sklearn.metrics import r2_score
from sklearn.metrics import roc_auc_score
from sklearn.metrics import roc_curve

###################################################
# APPLY RANDOM FOREST ON ORDINATION (PCOA) OUTPUT
###################################################

# RANDOM FOREST FOR CATEGORICAL METADATA

def qualitativeRF(metadata,dat):
    meta_cat = metadata.select_dtypes(include=['object'])

    # make empty dictionaries for column-wide metrics
    accuracyDict = {}
    rocDict = {}
    truefalse_aggregates = {}

    # run RF for w/ each categorical column as 'y'
    for column in meta_cat.columns:
        # join metadata and full data
        full_table = meta_cat.join(dat, how='inner', on=None)  # None specifies index join. Inner b/c we only want full matches
        full_table = full_table.dropna(subset=[column])

        # set test and training groups
        x = full_table.loc[:, ~full_table.columns.isin(meta_cat.columns)]  # ~ is a negation operator. Isolate non-meta columns for x
        y = full_table.loc[:, full_table.columns.isin(meta_cat.columns)]  # Isolate metadata columns for y

        # check that categorical values occur more than once so training can proceed
        if 1 not in dict(y[column].value_counts()).values():
            # perform random forest 100 times with 0.25, 0.75 test train split
            accuracyList = []
            rocList = []
            run = 1  # for the ^^ dictionary keys

            for i in range(0, 100):
                x_train, x_test, y_train, y_test = train_test_split(x, y[column], test_size=0.25, train_size=0.75)

                # train the classifier, predict y values on test data
                randForest = RandomForestClassifier()
                randForest.fit(x_train, y_train)
                y_predict = randForest.predict(x_test) # predicts classes, good for accuracy and interpretation

                # generate performance metrics and save
                accuracy = accuracy_score(y_test, y_predict)

                try:
                    roc_auc = roc_auc_score(y_test, randForest.predict_proba(x_test)[:, 1], multi_class='ovr', average='macro')
                except Exception as exc:
                    print(column,'\n',exc)
                    roc_auc = 999

                accuracyList.append(accuracy)
                rocList.append(roc_auc)
                run += 1

                # package performance metrics in a list for output
                accuracyDict[column] = accuracyList
                rocDict[column] = rocList

    outList = [accuracyDict, rocDict] #, truefalse_aggregates]
    return outList

# RANDOM FOREST FOR QUANTITATIVE METADATA

def quantitativeRF(metadata, dat):
    # make empty dictionaries for column-wide metrics
    r2Dict = {}
    #rocDict = {}
    #truefalse_aggregates = {}

    # get cat data
    meta_quant = metadata.select_dtypes(include=['float64'])

    for column in meta_quant.columns:
        # run RF for w/ each quantitative column as 'y'
        r2List = []

        # join meta and full data
        full_table = meta_quant.join(dat, how='inner', on=None)  # None specifies index join. Inner b/c only want full matches
        full_table = full_table.dropna(subset=[column])

        # set test and train groups
        X = full_table.loc[:, ~full_table.columns.isin(meta_quant.columns)]
        y = full_table.loc[:, full_table.columns.isin(meta_quant.columns)]

        for i in range(0, 100):
            x_train, x_test, y_train, y_test = train_test_split(X, y[column], test_size=0.25, train_size=0.75, stratify=y[column])

            # train the classifier and predict y values
            randForest = RandomForestRegressor(n_estimators=50)
            randForest.fit(x_train, y_train)
            y_predict = randForest.predict(x_test) # predicts classes, good for R2 and interpretation

            # generate performance metrics and save
            R2 = r2_score(y_test, y_predict)
            r2List.append(R2)

            # package performance metrics in a list for output
            r2Dict[column] = r2List

        outList = [r2Dict] #, rocDict, truefalse_aggregates]
        return outList


