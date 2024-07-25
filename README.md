# beta_diversity_testing
Comparing abilities of various beta diversity methods to resolve phenotype in 16s metagenomic applications

Toggle below for a brief overview of each major script's function and it's inputs/outputs.

<details>
<summary>## 0: Preprocessing</summary>

### 0.0_dada_to_fasta.sh 
- input: DADA 2 output ASV table (as .txt)
- output: fasta file with asv's as sequences

### 0.1_dada2biom.sh 
- input: DADA 2 output ASV table (as .txt)
- output: DADA 2 output ASV table (as .biom)
</details>

<details>
<summary>## 1 Trees</summary>

### 1.0_qiimeImport.sh
Basic imports of count, sequence, and metadata to qiime artifacts
- input:
  - dada_table.biom
  - dada_seqs.fa
  - meta.txt
- output:
  - freqTable.qza & v (count table and visual)
  - seqTable.qza & v (sequence information)
  - meta.qzv (visual of attached metadata)
 
### 1.1_insertionTree.sh
Build a tree based on the greengenes tree as a reference (not de novo). Then filter out the counts table so it only includes mapped sequences.
- input:
  - seqTable.qza
  - sepp-refs-gg-13-8.qza (reference tree)
  - meta.txt
- output:
  - insertionTree.qza
  - filtered_table.qza
  - discarded_table.qza
 
### 1.2_qiimeExport.sh
Export qiime artifacts
- input:
  - insertionTree.qza
  - table.qza
  - filtered_table.qza
- output: same file names but with .txt or .nwk extensions. 
</details>

<details>
<summary>## 2: Beta transformations</summary>

### 2.0_beta_jbc.R
Makes distances matrices for distance metrics jaccard & bray curtis. 
- input: meta.txt, filtered_table.txt for each study
- output: *metric*_distance_matrix.tsv for each core metric

### 2.1_beta_unifracs_local.sh
Makes distances matrices for distance metrics weighted & unweighted unifrac. 
- input: filtered_table.txt, tree.nwk for each study
- output: *metric*_distance_matrix.tsv for each core metric

### 2.2_beta_gemelli_*.sh
Two versions: one  for local use and one for HPC cluster use.
- additional arguments: method (ctf or rpca). If method == ctf: state and repeat id
- input: filtered_table.qza, tree.nwk for each study. If method == ctf: also includes meta.txt
- output: *metric*_distance_matrix.tsv for each gemelli metric

### 2.3_qiimeExport_*.sh
Two versions: one  for local use and one for HPC cluster use.
- input: qiime versions of distance matrices and ordinations
- output: tsv files of the same
</details>

<details>
<summary>## 3: Ordinations and PERMANOVA</summary>

### 3.0_pcoa.py
Performs pcoa on all non-gemelli methods and parses gemelli method outputs to standardized format so all ordination data is uniform across studies.
- input: distance matrices for every transformation
- output: ordinations for every transormation

### 3.1_permanova.*
Runs PERMANOVA on all distance matrices (R script). The shell script simply runs the R script on the cluster.
- input: distance matrices for every transformation
- output: permanova_results.tsv for each study
</details>
  
<details>
<summary>## 4: ML and posthoc</summary>

### 4.0_ML_handler.py
Runs machine learning algorithms knn and random forest (handled separately in the `functions/` directory) for features in each set of ordinations and the raw data for each study.
- input: *metric*_ordinations.tsv for each study and beta method, metadata
- output: 3 tsv files per study capturing accuracy, roc, and r2 values.

### 4.1_krwallis_posthoc.py
Performs post hoc analysis on machine learning output
- input: output from 4.0_ML_handler
- output: post hoc pairwsie comparisons as well as general KW test output
</details>

<details>
<summary>## 5 & S: Additional</summary>

Header 5 denotes plotting scripts.
Header "S" denotes scratch scripts that may or may not be utilized in final drafting stages.
</details>
