#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=6:00:00
#SBATCH --job-name=classifyQ2
#SBATCH --mem=32GB

start=$(date)

echo "===================================================="
echo "Job ID/Name : $SLURM_JOBID $SLURM_JOB_NAME"
echo "Start Time : $start"

### cml inputs: where is the reference data located?
targetDir=$1

echo "RECEIVED ARGUMENTS"
echo "DIRECTORY = $targetDir"

echo "Loading module and changing directory"
cd $targetDir
module load qiime2

echo "retrieving greengenes reference database via wget"
wget -O "sepp-refs-gg-13-8.qza" \
	 "https://data.qiime2.org/2019.10/common/sepp-refs-gg-13-8.qza"
echo "greengenes db loaded as sepp-refs-gg-13-8.qza"

echo ""
echo "Building insertion tree"
qiime fragment-insertion sepp \
        --i-representative-sequences seqTable.qza \
        --i-reference-database sepp-refs-gg-13-8.qza \
        --o-tree insertionTree.qza \
        --o-placements insertionPlacements.qza
echo "Insertion tree completed"

echo ""
echo "Filtering features using phylogeny"
qiime fragment-insertion filter-features \
	--i-table freqTable.qza \
	--i-tree insertionTree.qza \
	--o-filtered-table filtered_table.qza \
	--o-removed-table discarded_table.qza
echo "Retained and discarded feature tables completed"

echo ""
echo "Generating visuals"
# get a visual for retained fragments
qiime feature-table summarize \
	--i-table filtered_table.qza \
	--m-sample-exitmetadata-file meta.txt \
	--o-visualization filtered_table.qzv

# get a visual for discarded fragments
qiime feature-table summarize \
	--i-table discarded_table.qza \
	--m-sample-metadata-file meta.txt \
	--o-visualization discarded_table.qzv
echo "Visualizations generated"

echo "End of script"

end=$(date)
echo "End Time : $end"
echo "===================================================="
