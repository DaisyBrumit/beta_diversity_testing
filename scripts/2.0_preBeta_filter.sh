#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --mem=12GB
#SBATCH --time=01:00:00
#SBATCH --job-name=preBFilter
#SBATCH --nodes=1

############# TO RUN THIS SCRIPT #######################################
# navigate to ~/beta_diversity_testing/scripts/                        #
# enter command:                                                       # 
# sbatch --output=slurm_out/desired_filename 2.0_filename.sh $1        #
########################################################################


### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# cml inputs
study=$1

### EXECUTE CODE: CLEAN UP DATA FOR BETA TRANSFORMS ###
python3 functions/post_tree_dataClean.py ${study}

### REPORT JOB METRICS ###
# record end time
end_time=$(date +"%Y-%m-%d %H:%M:%S")

# Calculate total runtime
start_seconds=$(date -d "$start_time" +"%s")
end_seconds=$(date -d "$end_time" +"%s")
total_seconds=$((end_seconds - start_seconds))

# Convert total_seconds to HH:MM:SS format
total_runtime=$(date -u -d @$total_seconds +"%T")

# Record memory usage
memory_usage=$(sstat -j $SLURM_JOBID --format=JobID,MaxVMSize,AveCPU,NTasks)

# Print metrics
echo "Start Time: $start_time"
echo "End Time: $end_time"
echo "Total Runtime: $tddotal_runtime"
echo "Memory Usage: $memory_usage"
