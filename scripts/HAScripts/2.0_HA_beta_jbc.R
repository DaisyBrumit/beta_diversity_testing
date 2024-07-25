# PERFORM CORE BETA-DIVERSITY TRANSFORMATIONS
# INCLUDES: JACCARD, BRAY-CURTIS, (UN)WEIGHTED UNIFRAC

rm(list=ls())

# load in libraries
library(vegan)
library(phyloseq)
library(tidyverse)
source('~/beta_diversity_testing_almost_final/scripts/functions/pcoa_dataHandling.R')

# THIS SCRIPT ORIGINALLY CONTAINED UNIFRAC OPERATIONS. 
# THESE HAVE SINCE BEEN MOVED TO QIIME2 FOR BETTER HANDLING OF PLACEMENT DISTRIBUTIONS

# input global vars
studyList <- c('ECAM','Jones','Noguera-Julian','Vangay','Zeller')

for (study in studyList) {
  # read in freq table, tree, metadata
  setwd(paste0('~/beta_diversity_testing_almost_final/',study,'/HA/'))
  print(paste(study,'start'))
  
  files <- list.files(pattern = 'table.txt', recursive = FALSE)
  
  meta <- read.csv('../meta.txt', sep='\t', row.names=1, header = TRUE, 
                   check.names = FALSE)
  
  for (file in files) {
    n = str_split(file, '_')[[1]][2]
    
    data <- read.csv(file, sep='\t', row.names = 1, header=TRUE, 
                     check.names = FALSE) %>% t(.) %>% as.data.frame(.)
    
    # keep only shared indices
    shared.indices <- meta_match(meta, data)
    meta <- meta %>% filter(rownames(meta) %in% shared.indices)
    data <- data %>% filter(rownames(data) %in% shared.indices)
  
    # (for consistency with gemelli processes thru QIIME2)
    jaccard <- vegan::vegdist(data, method='jaccard') %>% as.matrix(.) %>%
      as.data.frame(.) %>% rownames_to_column(var = " ")
    bc <- vegan::vegdist(data, method = 'bray') %>% as.matrix(.)%>%
      as.data.frame(.) %>% rownames_to_column(var = " ")
    
    # save tables
    write.table(jaccard, paste0('distance_matrices/jaccard_',n,'_distance_matrix.tsv'), sep='\t', row.names = FALSE)
    write.table(bc, paste0('distance_matrices/bray_curtis_',n,'_distance_matrix.tsv'), sep='\t', row.names = FALSE)
    
    print(paste(study, n, 'completed'))
    }
  print(paste(study,'completed'))
}
