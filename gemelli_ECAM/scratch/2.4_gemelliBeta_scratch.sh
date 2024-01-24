#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=10:00:00
#SBATCH --job-name=gemelli
#SBATCH --mem=20GB

############# TO RUN THIS SCRIPT #######################################
# navigate to ~/beta_diversity_testing/scripts/                        #
# enter command:                                                       #
# sbatch --output=slurm_out/desired_filename 2.4_filename.sh $1 $2 *   #
# *note: ctf requires two additional arguments for state and repeatID  #
########################################################################


### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

### EXECUTE CODE: COMPLETE GEMELLI SUITE BETA DIV. TRANSFORMS ###
### cml inputs: where is the reference data located?
study=$1
method=$2

echo "RECEIVED ARGUMENTS"
echo "STUDY = $study"
echo "GEMELLI METHOD = $method"
echo "Loading module and changing to directory ~/beta_diversity_testing/${study}/scratch"

module load qiime2/2021.2
cd ~/beta_diversity_testing/${study}/scratch
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
		--i-table table.qza \
		--m-sample-metadata-file ../meta.txt \
		--p-individual-id-column $id \
		--p-state-column $state \
		--output-dir ctf_out
	
	echo "RUNNING PHYLO-CTF"
	qiime gemelli phylogenetic-ctf-without-taxonomy \
		--i-table table.qza \
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

fi

### CTF PROCEDURE 2: RUN ON RAREFIED DATA TO CONFIRM GEMELLI RESULTS
if [[ $method == "ctf" ]]
then
	id=$3
	state=$4
	echo "Running same plugin with rarefaction to depth 11939"

	qiime feature-table rarefy \
		--i-table table.qza \
		--p-sampling-depth 11939 \
		--o-rarefied-table rarefied-table.qza

	qiime gemelli ctf \
		--i-table rarefied-table.qza \
		--m-sample-metadata-file ../meta.txt \
		--p-individual-id-column $id \
		--p-state-column $state \
		--output-dir rare_ctf_out

	qiime gemelli phylogenetic-ctf-without-taxonomy \
		--i-table rarefied-table.qza \
		--i-phylogeny insertionTree.qza \
		--m-sample-metadata-file ../meta.txt \
		--p-individual-id-column $id \
		--p-state-column $state \
		--output-dir rare_phylo_ctf_out 

	echo "Converting phyo/nonphylo ctf artifacts to txt"
	out_list=("rare_ctf" "rare_phylo_ctf") # run for phylo and no phylo
	
	# generate txt file
	for prefix in "${out_list[@]}"; do
		qiime tools export \
			--input-path ${prefix}_out/distance_matrix.qza \
			--output-path outdir

		# rename file and move from new directory to existing directory
		mv outdir/* ../distance_matrices/${prefix}_distance_matrix.tsv
	done
fi

echo "SCRIPT COMPLETE"

### REPORT JOB METRICS ###
# record end time
end_time=$(date +"%Y-%m-%d %H:%M:%S")

# Calculate total runtime
start_seconds=$(date -d "$start_time" +"%s")
end_seconds=$(date -d "$end_time" +"%s")
total_seconds=$((end_seconds - start_seconds))

# Convert total_seconds to HH:MM:SS format
total_runtime=$(date -u -d @$total_seconds +"%T")

# Print metrics
echo ""
echo "Start Time: $start_time"
echo "End Time: $end_time"
echo "Total Runtime: $total_runtime"
echo "Memory Usage as per sstat:"
sstat -j $SLURM_JOBID --all
