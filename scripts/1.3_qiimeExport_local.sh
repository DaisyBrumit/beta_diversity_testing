#!/bin/bash

# cml inputs
study=$1

### EXECUTE CODE: EXPORT QIIME ARTIFACTS ###
echo "Changing study to ~/beta_diversity_testing/${study}/qiime"
cd ~/beta_diversity_testing/${study}/qiime

#echo ""
#echo "performing export from .qza to biom on ${study} filtered table"
#if [ ${study} == "gemelli_ECAM" ]
#then
#	qiime tools export \
#		--input-path table.qza \
#		--output-path ../
#else
#	qiime tools export \
#		--input-path filtered_table.qza \
#		--output-path ../
#fi

# rename feature-table.biom to filtered_table.biom for continuity
#mv ../feature-table.biom ../filtered_table.biom

#echo ""
#echo "converting filtered_table.biom to tsv"
#biom convert -i ../filtered_table.biom -o ../filtered_table.txt --to-tsv

#echo ""
#echo "exporting insertion tree to newick format"
#qiime tools export \
#	--input-path insertionTree.qza \
#	--output-path ../insertionTreeDir

# get tree file from qiime's exported tree directory
#mv ../insertionTreeDir/tree.nwk ../insertion_tree.nwk
#rm -r ../insertionTreeDir/

echo ""
echo "exporting rarefied table"
qiime tools export \
		--input-path rare_filtered_table.qza \
		--output-path ../

# rename feature-table.biom to rare_filtered_table.biom for continuity
mv ../feature-table.biom ../rare_filtered_table.biom

echo ""
echo "converting filtered_table.biom to tsv"
biom convert -i ../rare_filtered_table.biom -o ../rare_filtered_table.txt --to-tsv

echo "SCRIPT COMPLETE"