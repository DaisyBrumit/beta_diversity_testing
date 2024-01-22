# PERFORM CORE BETA-DIVERSITY TRANSFORMATIONS
# INCLUDES: JACCARD, BRAY-CURTIS, (UN)WEIGHTED UNIFRAC

rm(list=ls())

# load in libraries
library(vegan)
library(phyloseq)
library(tidyverse)
source('~/beta_diversity_testing/scripts/functions/pcoa_dataHandling.R')

# input global vars
studyList <- c('gemelli_ECAM','Jones','Noguera-Julian','Vangay','Zeller')

for (study in studyList) {
  # read in freq table, tree, metadata
  setwd(paste0('~/beta_diversity_testing/',study,'/'))
  print(paste(study,'start'))
  
  meta <- read.csv('meta.txt', sep='\t', row.names=1, header = TRUE, 
                   check.names = FALSE)
  tree <- phyloseq::read_tree('tree.nwk')
  data <- read.csv('filtered_table.txt', sep='\t', row.names = 1, header=TRUE, 
                   check.names = FALSE, skip =1) %>% t(.) %>% as.data.frame(.)
  
  # keep only shared indices
  shared.indices <- meta_match(meta, data)
  meta <- meta %>% filter(rownames(meta) %in% shared.indices)
  data <- data %>% filter(rownames(data) %in% shared.indices)
  
  # create phyloseq obj for unifrac transformation
  ps_obj <- phyloseq(otu_table(data, taxa_are_rows=FALSE), phy_tree(tree), sample_data(meta))
  
  # (for consistency with gemelli processes thru QIIME2)
  jaccard <- vegan::vegdist(data, method='jaccard') %>% as.matrix(.) %>%
    as.data.frame(.) %>% rownames_to_column(var = " ")
  bc <- vegan::vegdist(data, method = 'bray') %>% as.matrix(.)%>%
    as.data.frame(.) %>% rownames_to_column(var = " ")
  uni <- phyloseq::UniFrac(ps_obj, weighted = FALSE) %>% as.matrix(.)%>%
    as.data.frame(.) %>% rownames_to_column(var = " ")
  w.uni <- phyloseq::UniFrac(ps_obj, weighted = TRUE) %>% as.matrix(.)%>%
    as.data.frame(.) %>% rownames_to_column(var = " ")
  
  # save tables
  write.table(jaccard, 'distance_matrices/jaccard_distance_matrix.tsv', sep='\t', row.names = FALSE)
  write.table(bc, 'distance_matrices/bray_curtis_distance_matrix.tsv', sep='\t', row.names = FALSE)
  write.table(uni, 'distance_matrices/unweighted_unifrac_distance_matrix.tsv', sep='\t', row.names = FALSE)
  write.table(w.uni, 'distance_matrices/weighted_unifrac_distance_matrix.tsv', sep='\t', row.names = FALSE)
  
  print(paste(study,'completed'))
}
