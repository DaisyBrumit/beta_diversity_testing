#scratch for month and gemelli

rm(list=ls())
library(vegan)
library(tidyverse)

# meta_from_files: isolates metadata from filenames
source('~/beta_diversity_testing/scripts/functions/meta_from_files.R')

studyList <- c('ECAM')
qiimeList <- c('phylo_rpca', 'phylo_ctf')

for (study in studyList) {
  setwd(paste0('~/beta_diversity_testing/',study,'/distance_matrices'))
  getwd() # sanity check
  
  # init psuedo-F
  scores <- tibble(beta = character(), psuedoF = numeric(), pval = numeric(), month=factor())
  
  ### METADATA HANDLING: ONLY ONCE PER STUDY
  # read in metadata
  meta_init <- read.csv('../meta.txt', sep='\t', header = TRUE, 
                        check.names = FALSE) 
  
  meta_init$sampleid <- meta_init$`#SampleID`
  meta_init <- meta_init %>% dplyr::select(., c('sampleid', 'delivery', 'month'))
  
  # find all dist output files for this study
  files <- list.files(pattern = 'distance_matrix', recursive = FALSE)
  
  for(file in files){
    # using filename, save actual beta method as a string
    beta_method <- get_beta(file)  # isolate beta metric from filename
    #if (beta_method %in% qiimeList) {
      #ntaxa <= 'gemelli'} else { ntaxa <- get_n_taxa(file)}
    print(paste("Beta Method for", study, "=", beta_method)) #sanity check
    
    data <- read.table(file, header=TRUE, sep='\t', row.names = 1, check.names = FALSE)
    
    # In certain circumstances, unweighted unifrac returns NaN values. Remove problem samples.
    nan_indices <- colnames(data)[colSums(is.na(data)) > 0]
    data <- data[setdiff(row.names(data), nan_indices), setdiff(colnames(data), nan_indices)]
    
    meta <- meta_init %>% filter(meta_init$sampleid %in% rownames(data)) %>%
      filter(month != 19)
    
    months <- levels(as.factor(meta$month))
    
    for (m in months) {
      # Subset meta for the current month
      meta_tmp <- meta[meta$month == m, ]
      
      # Subset data based on SampleID
      data_tmp <- data[meta_tmp$sampleid, meta_tmp$sampleid]
      
      test.obj <- vegan::adonis2(data_tmp ~ meta_tmp$delivery, meta, permutations = 999, 
                                 na.action = na.omit)
      scores <- scores %>% add_row(., 
                                   beta = beta_method, psuedoF = test.obj$F[1], pval = test.obj$`Pr(>F)`[1], month=m)
      
    }
  }
  write_delim(scores, paste0('~/beta_diversity_testing/',study,'/permanova/ctfSpec_permanova_results.tsv'), col_names=TRUE, delim='\t')
}



