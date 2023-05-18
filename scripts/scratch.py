# scratch file: start by assessing Zeller data dimensions between Aaron and Jone's data

import pandas as pd
import numpy as np

table = pd.read_table('/Users/dfrybrum/beta_diversity_testing//Zeller_ForwardReads_DADA2.txt', index_col=None)
table = table.T

table.to_csv('/Users/dfrybrum/beta_diversity_testing/Zeller/Zeller_ForwardReads_DADA2_T.txt')

print('Beam me up, Scotty!')
