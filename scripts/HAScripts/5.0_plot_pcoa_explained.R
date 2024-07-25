# COMPARE PERCENT EXPLAINED VARIANCE WITH PCOA 

rm(list=ls())
library(vegan)
library(tidyverse)
source('~/beta_diversity_testing_almost_final/scripts/functions/meta_from_files.R')

studyList <- c('ECAM', 'Jones', 'Vangay', 'Noguera-Julian', 'Zeller')
qiimeList <- c('phylo_rpca', 'phylo_ctf', 'rpca', 'ctf')

pdf("~/beta_diversity_testing_almost_final/plots/HA_v_gemelli.pdf")
# define file reader
process_filename <- function(filename) {
  # Step 1: Remove "gemelli_comps/" if it exists
  clean_filename <- gsub("^gemelli_comps/", "", filename)
  
  # Step 2: Extract the integer and convert it to a factor "nTaxa"
  if (grepl("_\\d+_", clean_filename)) {
    nTaxa <- as.character(gsub(".*_([0-9]+)_ordinations.tsv$", "\\1", clean_filename))
  } else {
    nTaxa <- "all"
  }
  
  # Step 3: Extract the substring before the integer or "_ordinations"
  beta <- ifelse(grepl("_\\d+_", clean_filename),
                 gsub("(_[0-9]+_ordinations.tsv)$", "", clean_filename),
                 gsub("(_ordinations.tsv)$", "", clean_filename))
  
  # Return a list with beta and nTaxa
  return(list(beta = beta, nTaxa = nTaxa))
}

for (study in studyList) {
  setwd(paste0('~/beta_diversity_testing_almost_final/',study,'/HA/ordinations/'))
  getwd() # sanity check
  
  df <- tibble(study=character(),beta=character(),n.taxa=character(),PC1.Exp=numeric())
  
  # find all output files for this study
  files <- list.files(pattern = 'ordinations.tsv', recursive = TRUE)
  for (file in files) {
    fileInfo <- process_filename(file) # get beta method and ntaxa
    df.tmp <- read.table(file, header=TRUE, sep='\t', row.names = 1, check.names = FALSE)
    df <- add_row(df, study=study, beta=fileInfo[[1]], n.taxa=fileInfo[[2]], 
                  PC1.Exp=df.tmp[1,1])
  }
  
  df$n.taxa <- factor(df$n.taxa, levels=c('2','3','4','5','6','7','8','9','10','all'))
  
  # Filter out rows where n.taxa is "all" for the line plot
  df_line <- df %>% filter(n.taxa != "all")
  
  # Create a separate dataset for the horizontal lines
  df_hline <- df %>% filter(n.taxa == "all")
  
  # Create the plot
  plt <- ggplot() +
    # Add the line plot for n.taxa 2-10
    geom_line(data = df_line, aes(x = n.taxa, y = PC1.Exp, color = beta, group = beta)) +
    geom_point(data = df_line, aes(x = n.taxa, y = PC1.Exp, color = beta)) +
    # Add horizontal lines for n.taxa "all"
    geom_hline(data = df_hline, aes(yintercept = PC1.Exp, color = beta), linetype = "dashed") +
    scale_color_brewer(palette="Dark2") +
    labs(title = study) +
    theme_minimal() +
    theme(axis.text = element_text(size=14),
          legend.text = element_text(size=14),
          axis.title = element_blank())
  print(plt)
}
dev.off()
