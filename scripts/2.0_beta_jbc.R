# PERFORM JACCARD AND BRAY CURTIS TRANSFORMATIONS
# THIS SCRIPT ORIGINALLY CONTAINED UNIFRAC OPERATIONS.
# THESE HAVE SINCE BEEN MOVED TO QIIME2 FOR BETTER HANDLING OF PLACEMENT DISTRIBUTIONS. 
# INPUT: metadata and filtered sequences
# OUTPUT: one distance matrix per transformation/metric

rm(list=ls())

# load in libraries
library(vegan)
library(phyloseq)
library(tidyverse)

# Dr. Fodor's lognorm
lognorm <- function(table)
{
  avg <- sum(rowSums(table))/nrow(table)
  table <- sweep(table,1,rowSums(table),"/")
  table <- log10(table*avg + 1)
  return(table)
}

# input global vars
studyList <- c('ECAM','Jones','Noguera-Julian','Vangay','Zeller')

for (study in studyList) {
  # read in freq table, tree, metadata
  setwd(paste0('~/beta_diversity_testing/',study,'/'))
  print(paste(study,'start'))
  
  meta <- read.csv('meta.txt', sep='\t', row.names=1, header = TRUE, 
                   check.names = FALSE)
  data <- read.csv('filtered_table.txt', sep='\t', row.names = 1, header=TRUE, 
                   check.names = FALSE, skip =1) %>% t(.) %>% as.data.frame(.)
  
  # keep only shared indices
  shared.indices <- intersect(rownames(meta), rownames(data))
  meta <- meta %>% filter(rownames(meta) %in% shared.indices)
  data <- data %>% filter(rownames(data) %in% shared.indices)
  
  # normalize
  data <- lognorm(data)
  
  # generate distance matrices
  jaccard <- vegan::vegdist(data, method='jaccard') %>% as.matrix(.) %>%
    as.data.frame(.) %>% rownames_to_column(var = " ")
  bc <- vegan::vegdist(data, method = 'bray') %>% as.matrix(.)%>%
    as.data.frame(.) %>% rownames_to_column(var = " ")
  
  # save tables
  #write.table(data, 'lognorm_filtered_table.txt', sep='\t', row.names = TRUE)
  write.table(data, 'lognorm_filtered_table.txt', sep='\t', row.names = TRUE, col.names = NA, quote = FALSE)
  write.table(jaccard, 'distance_matrices/jaccard_distance_matrix.tsv', sep='\t', row.names = FALSE)
  write.table(bc, 'distance_matrices/bray_curtis_distance_matrix.tsv', sep='\t', row.names = FALSE)
  
  print(paste(study,'completed'))
}
