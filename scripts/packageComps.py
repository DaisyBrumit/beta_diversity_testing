import randForest as rf  # reference my randForest.py in same directory
import knn
import pandas as pd
import numpy as np
import os  # for directory walkthrough
from skbio.stats.ordination import pcoa
import sys

def main():
    #studyList = ['Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'gemelli_ECAM']
    studyList = ['gemelli_ECAM']
    pc_countList = [-2,-1,3,4,5,6,7,8,9,10]

    for study in studyList:
        for pc_count in pc_countList:
            # read in metadata
            meta_path = '/Users/dfrybrum/beta_diversity_testing/'+study+'/meta.txt'
            meta = pd.read_table(meta_path, index_col=0)
            if 'host_subject_id' in meta.columns:
                meta = meta.drop('host_subject_id', axis=1)
            if study == 'gemelli_ECAM':
                meta = meta['delivery'].to_frame()

            # set blank dictionaries for performance metrics
            accuracy_df = pd.DataFrame()
            roc_df = pd.DataFrame()
            r2_df = pd.DataFrame()

            # use walk to initiate a look at all files in a study directory
            study_path = '/Users/dfrybrum/beta_diversity_testing/'+study+'/'
            for root, dirs, files, in os.walk(study_path):
                # look at each individual file
                for file in files:

                    ### READ IN DATA ###
                    # if the file is a distance matrix from qiime2 output...
                    if file.endswith('distance_matrix.tsv'):
                        # isolate the beta diversity method by slicing the filename
                        string_elements = file.split("_")
                        string_elements = string_elements[:-2]  # remove '_distance_matrix.tsv'
                        beta_method = "_".join(string_elements)  # now we can ID our current method

                        # read in distance matrix and run pcoa
                        data = (pd.read_table(root + file, header=0, index_col=0))

                        ord = run_pcoa(data, pc_count)

                        # filter for RF input
                        ord, meta = metaFilter(ord, meta)

                        print('STUDY: ', study, '\nMETHOD: ', beta_method)
                        #catRF = rf.qualitativeRF(meta, ord)
                        #quantRF = rf.quantitativeRF(meta, ord)
                        catKNN = knn.qualitativeKNN(meta, ord)

                        # expand performance metrics from RF script output
                        #acc_tmp = pd.DataFrame(catRF[0])
                        #roc_tmp = pd.DataFrame(catRF[1])
                        #r2_tmp = pd.DataFrame(quantRF)
                        acc_tmp = pd.DataFrame(catKNN[0])
                        roc_tmp = pd.DataFrame(catKNN[1])

                        # add a column to track the beta metric currently used
                        #acc_tmp, roc_tmp, r2_tmp = acc_tmp.assign(method=beta_method), roc_tmp.assign(method=beta_method), r2_tmp.assign(method=beta_method)
                        acc_tmp, roc_tmp = acc_tmp.assign(method=beta_method), roc_tmp.assign(method=beta_method)

                        # concatenate merged table to main table with all methods
                        accuracy_df = pd.concat([accuracy_df, acc_tmp], ignore_index=True)
                        roc_df = pd.concat([roc_df, roc_tmp], ignore_index=True)
                        #r2_df = pd.concat([r2_df, r2_tmp], ignore_index=True)

                    # if the file is an unprocessed DADA2 file
                    elif file.endswith('DADA2.txt'):
                        # no custom path/splicing needed
                        beta_method = 'dada2'
                        data = pd.read_table(root+file, header=0, index_col=0).T # read in table
                        ord = run_pcoa(data, -1)

                        # filter for RF input
                        ord, meta = metaFilter(ord, meta)

                        print('STUDY: ', study, '\nMETHOD: ', beta_method)
                        #catRF = rf.qualitativeRF(meta, ord)
                        #quantRF = rf.quantitativeRF(meta, ord)
                        catKNN = knn.qualitativeKNN(meta, ord)

                        # expand performance metrics from RF script output
                        #acc_tmp = pd.DataFrame(catRF[0])
                        #roc_tmp = pd.DataFrame(catRF[1])
                        #r2_tmp = pd.DataFrame(quantRF)
                        acc_tmp = pd.DataFrame(catKNN[0])
                        roc_tmp = pd.DataFrame(catKNN[1])

                        # add a column to track the beta metric currently used
                        #acc_tmp, roc_tmp, r2_tmp = acc_tmp.assign(method=beta_method), roc_tmp.assign(method=beta_method), r2_tmp.assign(method=beta_method)
                        acc_tmp, roc_tmp = acc_tmp.assign(method=beta_method), roc_tmp.assign(method=beta_method)

                        # concatenate merged table to main table with all methods
                        accuracy_df = pd.concat([accuracy_df, acc_tmp], ignore_index=True)
                        roc_df = pd.concat([roc_df, roc_tmp], ignore_index=True)
                        #r2_df = pd.concat([r2_df, r2_tmp], ignore_index=True)
            # set pathnames
            if pc_count == -1:
                suffix = 'raw'
            elif pc_count == -2:
                suffix = 'all'
            else: suffix = str(pc_count)

            # print the collection of scores for every method associated with this study in the study's directory
            accuracy_df.to_csv('/Users/dfrybrum/beta_diversity_testing/'+study + '/knn_accuracy_table_' + suffix + '.txt', sep='\t', index=False)
            roc_df.to_csv('/Users/dfrybrum/beta_diversity_testing/'+study + '/knn_roc_auc_table_' + suffix + '.txt', sep='\t', index=False)
            r2_df.to_csv('/Users/dfrybrum/beta_diversity_testing/'+study + '/knn_r2_table_' + suffix + '.txt', sep='\t', index=False)


### RUN ML SCRIPTS FOR DESIRED PC COUNT ###
def run_pcoa(data, pc_count):
    # pc_count of -1 does not execute pcoa
    if pc_count == -1:
        ord = data
    # pc_count of 0 uses all pcoa axes
    elif pc_count == -2:
        ord = pcoa(data, method='eigh', number_of_dimensions=data.shape[0], inplace=False)
        ord = ord.samples.set_index(keys=data.index) # retain OG indices
    # otherwise keep pc_count number of axes
    else:
        ord = pcoa(data, method='eigh', number_of_dimensions=pc_count, inplace=False)
        ord = ord.samples.set_index(keys=data.index) # retain OG indices

    return ord

### PERFORM INITIAL FILTER FOR GLARING METADATA ISSUES ###
def metaFilter(data, meta):
    # are any meta columns void of data?
    empty_cols = meta.columns[meta.isnull().all()]
    meta.drop(empty_cols, axis=1, inplace=True)

    # are any meta columns void of differing data?
    singleValue_cols = meta.columns[meta.nunique() == 1]
    meta.drop(singleValue_cols, axis=1, inplace=True)

    # only keep shared samples, but don't merge
    filtered_meta = meta[meta.index.isin(data.index)]
    filtered_data = data[data.index.isin(meta.index)]

    return [filtered_data, filtered_meta]

def dateToNum(meta, date_featureList):
    for feature in date_featureList:
        # convert to datetime: errors = coerce means errs will return na values
        meta[feature] = pd.to_datetime(meta[feature], errors='coerce', infer_datetime_format=True)

        # make new col labels
        year_str = feature+'Year'
        month_str = feature + 'Month'
        day_str = feature + 'Day'

        # make new numeric columns out of datetime feature
        meta[year_str] = meta[feature].dt.year
        meta[month_str] = meta[feature].dt.month
        meta[day_str] = meta[feature].dt.day

        # drop object column
        meta = meta.drop(feature, axis=1)

        return meta


if __name__ == '__main__':
    main()
