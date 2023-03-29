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

module load qiime2

cd $directory
echo ""
echo "Beginning imports..."

## convert seqs to qiime2 artifact
qiime tools import\
	--input-path $seqPath \
	--output-path seqTable.qza \
	--type 'FeatureData[Sequence]'

echo "Sequences imported" 

## convert frequency table to q2 artifact
qiime tools import \
	--input-path $taxaPath \
	--output-path freqTable.qza \
	--type 'FeatureTable[Frequency]'

echo "Count data imported" 
echo "Making visual artifacts..."

qiime metadata tabulate \
	--m-input-file $metaPath \
	--o-visualization metadata.qzv
echo "metadata visual created"

qiime feature-table summarize \
	--i-table freqTable.qza \
	--m-sample-metadata-file $metaPath \
	--o-visualization freqTable.qzv
echo "frequency visual created"

qiime feature-table tabulate-seqs \
	--i-data seqTable.qza \
	--o-visualization seqTable.qzv
echo "sequence visual created"
echo "End of script"
echo ""

end=$(date)
echo "Run Time : $end-$start"
echo "===================================================="
