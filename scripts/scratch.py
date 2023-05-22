# scratch file: start by assessing Zeller data dimensions between Aaron and Jone's data

import pandas as pd
import numpy as np
from skbio.stats.ordination import pcoa

table = pd.read_table('/Users/dfrybrum/git/beta_diversity_testing/jones/phylo_ctf_distance_matrix.tsv', index_col=0)
meta = pd.read_table('/Users/dfrybrum/git/beta_diversity_testing/jones/meta.txt', index_col=0)
ord = pcoa(table, method='eigh', number_of_dimensions=3, inplace=False)
ord = ord.samples.set_index(keys=table.index)



print('Beam me up, Scotty!')
