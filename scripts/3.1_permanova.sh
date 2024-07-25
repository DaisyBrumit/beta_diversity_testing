#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --mem=24GB
#SBATCH --time=12:00:00
#SBATCH --job-name=perma
#SBATCH --nodes=1

############# TO RUN THIS SCRIPT #######################################
# navigate to ~/beta_diversity_testing/scripts/                        #
# enter command:                                                       # 
# sbatch --output=slurm_out/desired_filename 3.1_filename.sh           #
########################################################################


### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

### EXECUTE CODE: CONVERT COUNT DATA TO BIOM TABLE ###
module load anaconda3
conda activate lvc
Rscript --vanilla 3.1_permanova.R

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
sstat -j $SLURM_JOBID --all