#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --job-name=meta
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=20gb
#SBATCH --time=2:00:00
echo "======================================================"
echo "Start Time : $(date)"
echo "Submit Dir : $SLURM_SUBMIT_DIR"
echo "Job ID/Name : $SLURM_JOBID / $SLURM_JOB_NAME"
echo "Num Tasks : $SLURM_NTASKS total [$SLURM_NNODES nodes @ $SLURM_CPUS_ON_NODE CPUs/node]"
echo "Hostname : $HOSTNAME"
echo "======================================================"
echo ""

python3 beta_ml.py
