#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=12:00:00
#SBATCH --job-name=betaQ2
#SBATCH --mem=16GB

start=$(date)

echo "===================================================="
echo "Job ID/Name : $SLURM_JOBID $SLURM_JOB_NAME"
echo "Start Time : $start"

### cml inputs: where is the reference data located?
directory=$1
#samplingDepth=$2

echo ""
echo "RECEIVED ARGUMENTS"
echo "STUDY DIRECTORY = $directory"
#echo "SAMPLING DEPTH = $samplingDepth"

module load qiime2
cd $directory

echo ""
echo "Beginning core metrics run"
qiime diversity core-metrics-phylogenetic \
	--i-phylogeny insertionTree.qza \
	--i-table filtered_table.qza \
	--p-sampling-depth $samplingDepth \
	--m-metadata-file meta.txt \
	--output-dir core-metrics-results

# core metrics in qiime include Beta div. outputs: Bray-Curtis, UniFrac (weighted and un-), Jaccard
# other included outputs correspond to alpha diversity. 
echo "Core metrics run complete"

echo "Exporting distance .qza matrices to .txt files"
cd core-metrics-results

# list of qiime artifacts we want to export to text files
matrix_list=("bray_curtis_distance_matrix.qza" "jaccard_distance_matrix.qza" "unweighted_unifrac_distance_matrix.qza" "weighted_unifrac_distance_matrix.qza" "jaccard_pcoa_results.qza" "bray_curtis_pcoa_results.qza" "unweighted_unifrac_pcoa_results.qza" "weighted_unifrac_pcoa_results.qza")

# for every matrix in the list
for matrix in "${matrix_list[@]}"; do
	# Make an output file prefix by removing ".qza" from the artifact file name
	prefix=`echo $matrix | sed 's/.qza//'`
	
	# Export from artifact to a text file. 
	# Qiime will output the file to a directory.
	qiime tools export \
		--input-path $matrix \
		--output-path $prefix
	
	# Remove excessive directories by...
	# extracting the new directory content (a single file)
	file=`ls ${prefix}/`
	echo "$file"
	mv ${prefix}/* ${prefix}_${file}

	# and removing the now empty directory
	rm -r ${prefix}/


done

echo "Exports complete"
echo "End of script"
echo ""

end=$(date)
echo "End Time : $end"
echo "===================================================="
