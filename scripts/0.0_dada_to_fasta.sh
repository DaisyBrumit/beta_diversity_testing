#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --mem=12GB
#SBATCH --time=24:00:00
#SBATCH --job-name=dd2fa 
#SBATCH --nodes=1

############# TO RUN THIS SCRIPT #######################################
# navigate to ~/beta_diversity_testing/scripts/                        #
# enter command:                                                       # 
# sbatch --output=slurm_out/desired_filename 0.0_DADA2fasta.sh $1 $2   #
########################################################################

### SETUP ###
# Record start time
start_time=$(date +"%Y-%m-%d %H:%M:%S")

# load module
module load anaconda3

# take input from command line
input=$1 # use absolute path (~/beta_diversity_testing/Jones/Jones_ForwardReads_DADA2.txt)
outPath=$2 # use absolute path & name file 'dada_seqs.fasta'

echo ""
echo "INPUT RECIEVED:"
echo "INPUT: $input" 
echo "OUTPUT PATH: $outPath"

### EXECUTE CODE: RUN PYTHON SCRIPT ###
cd ~/beta_diversity_testing/scripts/functions

python dada_to_fasta.py $input $outPath

echo ""
echo "FASTA FILE GENERATED"

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
