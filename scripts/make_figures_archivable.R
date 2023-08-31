library(tidyverse)

## SET GLOBAL VARS THAT WILL NEED TO BE LOOPED
# set working dirctory from files tab as necessary to follow expected dir layout
study.list <- c('Jones', 'Vangay', 'Zeller', 'Noguera-Julian')
metric.list <- c('knn_accuracy')#, 'multinomial_accuracy')

## DEFINE CORE FUNCTIONS

# df_filter: remove nonsense output from incoming tables
df_filter <- function(df) {
  df.nas <- df %>% mutate(across(everything(), ~ifelse(.x == 999, NA, .x))) # turn all 999 into na
  df.filtered <- df.nas %>% dplyr::select_if(~ !any(is.na(.))) # remove whole column if all labels are na
  
  removed.cols <- df.nas %>% dplyr::select_if(~ any(is.na(.))) # get list of na cols
  print(paste(ncol(removed.cols), 'features removed \n', colnames(removed.cols))) # print column names
  
  return(df.filtered)
}

# multi_feature_boxplot: create summary figure
multi_feature_boxplot <- function(df, metric)
{
  plt <- ggplot(df, aes(x=transform, y=values)) +
    geom_boxplot() +
    labs(title = 'Average Performance Per Method', 
         subtitle = paste(metric, 'values')) +
    theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
          plot.title = element_text(size=10, face = 'bold'))
  return(plt)
}

## GENERATE FEATURE DATA FOR SUMMARY FIGS
for (metric in metric.list) {
  feature_avgs <- data_frame()
  for (study in study.list) {
    data.raw <- readr::read_tsv(paste0(study,'/',metric,'.txt')) # import data "as is"
    data <- df_filter(data.raw) # filter out cols that didn't make ml requirements
    feature_avgs.tmp <- data %>% group_by(transform) %>% summarise(across(everything(), mean, na.rm=TRUE)) %>%
      pivot_longer(cols = !contains('transform'), names_to = "feature", values_to = "values")
    feature_avgs <- feature_avgs %>% bind_rows(feature_avgs.tmp)
  }
  plt <- multi_feature_boxplot(feature_avgs, metric)
  print(plt)
} 

