# PERFORM CORE BETA-DIVERSITY TRANSFORMATIONS
# INCLUDES: JACCARD, BRAY-CURTIS, (UN)WEIGHTED UNIFRAC

# load in libraries
library(vegan)
library(phyloseq)
library(tidyverse)

rm(list=ls()) # clear workspace

# accept external arguments
args <- commandArgs(trailingOnly = TRUE)
study <- args[1]
ntaxa <- args[2]

fileIn <- paste0('high_abundance/top_',ntaxa,'_table.txt')

setwd(paste0('~/beta_diversity_testing/',study,'/'))
  
meta <- read.csv('refiltered_meta.txt', sep='\t', row.names=1, header = TRUE, 
                 check.names = FALSE)
tree <- phyloseq::read_tree('tree.nwk')


data <- read.csv('refiltered_table.txt', sep='\t', row.names = 1, header=TRUE, 
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
write.table(jaccard, paste0('distance_matrices/jaccard_distance_matrix_',ntaxa,'.tsv'), sep='\t', row.names = FALSE)
write.table(bc, paste0('distance_matrices/bray_curtis_distance_matrix_',ntaxa,'.tsv'), sep='\t', row.names = FALSE)
write.table(uni, paste0('distance_matrices/unweighted_unifrac_distance_matrix_',ntaxa,'.tsv'), sep='\t', row.names = FALSE)
write.table(w.uni, paste0('distance_matrices/weighted_unifrac_distance_matrix_',ntaxa,'.tsv'), sep='\t', row.names = FALSE)
