#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=10:00:00
#SBATCH --job-name=gemelli
#SBATCH --mem=20GB

############# TO RUN THIS SCRIPT ##########################################
# navigate to ~/beta_diversity_testing/scripts/                           #
# enter command:                                                          #
# sbatch --output=slurm_out/2.2_studyname 2.2_beta_gemelli_hpc.sh $1 $2 * #
# *note: ctf requires two additional arguments for state and repeatID     #
###########################################################################


### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

### EXECUTE CODE: COMPLETE GEMELLI SUITE BETA DIV. TRANSFORMS ###
study=$1
method=$2

echo "RECEIVED ARGUMENTS"
echo "STUDY = $study"
echo "GEMELLI METHOD = $method"
echo "Loading module and changing to directory ~/beta_diversity_testing/${study}"

module load qiime2/2021.2
cd ~/beta_diversity_testing/${study}/qiime
echo "Beginning ${method} procedures..."
echo ""
echo ""

### CTF PROCEDURE: requires 2 extra arguments in cml
if [[ $method == "ctf" ]] 
then
	id=$3
	state=$4
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
	
	# make txt file
	for prefix in "${out_list[@]}"; do
		echo "$prefix"
		qiime tools export \
			--input-path ${prefix}_out/distance_matrix.qza \
			--output-path outdir
		
		# rename and relocate file
		mv outdir/* ../distance_matrices/${prefix}_distance_matrix.tsv
	done
fi

echo "SCRIPT COMPLETE"

### REPORT JOB METRICS ###
# record end time
#end_time=$(date +"%Y-%m-%d %H:%M:%S")

# Calculate total runtime
#start_seconds=$(date -d "$start_time" +"%s")
#end_seconds=$(date -d "$end_time" +"%s")
#total_seconds=$((end_seconds - start_seconds))

# Convert total_seconds to HH:MM:SS format
#total_runtime=$(date -u -d @$total_seconds +"%T")

# Print metrics
#echo ""
#echo "Start Time: $start_time"
#echo "End Time: $end_time"
#echo "Total Runtime: $total_runtime"
#echo "Memory Usage as per sstat:"
