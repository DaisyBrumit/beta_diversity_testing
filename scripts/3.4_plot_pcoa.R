# PLOT PCOA OUTPUT WITH PERCENT EXPLAINED LABELS

rm(list = ls())
library(vegan)
library(tidyverse)
source('~/beta_diversity_testing/scripts/functions/meta_from_files.R')
source('~/beta_diversity_testing/scripts/functions/dec_to_percent.R')
source('~/beta_diversity_testing/scripts/functions/parse_fromBiplot.R')

studyList <- c('Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'gemelli_ECAM')

# prep this study's pcoa plot file
plot_file <- '~/beta_diversity_testing/plots/pcoa_plots.pdf'
pdf(plot_file)

for (study in studyList) {
  setwd(paste0('~/beta_diversity_testing/',study,'/ordinations/'))
  getwd() # sanity check
  
  ### METADATA HANDLING: ONLY ONCE PER STUDY
  # read in metadata
  meta <- read.csv(paste0('~/beta_diversity_testing/',study,'/meta.txt'), 
                     sep = '\t', row.names = 1, header = TRUE, check.names = FALSE)
  char_cols <- meta %>% select(where(is.factor) | where(is.character)) %>%
    select(where(function(x) n_distinct(x) <= 6))
  
  
  # find all distance matrix files for this study
  files <- list.files(pattern = 'ordinations', recursive = FALSE)
  # need to run pcoa and plot for each file
  for (file in files){ 
    # using filename, save actual beta method as a string
    beta_method <- get_beta(file)
    ntaxa <- get_n_taxa(file)
    print(paste("Beta Method for", study, beta_method, ntaxa)) #sanity check
    
    if (beta_method %in% c('phylo_rpca', 'rpca')) {
      data <- parse_ords(file)
      
      prop_exp <- read.table(file, header=FALSE, sep='\t', check.names = FALSE,
                             skip = 4, nrows=1)
    } else if (beta_method %in% c('phylo_ctf', 'ctf')){
      next
    } else {
      # read in data as a table
      data <- read.table(file, header=TRUE, sep='\t')
      
      # row 1 contains proportion var explained
      prop_exp <- data[1,]
      data <- data[-1,] # we don't need prop explained here anymore
    }
    
    # isolate percent var explained and assign indices
    row.names(data) <- data[[1]] # assign dist matrix row names
    data <- data[,-1] # don't need index values as a column, either
    
    for (column in colnames(char_cols)) {
      # drop all rows where the specified feature is missing data
      meta <- meta[!is.na(meta[column]), ] 
      
      shared.indices <- intersect(rownames(meta), rownames(data))
      meta <- meta %>% filter(rownames(meta) %in% shared.indices)
      data <- data %>% filter(rownames(data) %in% shared.indices)
      
      # Create the scatter plot
      plot.table <- data.frame(MDS1=data$PC1, 
                               MDS2=data$PC2,
                               row.names=row.names(meta))
      plot.table[[column]] <- as.factor(meta[[column]]) 
      MDS1_pct <- paste('MDS1:', dec_to_percent(prop_exp[2])) # percent label
      MDS2_pct <- paste('MDS2:', dec_to_percent(prop_exp[3])) # percent label
      
      plot <- ggplot(plot.table, aes(x=MDS1, y=MDS2, color=plot.table[[column]])) +
        geom_point(size=2) + 
        #stat_ellipse() +
        labs(title = paste(study, beta_method, ntaxa, "PCOA Results"), 
             subtitle = paste("meta column = ", column), 
             color= column) +
        xlab(MDS1_pct) + 
        ylab(MDS2_pct)
      
      print(plot) 
    }
  }
}
dev.off()
