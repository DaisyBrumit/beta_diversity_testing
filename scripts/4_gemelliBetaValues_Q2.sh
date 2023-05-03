#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=0:10:00
#SBATCH --job-name=gemelli
#SBATCH --mem=20GB
#SBATCH --output=gemelli%j.out
#SBATCH --error=gemelli%j.err

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
		--p-n-components 10 \
		--output-dir ctf_out
	
	echo "RUNNING PHYLO-CTF"
	qiime gemelli phylogenetic-ctf-without-taxonomy --i-table filtered_table.qza --i-phylogeny insertionTree.qza --m-sample-metadata-file meta.txt --p-individual-id-column $id --p-state-column $state --p-n-components 10 --output-dir phylo_ctf_out

elif [[ $method == *"rpca"* ]]
then

	echo "Running gemelli plugin with method = $method"
	echo "RUNNING RPCA"
	qiime gemelli rpca \
		--i-table filtered_table.qza \
		--p-n-components 10 \
       		--output-dir rpca_out	

	echo "RUNNING PHYLO RPCA"
	qiime gemelli phylogenetic-rpca-without-taxonomy --i-table filtered_table.qza --i-phylogeny insertionTree.qza --p-n-components 10 --output-dir phylo_rpca_out
fi

end=$(date)
echo "END OF SCRIPT AT TIME $end"
