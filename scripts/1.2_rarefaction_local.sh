#!/bin/bash

# get study dir and activate qiime
study=$1
sampling_depth=$2

conda activate qiime2-amplicon-2023.9

cd ~/beta_diversity_testing/${study}/qiime

qiime feature-table rarefy \
	--i-table filtered_table.qza \
	--p-sampling-depth ${sampling_depth} \
	--o-rarefied-table rare_filtered_table.qza

qiime feature-table summarize \
	--i-table rare_filtered_table.qza \
	--m-sample-metadata-file ../meta.txt \
	--o-visualization rare_filtered_table.qzv
