#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --mem=12GB
#SBATCH --time=00:10:00
#SBATCH --job-name=q2Import
#SBATCH --nodes=1

############# TO RUN THIS SCRIPT #######################################
# navigate to ~/beta_diversity_testing/scripts/                        #
# enter command:                                                       # 
# sbatch --output=slurm_out/1.0_studyname 1.0_qiimeImport.sh $1        #
########################################################################


### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# load module
module load qiime2/2021.2

# cml inputs
study=$1

### EXECUTE CODE: IMPORT DATA AS Q2 ARTIFACTS ###
echo "Changing study to ~/beta_diversity_testing/${study}"
cd ~/beta_diversity_testing/${study} 

echo ""
echo "Beginning imports..."
qiime tools import \
	--input-path dada_table.biom \
	--output-path qiime/freqTable.qza \
	--type 'FeatureTable[Frequency]'
echo "Count data imported"

qiime tools import\
	--input-path dada_seqs.fa \
	--output-path qiime/seqTable.qza \
	--type 'FeatureData[Sequence]'
echo "Sequences imported"

echo ""
echo "Making visual artifacts..."
qiime metadata tabulate \
	--m-input-file meta.txt \
	--o-visualization qiime/meta.qzv
echo "metadata visual created"

qiime feature-table summarize \
	--i-table qiime/freqTable.qza \
	--m-sample-metadata-file meta.txt \
	--o-visualization qiime/freqTable.qzv
echo "frequency visual created"

qiime feature-table tabulate-seqs \
	--i-data qiime/seqTable.qza \
	--o-visualization qiime/seqTable.qzv
echo "sequence visual created"
echo ""
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
