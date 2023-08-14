# PERFORM PERMANOVA ON ALL BETA DIVERSITY DISTANCE MATRICES

library(vegan)
library(tidyverse)

# take in arguments from cml
#arg <- commandArgs(trailingOnly = TRUE)
#study <- arg[1]
#beta <- arg[2]

# beta metrics
study <- 'Jones'
beta.list <- c('bray_curtis', 'jaccard', 'unweighted_unifrac', 'weighted_unifrac',
               'ctf', 'phylo_ctf')
#if (study == 'Jones')
#  beta.list <- append(beta.list, c('ctf', 'phylo_ctf'))
#else beta.list <- append(beta.list, c('rpca', 'phylo_rpca'))

# init psuedo-F
scores <- tibble(beta = character(), psuedoF = numeric(), pval = numeric())

for (beta in beta.list) {
  # import data
  dist <- read.table(paste0(study,'/',beta,'_distance_matrix.tsv'), 
                            header=TRUE, sep='\t') %>% dplyr::rename('sampleid' = 'X')
  
  meta <- read.table(paste0(study,'/meta.txt'), header = TRUE, sep='\t')
  
  full.table <- dplyr::inner_join(meta, dist, by='sampleid')
  meta.cols <- full.table %>% select(colnames(meta))
  dist.matrix <- full.table %>% select(all_of(.[['sampleid']])) %>% as.dist()
  
  # init psuedo-F
  #scores <- tibble(beta = character(), psuedoF = numeric(), pval = numeric())
  
  for (i in 2:length(colnames(meta.cols))){
    test.obj <- vegan::adonis2(dist.matrix ~ meta.cols[[i]], meta.cols, permutations = 999, 
                               na.action = na.omit)
    scores <- scores %>% add_row(., beta = beta, psuedoF = test.obj$F[1], pval = test.obj$`Pr(>F)`[1])
  }
}

write_csv(scores, paste0(study,'/permanova_results.csv'), col_names=TRUE)


