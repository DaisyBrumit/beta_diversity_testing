### 0
## 0.0_dada_to_fasta.sh 
- input: DADA 2 output ASV table (as .txt)
- output: fasta file with asv's as sequences

## 0.1_dada2biom.sh 
- input: DADA 2 output ASV table (as .txt)
- output: DADA 2 output ASV table (as .biom)

### 1
## 1.0_qiimeImport.sh
Basic imports of count, sequence, and metadata to qiime artifacts
- input:
  - dada_table.biom
  - dada_seqs.fa
  - meta.txt
- output:
  - freqTable.qza & v (count table and visual)
  - seqTable.qza & v (sequence information)
  - meta.qzv (visual of attached metadata)
 
## 1.1_insertionTree.sh
Build a tree based on the greengenes tree as a reference (not de novo). Then filter out the counts table so it only includes mapped sequences.
- input:
  - seqTable.qza
  - sepp-refs-gg-13-8.qza (reference tree)
  - meta.txt
- output:
  - insertionTree.qza
  - filtered_table.qza
  - discarded_table.qza
 
## 1.2_qiimeExport.sh
