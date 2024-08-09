#!/bin/bash

### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

### EXECUTE CODE: COMPLETE GEMELLI SUITE BETA DIV. TRANSFORMS ###
study=$1
method=$2
out=$3 # define where you want your standard output to go

exec &> ${out} # direct stdout
echo "RECEIVED ARGUMENTS"
echo "STUDY = $study"
echo "GEMELLI METHOD = $method"
echo "Changing to directory ~/beta_diversity_testing/${study}/qiime"

cd ~/beta_diversity_testing/${study}/qiime
echo ""
echo "Beginning ${method} procedures..."
echo ""
echo ""

### CTF PROCEDURE: requires 2 extra arguments in cml
if [[ $method == "ctf" ]] 
then
	id=$4
	state=$5
	echo "Running gemelli plugin with method = $method"
	echo "Individual ID = $id \n State column = $state"
	echo "RUNNING CTF"
	qiime gemelli ctf \
		--i-table filtered_table.qza \
		--m-sample-metadata-file ../meta.txt \
		--p-individual-id-column $id \
		--p-state-column $state \
		--output-dir ctf_out
	
	echo "RUNNING PHYLO-CTF"
	qiime gemelli phylogenetic-ctf-without-taxonomy \
		--i-table filtered_table.qza \
		--i-phylogeny insertionTree.qza \
		--m-sample-metadata-file ../meta.txt \
		--p-individual-id-column $id \
		--p-state-column $state \
		--output-dir phylo_ctf_out
	
	echo "Converting phyo/nonphylo ctf artifacts to txt"
	out_list=("ctf" "phylo_ctf") # run for phylo and no phylo
	
	# generate txt file
	for prefix in "${out_list[@]}"; do
		qiime tools export \
			--input-path ${prefix}_out/distance_matrix.qza \
			--output-path outdir

		# rename file and move from new directory to existing directory
		mv outdir/* ../distance_matrices/${prefix}_distance_matrix.tsv
	done

### rpca procedure
elif [[ $method == "rpca" ]]
then

	echo "Running gemelli plugin with method = $method"
	echo "RUNNING RPCA"
	qiime gemelli rpca \
		--i-table filtered_table.qza \
       		--output-dir rpca_out	
	
	echo "RUNNING PHYLO RPCA"
	qiime gemelli phylogenetic-rpca-without-taxonomy \
		--i-table filtered_table.qza \
		--i-phylogeny insertionTree.qza \
		--output-dir phylo_rpca_out
	
	echo "Converting phyo/nonphylo rpca artifacts to txt"
	out_list=("rpca" "phylo_rpca") # run for phylo and no phylo

fi
echo "SCRIPT COMPLETE"
