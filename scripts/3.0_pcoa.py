# RUN PCOA ON DATASETS TO COMPARE CLUSTERING BEHAVIOR
# ACROSS GEMELLI SETS AND CORE METRICS OF VARYING TAXA COUNTS

import pandas as pd
import numpy as np
import os
from skbio.stats.ordination import pcoa

# import metadata retreival functions
import sys
# Get the current script's directory
current_script_directory = os.path.dirname(os.path.realpath(__file__))
subdirectory_path = os.path.join(current_script_directory, 'functions')
sys.path.append(subdirectory_path)
import meta_from_files as mff

# create a directory using home "~/" in a way python understands
home_path = os.path.expanduser('~/beta_diversity_testing/')

studyList = ['Zeller','Jones','Vangay','Noguera-Julian','gemelli_ECAM']
qiimeList = ['phylo_rpca','phylo_ctf','ctf','rpca']

for study in studyList:
    study_path = home_path + study

    # read in metadata
    meta_path = study_path + '/meta.txt'
    meta = pd.read_table(meta_path, index_col=0)

    # specify path for file walk
    dist_matrix_path = study_path + '/distance_matrices/'

    for root, dirs, files in os.walk(dist_matrix_path):
        # look at each file
        for file in files:
	    #skip hidden files & dirs
            if file.startswith('.'):
                continue

            ### Read in data ###
            data_path = os.path.join(root,file)
            data = pd.read_table(data_path, header=0, index_col=0)

            # in certain circumstances, unweighted unifrac retruns NaN values. Remove problem samples.
            nan_indices = data.columns[data.isna().any()]
            data = data.drop(index=nan_indices, columns=nan_indices)

            # set output file path for full data
            if file.endswith('distance_matrix.tsv'):
                # retrieve beta method from filename & set output file name
                beta_method = mff.get_beta(file)
                output_file = study_path + '/ordinations/' + beta_method + '_ordinations.tsv'

                print(study + ' ' + beta_method) # sanity check

            # Set output file path for HA data
            else:
                # retrieve beta method & taxa count from filename & set output file name
                beta_method = mff.get_beta(file)
                ntaxa = mff.get_n_taxa(file)
                output_file = study_path + '/ordinations/' + beta_method +  '_' + ntaxa + '_ordinations.tsv'

                print(study + ' ' + beta_method + ' ' + ntaxa) # sanity check

            # double check that data and meta have matching indices
            shared_indices = meta.index.intersection(data.index)
            meta = meta.loc[shared_indices]

            # Run pcoa
            pcoa_obj = pcoa(data, method='eigh', number_of_dimensions=len(data.columns), inplace=True)

            # want the first row of the output table to include proportion of variance explained
            df_out = pd.DataFrame(pcoa_obj.proportion_explained).T
            df_out = df_out.rename(index= {0 : "PropExplained"})

            # set indices within pcoa_obj
            pcoa_obj.samples = pcoa_obj.samples.set_index(keys=data.index)

            # combine PropExplained and pcoa_obj components, then export
            df_out = pd.concat([df_out, pcoa_obj.samples])
            df_out.to_csv(output_file, sep='\t', index=True)
