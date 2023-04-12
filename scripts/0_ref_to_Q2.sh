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
treePath=$4

echo "RECEIVED ARGUMENTS"
echo "OUTPUT DIRECTORY = $directory"
echo "SEQ FILE = $seqPath"
echo "TAXONOMY FILE = $taxaPath"
echo "TREE FILE = $treePath"

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
## for headerless, tsv input styles.
## for tsv with headers, use --input-format TSVTaxonomyFormat
qiime tools import \
	--input-path $taxaPath \
	--output-path refTaxonomy.qza \
	--type 'FeatureTable[Taxonomy]' \
	--input-format HeaderlessTSVTaxonomyFormat

echo "Reference taxonomy imported" 

## convert (ROOTED!) ref tree to q2 artifact
## for unrooted trees, change --type to Phylogeny[Unrooted]
qiime tools import \
	--input-path $treePath \
	--output-path refTree.qza \
	--type 'Phylogeny[Rooted]'

echo "Reference tree imported"
echo "End of script"

end=$(date)
echo "End Time : $end"
echo "===================================================="
