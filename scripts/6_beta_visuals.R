# PLOTTING BETA DIVERSITY COMPARISON VISUALS
# AUTHORED BY DAISY FRY BRUMIT

library(tidyverse) # for ggplot and df maipulations
library(gridExtra) # for outputting plots as pdf

### SET GLOBAL VARS ### 
rootDir <- '/Users/dfrybrum/Documents/FodorLab/gemelli/' # path to working dir
studyList <- c('Zeller', 'Jones') #, 'Vangay', 'Noguera-Julian') # all studies (also Directories!)
metricList <- c('accuracy', 'roc_auc', 'r2') # all performace metrics
plotList <- list() # hold all plots for single pdf later
plot_index <- 1 # will run through indices as we ad plots

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
     
    # get features as a list of strings
    feature_names <- colnames(df)[-which(colnames(df) == 'method')]
    
    # make plots for all features, add to global plot list
    for (feature in feature_names) {
      plot <- make_boxplot(df, study, feature, metric)
      plotList[[plot_index]] <- plot
      plot_index <- plot_index + 1 # next index value
    } 
  }
}

### EXPORT ALL PLOTS AS 1 PDF ###
pdf('beta_div_comp_plots.pdf', onefile = TRUE) # initiate pdf file

# loop through every index in the plot list
#for (i in seq(length(plotList))) {
  #do.call('grid.arrange', plotList[[i]]) # grid arrange to place plots
#}
#grid.arrange(grobs=plotList, ncol=2)
marrangeGrob(grobs = plotList, nrow=2, ncol=2)
dev.off() # end of pdf creation
#}

