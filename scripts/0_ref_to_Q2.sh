#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=0:10:00
#SBATCH --job-name=ref2q2

start=$(date)

echo "===================================================="
echo "Job ID/Name : $SLURM_JOBID $SLURM_JOB_NAME"
echo "Start Time : $start"

### cml inputs: where is the reference data located?
directory=$1
taxaPath=$2
seqPath=$3

echo "RECEIVED ARGUMENTS"
echo "DIRECTORY = $directory"
echo "SEQ FILE = $seqPath"
echo "FREQ FILE = $freqPath"

echo "Changing directory and loading module"
cd $directory
module load qiime2

echo "Beginning imports"
## convert ref seqs to qiime2 artifact
qiime tools import\
	--input-path $seqPath \
	--output-path refSeqs.qza \
	--type 'FeatureData[Sequence]'

echo "Reference sequences imported" 

## convert ref taxonomy to q2 artifact
qiime tools import \
	--input-path $taxaPath \
	--output-path refTaxonomy.qza \
	--type 'FeatureTable[Taxonomy]' \
	--input-format HeaderlessTSVTaxonomyFormat

echo "Reference taxonomy imported" 
echo "End of script"

end=$(date)
echo "Run Time : $end - $start"
echo "===================================================="
