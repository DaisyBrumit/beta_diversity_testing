##########################################
# 1
##########################################
import os
import biom
import qiime2 as q2
import pandas as pd
import numpy as np

from qiime2 import Artifact
from qiime2 import Metadata
from qiime2.plugins.feature_table.methods import rarefy
from qiime2.plugins.gemelli.actions import (ctf, phylogenetic_ctf_without_taxonomy)
from qiime2.plugins.diversity.actions import (beta, beta_phylogenetic)

from skbio import TreeNode
from skbio.stats.distance import (DistanceMatrix, permanova)

##########################################
# 2
##########################################

meta_in = pd.read_table('./data/metadata-matched.tsv', index_col=0) # read in meta
bt_in = biom.load_table('./data/table.biom') # read in biom
df = pd.DataFrame(bt_in.to_dataframe()) # convert to df

# filter out metadata (dims match)
meta = meta_in[~meta_in.month.isin([0,15,19])] # remove some months
meta = meta[meta.mom_child == 'C'] # filter for relationship
meta['host_subject_id_str'] = 'subject_' + meta['host_subject_id'].astype(int).astype(str) # create string var for ids

# apply filters to data
shared_ids = set(df.columns) & set(meta.index)
df = df.filter(shared_ids) # dims match
mask = df.sum(axis=1) > 1 # filter for multiple observations (row sums to > 1)
df = df[mask]
df = df.loc[:, df.sum() > 0] # filter for multiple feature instances (col sums to > 1)

# convert to biom, prep for rarefaction
bt = biom.Table(df.values, observation_ids=df.index, sample_ids=df.columns)
r_depth = int(np.percentile(bt.sum('sample'), 25)) # further filter for rarefaction step
keep_ids = bt.ids()[bt.sum('sample') > r_depth]
bt = bt.filter(keep_ids)

# reindex meta
meta = meta.reindex(bt.ids())

##########################################
# 3
##########################################
# WRITE OUT FILTERED DATA AS A BIOM FILE, META AS TSV
bt_out_path = './data/filtered_table.biom'
with biom.util.biom_open(bt_out_path, 'w') as f:
    bt.to_hdf5(f, 'scotty')

meta.index.name = '#SampleID'
meta.to_csv('./data/filtered_meta.tsv', sep='\t', index=True)

##########################################
# 4
##########################################
# bt == filtered (biom) version of original counts table
# meta == original metadata filtered to only retained bt samples

table = Artifact.import_data('FeatureTable[Frequency]', bt) # convert bt to q2 artifact
rare_table = rarefy(table, r_depth, with_replacement=True).rarefied_table # table used for non-gemelli methods

bt = bt.filter(rare_table.view(biom.Table).ids('observation'), axis='observation') # filter bt obs by rarefied out
table = Artifact.import_data('FeatureTable[Frequency]', bt) # reimport
rare_meta = meta.reindex(bt.ids()) # reindex metadata

# prune tree
#tree = TreeNode.read('./data/insertion-tree.nwk')
#tree = tree.shear(bt.ids('observation'))
#tree.prune()

##########################################
# 5
##########################################

# CHECK DIMS
rare_bt = rare_table.view(biom.Table)
print('bt: ', bt.shape)
print('rare_bt: ', rare_bt.shape)

# WRITE OUT DATA
bt_out_path = './data/post_rare_filtered_table.biom'
with biom.util.biom_open(bt_out_path, 'w') as f:
    bt.to_hdf5(f, 'scotty')

rare_meta.index.name = '#SampleID'
meta.to_csv('./data/post_rare_filtered_meta.tsv', sep='\t', index=True)
#tree.write('./data/pruned_tree.nwk')

##########################################
# 6
##########################################

tree = Artifact.load('./data/insertion-tree.qza')
# Gemelli methods
#phylo_ctf_table = phylogenetic_ctf_without_taxonomy(table, Metadata(meta_q2), 'host_subject_id_str', 'month',
#                                                    min_depth=100)
#ctf_table = ctf(table, Metadata(meta_q2), 'host_subject_id_str', 'month', n_components=2, n_initializations=5,
#               max_iterations_rptm=5, max_iterations_als=5)

# run in cml, see screenshot

# Phylogenetic methods
u_unifrac = beta_phylogenetic(rare_table, tree, 'unweighted_unifrac')
w_unifrac = beta_phylogenetic(rare_table, tree, 'weighted_unifrac')

# Naive methods
bray_curtis = beta(rare_table, 'braycurtis')
jaccard = beta(rare_table, 'jaccard')

##########################################
# 7
##########################################

# Isolate matrices
phylo_ctf_dm = Artifact.load('./data/phylo_ctf_out/distance_matrix.qza').view(DistanceMatrix)
ctf_dm = Artifact.load('./data/ctf_out/distance_matrix.qza').view(DistanceMatrix)
u_unifrac_dm = u_unifrac.distance_matrix.view(DistanceMatrix)
w_unifrac_dm = w_unifrac.distance_matrix.view(DistanceMatrix)
bray_curtis_dm = bray_curtis.distance_matrix.view(DistanceMatrix)
jaccard_unifrac_dm = jaccard.distance_matrix.view(DistanceMatrix)

dist_dict = {'Phylo-CTF:':phylo_ctf_dm,
            'CTF:':ctf_dm,
            'Unweighted-Unifrac:':u_unifrac_dm,
            'Weighted-Unifrac:':w_unifrac_dm,
            'Bray-Curtis:':bray_curtis_dm,
            'Jaccard:':jaccard_unifrac_dm
            }

##########################################
# 6
##########################################

import warnings

warnings.simplefilter(action='ignore', category=FutureWarning)
[56]
permanova_out = {}
fstat_tmp = {}

for method in dist_dict:

    dist_tmp = dist_dict[method]
    meta_tmp = rare_meta.loc[dist_tmp.ids, ['delivery', 'month']].dropna()

    for timepoint, time_df in meta_tmp.groupby('month'):

        ids = set(dist_tmp.ids) & set(time_df.index)

        if len(set(meta_tmp.loc[ids, 'delivery'])) < 2:
            continue
        if meta_tmp.loc[ids, 'delivery'].value_counts().min() < 2:
            continue

        dist_tmp_time = dist_tmp.copy().filter(ids)
        permanova_tmp = permanova(dist_tmp_time, meta_tmp.loc[ids, 'delivery'], permutations=999)

        fstat_tmp[(method, timepoint, 'F-Stat')] = [permanova_tmp['test statistic']]

fstat_tmp_df = pd.DataFrame(fstat_tmp, ['score']).T.reset_index()
fstat_tmp_df.columns = ['method', 'fold', 'evaluation', 'score']
permanova_out[('delivery')] = fstat_tmp_df

##########################################
# 7
##########################################

fstat_tmp_df.to_csv('./data/permanova.tsv', sep='\t')