# PLOT PCOA OUTPUT WITH PERCENT EXPLAINED LABELS

rm(list = ls())
library(vegan)
library(tidyverse)
source('~/beta_diversity_testing/scripts/functions/meta_from_files.R')
source('~/beta_diversity_testing/scripts/functions/parse_fromBiplot.R')

studyList <- c('Jones', 'gemelli_ECAM')

# prep this study's pcoa plot file
plot_file <- '~/beta_diversity_testing/plots/pcoa_plots_ctf.pdf'
pdf(plot_file)

for (study in studyList) {
  setwd(paste0('~/beta_diversity_testing/',study,'/ordinations/'))
  getwd() # sanity check
  
  ### SET MAJOR PARAMETERS FOR PLOTTING INFO ###
  if (study == "gemelli_ECAM") {
    feature <- 'delivery' # this is the feature we'll color code by
    index <- 'host_subject_id' # repeat subject id 
    group <- 'month' # feature associated with replicate measures
    
  } else if (study == "Jones") {
    feature <- 'Genotype' # this is the feature we'll color code by
    index <- 'repeat_ID'  # repeat subject id
    group <- 'Visit' # feature associated with replicate measures
  }
  
  # find all metadata/ordination files for this study
  files <- list.files(pattern = 'ctf_ords', recursive = FALSE)
  
  # need to run pcoa and plot for each file
  for (file in files){ 
    
    # using filename, save actual beta method as a string
    beta_method <- get_beta(file)
    ntaxa <- get_n_taxa(file)
    print(paste("Beta Method for", study, beta_method, ntaxa)) #sanity check
    
    # proportion explained is in line 5 of the biplot file
    prop_exp_file <- paste0(beta_method,'_ordinations_fromBiplot.tsv')
    prop_exp <- read.table(prop_exp_file, header=FALSE, sep='\t', check.names = FALSE,
                           skip = 4, nrows=1)
    # retrieve data
    data.with.meta <- read.table(file, sep = '\t', check.names = FALSE, header = TRUE, 
                     comment.char = '')
    
    # GENERAL PLOT #
    # create labels
    MDS1.lab <- paste("MDS1:",as.character(round(prop_exp[2], digits=4))) # print first 4 decimals
    MDS2.lab <- paste("MDS2:",as.character(round(prop_exp[3], digits=4))) # print first 4 decimals
    
    PC_plot_sso <- ggplot(data.with.meta, aes(x=PC1, y=PC2, color=.data[[feature]])) +
      geom_point(size=2) + 
      labs(title = paste(study, beta_method, ntaxa, "PCOA RESULTS"), 
           subtitle = paste("meta feature = ", feature), 
           color = feature) +
      xlab(MDS1.lab) + 
      ylab(MDS2.lab)
    
    print(PC_plot_sso)
    
    # PLOT OVER GROUP #
    PCGroup_plot_sso <- ggplot(data.with.meta, aes(x=.data[[group]], 
                              y=PC1, color=.data[[feature]])) +
      geom_point(size=2) + 
      labs(title = paste(study, beta_method, ntaxa, "PCOA RESULTS"), 
           subtitle = paste("meta feature = ", feature), 
           color = feature) +
      xlab(group) + 
      ylab(MDS1.lab)
    
    print(PCGroup_plot_sso)
    
    
    # PLOT FOR PC AXES VIA BIPLOT #
    # read in metadata %>% select only relevant info %>% remove redundant rows
    meta.standalone <- read.csv(paste0('~/beta_diversity_testing/',study,'/meta.txt'), 
                                sep = '\t', header = TRUE, check.names = FALSE) %>%
      select(index, feature) %>% distinct()
    row.names(meta.standalone) <- meta.standalone[[index]]
    
    data.biplot <- parse_ords(prop_exp_file) # df from biplot, NOT state sub ordination
    
    PC_plot_biplot <- ggplot(data.biplot, aes(x=PC1, y=PC2, color=meta.standalone[[feature]])) +
      geom_point(size=2) + 
      labs(title = paste(study, beta_method, ntaxa, "PCOA RESULTS"), 
           subtitle = paste("meta feature = ", feature), 
           color = feature) +
      xlab(MDS1.lab) + 
      ylab(MDS2.lab)
    
    print(PC_plot_biplot)
  }
}
dev.off()
