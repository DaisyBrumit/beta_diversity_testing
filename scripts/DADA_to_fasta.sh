#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --mem=12GB
#SBATCH --time=24:00:00
#SBATCH --job-name=dd2fa 
#SBATCH --nodes=1

echo "START TIME: ${date}"

module load anaconda3

input=$1
outPath=$2

echo ""
echo "INPUT RECIEVED:\n INPUT: $input \n OUTPUT PATH: $outPath"

python DATA_to_fasta.py $input $outPath

echo ""
echo "FASTA FILE GENERATED"
