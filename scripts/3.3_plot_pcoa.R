# PLOT PCOA OUTPUT WITH PERCENT EXPLAINED LABELS

rm(list = ls())
library(vegan)
library(tidyverse)
source('~/beta_diversity_testing/scripts/functions/meta_from_files.R')


studyList <- c('Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'gemelli_ECAM')

# prep this study's pcoa plot file
plot_file <- '~/beta_diversity_testing/plots/pcoa_plots.pdf'
pdf(plot_file)

for (study in studyList) {
  setwd(paste0('~/beta_diversity_testing/',study,'/ordinations/'))
  getwd() # sanity check
  
  ### METADATA HANDLING: ONLY ONCE PER STUDY
  # read in metadata
  meta <- read.csv(paste0('~/beta_diversity_testing/',study,'/refiltered_meta.txt'), 
                     sep = '\t', row.names = 1, header = TRUE, check.names = FALSE)
  char_cols <- names(meta)[sapply(meta, function(col) is.character(col) || is.factor(col))]
  
  # find all distance matrix files for this study
  files <- list.files(pattern = 'ordinations.tsv', recursive = FALSE)
  # need to run pcoa and plot for each file
  for (file in files){ 
    
    # using filename, save actual beta method as a string
    beta_method <- get_beta(file)
    ntaxa <- get_n_taxa(file)
    print(paste("Beta Method for", study, beta_method, ntaxa)) #sanity check
    
    # read in data as a table
    data <- read.table(file, header=TRUE, sep='\t')
    
    # row 1 contains proportion var explained
    prop_exp <- data[1,]
    
    # isolate percent var explained and assign indices
    row.names(data) <- data[[1]] # assign dist matrix row names
    data <- data[-1,] # we don't need prop explained here anymore
    data <- data[,-1] # don't need index values as a column, either
    
    data <- log10(data+1)
    
    for (column in char_cols) {
      # drop all rows where the specified feature is missing data
      meta <- meta[!is.na(meta[column]), ] 
      
      # meta and data must share id's 
      shared.indices <- intersect(rownames(meta), rownames(data))
      data <- data %>% filter(rownames(data) %in% shared.indices)
      meta <- meta %>% filter(rownames(meta) %in% shared.indices)
      
      # Create the scatter plot
      plot.table <- data.frame(MDS1=data$PC1, 
                               MDS2=data$PC2,
                               row.names=row.names(meta))
      plot.table[[column]] <- as.factor(meta[[column]])
      x.lab <- paste("MDS1:",as.character(round(prop_exp[2], digits=4))) # print first 4 decimals
      y.lab <- paste("MDS2:",as.character(round(prop_exp[3], digits=4))) # print first 4 decimals
      
      plot <- ggplot(plot.table, aes(x=MDS1, y=MDS2, color=plot.table[[column]])) +
        geom_point(size=2) + 
        #stat_ellipse() +
        labs(title = paste(study, beta_method, ntaxa, "log 10 PCOA RESULTS"), 
             subtitle = paste("meta column = ", column), 
             fill=plot.table[[column]]) +
        xlab(x.lab) + 
        ylab(y.lab)
      
      print(plot) 
    }
  }
}
dev.off()
