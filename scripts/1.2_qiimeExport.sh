#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --time=00:30:00
#SBATCH --job-name=q2Export
#SBATCH --nodes=1

############# TO RUN THIS SCRIPT #######################################
# navigate to ~/beta_diversity_testing/scripts/                        #
# enter command:                                                       # 
# sbatch --output=slurm_out/1.2_study 0.1_filename.sh $1               #
########################################################################


### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# cml inputs
study=$1

# load module
module load qiime2/2021.2

### EXECUTE CODE: EXPORT QIIME ARTIFACTS ###
echo "Changing study to ~/beta_diversity_testing/${study}/qiime"
cd ~/beta_diversity_testing/${study}/qiime 

echo "performing export from .qza to biom on ${study} filtered table"
if [ ${study} == "gemelli_ECAM" ]
then
	qiime tools export \
		--input-path table.qza \
		--output-path ../
else
	qiime tools export \
		--input-path filtered_table.qza \
		--output-path ../
fi 

# rename feature-table.biom to filtered_table.biom for continuity
mv ../feature-table.biom ../filtered_table.biom

echo "converting biom to tsv"
biom convert -i ../filtered_table.biom -o ../filtered_table.txt --to-tsv

echo "exporting insertion tree to newick format"
qiime tools export \
	--input-path insertionTree.qza \
	--output-path ../insertionTree.nwk

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
echo "Start Time: $start_time"
echo "End Time: $end_time"
echo "Total Runtime: $tddotal_runtime"

sstat -j $SLURM_JOBID --format=JobID,MaxVMSize,AveCPU,NTasks
