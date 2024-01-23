# PLOT PSUEDO-F VALUES ACROSS STUDIES

rm(list=ls())
library(tidyverse)

studyList <- c('Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'gemelli_ECAM')
qiimeList <- c('phylo_rpca', 'rpca', 'ctf', 'phylo_ctf')

plot_file <- '~/beta_diversity_testing/plots/psuedoF_plots.pdf'
pdf(plot_file)

# create a whole table for summary info
full.table <- tibble(beta = character(), psuedoF = numeric(), pval = numeric(), 
                     study = character(), log_psuedoF = numeric())

for (study in studyList) {
  setwd(paste0('~/beta_diversity_testing/',study))
  getwd() # sanity check
  
  # read in study table
  study.table <- read.table(paste0('./permanova/permanova_results.tsv'), header = TRUE)
  study.table$study <- study
  
  # make a log transformed version of F stat
  study.table$log_psuedoF = log10(study.table$psuedoF + 1)
  
  # append study table to full table
  full.table <- full.table %>% bind_rows(., study.table)
  
  # study specific plot: beta x F stat
  study.plot <- ggplot(study.table, aes(x=beta, y=psuedoF)) +
    geom_boxplot() +
    labs(title = paste(study,"PsuedoF"), 
         subtitle = "Whole data") +
    theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
          plot.title = element_text(size=10, face = 'bold'))
  
  print(study.plot)
}

# cross-study plot: beta x F stat
full.plot <- ggplot(full.table, aes(x=beta, y=psuedoF)) +
  geom_boxplot() +
  labs(title = paste("PsuedoF: All Studies"), 
       subtitle = "Whole data") +
  theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
        plot.title = element_text(size=10, face = 'bold'))

print(full.plot)
dev.off()