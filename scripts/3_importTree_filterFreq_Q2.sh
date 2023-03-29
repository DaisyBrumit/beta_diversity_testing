#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=2:00:00
#SBATCH --job-name=betaQ2
#SBATCH --mem=8GB

start=$(date)

echo "===================================================="
echo "Job ID/Name : $SLURM_JOBID $SLURM_JOB_NAME"
echo "Start Time : $start"

### cml inputs: where is the reference data located?
treePath=$1
directory=$2

echo ""
echo "RECEIVED ARGUMENTS"
echo "ABSOLUTE TREE PATH = $treePath"
echo "STUDY DIRECTORY = $directory"

module load qiime2

cd $directory

echo ""
echo "Importing tree file to QIIME2 artifact"
qiime tools import \
	--input-path $treePath \
	--output-path tree.qza \
	--type 'Phylogeny[Rooted]'
echo "tree file output to study directory"

echo ""
echo "Filtering table by tree-given tip identifiers"
qiime phylogeny filter-table \
	--i-table freqTable_grouped.qza \
	--i-tree tree.qza\
	--o-filtered-table freqTable_filtered.qza
echo"Filtered frequency table output to study directory"

echo ""
echo "Creating visual of filtered table"
qiime feature-table summarize \
	--i-table freqTable_filtered.qza \
	--m-sample-metadata-file meta.txt \
	--o-visualization freqTable_filtered.qzv
echo "frequency visual created"
echo "End of script"
echo ""

end=$(date)
echo "End Time : $end"
echo "===================================================="
