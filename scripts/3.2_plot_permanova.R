# PLOT PSUEDO-F VALUES ACROSS STUDIES

rm(list=ls())
library(tidyverse)

studyList <- c('Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'gemelli_ECAM')
qiimeList <- c('phylo_rpca', 'rpca', 'ctf', 'phylo_ctf')

plot_file <- '~/beta_diversity_testing/plots/psuedoF_plots.pdf'
pdf(plot_file)

# create a whole table for summary info
full.table <- tibble(beta = character(), psuedoF = numeric(), pval = numeric(), 
                     ntaxa = factor(), study = character(), log_psuedoF = numeric())

for (study in studyList) {
  
  setwd(paste0('~/beta_diversity_testing/',study))
  getwd() # sanity check
  
  study.table <- read.table(paste0('./permanova/permanova_results.tsv'), header = TRUE)
  study.table$study <- study
    
  # make ntaxa reflect gemelli
  study.table$ntaxa <- as.character(study.table$ntaxa)
  study.table <- study.table %>% mutate(ntaxa = ifelse(beta %in% qiimeList, 'gemelli', ntaxa))
  study.table$ntaxa <- factor(study.table$ntaxa, 
                                levels=c('all', 'gemelli', '2','3','4','5','8','10'))
  
  # make a log transformed version of F stat
  study.table$log_psuedoF = log10(study.table$psuedoF + 1)
    
  # append study table to full table
  full.table <- full.table %>% bind_rows(., study.table)
  
  # study specific plot with "fill" by beta
  studyplot.fill <- ggplot(study.table, aes(x=ntaxa, y=psuedoF, fill=beta)) +
    geom_boxplot() +
    labs(title = paste(study,"PsuedoF"), 
         subtitle = "Whole data vs HA taxa") +
    theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
          plot.title = element_text(size=10, face = 'bold'))
  
  log.studyplot.fill <- ggplot(study.table, aes(x=ntaxa, y=log_psuedoF, fill=beta)) +
    geom_boxplot() +
    labs(title = paste(study,"log10 PsuedoF"), 
         subtitle = "Whole data vs HA taxa") +
    theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
          plot.title = element_text(size=10, face = 'bold'))
  
  # study specific plot without beta fill
  studyplot.nofill <- ggplot(study.table, aes(x=ntaxa, y=psuedoF)) +
    geom_boxplot() +
    labs(title = paste(study,"PsuedoF"), 
         subtitle = "Whole data vs HA taxa") +
    theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
          plot.title = element_text(size=10, face = 'bold'))
  
  print(studyplot.fill)
  print(log.studyplot.fill)
  print(studyplot.nofill)
  
}

# meta plot (all studies) with and without fill (same as study plots above)
fullplot.fill <- ggplot(full.table, aes(x=ntaxa, y=psuedoF, fill=beta)) +
  geom_boxplot() +
  labs(title = paste("PsuedoF: All Studies"), 
       subtitle = "Whole data vs HA taxa") +
  theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
        plot.title = element_text(size=10, face = 'bold'))

log.fullplot.fill <- ggplot(full.table, aes(x=ntaxa, y=log_psuedoF, fill=beta)) +
  geom_boxplot() +
  labs(title = paste("log10 PsuedoF: All Studies"), 
       subtitle = "Whole data vs HA taxa") +
  theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
        plot.title = element_text(size=10, face = 'bold'))

fullplot.nofill <- ggplot(full.table, aes(x=ntaxa, y=psuedoF)) +
  geom_boxplot() +
  labs(title = paste("PsuedoF: All Studies"), 
       subtitle = "Whole data vs HA taxa") +
  theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
        plot.title = element_text(size=10, face = 'bold'))

print(fullplot.fill)
print(log.fullplot.fill)
print(fullplot.nofill)

dev.off()

