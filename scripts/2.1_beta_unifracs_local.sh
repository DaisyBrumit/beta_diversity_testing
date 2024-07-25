#!/bin/bash

study=$1

# change directory and activate environment
cd ~/beta_diversity_testing/${study}/qiime
pwd
conda activate qiime2-2021.2

# generate beta transformation in qiime2
qiime diversity beta-phylogenetic --i-phylogeny insertionTree.qza --i-table filtered_table.qza --p-metric unweighted_unifrac --o-distance-matrix unweighted_unifrac.qza
qiime diversity beta-phylogenetic --i-phylogeny insertionTree.qza --i-table filtered_table.qza --p-metric weighted_unifrac --o-distance-matrix weighted_unifrac.qza

# export the distance matrices from qiime2
qiime tools export --input-path weighted_unifrac.qza --output-path ../distance_matrices/weighted_unifrac
qiime tools export --input-path unweighted_unifrac.qza --output-path ../distance_matrices/unweighted_unifrac

# remove redundant file nesting
cd ../distance_matrices
mv unweighted_unifrac/distance_matrix.tsv unweighted_unifrac_distance_matrix.tsv
mv weighted_unifrac/distance_matrix.tsv weighted_unifrac_distance_matrix.tsv

rm -r unweighted_unifrac/
rm -r weighted_unifrac/
