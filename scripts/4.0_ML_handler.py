import pandas as pd
import numpy as np
import os # for directory walkthrough
import sys # import metadata retreival functions
import warnings

# Get the current script's directory
current_script_directory = os.path.dirname(os.path.realpath(__file__))
subdirectory_path = os.path.join(current_script_directory, 'functions')
sys.path.append(subdirectory_path)
import meta_from_files as mff
import parse_fromBiplot as parser
import randForest as rf
import knn

# set major global parameters ("toggle" rf and knn)
warnings.simplefilter(action='ignore', category=FutureWarning) # only supress future warnings
rootdir = '/Users/dfrybrum/beta_diversity_testing/'
studyList = ['Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'ECAM']
ML_method = 'rf'
#ML_method = 'knn'

# function for actually running ml methods
def run_ml(meta, ords, beta, ML_method):
    if ML_method == 'rf':
        cat = rf.qualitativeRF(meta, ords, test=0.4, train=0.6) # classifier (categorical variables)
        quant = rf.quantitativeRF(meta, ords, test=0.4, train=0.6) # regressor (quantitative variables)
    elif ML_method == 'knn':
        cat = knn.qualitativeKNN(meta, ords, test=0.4, train=0.6) # classifier (categorical variables)
        quant = knn.quantitativeKNN(meta, ords, test=0.4, train=0.6) # regressor (quantitative variables)

    # each ml script outputs 3 tables of performance metrics
    acc_tmp = pd.DataFrame(cat[0])  # 0 == dictionary w/ accuracy scores to features
    roc_tmp = pd.DataFrame(cat[1])  # 1 == {roc_auc scores : features}
    r2_tmp = pd.DataFrame(quant)  # 0 == {r2 scores : features}

    # add beta method label to each dataframe and output
    acc_tmp['beta'], roc_tmp['beta'], r2_tmp['beta'] = beta, beta, beta
    return acc_tmp, roc_tmp, r2_tmp

# run ML for each study
for study in studyList:
    # dataframes will be packaged for later visualization
    accuracy_df = pd.DataFrame()
    roc_df = pd.DataFrame()
    r2_df = pd.DataFrame()

    # walk through all files under rootdir
    for root, dirs, files, in os.walk(rootdir + study + '/ordinations/'):
        # look at each individual file
        for file in files:
            filepath = rootdir + study + '/ordinations/' + file
            beta = mff.get_beta(file)

            # read in data for core metrics
            if file.endswith('ordinations.tsv') and ('ctf' in beta or 'rpca' in beta):
                # THIS BLOCK IS FOR BIPLOT ORDS
                #if study == 'ECAM' and 'ctf' in beta: continue
                #elif study == 'Jones' and 'ctf' in beta: continue
                #else:
                # load in metadata
                meta = pd.read_table(rootdir + study + '/meta.txt', index_col=0)  # load metadata
                ords = pd.read_table(filepath, header=0, index_col=0) # load pcoa output
                ords = ords.drop(['PropExplained'], axis=0) # row 1 == prop explained. Don't need.
                ords = ords[['PC1', 'PC2', 'PC3']]

            elif file.endswith('ordinations.tsv'):
                meta = pd.read_table(rootdir + study + '/meta.txt', index_col=0)  # load metadata
                ords = pd.read_table(filepath, header=0, index_col=0)  # load pcoa output
                ords = ords.drop(['PropExplained'], axis=0)  # row 1 == prop explained. Don't need.
                ords.iloc[:, 0:20]

            # THIS BLOCK IS FOR CTF'S BIPLOT ORDS
            # read in data for gemelli metrics
            #elif file.endswith('fromBiplot.tsv'):
                #meta = pd.read_table(rootdir + study + '/meta.txt', index_col=0)  # load metadata
                #ords = parser.parse_ords(filepath) # use custom parser for gemelli metrics

                # index metadata by repeat id's for Jones and ECAM
                #if study == 'ECAM':
                    #keep_cols = ['delivery', 'host_subject_id'] # only need delivery and host_subject_id for ECAM
                    #meta = meta[keep_cols].drop_duplicates()
                    #meta.set_index('host_subject_id', inplace=True) # this will be your new index

                #elif study == 'Jones':
                    #keep_cols = ['Genotype', 'repeat_ID']
                    #meta = meta[keep_cols].drop_duplicates()
                    #meta.set_index('repeat_ID', inplace=True)  # this will be your new index

                #else: continue
            else: continue

            print('STUDY: ', study, '\nMETHOD: ', beta) # sanity check
            if beta != '' :
                # call ML function
                acc_tmp, roc_tmp, r2_tmp = run_ml(meta, ords, beta, ML_method)

                accuracy_df = pd.concat([accuracy_df, acc_tmp], ignore_index=True)
                roc_df = pd.concat([roc_df, roc_tmp], ignore_index=True)
                r2_df = pd.concat([r2_df, r2_tmp], ignore_index=True)

        # make dirs an empty list to prevent recursion
        dirs[:] = []

    # process raw data (no ordinations)
    raw_file_path = os.path.join(rootdir + study, 'filtered_table.txt')
    if os.path.exists(raw_file_path):
        rawDF = pd.read_table(raw_file_path, index_col=0, skiprows=1).T
        meta = pd.read_table(rootdir + study + '/meta.txt', index_col=0)  # load metadata

        print('STUDY: ', study, '\nMETHOD: ', 'raw')  # sanity check

        # call ML function
        acc_tmp, roc_tmp, r2_tmp = run_ml(meta, rawDF, 'raw', ML_method)

        accuracy_df = pd.concat([accuracy_df, acc_tmp], ignore_index=True)
        roc_df = pd.concat([roc_df, roc_tmp], ignore_index=True)
        r2_df = pd.concat([r2_df, r2_tmp], ignore_index=True)

    # coerce empty outputs to na values (if they exist)
    accuracy_df.replace(np.nan, 'NA', inplace=True)
    roc_df.replace(np.nan, 'NA', inplace=True)
    r2_df.replace(np.nan, 'NA', inplace=True)

    # output dataframes for each performance metric
    accuracy_df.to_csv(rootdir + study + '/ML/accuracy_trajectory_20PCs_' + ML_method + '.tsv', sep='\t', index=False)
    roc_df.to_csv(rootdir + study + '/ML/roc_trajectory_20PCs_' + ML_method + '.tsv', sep='\t', index=False)
    r2_df.to_csv(rootdir + study + '/ML/r2_trajectory_20PCs_' + ML_method + '.tsv', sep='\t', index=False)

print("beam me up, scotty!")