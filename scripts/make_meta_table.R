# CREATE FULL DATASET FOR MACHINE LEARNING COMPARISON PLOTS
# AUTHORED BY DAISY FRY BRUMIT

# load required packages
library(tidyverse) # for ggplot and df maipulations
#library(gridExtra) # for outputting plots as pdf
#library(naniar)
#library(reshape2)
source('~/beta_diversity_testing/scripts/plotting_functions.R')

# set global vars and directories
rootDir <- '~/beta_diversity_testing/' # path to working dir
file_pattern <- "table_[3456789]|_all|_raw.txt"

full.table <- data.frame(method = character(), feature = character(),
                         values = numeric(), study = character(), ml_method = character(),
                         ml_metric = character(), pc_axes = character())

# read in tables
for (file in list.files(path = rootDir, pattern = file_pattern, recursive = TRUE)) {
  # import file and basic filtering
  df.tmp <- read.table(paste0(rootDir,file), header = TRUE)
  df.tmp <- filter.na.cols(df.tmp)
  
  # average performance metric values per feature
  df.tmp <- df.tmp %>% group_by(method) %>% summarise(across(everything(), mean, na.rm=TRUE))
  
  # expand to long format (collapse all features into a value and name column)
  df.tmp <- df.tmp %>% mutate(id = row_number()) %>% 
    pivot_longer(cols = !contains('method'), names_to = "feature", values_to = "values") %>%
    filter(feature != 'id')
  
  # extract metadata from file path
  file.strings <- unlist(strsplit(file, '/'))
  file.strings[4] <- unlist(strsplit(file.strings[3], '_'))[1] # isolate ml performance metric
  file.strings[5] <- unlist(strsplit(file.strings[3], '_'))[3] # get pc axis count plus '.txt'
  file.strings[5] <- unlist(strsplit(file.strings[5], '[.]'))[1] # remove '.txt'
  
  # add metadata to df.tmp as features
  df.tmp$study <- file.strings[1]
  df.tmp$ml_method <- file.strings[2]
  df.tmp$ml_metric <- file.strings[4]
  df.tmp$pc_axes <- file.strings[5]
  
  # append data from this file to cumulative table
  full.table <- full.table %>% add_row(., df.tmp)
}

write_csv(full.table, paste0(input_dir,'permanova_rpca_maxIteration.txt'), sep='\t', col_names=TRUE)
