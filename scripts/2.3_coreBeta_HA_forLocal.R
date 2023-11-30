# PERFORM CORE BETA-DIVERSITY TRANSFORMATIONS
# INCLUDES: JACCARD, BRAY-CURTIS, (UN)WEIGHTED UNIFRAC
# SPECIFIC TO HIGH ABUNDANCE TAXA SETS
# REQUIRES 1 MANUAL INPUT "study"

# load in libraries
library(vegan)
library(phyloseq)
library(tidyverse)

# input global vars
rm(list=ls())
study <- 'Zeller'

# read in tree
setwd(paste0('~/beta_diversity_testing/',study,'/high_abundance/'))

tree <- phyloseq::read_tree('../tree.nwk')

# need to execute tasks for all HA tables
for(n in c('2','3','4','5','10')) {
  # refresh meta each time for labeling reasons (me being lazy)
  meta <- read.csv('../refiltered_meta.txt', sep='\t', header = TRUE, row.names = 1, 
                   check.names = FALSE)
  
  # set file name based on n taxa
  fileIn <- paste0('top_',n,'_table.txt')
  
  data <- read.csv(fileIn, sep='\t', row.names = 1, header=TRUE, 
                   check.names = FALSE) %>% t(.) %>% as.data.frame(.)
  
  # add step for HA data to remove completely empty entries
  sums <- rowSums(data)
  data <- data[sums > 0, ]
  
  # create phyloseq obj for unifrac transformation
  ps_obj <- phyloseq(otu_table(data, taxa_are_rows=FALSE), phy_tree(tree), sample_data(meta))
  
  # (for consistency with gemelli processes thru QIIME2)
  jaccard <- vegan::vegdist(data, method='jaccard') %>% as.matrix(.) 
  bc <- vegan::vegdist(data, method = 'bray') %>% as.matrix(.)
  uni <- phyloseq::UniFrac(ps_obj, weighted = FALSE) %>% as.matrix(.)
  w.uni <- phyloseq::UniFrac(ps_obj, weighted = TRUE) %>% as.matrix(.)
  
  # save tables
  write.table(jaccard, paste0('../distance_matrices/jaccard_distance_matrix_',n,'.tsv'), sep='\t', row.names = FALSE)
  write.table(bc, paste0('../distance_matrices/bray_curtis_distance_matrix_',n,'.tsv'), sep='\t', row.names = FALSE)
  write.table(uni, paste0('../distance_matrices/unweighted_unifrac_distance_matrix_',n,'.tsv'), sep='\t', row.names = FALSE)
  write.table(w.uni, paste0('../distance_matrices/weighted_unifrac_distance_matrix_',n,'.tsv'), sep='\t', row.names = FALSE)
}
