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
samplingDepth=$2

echo ""
echo "RECEIVED ARGUMENTS"
echo "STUDY DIRECTORY = $directory"
echo "SAMPLING DEPTH = $samplingDepth"

module load qiime2

cd $directory

echo ""
echo "Beginning core metrics run"
qiime diversity core-metrics-phylogenetic \
	--i-phylogeny tree.qza \
	--i-table freqTable_filtered.qza \
	--p-sampling-depth $samplingDepth \
	--m-metadata-file meta.txt \
	--output-dir core-metrics-results

# core metrics in qiime include Beta div. outputs: Bray-Curtis, UniFrac (weighted and un-), Jaccard
# other included outputs correspond to alpha diversity. 
echo "Core metrics run complete"

echo ""
echo "Beginning gemmeli-provided metrics run"


echo "End of script"
echo ""

end=$(date)
echo "End Time : $end"
echo "===================================================="
