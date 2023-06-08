#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=0:10:00
#SBATCH --job-name=myDat2q2

start=$(date)

echo "===================================================="
echo "Job ID/Name : $SLURM_JOBID $SLURM_JOB_NAME"
echo "Start Time : $start"

### cml inputs: where is the reference data located?
directory=$1
seqPath=$2
freqPath=$3
metaPath=$4

echo "RECEIVED ARGUMENTS"
echo "DIRECTORY = $directory"
echo "SEQ FILE = $seqPath"
echo "FREQ FILE = $freqPath"
echo "META FILE = $metaPath"
echo "Loading module and changing directory"

module load qiime2

echo ""
echo "moving metadata to file meta.txt"
mv $metaPath ${directory}meta.txt

echo ""
echo "Beginning imports..."
## convert seqs to qiime2 artifact
qiime tools import\
	--input-path $seqPath \
	--output-path ${directory}seqTable.qza \
	--type 'FeatureData[Sequence]'
echo "Sequences imported" 

## convert frequency table to q2 artifact
qiime tools import \
	--input-path $freqPath \
	--output-path ${directory}freqTable.qza \
	--type 'FeatureTable[Frequency]'
echo "Count data imported" 

echo ""
echo "Making visual artifacts..."
qiime metadata tabulate \
	--m-input-file $metaPath \
	--o-visualization ${directory}meta.qzv
echo "metadata visual created"

qiime feature-table summarize \
	--i-table ${directory}freqTable.qza \
	--m-sample-metadata-file $metaPath \
	--o-visualization ${directory}freqTable.qzv
echo "frequency visual created"

qiime feature-table tabulate-seqs \
	--i-data ${directory}seqTable.qza \
	--o-visualization ${directory}seqTable.qzv
echo "sequence visual created"
echo "End of script"
echo ""

end=$(date)
echo "End Time : $end"
echo "===================================================="
