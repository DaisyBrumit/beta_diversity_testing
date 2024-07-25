import pandas as pd
import numpy as np
from scipy.stats import kruskal
import scikit_posthocs as sp

# List of studies and method
studyList = ['ECAM', 'Jones', "Noguera-Julian", 'Vangay', 'Zeller']
#method = 'knn'
method='rf'

# Function to read data and combine into a single DataFrame
def read_data(study, metric, method):
    homedir = f'~/beta_diversity_testing/{study}/ML/'
    file_path = f'{homedir}{metric}_{method}.tsv'
    df = pd.read_csv(file_path, sep='\t')
    df['study'] = study
    df['metric'] = metric
    return df


# Initialize an empty list to hold data from all studies and metrics
all_data = []

# Loop over metrics and studies to read and combine data
for metric in ['accuracy', 'r2', 'roc']:
    for study in studyList:
        print(f"Reading {study} files for {metric}")
        df = read_data(study, metric, method)
        all_data.append(df)

# get all values in one df
combined_df = pd.concat(all_data, ignore_index=True)

# elongate & clean
long_df = combined_df.melt(id_vars=['study', 'metric', 'beta'], var_name='metadata', value_name='value')
long_df = long_df.dropna(subset=['value'])

# KW test for each metric
resultsList = []
for metric in ['accuracy', 'r2', 'roc']:
    metric_df = long_df[long_df['metric'] == metric]

    # get groups
    beta_groups = metric_df.groupby('beta')['value'].apply(list)
    groups = [group for group in beta_groups]

    # Kruskal-Wallis test
    stat, p_value = kruskal(*groups)
    resultsList.append({'metric': metric, 'stat': stat, 'p_value': p_value})

    print(f"Kruskal-Wallis H Test for {metric}: stat={stat}, p-value={p_value}")

    # run post-hoc comparisons (Dunn) if KW is significant
    if p_value < 0.05:
        post_hoc = sp.posthoc_dunn(metric_df, val_col='value', group_col='beta', p_adjust='fdr_bh')
        post_hoc_file = f'~/beta_diversity_testing/plots/{method}_post_hoc_{metric}.tsv'
        post_hoc.to_csv(post_hoc_file, sep='\t')
        print(f"Post-hoc pairwise comparisons for {metric} saved to {post_hoc_file}.")

# save output
results_df = pd.DataFrame(resultsList)
results_file = f'~/beta_diversity_testing/plots/{method}_kruskal_wallis_results.tsv'
results_df.to_csv(results_file, sep='\t', index=False)

print(f"Kruskal-Wallis test results saved to {results_file}.")