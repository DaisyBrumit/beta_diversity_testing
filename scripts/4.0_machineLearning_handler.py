import randForest as rf # reference my randForest.py in same directory
import pandas as pd
import os # for directory walkthrough
from skbio.stats.ordination import pcoa, OrdinationResults

# import metadata retreival functions
import sys
# Get the current script's directory
current_script_directory = os.path.dirname(os.path.realpath(__file__))
subdirectory_path = os.path.join(current_script_directory, 'functions')
sys.path.append(subdirectory_path)
import meta_from_files as mff

rootdir = '/Users/dfrybrum/beta_diversity_testing/'
studyList = ['Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'gemelli_ECAM'] # study names, also subdirs for rootdir

for study in studyList:
    # load in metadata
    meta = pd.read_table(rootdir+study+'/refiltered_meta.txt', index_col=0) # look for meta.txt in all study subdirs of the root dir

    # dataframes will be packaged for later visualization
    accuracy_df = pd.DataFrame()
    roc_df = pd.DataFrame()
    r2_df = pd.DataFrame()

    # walk through all files under rootdir
    for root, dirs, files, in os.walk(rootdir+study+'/distance_matrices/'):
        # look at each individual file
        for file in files:
            # if the file is a distance matrix from qiime2 output...
            if file.endswith('distance_matrix.tsv'):
                # isolate the beta diversity method by slicing the filename
                # this will serve as an identifier in final dataframes
                string_elements = file.split("_")
                string_elements = string_elements[:-2] # remove '_distance_matrix.tsv'
                beta_method = "_".join(string_elements)  # now we can ID our current method

                # read in distance matrix (for PERMANOVA)
                dist = (pd.read_table(rootdir + study + '/' + file, header=0, index_col=0))

                # run pcoa (for random forest)
                #ord = pcoa(dist, method='eigh', number_of_dimensions=i, inplace=False) # RUN IN FOR LOOP FOR MULTIPLE DIMS LATER
                ord = pcoa(dist, method='eigh', number_of_dimensions=dist.shape[0], inplace=False)
                ord = ord.samples.set_index(keys=dist.index) # convert OrdinationResults obj to pd DataFrame with samples as indices

                # generate quant and qual rand forest output
                print('STUDY: ', study, '\nMETHOD: ', beta_method)
                catRF = rf.qualitativeRF(meta, ord)
                quantRF = rf.quantitativeRF(meta, ord)

            # if the file is a dada2 count table with original counts...
            elif file.endswith('DADA2.txt'):
                beta_method = 'dada2' # no custom path/splicing needed
                path = rootdir + study + '/' + study + '_ForwardReads_DADA2.txt'
                dat = pd.read_table(path, header=0, index_col=0) # read in table
                catRF = rf.qualitativeRF(meta, ord) # no pcoa needed for RF
                quantRF = rf.quantitativeRF(meta, ord) # no pcoa needed for RF

            try:
                # expand dictionary contents
                acc_expand = pd.DataFrame(catRF[0])  # 0 == dictionary w/ accuracy scores to features
                roc_expand = pd.DataFrame(catRF[1])  # 1 == {roc_auc scores : features}
                r2_expand = pd.DataFrame(quantRF[0])  # 0 == {r2 scores : features}

                length = len(r2_expand)  # all 'expand' lists should == 100, but just in case RF iterations change later...
                method_expand = pd.DataFrame({'method': [beta_method] * length})

                # append contents to dataframes
                acc_merge = method_expand.join(acc_expand)
                roc_merge = method_expand.join(roc_expand)
                r2_merge = method_expand.join(r2_expand)

                accuracy_df = pd.concat([accuracy_df, acc_merge], ignore_index=True)
                roc_df = pd.concat([roc_df, roc_merge], ignore_index=True)
                r2_df = pd.concat([r2_df, r2_merge], ignore_index=True)
            except:
                pass
                #print("missing RF out")

    # print the collection of scores for every method associated with this study in the study's directory
    #accuracy_df.to_csv(rootdir + study + '/accuracy_table_' + str(i) + '.txt', sep='\t', index=False)
    #roc_df.to_csv(rootdir + study + '/roc_auc_table_' + str(i) + '.txt', sep='\t', index=False)
    #r2_df.to_csv(rootdir + study + '/r2_table_' + str(i) + '.txt', sep='\t', index=False)

    accuracy_df.to_csv(rootdir + study + '/accuracy_table_all.txt', sep='\t', index=False)
    roc_df.to_csv(rootdir + study + '/roc_auc_table_all.txt', sep='\t', index=False)
    r2_df.to_csv(rootdir + study + '/r2_table_all.txt', sep='\t', index=False)

print("beam me up, scotty!")