#!/bin/bash
#SBATCH --partition=Orion
#SBATCH --nodes=1
#SBATCH --time=6:00:00
#SBATCH --job-name=classifyQ2
#SBATCH --mem=32GB

start=$(date)

echo "===================================================="
echo "Job ID/Name : $SLURM_JOBID $SLURM_JOB_NAME"
echo "Start Time : $start"

### cml inputs: where is the reference data located?
targetDir=$1
refDir=$2

echo "RECEIVED ARGUMENTS"
echo "TARGET DIRECTORY = $targetDir"
echo "REFERENCE DIRECTORY = $refDir"

echo "Loading module"
module load qiime2

echo "Initiating classifier"
qiime feature-classifier classify-consensus-blast \
	--i-query $targetDir/seqTable.qza \
	--i-reference-reads $refDir/refSeqs.qza \
	--i-reference-taxonomy $refDir/refTaxonomy.qza \
	--o-classification $targetDir/taxonomy.qza
echo "Classification complete" 

echo "Merging taxonomy and frequency table labels"
qiime feature-table group \
	--i-table freqTable.qza \
	--p-axis 'feature' \
	--m-metadata-file taxClassifications.qza \
	--m-metadata-column Taxon \
	--p-mode 'sum' \
	--o-grouped-table freqTable_grouped.qza
echo "Grouped frequency table output to study directory"

echo "Generating grouped table visual"
qiime feature-table summarize \
	--i-table freqTable_grouped.qza \
	--o-visualization freqTable_grouped.qzv
echo "Visual artifact output to study directory"

echo ""
echo "Generating taxa barplot"
qiime taxa barplot \
	--i-table freqTable.qza \
	--i-taxonomy taxonomy.qza \
	--m-metadata-file meta.txt \
	--o-visualization taxa_barplot.qzv
echo "Barplot file created" 
echo "End of script"

end=$(date)
echo "End Time : $end"
echo "===================================================="
