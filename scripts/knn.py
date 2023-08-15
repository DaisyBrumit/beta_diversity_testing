import randForest as rf
import pandas as pd
import numpy as np

from sklearn.neighbors import KNeighborsClassifier, KNeighborsRegressor
from sklearn.model_selection import StratifiedShuffleSplit
#from sklearn.preprocessing import LabelBinarizer
from sklearn.metrics import accuracy_score
#from sklearn.metrics import r2_score
from sklearn.metrics import roc_auc_score

def qualitativeKNN(metadata,dat):
    # make empty dictionaries for performance metrics
    accuracyDict = {}
    rocDict = {}

    # only use categorial metadata, join to data
    meta_cat = metadata.select_dtypes(include=['object'])
    preFilter_table = meta_cat.join(dat, how='inner', on=None)

    # run RF for w/ each categorical column as 'y'
    for column in meta_cat.columns:
        print("CAT COLUMN: ", column)
        # store performance metrics for all RF runs
        accuracyList = []
        rocList = []

        # filter data one more time
        #print("CAT COLUMN: ", column, "\nPRE-FILTER Y VALUE COUNTS: ", dict(preFilter_table[column].value_counts()))
        full_table = rf.preML_filter(preFilter_table, column)

        if type(full_table) == int:
            pass # skip this column if there's insufficient data
        else:
            #print('POST-FILTER Y VALUE COUNTS: ', dict(full_table[column].value_counts()))
            # set test and training groups
            x = full_table.loc[:, ~full_table.columns.isin(meta_cat.columns)]  # ~ is a negation operator. Isolate non-meta columns for x
            y = full_table[column]  # Isolate desired metadata column for y

            shuffle_split = StratifiedShuffleSplit(n_splits=10, test_size=0.5, random_state=0)
            shuffle_split.get_n_splits(x, y)

            # perform random forest 100 times with 0.25, 0.75 test train split
            for fold, (train_index, test_index) in enumerate(shuffle_split.split(x, y.argmax(1))):
                # split
                x_train, x_test = x[train_index], x[test_index]
                y_train, y_test = y[train_index].ravel(), y[test_index].ravel()

                # predict
                model = KNeighborsClassifier(n_neighbors=10)
                knn_tmp = model.fit(x_train, y_train)
                y_predict = knn_tmp.predict(x_test)
                y_score = knn_tmp.predict_proba(x_test)
                y_score = y_score[:, 1]

                # macro score
                roc_auc = roc_auc_score(y_test, y_score,multi_class='ovr', average='macro')
                accuracy = accuracy_score(y_test, y_predict)

                accuracyList.append(accuracy)
                rocList.append(roc_auc)

            # package performance metrics in a list for output
            accuracyDict[column] = accuracyList
            rocDict[column] = rocList


    outList = [accuracyDict, rocDict]
    return outList

# RANDOM FOREST FOR QUANTITATIVE METADATA
