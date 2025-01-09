# COMPLETE RANDOM FOREST RUNS ON ALL BETA DIVERSITY METRICS
# IN ACCORDANCE WITH BETA_DIVERSITY_ANALYSIS PROJECT
# AUTHORED BY: DAISY FRY BRUMIT

# Imports
import os
import pandas as pd
import numpy as np
import randForest as rf
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelBinarizer
from sklearn.neighbors import KNeighborsClassifier, KNeighborsRegressor
from sklearn.metrics import accuracy_score, r2_score, roc_auc_score

###########################################
# APPLY RANDOM FOREST TO CATEGORICAL AND
# QUANTITATIVE INPUT PER METADATA FEATURE
###########################################

# RANDOM FOREST FOR CATEGORICAL METADATA

def qualitativeKNN(metadata,dat,test, train):
    # make empty dictionaries for performance metrics
    accuracyDict = {}
    rocDict = {}

    # only use categorial metadata, join to data
    meta_cat = metadata.select_dtypes(include=['object'])
    preFilter_table = meta_cat.join(dat, how='inner', on=None)

    # run KNN for w/ each categorical column as 'y'
    for column in meta_cat.columns:
        print("CAT COLUMN: ", column)
        # store performance metrics for all KNN runs
        accuracyList = []
        rocList = []

        # filter data one more time
        print("CAT COLUMN: ", column, "\nPRE-FILTER Y VALUE COUNTS: ", dict(preFilter_table[column].value_counts()))
        full_table = rf.preML_filter(preFilter_table, column, test=test, quant=0)

        if type(full_table) == int:
            pass # skip this column if there's insufficient data
        elif len(dict(full_table[column].value_counts())) == 1:
            print("only one output variable: ", dict(full_table[column].value_counts()))
            pass
        else:
            print('POST-FILTER Y VALUE COUNTS: ', dict(full_table[column].value_counts()))
            # set test and training groups
            x = full_table.loc[:, ~full_table.columns.isin(meta_cat.columns)]  # ~ is a negation operator. Isolate non-meta columns for x
            y = full_table[column].astype(str)  # Isolate desired metadata column for y
            print(y.shape)

            # perform random forest 100 times with 0.25, 0.75 test train split
            #time = 1
            for i in range(0, 100):
                x_train, x_test, y_train, y_test = train_test_split(x, y, stratify=y, test_size=test, train_size=train)

                # train the classifier, predict y values on test data
                knn = KNeighborsClassifier(n_neighbors=10)
                knn.fit(x_train, y_train)
                y_predict = knn.predict(x_test) # predicts classes, good for accuracy and interpretation

                # generate performance metrics and save
                accuracy = accuracy_score(y_test, y_predict)

                #try:
                # use label binarizer to enable multiclass application of roc_auc score calculation
                lb = LabelBinarizer() # call a binarizer object
                lb.fit(y_test) # train the binarizer using actual test-set class labels
                y_test = lb.transform(y_test) # convert true class labels to binarized set
                #if time == 1: print(y_test.shape)
                y_predict = lb.transform(y_predict) # convert predicted class labels to binarized set

                # calculate (unweighted) averaged roc_auc value using one-versus-rest approach
                roc_auc = roc_auc_score(y_test, y_predict, multi_class='ovr', average='macro')

                #except Exception as e:
                    #roc_auc = 'NA'

                # append performance metrics to list
                accuracyList.append(accuracy)
                rocList.append(roc_auc)
                #time += 1

            # package performance metrics in a list for output
            accuracyDict[column] = accuracyList
            rocDict[column] = rocList


    outList = [accuracyDict, rocDict]
    return outList

# RANDOM FOREST FOR QUANTITATIVE METADATA

def quantitativeKNN(metadata, dat, test, train):
    # make empty dictionaries for column-wide metrics
    r2Dict = {}

    # only use quantitative metadata, make one table with data
    meta_quant = metadata.select_dtypes(include=['float64', 'int64'])
    preFilter_table = meta_quant.join(dat, how='inner', on=None)

    for column in meta_quant.columns:
        print("QUANT COLUMN: ", column)
        # run KNN for w/ each quantitative column as 'y'
        r2List = []

        # filter data one more time
        full_table = rf.preML_filter(preFilter_table, column, test=test, quant=1)

        if type(full_table) == int:
            pass # skip this column if there's insufficient data
        elif len(dict(full_table[column].value_counts())) == 1:
            print("only one output variable: ", dict(full_table[column].value_counts()))
            pass
        else:
            # set test and train groups
            x = full_table.loc[:, ~full_table.columns.isin(meta_quant.columns)]
            y = full_table[column]
            print(y.shape)

            for i in range(0, 100):
                x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=test, train_size=train)

                # set the number of neighbors default as 10
                if x_test.shape[0] >= 10:
                    neighbors = 10

                # or lower if needed
                else:
                    neighbors = x_test.shape[0]

                # train the classifier and predict y values
                knn = KNeighborsRegressor(n_neighbors=neighbors)
                knn.fit(x_train, y_train)
                y_predict = knn.predict(x_test) # predicts classes, good for R2 and interpretation

                # generate performance metrics and save
                R2 = r2_score(y_test, y_predict)
                if (R2 > 1):
                    print("INVALID R2 IN COLUMN ", column)
                r2List.append(R2)

                # package performance metrics in a list for output
                r2Dict[column] = r2List

    return r2Dict

