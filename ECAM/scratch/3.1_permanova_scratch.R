# PERFORM PERMANOVA ON ALL BETA DIVERSITY MATRICES

rm(list=ls())
library(vegan)
library(tidyverse)

# meta_from_files: isolates metadata from filenames
source('~/beta_diversity_testing/scripts/functions/meta_from_files.R')

studyList <- c('gemelli_ECAM')
qiimeList <- c('phylo_rpca', 'phylo_ctf', 'rpca', 'ctf')

for (study in studyList) {
  setwd(paste0('~/beta_diversity_testing/',study,'/scratch'))
  getwd() # sanity check
  
  # init psuedo-F
  scores <- tibble(beta = character(), psuedoF = numeric(), pval = numeric())
  
  ### METADATA HANDLING: ONLY ONCE PER STUDY
  # read in metadata
  meta_init <- read.csv('../meta.txt', sep='\t', header = TRUE, 
                                check.names = FALSE) 
  
  # I only use the delivery variable from ECAM data
  if(study=='gemelli_ECAM'){
    meta_init$sampleid <- meta_init$`#SampleID`
    meta_init <- meta_init %>% dplyr::select(., c('sampleid', 'delivery', 'month'))
    meta_init <- meta_init %>% filter(!(month %in% c(0, 15, 19)))
  }
  
  # find all dist output files for this study
  files <- list.files(pattern = 'distance_matrix.tsv', recursive = TRUE)
  
  for(file in files){
    # using filename, save actual beta method as a string
    beta_method <- get_beta(file)  # isolate beta metric from filename
    #if (beta_method %in% qiimeList) {
    #  ntaxa <= 'gemelli'} else { ntaxa <- get_n_taxa(file)}
    print(paste("Beta Method for", study, "=", beta_method)) #sanity check
    
    data <- read.table(file, header=TRUE, sep='\t', row.names = 1, check.names = FALSE)
    
    # In certain circumstances, unweighted unifrac returns NaN values. Remove problem samples.
    nan_indices <- colnames(data)[colSums(is.na(data)) > 0]
    data <- data[setdiff(row.names(data), nan_indices), setdiff(colnames(data), nan_indices)]
    
    meta <- meta_init %>% filter(meta_init$sampleid %in% rownames(data)) %>% group_by(month)
    meta_groups <- split(meta, meta$month)
    
    for (month_group in meta_groups) {
      if (nrow(month_group) < 2) {
        next
      }
      filtered_data <- data %>%
        filter(rownames(.) %in% month_group$sampleid) %>%
        select(month_group$sampleid)
      
      test.obj <- vegan::adonis2(filtered_data ~ delivery, month_group, permutations = 999, 
                                 na.action = na.omit)
          
        # Append the results to 'scores'
        scores <- scores %>% add_row(beta = beta_method, 
                                       psuedoF = test.obj$F[1], 
                                       pval = test.obj$`Pr(>F)`[1])
        }
    }
    write_delim(scores, paste0('~/beta_diversity_testing/',study,'/scratch/permanova_results.tsv'), col_names=TRUE, delim='\t')
}

plot <- ggplot(scores, aes(x=beta, y=psuedoF)) +
  geom_boxplot() +
  labs(title = paste(study,"PsuedoF")) +
  theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
        plot.title = element_text(size=10, face = 'bold'))
print(plot)  
