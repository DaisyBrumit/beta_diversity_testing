# beta_diversity_testing
project dedicated to testing phylogenetically aware beta diversity metrics proposed by Rob Knight's lab ([publication link](https://pubmed.ncbi.nlm.nih.gov/35477286/))

## Repository Navigation
This repository is organized by 2 main categories: general scripts and study-specific content. The `scripts` directory contains scripts meant for general use by all or some studies used in this project. They contain slurm/bash, R, and python scripts (potentially to later include java). Other directories are named for studies by their authors' surnames. Contents of each are detailed below. All .sh (SLURM) scripts are meant to be run from the HPC cluster but can be repurposed for general use to run from a local command line. 

In practice, the scripts are meant to be run from in command line with a directory that is 1 position above any directory that will hold *all* study-specific content. When any shell script accepts a <target directory> argument, this directory should always point to the study-specific directory. For all examples, assume I am working from a fiel system organized as shown below, where `working directory` is where all automated scripts are stored, `greengenes` is where gg reference data is stored, and `my_study` is where all files related to the "my_study" study is stored. All .sh scripts are written for use with a SLURM scheduler.

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
- input: dada2 count table (or some other count table recognized by qiime)in BIOM format
- input: fasta file with sequences found in count table **(if not supplied, there is a script to deal with this)**
- input: tsv/txt file with associated metadata
- output: `freqTable.qza` & `freqTable.qzv` qiime2 FeatureTable[Frequency] type and visual
- output: `seqTable.qza` & `seqTable.qzv` qiime2 FeatureData[Sequence] type and visual
- output: `meta.qzv` visual artifact for metadata
- output: `meta.txt` a renamed replica of the orignal metadata file (if not already named as such) to reduce need for extra input arguments in future scripts

To run: `sbatch 1_myData_to_Q2.sh <directory path> <sequence file> <count data file> <metadata file>`

Example: `sbatch 1_myData_to_Q2.sh my_study/ my_study/dada2seqs.fa my_study/dada2_forward_reads.biom my_study/metadata.txt`

**2_insertionTree_Q2.sh**

Create a study-specific tree by using a preconstructed tree from greengenes. This process uses Qiime2's `fragment-insertion` plugin and will let us build a tree based on a vetted reference instead of building one from scratch and hoping for the best. 

- inputs: `seqTable.qza` & greengenes reference database (provided by Qiime2, already loaded as a Qiime artifact)
- outputs: `insertionTree.qza` `insertionPlacements.qza` study specific tree and a fragment placement map to that tree.
  
Filter frequency table (study) features to only include those included in the new tree

- inputs: `freqTable.qza` `insertionTree.qza` `meta.txt`
- output: `filtered_table.qza` `filtered_table.qzv` frequency table with retained (filtered) features (and visual)
- output: `discarded_table.qza` `discarded_table.qzv` frequency table with features that were discarded for not overlapping with the tree (and visual)

To run: `sbatch 2_insertionTree_Q2.sh <target directory>`

**3_coreBetaValues_Q2.sh**

Generate diversity metrics using a qiime's core diversity function.
- input: `insertionTree.qza` `filtered_table.qza` `meta.txt`
- parameter: associated sampling depth. Read more about selecting the appropriate value [here](https://docs.qiime2.org/2018.6/tutorials/moving-pictures/#moving-pics-diversity) and use `freqTable.qzv` as a guide for your own data.
- output: `core-metrics-results` a whole directory of output values and visuals for all metrics included in this suite. Each output will include files for bray curtis, jaccard, and weighted/unweighted unifrac distances.
   - `<metric>_distance_matrix.qza` corresponds to table output `<metric>_distance_matrix.tsv`
   - `<metric>_pcoa_results.qza` corresponds to table output `<metric>_pcoa_results.txt`
   - `<metric>_emperor.qzv` contains a qiime visualization of emperor (pcoa) plots by each metadata field in the dataset.

To run: `sbatch 3_importTree_filterFreq_Q2.sh <target directory> <sampling depth>`

**DADA_to_fasta.py**

Generates a fasta file where the sequences are *also* the headers for studies where fasta files are not a given or sequence space is preferred. Achieved by reading in headers from a dada2 output file where headers are sequences. The resulting fasta file can be used in qiime later.

- input: DADA2 file path
- output: fasta file

To run: access via `run_DADA_to_fasta.sh` with the following command

`sbatch run_DADA_to_fasta.sh <path to DADA2 file> <desired output path>`

## General workflow through QIIME2.2021.2

![beta_diversity_flowchart](https://user-images.githubusercontent.com/82405964/233413461-1596e980-e877-458f-b807-b677937e8ff1.png)

