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

