# PERFORM PERMANOVA ON ALL BETA DIVERSITY MATRICES

rm(list=ls())
library(vegan)
library(tidyverse)
set.seed(89)

# meta_from_files: isolates metadata from filenames
source('~/beta_diversity_testing/scripts/functions/meta_from_files.R')

studyList <- c('Ruiz-Calderon', 'Jones', 'Vangay', 'Noguera-Julian', 'Zeller')
qiimeList <- c('phylo_rpca', 'rpca')

for (study in studyList) {
  setwd(paste0('~/beta_diversity_testing/',study,'/distance_matrices'))
  getwd() # sanity check
  
  # init psuedo-F
  scores <- tibble(beta = character(), psuedoF = numeric(), pval = numeric(), 
                   iteration = numeric())
  
  ### METADATA HANDLING: ONLY ONCE PER STUDY
  # read in metadata
  meta_init <- read.csv('../meta.txt', sep='\t', header = TRUE, 
                        check.names = FALSE) 
  
  # find all dist output files for this study
  files <- list.files(pattern = 'distance_matrix', recursive = FALSE)
  
  for(file in files){
    # using filename, save actual beta method as a string
    beta_method <- get_beta(file)  # isolate beta metric from filename
    print(paste("Beta Method for", study, "=", beta_method))
    
    # read in data
    data <- read.table(file, header=TRUE, sep='\t', row.names = 1, check.names = FALSE)
    
    # In certain circumstances, unweighted unifrac returns NaN values. Remove problem samples.
    nan_indices <- colnames(data)[colSums(is.na(data)) > 0]
    
    data <- data[setdiff(row.names(data), nan_indices), setdiff(colnames(data), nan_indices)]
    meta <- meta_init %>% filter(meta_init$sampleid %in% rownames(data))
    
    for (run in 1:15){
      for (i in 2:length(colnames(meta))){
        if (length(unique(meta[[i]])) <= 1){
          next
        } else {
          meta[[i]] <- sample(meta[[i]])
          test.obj <- vegan::adonis2(data ~ meta[[i]], meta, permutations = 999, 
                                     na.action = na.omit)
          scores <- scores %>% add_row(., 
                                       beta = beta_method, psuedoF = test.obj$F[1], 
                                       pval = test.obj$`Pr(>F)`[1], iteration = run)
          print(paste(study, beta_method, run, test.obj$F[1]))
        }
      } 
    }
  }
  write_delim(scores, paste0('~/beta_diversity_testing/',study,'/permanova/permanova_results_shuffled.tsv'), col_names=TRUE, delim='\t')
}

