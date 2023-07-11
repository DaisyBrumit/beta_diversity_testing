import randForest as rf  # reference my randForest.py in same directory
import pandas as pd
import os  # for directory walkthrough
from skbio.stats.ordination import pcoa
import sys

def main():
    # take in arguments from command line
    #study = str(sys.argv[1]) # study to work on as a string
    #pc_count = int(sys.argv[2]) # number of pcoa components to use
    study = 'Vangay'
    pc_count = 3

    # read in metadata
    #meta_path = '/users/dfrybrum/fodor_lab/beta_diversity_testing/'+study+'/meta.txt'
    meta_path = '/Users/dfrybrum/git/beta_diversity_testing/'+study+'/meta.txt'
    meta = pd.read_table(meta_path, index_col=0)

    # set blank dictionaries for performance metrics
    accuracy_df = pd.DataFrame()
    roc_df = pd.DataFrame()
    r2_df = pd.DataFrame()

    # use walk to initiate a look at all files in a study directory
    #study_path ='/users/dfrybrum/fodor_lab/beta_diversity_testing/'+study + '/'
    study_path = '/Users/dfrybrum/git/beta_diversity_testing/'+study+'/'
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
                catRF = rf.qualitativeRF(meta, ord)
                quantRF = rf.quantitativeRF(meta, ord)

                # expand performance metrics from RF script output
                acc_tmp = pd.DataFrame(catRF[0])
                roc_tmp = pd.DataFrame(catRF[1])
                r2_tmp = pd.DataFrame(quantRF)

                # add a column to track the beta metric currently used
                acc_tmp, roc_tmp, r2_tmp = acc_tmp.assign(method=beta_method), roc_tmp.assign(method=beta_method), r2_tmp.assign(method=beta_method)

                # concatenate merged table to main table with all methods
                accuracy_df = pd.concat([accuracy_df, acc_tmp], ignore_index=True)
                roc_df = pd.concat([roc_df, roc_tmp], ignore_index=True)
                r2_df = pd.concat([r2_df, r2_tmp], ignore_index=True)

            # if the file is an unprocessed DADA2 file
            elif file.endswith('DADA2.txt'):
                # no custom path/splicing needed
                beta_method = 'dada2'
                data = pd.read_table(root+file, header=0, index_col=0).T # read in table
                ord = run_pcoa(data, -1)

                # filter for RF input
                ord, meta = metaFilter(ord, meta)

                print('STUDY: ', study, '\nMETHOD: ', beta_method)
                catRF = rf.qualitativeRF(meta, ord)
                quantRF = rf.quantitativeRF(meta, ord)

                # expand performance metrics from RF script output
                acc_tmp = pd.DataFrame(catRF[0])
                roc_tmp = pd.DataFrame(catRF[1])
                r2_tmp = pd.DataFrame(quantRF)

                # add a column to track the beta metric currently used
                acc_tmp, roc_tmp, r2_tmp = acc_tmp.assign(method=beta_method), roc_tmp.assign(method=beta_method), r2_tmp.assign(method=beta_method)

                # concatenate merged table to main table with all methods
                accuracy_df = pd.concat([accuracy_df, acc_tmp], ignore_index=True)
                roc_df = pd.concat([roc_df, roc_tmp], ignore_index=True)
                r2_df = pd.concat([r2_df, r2_tmp], ignore_index=True)
    # set pathnames
    if pc_count == -1:
        suffix = 'raw'
    elif pc_count == -2:
        suffix = 'all'
    else: suffix = str(pc_count)

    # print the collection of scores for every method associated with this study in the study's directory
    #accuracy_df.to_csv('/users/dfrybrum/fodor_lab/beta_diversity_testing/'+study + '/accuracy_table_' + suffix + '.txt', sep='\t', index=False)
    #roc_df.to_csv('/users/dfrybrum/fodor_lab/beta_diversity_testing/'+study + '/roc_auc_table_' + suffix + '.txt', sep='\t', index=False)
    #r2_df.to_csv('/users/dfrybrum/fodor_lab/beta_diversity_testing/'+study + '/r2_table_' + suffix + '.txt', sep='\t', index=False)
    accuracy_df.to_csv('/Users/dfrybrum/git/beta_diversity_testing/'+study + '/accuracy_table_' + suffix + '.txt', sep='\t', index=False)
    roc_df.to_csv('/Users/dfrybrum/git/beta_diversity_testing/'+study + '/roc_auc_table_' + suffix + '.txt', sep='\t', index=False)
    r2_df.to_csv('/Users/dfrybrum/git/beta_diversity_testing/'+study + '/r2_table_' + suffix + '.txt', sep='\t', index=False)


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

if __name__ == '__main__':
    main()
