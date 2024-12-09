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

studyList <- c('Zeller', 'Jones', 'Vangay', 'Noguera-Julian', 'ECAM')
ml_method <- 'knn'

# define generic plotting function for a single study
make_study_plot <- function(table, study, ml_label, metric) {
  if (ml_label == 'rf') {ml_label <- 'random forest'}
  
  title_str <- paste(study, ml_label, 'performance by', metric)
  sub_str <- 'One point = average performance on one feature'
  
  plot <- ggplot(table, aes(x=beta, y=score)) +
    geom_boxplot() +
    geom_point(aes(color=table$feature)) +
    scale_color_brewer(palette="Dark2") +
    labs(title = title_str, subtitle = sub_str, color="Feature Class") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
          plot.title = element_text(size=10, face = 'bold'),
          legend.title=element_blank(),
          axis.title.x = element_blank())
  
  print(plot)
}

# define plotting function for the final, all-study table per metric
make_full_plot <- function(table, ml_label, metric) {
  if (ml_label == 'rf') {ml_label <- 'random forest'}
  mean_scores <- table %>% group_by(metric) %>% 
    summarize(mean.score = mean(score, na.rm=TRUE))
  
  #title_str <- paste("Using", ml_label,", various performance scores appear
   #                  broadly similar across beta diversity transformations.")
  #title_str <- paste("Overall", ml_label, 'performance by ml metric')
  #sub_str <- 'One point = average performance score on one metadata feature'
  
  plot <- ggplot(table, aes(x=beta, y=score)) +
    geom_boxplot() +
    geom_point(aes(color=study)) +
    geom_hline(data= mean_scores, aes(yintercept=mean.score), color='red') +
    scale_color_brewer(palette="Dark2") +
    facet_grid(metric ~ ., scales = 'free_y') +
    theme_minimal() +
    theme(axis.text = element_text(size=16),
          legend.text = element_text(size=16),
          axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5),
          title = element_blank(),
          axis.title = element_blank(),
          legend.title=element_text(size=16,face="bold")) +
    labs(color='Study')
  
  print(plot)
}

# name file and initiate pdf
plot_file <- paste0('~/beta_diversity_testing/plots/ML_plots_',ml_method,'.pdf')
pdf(plot_file)

all_studies_df <- tibble(study=character(), beta=character(), metric=character(),
                        feature=character(), score=double())
  
for (study in studyList) {
  
  setwd(paste0('~/beta_diversity_testing/',study,'/ML')) # set working dir
  getwd() # sanity check
  
  # get a list of all files in each study's ML directory for this ML method
  files <- list.files(pattern = ml_method, recursive = FALSE)
  files <- files[!grepl("raw", files)] # remove test files
  
  for (file in files) {
    ml_metric <- get_ML_metric(file) # retrive ML performance metric
    df <- read.table(file, header = TRUE) # read in the ML performance table
    df <- df %>%
      mutate(beta = str_replace_all(beta, "_", " "))
    # replace nonsense variables with NA
    for (column in df) 
    {
      df <- replace_with_na_all(df, condition = ~.x == 'NA')
    }
    
    
    # For each feature, get the average performance per beta method
    avg_df <- df %>% group_by(beta) %>% summarise(across(everything(), mean, na.rm=TRUE))
    avg_df <- avg_df %>% gather(key = "feature", value = 'score', -beta) # convert to long format
    
    # get a plot for just this study & metric 
    make_study_plot(avg_df, study, ml_method, ml_metric)
    
    # append this table to the all-study table for this metric
    avg_df$study <- study
    avg_df$metric <- ml_metric
    all_studies_df <- bind_rows(all_studies_df, avg_df)
  }
}
  # make final, all inclusive plot after log transforming
  #all_studies_df <- all_studies_df %>% mutate(score = log10(score+1)) %>% filter(!is.nan(score))
  make_full_plot(all_studies_df, ml_method, ml_metric)
  dev.off()
  