# PLOTTING BETA DIVERSITY COMPARISON VISUALS
# AUTHORED BY DAISY FRY BRUMIT

library(tidyverse) # for ggplot and df maipulations
library(gridExtra) # for outputting plots as pdf
library(naniar)
library(reshape2)

### SET GLOBAL VARS ### 
rootDir <- '/Users/dfrybrum/git/beta_diversity_testing/' # path to working dir
studyList <- c('Zeller', 'Jones', 'Vangay', 'Noguera-Julian') # all studies (also Directories!)
metricList <- c('accuracy', 'roc_auc', 'r2') # all performace metrics
plotList <- list() # hold all plots for single pdf later
avgPlotList <- list()
plot_index <- 1 # will run through indices as we ad plots
avgPlot_index <- 1

### SET FUNCTIONS ###
# import tsv, return as df
df_import <- function(metric_string) {
  df <- read_tsv(paste0(study,'/',metric_string,'_table.txt'))
  return(df)
}

# take in df and all relevant strings, return a plot with appropriate titles and data
# tilt labels to fit with 'theme', add descriptive title, remove bulky x-axis label
make_boxplot <- function(df, study, feature_as_string, metric) {
  plot <- ggplot(df, aes_string(x = 'method', y = feature)) + 
    geom_boxplot() +
    labs(title = paste(study,feature), subtitle = paste('RF',metric), x=NULL) +
    theme(axis.text.x = element_text(angle=45, hjust = 0.5, vjust = 0.5),
          plot.title = element_text(size=12, face='bold'))
}

#### EXECUTE FUNCTIONS FOR ALL DATASETS ###
setwd(rootDir) # set working directory
for (study in studyList) {
  
  for (metric in metricList) {
    
    df <- df_import(metric)
    
    # replace nonsense values with na
    for (column in df) {
      df <- replace_with_na_all(df, condition = ~.x == 999)
    }
     
    # get features as a list of strings
    feature_names <- colnames(df)[-which(colnames(df) == 'method')]
    
    # average performance metric values per feature
    feature_avgs <- df %>% group_by(method) %>% summarise(across(everything(), mean, na.rm=TRUE))
    
    # expand averages into long form with 3 columns: method, feature name, and average value
    feature_avgs <-feature_avgs %>% mutate(id = row_number()) %>% 
      pivot_longer(cols = !contains('method'), names_to = "names", values_to = "values") %>%
      filter(names != 'id')
    
    # generate plot specifically for averaged feature values
    plot <- ggplot(feature_avgs, aes(x=method, y=values)) +
      geom_boxplot() +
      labs(title = paste(study, 'average performance per method'), subtitle = paste('RF', metric)) +
      theme(axis.text.x = element_text(angle=45, hjust = 0.5, vjust = 0.5), plot.title = element_text(size=12, face='bold'))
    
    # add plot objects to separate list
    # this wll let me print these items first to the PDF, with individual feature figures after
    avgPlotList[[avgPlot_index]] <- plot
    avgPlot_index <- avgPlot_index + 1
    
    # make plots for all indvidual features, add to separate list
    for (feature in feature_names) {
      plot <- make_boxplot(df, study, feature, metric)
      plotList[[plot_index]] <- plot
      plot_index <- plot_index + 1 # next index value
    } 
  }
}

### EXPORT ALL PLOTS AS 1 PDF ###
# create global list
fullList <- append(avgPlotList, plotList)

# open pdf document
pdf('beta_div_comp_plots.pdf', onefile = TRUE)

# add plots as 'grobs' to arrange them 4 per page
marrangeGrob(grobs = fullList, nrow=2, ncol=2)

# close the pdf
dev.off() # end of pdf creation
#}

