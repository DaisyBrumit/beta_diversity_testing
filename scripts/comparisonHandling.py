import randForest as rf
import pandas as pd
import os# for directory walkthrough

rootdir = '/Users/dfrybrum/Documents/FodorLab/gemelli/' # reference directory where ALL files are stored
studyList = ['Zeller', 'Jones', 'Vangay', 'Noguera-Julian'] # study names, also subdirs for rootdir

for study in studyList:
    # load in metadata
    meta = pd.read_table(rootdir+study+'/meta.txt', index_col=0) # look for meta.txt in all study subdirs of the root dir

    # dataframes will be packaged for later visualization
    accuracy_df = pd.DataFrame()
    roc_df = pd.DataFrame()
    r2_df = pd.DataFrame()

    # walk through all files under rootdir
    for root, dirs, files, in os.walk(rootdir+study+'/'):
        # look at each individual file
        for file in files:
            # if the file is a distance matrix from qiime2 output...
            if file.endswith('distance_matrix.tsv'):
                # isolate the beta diversity method by slicing the filename
                # this will serve as an identifier in final dataframes
                string_elements = file.split("_")
                # string_elements = string_elements[:-3] # remove pcoa, results, ord.txt
                beta_method = "_".join(string_elements)  # now we can ID our current method

                print('string elements:\n', string_elements)
                print('beta method:\n', beta_method)

print("beam me up, scotty!")