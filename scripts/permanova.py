# COMPLETE PERMANOVA ON ALL BETA DIVERSITY DISTANCE MATRICES
# IN ACCORDANCE WITH BETA_DIVERSITY_ANALYSIS PROJECT
# AUTHORED BY: DAISY FRY BRUMIT

# Imports
import pandas as pd
import numpy as np
from skbio.stats.distance import permanova

def perma(dat, meta):

    # hold dictionary for f stats and p values
    f_dict = {}
    p_dct = {}

    for (colName, colValues) in meta.iteritems():
        print(colName)
        output = permanova(dat, colValues)

    return output

dm = pd.read_table('/Users/dfrybrum/Documents/FodorLab/gemelli/Zeller/phylo_rpca_distance_matrix.tsv', header=0, index_col=0)
meta = pd.read_table('/Users/dfrybrum/Documents/FodorLab/gemelli/Zeller/meta.txt', index_col=0)
perma(dm,meta)

print("Beam me up, Scotty!")