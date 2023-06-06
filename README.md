# beta_diversity_testing
project dedicated to testing phylogenetically aware beta diversity metrics proposed by Rob Knight's lab ([publication link](https://pubmed.ncbi.nlm.nih.gov/35477286/))

## Repository Navigation
This repository is organized by 2 main categories: general scripts and study-specific content. The `scripts` directory contains scripts meant for general use by all or some studies used in this project. Other directories are named for studies by their authors' surnames. Contents of each are detailed below. All .sh (SLURM) scripts are meant to be run using a SLURM scheduler but can be repurposed for general use to run from a local command line. 

Scripts are meant to be run from command line with a directory that is 1 position above the `scripts` and study-specific directories. When any shell script accepts a <target directory> argument, this directory should always point to the study-specific directory. For all examples, assume I am working from a file system organized as shown below, where `working directory` is where I type my commands, `scripts` is where I access scripts, and `my_study` is where all files related to the "my_study" study is stored. 

![image](https://drive.google.com/file/d/1gpcj66d58pinCzOCUGS3Da6clFd--Vp0/view?usp=share_link)

### Scripts
**1_myData_to_Q2.sh**

Import sequence, meta-, and count data into qime artifacts for downstream use.
- inputs: 
  - dada2 count table in BIOM format. To convert to biom format, reference `dada_to_biom.sh` in the supplemental scripts directory.
  - fasta file with sequences found in count table. If not supplied, reference `dada_to_fasta.py` in the supplemental scripts directory.
  - tsv/txt file with associated metadata
- outputs: 
  - `freqTable.qza` & `freqTable.qzv` qiime2 FeatureTable[Frequency] type and visual
  - `seqTable.qza` & `seqTable.qzv` qiime2 FeatureData[Sequence] type and visual
  - `meta.qzv` visual artifact for metadata
  - `meta.txt` a renamed replica of the orignal metadata file for uniform input to future scripts

To run: `sbatch scripts/1_myData_to_Q2.sh <directory path> <sequence file> <count data file> <metadata file>`

Example: `sbatch scripts/1_myData_to_Q2.sh my_study/ my_study/dada2seqs.fa my_study/dada2_forward_reads.biom my_study/metadata.txt`

**2_insertionTree_Q2.sh**

Create a study-specific tree by using a preconstructed tree from greengenes. This process uses Qiime2's `fragment-insertion` plugin and will let us build a tree based on a vetted reference instead of building one from scratch and hoping for the best. 

- inputs: `seqTable.qza` & greengenes reference database (provided by Qiime2, already loaded as a Qiime artifact)
- outputs: `insertionTree.qza` `insertionPlacements.qza` study specific tree and a fragment placement map to that tree.
  
Filter frequency table (study) features to only include those included in the new tree

- inputs: `freqTable.qza` `insertionTree.qza` `meta.txt`
- outputs: 
  - `filtered_table.qza` `filtered_table.qzv` frequency table with retained (filtered) features (and visual)
  - `discarded_table.qza` `discarded_table.qzv` frequency table with features that were discarded for not overlapping with the tree (and visual)

To run: `sbatch scripts/2_insertionTree_Q2.sh <target directory>`

**3_coreBetaValues_Q2.sh**

Generate diversity metrics using a qiime's core diversity function.
- inputs: `insertionTree.qza` `filtered_table.qza` `meta.txt`
- parameter: associated sampling depth. Read more about selecting the appropriate value [here](https://docs.qiime2.org/2018.6/tutorials/moving-pictures/#moving-pics-diversity) and use `freqTable.qzv` as a guide for your own data.
- outpust: `core-metrics-results` a whole directory of output values and visuals for all metrics included in this suite. Each output will include files for bray curtis, jaccard, and weighted/unweighted unifrac distances.
   - `<metric>_distance_matrix.qza` corresponds to table output `<metric>_distance_matrix.tsv`

To run: `sbatch scripts/3_importTree_filterFreq_Q2.sh <target directory> <sampling depth>`
  
**4_gemelliBetaValues_Q2.sh**
 
Generate diversty metrics using gemelli's phylogenetically aware approach, as well as phylogenetically naive equivalents. For repeated-measures design, use `ctf` options, otherwise, use `rpca` options.

For RPCA
- inputs: `filtered_table.qza` `insertionTree.qza`
  - ctf only: also `meta.txt`
- outputs: `<metric>_distance_matrix.tsv` for both relevant metrics

To run rpca: `sbatch scripts/4_gemelliBetaValues_Q2.sh <target directory> rpca`

To run ctf: `sbatch scripts/4_gemelliBetaValues_Q2.sh <target directory> ctf <repeat id> <state of interest>` where repeat id is the column name in metadata the represents repeated sample ids, and state of interest represents some metadata column that contains categorical information of interest. These addtional parameters are not of supreme importance as we will conduct pcoa ourselves downstream for *every* feature of interest, but they are required arguments in the gemell plugin for qiime.

**6_beta_visuals.R**

Generate summary plots of random forest performance metrics.
- input: for *each* study, `accuracy_table_<component count>.txt`, `roc_auc_table_<component count>.txt`, `r2_table_<component count>.txt`
   - for example, for study "my study" where random forest was run with 3 PCoA axes, the accuracy input table will read `accuracy_table_3PC.txt`
- output: `beta_div_comp_plots.pdf` a single PDF with plots of beta diversity performance across all studies, plots within studies across features, and plots for each feature per study. This is, obviously, a lot of information, so all plots are printed from most to least information, so meta summaries are at the top of the file.
  
**DADA_to_fasta.py**

Generates a fasta file where the sequences are *also* the headers for studies where fasta files are not a given or sequence space is preferred. Achieved by reading in headers from a dada2 output file where headers are sequences. The resulting fasta file can be used in qiime later.

- input: DADA2 file path
- output: fasta file

To run: access via `run_DADA_to_fasta.sh` with the following command

`sbatch run_DADA_to_fasta.sh <path to DADA2 file> <desired output path>`

## General workflow through QIIME2.2021.2

![beta_diversity_flowchart(2)](https://user-images.githubusercontent.com/82405964/233413946-73e1ae99-cc6a-44fd-867b-92f4d388b265.png)

## Notes to self regarding future script integrations

- `generic_pylo_trans_out.sh` should be integrated into `4_gemelliBetaValues.sh` to convert gemelli FeatureTable[Frequency] artifact into a .biom table to a .tsv file. 

- `packageComps.py` calls from `randForest.py` and (ideally...) `permanova.py` to fetch actual performance metrics, tabulate them neatly, and then export for visuals creation in R package. Thus, consider renaming script (later) to `5_betaCompare.py` or something similarly descriptive and label the accessory scripts as such.

- final script step name: `6_visualGeneration.R`. Try to get all visuals out of one script. Shouldn't be too hard.
  
