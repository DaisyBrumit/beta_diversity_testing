import pandas as pd
import numpy as np
import os
from skbio import DistanceMatrix
from skbio.stats.distance import permanova

# create a directory using home "~/" in a way python understands
home_path = os.path.expanduser('~/beta_diversity_testing_almost_final/')

studyList = ['ECAM', 'Jones', 'Vangay', 'Noguera-Julian', 'Zeller']

results = []

for study in studyList:
    study_path = os.path.join(home_path, study)

    # read in metadata
    meta_path = os.path.join(study_path, 'meta.txt')
    meta = pd.read_table(meta_path, index_col=0)

    # specify path for file walk
    dist_matrix_path = os.path.join(study_path, 'HA', 'distance_matrices')

    for root, dirs, files in os.walk(dist_matrix_path):
        for file in files:
            if file.startswith('.') or not file.endswith('distance_matrix.tsv'):
                continue

            # get beta method and matrix #
            beta_method = file.split('_distance_matrix.tsv')[0]
            matrix_number = beta_method.split('_')[-1]
            beta_method = '_'.join(beta_method.split('_')[:-1])

            if matrix_number not in [str(i) for i in range(2, 11)]:
                continue

            # Read in distance matrix
            data_path = os.path.join(root, file)
            data = pd.read_table(data_path, header=0, index_col=0)

            # In certain circumstances, unweighted unifrac returns NaN values. Remove problem samples.
            nan_indices = data.columns[data.isna().any()]
            data = data.drop(index=nan_indices, columns=nan_indices)

            # Match data and metadata indices
            shared_indices = meta.index.intersection(data.index)
            data = data.loc[shared_indices, shared_indices]
            meta_subset = meta.loc[shared_indices]

            # Run PERMANOVA for each column in the metadata
            for column in meta_subset.columns:
                # drop nan values from the current column
                meta_subset_clean = meta_subset.dropna(subset=[column])
                data_clean = data.loc[meta_subset_clean.index, meta_subset_clean.index]

                # ...but only if there are samples left after nan drop
                if not meta_subset_clean.empty and not data_clean.empty:
                    if meta_subset_clean[column].nunique() > 1:
                        data_clean = np.ascontiguousarray(data_clean.values)
                        results_permanova = permanova(DistanceMatrix(data_clean), meta_subset_clean[column])

                        results.append({
                            'study': study,
                            'beta_method': beta_method,
                            'matrix_number': matrix_number,
                            'metadata_column': column,
                            'f_statistic': results_permanova['test statistic'],
                            'p_value': results_permanova['p-value']
                        })

# Convert results to a DataFrame and save to a CSV
results_df = pd.DataFrame(results)
results_df.to_csv(os.path.join(home_path, 'HA_permanova_results.csv'), index=False)

print("PERMANOVA analysis completed and results saved to permanova_results.csv")
