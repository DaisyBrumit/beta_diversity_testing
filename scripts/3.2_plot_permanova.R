# PLOT PSUEDO-F VALUES ACROSS STUDIES

rm(list=ls())
library(tidyverse)

studyList <- c('Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'gemelli_ECAM')
qiimeList <- c('phylo_rpca', 'rpca', 'ctf', 'phylo_ctf')

plot_file <- '~/beta_diversity_testing/plots/psuedoF_plots.pdf'
pdf(plot_file)

# create a whole table for summary info
full.table <- tibble(beta = character(), psuedoF = numeric(), pval = numeric(), 
                    study = character())

for (study in studyList) {
  
  setwd(paste0('~/beta_diversity_testing/',study))
  getwd() # sanity check
  
  study.table <- read.table(paste0('./permanova/permanova_results.tsv'), header = TRUE)
  study.table$study <- study
  
  # make a log transformed version of F stat
  #study.table$log_psuedoF = log10(study.table$psuedoF + 1)
    
  # append study table to full table
  full.table <- full.table %>% bind_rows(., study.table)
  
  # study specific plot
  study_plot <- ggplot(study.table, aes(x=beta, y=psuedoF)) +
    geom_boxplot() +
    labs(title = paste(study,"PsuedoF"), 
         subtitle = '') +
    theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
          plot.title = element_text(size=10, face = 'bold'))
  
  #log.studyplot <- ggplot(study.table, aes(x=beta, y=log_psuedoF)) +
    #geom_boxplot() +
    #labs(title = paste(study,"log10 PsuedoF"), 
     #    subtitle = "Whole data vs HA taxa") +
    #theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
     #     plot.title = element_text(size=10, face = 'bold'))
  
  print(study_plot)
  
}

# meta plot (all studies) with and without fill (same as study plots above)
full_plot <- ggplot(full.table, aes(x=beta, y=psuedoF)) +
  geom_boxplot() +
  geom_point(aes(color=study))
  labs(title = paste("PsuedoF: All Studies"), 
       color = "Study") +
  theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
        plot.title = element_text(size=10, face = 'bold'))

print(full_plot)

dev.off()

