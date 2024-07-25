# RUN PCOA ON DATASETS TO COMPARE CLUSTERING BEHAVIOR

import pandas as pd
import numpy as np
import os
from skbio.stats.ordination import pcoa

# import metadata retrieval functions
import sys
current_script_directory = os.path.dirname(os.path.realpath(__file__)) # Get the current script's directory
subdirectory_path = os.path.join(current_script_directory, 'functions') # set new pathname
sys.path.append(subdirectory_path) # append the pathname for functions
import meta_from_files as mff # access functions

# set home path & sudy lists
home_path = os.path.expanduser('~/beta_diversity_testing/')
studyList = ['ECAM','Jones','Vangay','Noguera-Julian','Zeller']
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
            if file.startswith('.'):
                continue # skip hidden dirs

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

            ### GEMELLI METHODS OUTPUT TO A DIFFERENT FORMAT. READ IN ACCORDINGLY ###
            # get rpca axes
            if beta_method in ['rpca','phylo_rpca']:
                biplot_path = os.path.join(study_path, 'ordinations', f"{beta_method}_ordinations_fromBiplot.tsv")
                # Read the biplot file
                with open(biplot_path, 'r') as biplot_file:
                    lines = biplot_file.readlines()

                # get proportion explained & site data
                proportion_explained = lines[4].strip().split('\t')
                site_start = next(i for i, line in enumerate(lines) if line.startswith('Site\t')) + 2
                site_end = next(i for i, line in enumerate(lines) if line.startswith('Biplot\t')) - 1
                site_data = lines[site_start:site_end]

                # create dataframe
                df_out = pd.DataFrame(columns=['PC1', 'PC2', 'PC3'])
                df_out.loc['PropExplained'] = proportion_explained # add prop explained as first row

                # special parsing
                for line in site_data:
                    parts = line.strip().split('\t')
                    sample_id = parts[0]
                    coordinates = parts[1:]
                    df_out.loc[sample_id] = coordinates

                # save dataframe
                output_file = os.path.join(study_path, 'ordinations', f"{beta_method}_ordinations.tsv")
                df_out.to_csv(output_file, sep='\t', index=True)
                print(f"{study} {beta_method} - Parsed and saved.")

            # get ctf axes
            elif beta_method in ['ctf','phylo_ctf']:
                biplot_path = os.path.join(study_path, 'ordinations', f"{beta_method}_ordinations_fromBiplot.tsv")
                ord_path = os.path.join(study_path, 'ordinations', f"{beta_method}_ords_with_meta.tsv")

                # Read the biplot file
                with open(biplot_path, 'r') as biplot_file:
                    lines = biplot_file.readlines()

                # get proportion explained & site data
                proportion_explained = lines[4].strip().split('\t')
                ord_data = pd.read_table(ord_path)

                # create dataframe
                pe_df = pd.DataFrame(columns=['PC1', 'PC2', 'PC3'])
                pe_df.loc['PropExplained'] = proportion_explained
                sample_id = ord_data['#SampleID']
                coordinates = ord_data.iloc[:,1:4].to_numpy() # actual PCs
                coordinates_df = pd.DataFrame(coordinates, index=sample_id, columns=['PC1', 'PC2', 'PC3'])
                df_out = pd.concat([pe_df, coordinates_df])

                # save dataframe
                output_file = os.path.join(study_path, 'ordinations', f"{beta_method}_ordinations.tsv")
                df_out.to_csv(output_file, sep='\t', index=True)
                print(f"{study} {beta_method} - Parsed and saved.")

            ### PCOA NEEDS TO ACTUALLY BE RUN ON ALL NON-GEMELLI TRANSFORMATIONS ###
            else:
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
