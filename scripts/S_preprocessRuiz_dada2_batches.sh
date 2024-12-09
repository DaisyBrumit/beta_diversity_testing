#!/bin/bash
#SBATCH --job-name=S_ruiz
#SBATCH --output=slurm-out/dada2_chunk_%A_%a.out
#SBATCH --time=48:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --array=3-8 # Modify based on number of chunks

# Load R module
# module load R

# Define chunk size
CHUNK_SIZE=100

# Get the list of files in the 'filtered_seqs' directory
FILES=$(ls ~/bdt/Ruiz-Calderon/preprocessing/filtered_seqs/*.fastq)
# Convert the file list to an array
FILES_ARRAY=($FILES)

# Get the total number of files
TOTAL_FILES=${#FILES_ARRAY[@]}

# Calculate the start and end index for the current chunk
START_IDX=$(( ($SLURM_ARRAY_TASK_ID - 1) * $CHUNK_SIZE + 1 ))
END_IDX=$(( $SLURM_ARRAY_TASK_ID * $CHUNK_SIZE ))
if [ $END_IDX -gt $TOTAL_FILES ]; then
	    END_IDX=$TOTAL_FILES
    fi

    # Extract the list of files for this chunk
    CHUNK_FILES="${FILES_ARRAY[@]:$((START_IDX-1)):$(($END_IDX-$START_IDX+1))}"

    # Call the R script, passing the chunk of files
    Rscript SB_preprocessRuiz.R "$START_IDX" "$END_IDX" "$CHUNK_FILES"

