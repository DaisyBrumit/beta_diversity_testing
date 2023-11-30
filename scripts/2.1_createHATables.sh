#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --mem=12GB
#SBATCH --time=10:00:00
#SBATCH --job-name=HATables
#SBATCH --nodes=1

############# TO RUN THIS SCRIPT #######################################
# navigate to ~/beta_diversity_testing/scripts/                        #
# enter command:                                                       # 
# sbatch --output=slurm_out/desired_filename 2.1_filename.sh           #
########################################################################


### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

### EXECUTE CODE: RUN FULL PYTHON CODE TO CREATE HA TABLES ###
python 2.1_createHATables.py
echo "Script complete"

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
