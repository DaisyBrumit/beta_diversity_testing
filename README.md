# beta_diversity_testing
project dedicated to testing phylogenetically aware beta diversity metrics proposed by Rob Knight's lab ([publication link](https://pubmed.ncbi.nlm.nih.gov/35477286/))

## Repository Navigation
This repository is organized by 2 main categories: general scripts and study-specific content. The `scripts` directory contains scripts meant for general use by all or some studies used in this project. They contain slurm/bash, R, and python scripts (potentially to later include java). Other directories are named for studies by their authors' surnames. Contents of each are detailed below. All .sh (SLURM) scripts are meant to be run from the HPC cluster but can be repurposed for general use to run from a local command line. 

### Scripts
**0_ref_to_Q2.sh**

Import reference sequence and taxonomy data into qiime artifacts for downstream use
- input: reference taxonomy file (tab separated textfile)
- input: reference sequence file (fasta format)
- output: `refSeqs.qza` qiime2 FeatureTable[Sequence] artifact for sequences
- output: `refTaxonomy.qza` FeatureTable[Taxonomy] artifact for taxonomy

To run: `sbatch 0_ref_to_Q2.sh <directory path> <reference taxonomy file> <reference sequence file>`

Example: It is recommended that all reference information stay in one directory. For example, for the Jones study, I used greengenes via [qiime resources page](https://docs.qiime2.org/2018.2/data-resources/#greengenes-16s-rrna) and kept all of the associated information in a directory called `greengene`. Thus, to run this script from one directory *above* my reference directory, I ran command 

`sbatch 0_ref_to_Q2.sh greengene/ 99_otu_taxonomy.txt 99_otus.fasta`

**1_myData_to_Q2.sh**

Import sequence, meta-, and count data into qime artifacts for downstream use.
- input: dada2 count table (or some other count table recognized by qiime)
- input: fasta file with sequences found in count table **(if not supplied, there is a script to deal with this)**
- input: tsv/txt file with associated metadata
- output: `freqTable.qza` & `freqTable.qzv` qiime2 FeatureTable[Frequency] type and visual
- output: `seqTable.qza` & `seqTable.qzv` qiime2 FeatureData[Sequence] type and visual
- output: `meta.qzv` visual artifact for metadata
- output: `meta.txt` a renamed replica of the orignal metadata file (if not already named as such) to reduce need for extra input arguments in future scripts

To run: `sbatch 1_myData_to_Q2.sh <directory path> <sequence file> <count data file> <metadata file>`

**2_classify_Q2.sh**

Create study specific taxonomy file based on reference input from step 0 and query input from step 1. This classification process uses qiime's `classify-consensus-blast` option, which uses blast+.
- input: `refSeqs.qza` `refTaxonomy.qza` `seqTable.qza`
- output: `taxonomy.qza` qiime2 [FeatureData[Taxonomy]' artifact

To run: Note that this script pulls files from 2 locations: the reference directory and the study-specific directory, and all input files have been generated with **pre-assigned** names from previous scripts. Therefore, running this (and subsequent) scripts will generally be as easy as specifying directories. Run command `sbatch 2_classify_Q2.sh <target directory> <reference directory>`.

**2p5_visualTaxonomy_Q2.sh**

Create barplot(s) corresponding to newly created taxonomy. Think of this as step "2.5" that I chose to run in a separate script because step 2 takes a while.
- input: `freqTable.qza` `taxonomy.qza` `meta.txt`
- output: `taxa_barplot.qzv` visual artifact for viewing taxonomy data

To run: `sbatch 2p5_visualTaxonomy_Q2.sh <target directory>`

## General workflow through QIIME2.2021.2
0) Upload reference taxonomy and sequences as QIIME (Q2) artifacts.
