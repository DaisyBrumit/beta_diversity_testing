import pandas as pd
import numpy as np
import os # for directory walkthrough
import sys # import metadata retreival functions
import warnings

# Get the current script's directory
current_script_directory = os.path.dirname(os.path.realpath(__file__))
subdirectory_path = '/Users/dfrybrum/beta_diversity_testing_almost_final/scripts/functions'
sys.path.append(subdirectory_path)
import meta_from_files as mff
import parse_fromBiplot as parser
import randForest as rf
import knn

# set major global parameters
warnings.simplefilter(action='ignore', category=FutureWarning)
rootdir = '/Users/dfrybrum/beta_diversity_testing_almost_final/'
studyList = ['Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'ECAM']
ML_method = 'rf'
#ML_method = 'knn'

# run ML for each study
for study in studyList:
    # dataframes will be packaged for later visualization
    accuracy_df = pd.DataFrame()
    roc_df = pd.DataFrame()
    r2_df = pd.DataFrame()

    # walk through all files under rootdir
    for root, dirs, files, in os.walk(rootdir + study + '/HA/ordinations/'):
        # look at each individual file
        for file in files:
            filepath = rootdir + study + '/HA/ordinations/' + file
            beta = mff.get_beta(file)

            # load in metadata
            meta = pd.read_table(rootdir + study + '/meta.txt', index_col=0)  # load metadata
            ords = pd.read_table(filepath, header=0, index_col=0) # load pcoa output
            ords = ords.drop(['PropExplained'], axis=0) # row 1 == prop explained. Don't need.
            ords = ords[['PC1', 'PC2', 'PC3']]

            print('STUDY: ', study, '\nMETHOD: ', beta) # sanity check

            # call ML function
            if ML_method == 'rf':
                cat = rf.qualitativeRF(meta, ords, test=0.4, train=0.6)
                quant = rf.quantitativeRF(meta, ords, test=0.4, train=0.6)
            elif ML_method == 'knn':
                cat = knn.qualitativeKNN(meta, ords, test=0.4, train=0.6)
                quant = knn.quantitativeKNN(meta, ords, test=0.4, train=0.6)

            # expand dictionary contents
            acc_tmp = pd.DataFrame(cat[0])  # 0 == dictionary w/ accuracy scores to features
            roc_tmp = pd.DataFrame(cat[1])  # 1 == {roc_auc scores : features}
            r2_tmp = pd.DataFrame(quant)  # 0 == {r2 scores : features}

            acc_tmp['beta'], roc_tmp['beta'], r2_tmp['beta'] = beta, beta, beta # add beta method label

            accuracy_df = pd.concat([accuracy_df, acc_tmp], ignore_index=True)
            roc_df = pd.concat([roc_df, roc_tmp], ignore_index=True)
            r2_df = pd.concat([r2_df, r2_tmp], ignore_index=True)

        # Make dirs an empty list to prevent recursion
        dirs[:] = []

    # Coerce empty outputs to na values
    accuracy_df.replace(np.nan, 'NA', inplace=True)
    roc_df.replace(np.nan, 'NA', inplace=True)
    r2_df.replace(np.nan, 'NA', inplace=True)

    # print the collection of scores for every method associated with this study in the study's directory
    accuracy_df.to_csv(rootdir + study + '/HA/ML/accuracy_' + ML_method + '.tsv', sep='\t', index=False)
    roc_df.to_csv(rootdir + study + '/HA/ML/roc_' + ML_method + '.tsv', sep='\t', index=False)
    r2_df.to_csv(rootdir + study + '/HA/ML/r2_' + ML_method + '.tsv', sep='\t', index=False)

print("beam me up, scotty!")