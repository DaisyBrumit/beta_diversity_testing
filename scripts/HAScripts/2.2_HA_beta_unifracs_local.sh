#!/bin/bash


study=$1

for i in {2..10}
do
	cd ~/beta_diversity_testing_almost_final/${study}/HA/qiime
	pwd
	qiime diversity beta-phylogenetic --i-phylogeny ../../qiime/insertionTree.qza --i-table top_${i}_table.qza --p-metric unweighted_unifrac --o-distance-matrix ${i}_unweighted_unifrac.qza
	qiime diversity beta-phylogenetic --i-phylogeny ../../qiime/insertionTree.qza --i-table top_${i}_table.qza --p-metric weighted_unifrac --o-distance-matrix ${i}_weighted_unifrac.qza

	qiime tools export --input-path ${i}_weighted_unifrac.qza --output-path ../distance_matrices/weighted_unifrac_${i}
	qiime tools export --input-path ${i}_unweighted_unifrac.qza --output-path ../distance_matrices/unweighted_unifrac_${i}

	cd ../distance_matrices
	pwd
	mv unweighted_unifrac_${i}/distance-matrix.tsv unweighted_unifrac_${i}_distance_matrix.tsv
	mv weighted_unifrac_${i}/distance-matrix.tsv weighted_unifrac_${i}_distance_matrix.tsv
done

rm -r unweighted_unifrac_${i}/
rm -r weighted_unifrac_${i}/
