# scratch file: start by assessing Noguera-Julian data dimensions between Aaron and Jone's data

import pandas as pd
import numpy as np
from skbio.stats.ordination import pcoa
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.metrics import roc_auc_score, r2_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelBinarizer

table = pd.read_table('/Users/dfrybrum/beta_diversity_testing/Noguera-Julian/Noguera-Julian_ForwardReads_DADA2.txt', index_col=0)
t2 = table.T
t2.to_csv('/Users/dfrybrum/beta_diversity_testing/Noguera-Julian/Noguera-Julian_ForwardReads_DADA2.txt', sep='\t')



print('Beam me up, Scotty!')
