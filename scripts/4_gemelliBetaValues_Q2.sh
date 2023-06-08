#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=10:00:00
#SBATCH --job-name=gemelli
#SBATCH --mem=20GB

start=$(date)

echo "===================================================="
echo "Job ID/Name : $SLURM_JOBID $SLURM_JOB_NAME"
echo "Start Time : $start"

### cml inputs: where is the reference data located?
directory=$1
method=$2

echo "RECEIVED ARGUMENTS"
echo "DIRECTORY = $directory"
echo "GEMELLI METHOD = $method"
echo "Loading module and changing directory"

module load qiime2/2021.2
cd $directory
echo ""

### ctf procedure: requires 2 extra arguments in cml
if [[ $method == "ctf" ]] 
then
	id=$3
	state=$4
	echo "Running gemelli plugin with method = $method"
	echo "Individual ID = $id \n State column = $state"
	echo "RUNNING CTF"
	qiime gemelli ctf \
		--i-table filtered_table.qza \
		--m-sample-metadata-file meta.txt \
		--p-individual-id-column $id \
		--p-state-column $state \
		--output-dir ctf_out
	
	echo "RUNNING PHYLO-CTF"
	qiime gemelli phylogenetic-ctf-without-taxonomy \
		--i-table filtered_table.qza \
		--i-phylogeny insertionTree.qza \
		--m-sample-metadata-file meta.txt \
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
		mv outdir/* ${prefix}_distance_matrix.tsv
		# delete unused directory
		rm -r outdir/
		rm -r ${prefix}_out/
	done

### rpca procedure
elif [[ $method == *"rpca"* ]]
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
		mv outdir/* ${prefix}_distance_matrix.tsv
		# remove unused directory
		rm -r outdir/
		rm -r ${prefix}_out/
	done
fi

end=$(date)
echo "END OF SCRIPT AT TIME $end"
