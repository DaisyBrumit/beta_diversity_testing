# beta_diversity_testing
project dedicated to testing phylogenetically aware beta diversity metrics proposed by Rob Knight's lab ([publication link](https://pubmed.ncbi.nlm.nih.gov/35477286/))

## Repository Navigation
This repository is organized by 2 main categories: general scripts and study-specific content. The `scripts` directory contains scripts meant for general use by all or some studies used in this project. They contain slurm/bash, R, and python scripts (potentially to later include java). Other directories are named for studies by their authors' surnames. Contents of each are detailed below. All .sh (SLURM) scripts are meant to be run from the HPC cluster but can be repurposed for general use to run from a local command line. 

The scripts are meant to be run from a directory that is 1 position above any directory that will hold *all* study-specific content. When any shell script accepts a <target directory> argument, this directory should always point to the study-specific directory. For all examples, assume I am working from a fiel system organized as shown below, where `working directory` is where all automated scripts are stored, `greengenes` is where gg reference data is stored, and `my_study` is where all files related to the "my_study" study is stored. 

![image](https://user-images.githubusercontent.com/82405964/231242766-c6f1a68c-16df-489b-9273-ddcb8b39cf56.png)

### Scripts
**0_ref_to_Q2.sh**

Import reference sequence and taxonomy data into qiime artifacts for downstream use. NOT CURRENTLY IN USE AS DIFFERENT REFERENCE METHODS ARE EXECUTED IN SCRIPT `2_insertionTree_Q2.sh `
- input: reference taxonomy file (tab separated textfile)
- input: reference sequence file (fasta format)
- input: reference tree file (newick format)
- output: `refSeqs.qza` qiime2 FeatureTable[Sequence] artifact for sequences to target directory
- output: `refTaxonomy.qza` FeatureTable[Taxonomy] artifact for taxonomy to target directory

To run: `sbatch 0_ref_to_Q2.sh <target directory> <reference sequence file> <reference taxonomy file> <reference tree file>`

Example: `sbatch 0_ref_to_Q2.sh my_study/ greengene/99_otus.fasta greengene/99_otu_taxonomy.txt greengene/99_otus.tree`

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
Example: `sbatch 1_myData_to_Q2.sh my_study dada2seqs.fa dada2_forward_reads.txt metadata.txt`

**2_classify_Q2.sh**

Create study specific taxonomy file based on reference input from step 0 and query input from step 1. This classification process uses qiime's `classify-consensus-blast` option, which uses blast+. After taxonomy is created, group orginal count data by taxonomy and re-label features accourdingly. This grouping will be achieved by summing up frequencies as the current iteration uses absolute counts, not relative counts. Create visual artifacts for the taxonomy and the new frequency table.
- input: `refSeqs.qza` `refTaxonomy.qza` `seqTable.qza`
- output: `taxonomy.qza` qiime2 `FeatureData[Taxonomy]' artifact
- output: `taxa_barplot.qzv` visual artifact for viewing taxonomy data
- output `freqTable_grouped.qza` `freqTable_grouped.qzv` new FeatureTable[Frequency] artifact with taxa as labels (and visual)

To run: Note that this script pulls files from 2 locations: the reference directory and the study-specific directory, and all input files have been generated with **pre-assigned** names from previous scripts. Therefore, running this (and subsequent) scripts will generally be as easy as specifying directories. Run command `sbatch 2_classify_Q2.sh <target directory> <reference directory>`.

**3_importTree_filterFreq_Q2.sh**

Read in a tree (reference or self-built), filter the current frequency/count table using the tree, then generate visual output of new freq table
- input: some tree file, whether from a reference or self-built. **If this tree is not in the sample directory, cml argument 1 needs to be input as an absolute path, not a relative path**
- input: `meta.txt` `freqTable_grouped.qza`
- output: `tree.qzv` qiime Phylogeny[Rooted] artifact
- output: `freqTable_filtered.qza` `freqTable_filtered.qzv` another FeatureTable[Frequeny] artifact of the now-filtered counts (and visual)

To run: `sbatch 3_betaDiversityValues_Q2.sh <absolute path to tree> <study directory>`

**4_betaDiversityValues_Q2.sh**

Generate diversity statistics using a wide variety of metrics through qiime.
- input: `freqTable_filtered.qza` `meta.txt` `tree.qza`
- parameter: associated sampling depth. Read more about selecting the appropriate value [here](https://docs.qiime2.org/2018.6/tutorials/moving-pictures/#moving-pics-diversity) and use `freqTable.qzv` as a guide for your own data.
- output: `core-metrics-results` a whole directory of output values and visuals for all metrics included in this suite

To run: `sbatch 4_importTree_filterFreq_Q2.sh <study directory> <sampling depth>`

## General workflow through QIIME2.2021.2

![image](https://user-images.githubusercontent.com/82405964/228918280-571541da-0d71-42a2-990a-90d6d4b9d5e7.png)

