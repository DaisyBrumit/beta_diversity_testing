# beta_diversity_testing
project dedicated to testing phylogenetically aware beta diversity metrics proposed by Rob Knight's lab ([publication link](https://pubmed.ncbi.nlm.nih.gov/35477286/))

## Repository Navigation
This repository is organized by 2 main categories: general scripts and study-specific content. The `scripts` directory contains scripts meant for general use by all or some studies used in this project. They contain slurm/bash, R, and python scripts (potentially to later include java). Other directories are named for studies by their authors' surnames. Contents of each are detailed below. All .sh (SLURM) scripts are meant to be run from the HPC cluster but can be repurposed for general use to run from a local command line. 

### Scripts
**0_ref_to_Q2.sh**
- input: reference taxonomy file (tab separated textfile)
- input: reference sequence file (fasta format)
- output: `refSeqs.qza` qiime2 FeatureTable[Sequence] artifact for sequences
- output: `refTaxonomy.qza` FeatureTable[Taxonomy] artifact for taxonomy

To run: `sbatch 0_ref_to_Q2.sh <path to taxonomy file> <path to sequence file> <path to output directory>`

Example: It is recommended that all reference information stay in one directory. For example, for the Jones study, I used greengenes via [qiime resources page](https://docs.qiime2.org/2018.2/data-resources/#greengenes-16s-rrna) and kept all of the associated information in a directory called `greengene`. Thus, to run this script from one directory *above* my reference directory, I ran command 

`sbatch 0_ref_to_Q2.sh greengene/99_otu_taxonomy.txt greengene/99_otus.fasta greengene/`

**1_myData_to_Q2.sh**
- input: dada2 count table (or some other count table recognized by qiime)
- input: fasta file with sequences found in count table **(if not supplied, there is a script to deal with this)**
- output: `freqTable.qza` qiime2 FeatureTable[Frequency] type
- output: seqTable.qza` qiime2 FeatureTable[Sequence] type

## General workflow through QIIME2.2021.2
0) Upload reference taxonomy and sequences as QIIME (Q2) artifacts.
