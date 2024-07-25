# PLOT PSUEDO-F VALUES ACROSS STUDIES

rm(list=ls())
library(tidyverse)

studyList <- c('Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'ECAM')
qiimeList <- c('phylo_rpca', 'rpca', 'ctf', 'phylo_ctf')

plot_file <- '~/beta_diversity_testing_almost_final/plots/psuedoF_plots.pdf'
pdf(plot_file)

# create a whole table for summary info
full.table <- tibble(beta = character(), psuedoF = numeric(), pval = numeric(), 
                      study = character(), log_psuedoF = numeric())

for (study in studyList) {
  
  setwd(paste0('~/beta_diversity_testing_almost_final/',study))
  getwd() # sanity check
  
  study.table <- read.table(paste0('./permanova/permanova_results.tsv'), header = TRUE)
  study.table$study <- str_replace(study, "_", " ")
  
  # make a log transformed version of F stat
  study.table$log_psuedoF = log10(study.table$psuedoF + 1)
    
  # append study table to full table
  full.table <- full.table %>% bind_rows(., study.table)
  
  # fill color by significance
  study.table$signif <- case_when(study.table$pval < 0.05 ~ "**", 
                                  study.table$pval < 0.1 ~ "*", TRUE ~ "")
  
  # study specific plot with "fill" by beta
  studyplot <- ggplot(study.table, aes(x=beta, y=psuedoF)) +
    geom_boxplot() +
    geom_point() +
    scale_color_brewer(palette="Dark2") +
    geom_text(aes(label=signif),color = "red") +
    labs(title = paste(study,"PsuedoF")) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 30, vjust = 0.7))
  
  #log.studyplot <- ggplot(study.table, aes(x=beta, y=log_psuedoF)) +
    #geom_boxplot() +
    #labs(title = paste(study,"log10 PsuedoF"), 
     #    subtitle = "Whole data vs HA taxa") +
    #theme_minimal() +
    #theme(axis.text.x = element_text(angle = 30, vjust = 0.7))
  
  print(studyplot)
  #print(log.studyplot)
}

# meta plot (all studies) with and without fill (same as study plots above)
fullplot <- ggplot(full.table, aes(x=beta, y=psuedoF)) +
  geom_boxplot() +
  geom_point(aes(color=study)) +
  scale_color_brewer(palette="Dark2") +
  #labs(title = paste("PsuedoF: All Studies")) +
  theme_minimal() +
  theme(axis.text = element_text(size=14),
        axis.title = element_text(size=14, face = 'bold'),
        axis.text.x = element_text(angle = 30, vjust = 0.7),
        legend.text = element_text(size=14),
        legend.title = element_text(size=14, face = 'bold')) +
  labs(x='Beta Metric', y='Pseudo-F Value', color='Study')

#log.fullplot <- ggplot(full.table, aes(x=beta, y=log_psuedoF)) +
  #geom_boxplot() +
  #geom_point(aes(color=study)) +
  #labs(title = paste("log10 PsuedoF: All Studies"), 
       #subtitle = "Whole data vs HA taxa") +
  #theme_minimal() +
  #theme(axis.text.x = element_text(angle = 30, vjust = 0.7),
        #legend.title = element_blank(),
        #axis.title.x = element_blank())

print(fullplot)
#print(log.fullplot)


dev.off()

