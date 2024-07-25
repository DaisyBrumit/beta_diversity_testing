# PERFORM PERMANOVA ON ALL BETA DIVERSITY MATRICES

rm(list=ls())
library(vegan)
library(tidyverse)

# meta_from_files: isolates metadata from filenames
source('~/beta_diversity_testing_almost_final/scripts/functions/meta_from_files.R')

studyList <- c('ECAM', 'Jones', 'Vangay', 'Noguera-Julian', 'Zeller')
qiimeList <- c('phylo_rpca', 'phylo_ctf', 'rpca', 'ctf')

for (study in studyList) {
  setwd(paste0('~/beta_diversity_testing_almost_final/',study,'/distance_matrices'))
  getwd() # sanity check
  
  # init psuedo-F
  scores <- tibble(beta = character(), psuedoF = numeric(), pval = numeric())
  
  ### METADATA HANDLING: ONLY ONCE PER STUDY
  # read in metadata
  meta_init <- read.csv('../meta.txt', sep='\t', header = TRUE, 
                                check.names = FALSE) 
  
  # I only use the delivery variable from ECAM data
  if(study=='ECAM'){
    meta_init$sampleid <- meta_init$`#SampleID`
    meta_init <- meta_init %>% dplyr::select(., c('sampleid', 'delivery'))
  }
  
  # find all dist output files for this study
  files <- list.files(pattern = 'distance_matrix', recursive = FALSE)
  
  for(file in files){
    # using filename, save actual beta method as a string
    beta_method <- get_beta(file)  # isolate beta metric from filename
    #if (beta_method %in% qiimeList) {
      #ntaxa <= 'gemelli'} else { ntaxa <- get_n_taxa(file)}
    #print(paste("Beta Method for", study, "=", beta_method, ntaxa)) #sanity check
    print(paste("Beta Method for", study, "=", beta_method))
    
    data <- read.table(file, header=TRUE, sep='\t', row.names = 1, check.names = FALSE)
    
    # In certain circumstances, unweighted unifrac returns NaN values. Remove problem samples.
    nan_indices <- colnames(data)[colSums(is.na(data)) > 0]
    data <- data[setdiff(row.names(data), nan_indices), setdiff(colnames(data), nan_indices)]
    
    meta <- meta_init %>% filter(meta_init$sampleid %in% rownames(data))

    for (i in 2:length(colnames(meta))){
      test.obj <- vegan::adonis2(data ~ meta[[i]], meta, permutations = 999, 
                                 na.action = na.omit)
      scores <- scores %>% add_row(., 
                  beta = beta_method, psuedoF = test.obj$F[1], pval = test.obj$`Pr(>F)`[1])
      
      }
    }
    write_delim(scores, paste0('~/beta_diversity_testing_almost_final/',study,'/permanova/permanova_results.tsv'), col_names=TRUE, delim='\t')
}


  
