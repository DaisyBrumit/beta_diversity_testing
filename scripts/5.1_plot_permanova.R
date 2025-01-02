# PLOT PSUEDO-F VALUES ACROSS STUDIES

rm(list=ls())
library(tidyverse)
source('~/beta_diversity_testing/scripts/functions/plotting_functions.R')

studyList <- c('Zeller', 'Vangay', 'Noguera-Julian', 'Jones', 'Ruiz-Calderon')
read.study.permanova <- function(path) {

  tmp.table <- read.table(path, header = TRUE)
  tmp.table$study <- str_replace(study, "_", " ")

  # make a log transformed version of F stat
  tmp.table$log_psuedoF = log10(tmp.table$psuedoF + 1)

  # fill color by significance
  tmp.table$signif <- case_when(tmp.table$pval < 0.05 ~ "**",
                                tmp.table$pval < 0.1 ~ "*", TRUE ~ "")

  return(tmp.table)
}

plot_file <- '~/beta_diversity_testing/plots/psuedoF_plots.pdf'
pdf(plot_file)

# create a whole table for summary info
full.table <- tibble(beta = character(), psuedoF = numeric(), pval = numeric(), 
                      study = character(), log_psuedoF = numeric())
full.shuffle <- tibble(beta = character(), psuedoF = numeric(), pval = numeric(),
                      study = character(), log_psuedoF = numeric(), iteration=numeric())

for (study in studyList) {
  
  setwd(paste0('~/beta_diversity_testing/',study))
  getwd() # sanity check

  # study specific plot with "fill" by beta
  study.table <- read.study.permanova(path = paste0('./permanova/permanova_results.tsv'))
  study.table$beta <- str_replace(study.table$beta, "_", " ")
  study.table <- study.table %>% filter(!beta %in% c('ctf', 'phylo ctf'))
  
  study.plot <- f.plot.study(study.table, title = paste(study,"PsuedoF"))
  print(study.plot)

  # append study table to full table
  full.table <- full.table %>% bind_rows(., study.table)

  # make table for shuffled results
  study.shuffle <- read.study.permanova(path = paste0('./permanova/permanova_results_shuffled.tsv'))
  study.shuffle$beta <- str_replace(study.shuffle$beta, "_", " ")
  
  full.shuffle <- full.shuffle %>% bind_rows(., study.shuffle)
}
# set orders

# meta plots (all studies)
plot <- f.plot.multi(full.table, title = 'PERMANOVA F stats')
print(plot)

#specific add in: remove extreme outlier in Ruiz-Calderon
study.table <- study.table %>% filter(psuedoF < 5000)
full.table <- full.table %>% filter(psuedoF < 5000)

dev.off()

# shuffled permanova plots

shuffle_plot_file <- '~/beta_diversity_testing/plots/psuedoF_plots_shuffled.pdf'
pdf(shuffle_plot_file)

full.shuffle$log_pval <- log10(full.shuffle$pval + 0.000001)
plt <- ggplot(full.shuffle, aes(x=beta, y=pval)) +
  geom_boxplot() +
  geom_point(aes(color=study), alpha = 0.6, size = 0.5,
             position = position_jitter(width = 0.15, height = 0)) +
  scale_color_brewer(palette="Set1") +
  theme_minimal() +
  theme(axis.text = element_text(size=12),
        axis.title = element_text(size=12, face = 'bold'),
        axis.text.x = element_text(angle = 90, vjust = 0.7),
        #legend.title=element_blank(),
        #legend.text = element_blank()) +
        legend.text = element_text(size=12),
        legend.title = element_text(size=12, face = 'bold')) +
  labs(x='Beta', y='Pseudo-F Value', color="Study")
print(plt)

# unique beta values
beta_values <- unique(full.shuffle$beta)

# plot for each beta value
for (beta_value in beta_values) {
  x <- full.shuffle %>% filter(beta == beta_value)
  
  plt <- ggplot(x, aes(x = psuedoF)) +
    geom_histogram() +
    labs(title = beta_value)
  print(plt)
}

dev.off()

