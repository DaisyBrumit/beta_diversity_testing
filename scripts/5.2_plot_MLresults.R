# PLOT ML Method performance
# key terms:
# ml_label == string version of ml_method for plot labels (random forest, knn)
# beta == beta_diversity method used (bray curtis, jaccard, etc)
# metric == ml performance metric used (accuracy, r2, roc)
# score == the numeric value associated with metric (either raw or averaged)

rm(list=ls())
library(tidyverse)
library(naniar)
source('~/beta_diversity_testing/scripts/functions/meta_from_files.R')
source('~/beta_diversity_testing/scripts/functions/plotting_functions.R')

studyList <- c('Zeller', 'Vangay', 'Noguera-Julian', 'Ruiz-Calderon', 'Jones')
ml_method <- 'rf'
if (ml_method == 'rf') {ml_label <- 'random forest'}

plot_file <- paste0('~/beta_diversity_testing/plots/ML_plots_',ml_method,'_trajectory.pdf')
pdf(plot_file)

all_studies_df <- tibble(study=character(), beta=character(), metric=character(),
                        feature=character(), score=double())

# read in & plot study-specific files
for (study in studyList) {
  setwd(paste0('~/beta_diversity_testing/',study,'/ML')) # set working dir

  # get a list of all files in each study's ML directory for this ML method
  files <- list.files(pattern = ml_method, recursive = FALSE)
  files <- files[grepl("trajectory_3", files)] # remove test files
    
  study_df <- tibble(study=character(), beta=character(), metric=character(),
                       feature=character(), score=double())
  for (file in files) {
      ml_metric <- get_ML_metric(file) # retrive ML performance metric
      df <- read.table(file, header = TRUE) # read in the ML performance table
      df <- df %>% mutate(beta = str_replace_all(beta, "_", " "))
      df <- df %>% mutate_all(~ replace(., . == 'NA', NA)) # replace nonsense with NA
      
      # for each feature, get the average performance per beta method
      df <- df %>% group_by(beta) %>% summarise(across(everything(), mean, na.rm=TRUE))
      df <- df %>% gather(key = "feature", value = 'score', -beta) # convert to long format
      df$study <- study
      df$metric <- ml_metric
        
      study_df <- bind_rows(study_df, df)
      all_studies_df <- bind_rows(all_studies_df, df)
    }
    
    # get a plot for just this study & metric
    study.title <- paste(study, 'ML out')
    study.subtitle <- paste(ml_method)
    plt <- ml.plot.study(study_df, study.title, study.subtitle)
    print(plt)
    
    # append this table to the all-study table for this metric
    #avg_df$study <- study
    #avg_df$metric <- ml_metric
    #all_studies_df <- bind_rows(all_studies_df, avg_df)
  }

# get sub df based on gemelli approach
all_studies_df <- all_studies_df %>% filter(., score > -1)

rpca.df <- all_studies_df %>% filter(!beta %in% c('ctf','phylo ctf'))
rpca.df$beta <- factor(rpca.df$beta, levels=c('rpca','phylo rpca', 'jaccard',
                'bray curtis', 'unweighted unifrac', 'weighted unifrac', 
                'lognorm', 'raw'))

# plot multi-study figures
ml.plot.meta(rpca.df, ml_method)

dev.off()
