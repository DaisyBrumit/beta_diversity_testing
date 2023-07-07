#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --job-name=ml_run
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=10
#SBATCH --mem=64gb
#SBATCH --time=200:00:00
#SBATCH --mail-user=$dfrybrum@uncc.edu

echo "======================================================"
echo "Start Time : $(date)"
echo "Submit Dir : $SLURM_SUBMIT_DIR"
echo "Job ID/Name : $SLURM_JOBID / $SLURM_JOB_NAME"
echo "Num Tasks : $SLURM_NTASKS total [$SLURM_NNODES nodes @ $SLURM_CPUS_ON_NODE CPUs/node]"
echo "======================================================"
echo ""

# Define a list of strings
study_list=("Jones" "Vangay" "Zeller" "Noguera-Julian" "gemmeli_ECAM")
num_pcAxes=("-2" "-1" "3" "4" "5" "6" "7" "8" "9" "10")

# Function to perform the parallel process on each item
run_ml() {
    local study="$1"
    local num="$2"
    # Add your processing logic here
    echo "Processing: $study"
    python3 beta_ml.py $study $num
    echo "Finished processing: $study"
}

# Loop through the list and run the process_string function in the background for each item
for study in "${study_list[@]}"; do
  for num in "${num_pcAxes[@]}"; do
    run_ml "$study" "$num"&
  done
done

# Wait for all background processes to finish
wait