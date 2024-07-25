#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --mem=32GB
#SBATCH --time=48:00:00
#SBATCH --job-name=makeTree

############# TO RUN THIS SCRIPT #######################################
# navigate to ~/beta_diversity_testing/scripts/                        #
# enter command:                                                       #
# sbatch --output=slurm_out/1.1_studyname 1.1_insertionTree.sh $1      #
########################################################################


### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# cml inputs
study=$1

# load module
module load qiime2/2021.2

### EXECUTE CODE: CREATE INSERTION TREE WITH GREENGENES ###
echo "Changing study to ~/beta_diversity_testing/${study}/qiime/"
cd ~/beta_diversity_testing/${study}/qiime 

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
echo "Filtered and discarded feature tables completed"

echo ""
echo "Generating visuals"
# get a visual for retained fragments
qiime feature-table summarize \
	--i-table filtered_table.qza \
	--m-sample-metadata-file ../meta.txt \
	--o-visualization filtered_table.qzv

# get a visual for discarded fragments
qiime feature-table summarize \
	--i-table discarded_table.qza \
	--m-sample-metadata-file ../meta.txt \
	--o-visualization discarded_table.qzv
echo "Visualizations generated"

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