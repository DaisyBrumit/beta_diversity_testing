# scratch file: start by assessing Zeller data dimensions between Aaron and Jone's data

import pandas as pd
import numpy as np
from skbio.stats.ordination import pcoa
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.metrics import roc_auc_score, r2_score
from sklearn.model_selection import train_test_split

table = pd.read_table('/Users/dfrybrum/beta_diversity_testing/jones/phylo_ctf_distance_matrix.tsv', index_col=0)
meta = pd.read_table('/Users/dfrybrum/beta_diversity_testing/jones/meta.txt', index_col=0)
meta_cat = meta.select_dtypes(include=['object'])
dat = pcoa(table, method='eigh', number_of_dimensions=3, inplace=False)
dat = dat.samples.set_index(keys=table.index)

for column in meta_cat.columns:
    print(meta_cat[column].dtypes)
    full_table = meta_cat.join(dat, how='inner', on=None)  # None specifies index join. Inner b/c we only want full matches
    full_table = full_table.dropna(subset=[column])

    # set test and training groups
    x = full_table.loc[:,~full_table.columns.isin(meta_cat.columns)]  # ~ is a negation operator. Isolate non-meta columns for x
    y = full_table.loc[:, full_table.columns.isin(meta_cat.columns)]

    x_train, x_test, y_train, y_test = train_test_split(x, y[column], test_size=0.25, train_size=0.75)

    # train the classifier, predict y values on test data
    randForest = RandomForestClassifier()
    randForest.fit(x_train, y_train)

    y_proba = randForest.predict_proba(x_test)[:, 1]
    y_predict = randForest.predict(x_test)

    roc_auc = roc_auc_score(y_test, y_proba, multi_class='ovr', average='macro')

print('Beam me up, Scotty!')
