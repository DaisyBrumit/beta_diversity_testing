#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --mem=8GB
#SBATCH --time=00:10:00
#SBATCH --job-name=dada2biom
#SBATCH --nodes=1

############# TO RUN THIS SCRIPT #######################################
# navigate to ~/beta_diversity_testing/scripts/                        #
# enter command:                                                       # 
# sbatch --output=slurm_out/desired_filename 0.1_filename.sh $1        #
########################################################################


### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# cml inputs
study=$1

### EXECUTE CODE: CONVERT COUNT DATA TO BIOM TABLE ###
echo "Changing study to ~/beta_diversity_testing/${study}"
cd ~/beta_diversity_testing/${study} 

echo "Converting file ${file} to biom"
biom convert -i ${study}_ForwardReads_DADA2.txt -o dada_table.biom --table-type="OTU table" --to-hdf5

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
