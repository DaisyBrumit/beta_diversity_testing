# PLOTTING BETA DIVERSITY ACCURACY OVER PC AXES
# AUTHORED BY DAISY FRY BRUMIT

library(tidyverse) # for ggplot and df maipulations
library(gridExtra) # for outputting plots as pdf
library(naniar)
library(reshape2)

# Set global vars
#beta_div <- c('bray_curtis', 'dada2', 'jaccard', 'phylo_rpca', 'phylo_ctf', 'rpca',
              #'ctf', 'unweighted_unifrac', 'weighted_unifrac')

rootDir <- '/Users/dfrybrum/beta_diversity_testing/' # path to working dir
study <- 'Vangay' # all studies (also Directories!)
metric <- 'Accuracy' # all performace metrics

# set function for importing custom named dataframes
df_import <- function(metric_string, nPC) {
  #df <- read_tsv(paste0(study,'/',metric_string,'_table.txt'))
  df_name <- paste0(study,nPC)
  df_in <- read_tsv(paste0(study,'/',metric_string,'_table_',nPC,'.txt'))
  
  df_out <- assign(df_name, df)
  return(df_out)
}

for (i in 3:10)
{
  df_import(str_to_lower(metric), i)
}