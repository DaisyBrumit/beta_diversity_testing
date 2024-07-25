rm(list=ls())
setwd('~/beta_diversity_testing_almost_final/plots')
library(tidyverse)
library(reshape)

### function for minute cleaning
rm_dups <- function(df) {
  df_cleaned <- df %>%
    filter(as.numeric(X1) >= as.numeric(X2)) %>%
    mutate(pair = pmap_chr(list(X1, X2), ~ paste(sort(c(...)), collapse = "-"))) %>%
    distinct(pair, .keep_all = TRUE) %>%
    select(-pair)
  
  return(df_cleaned)
}

#pdf('knn_posthoc.pdf')
files <- list.files('.','knn_post_hoc')
for (file in files){
  # isolate the performance metric name for title
  metric <- strsplit(file,'_')[[1]][4]
  metric <- gsub('.tsv','',metric)
  
  # read in matrix and mirror labels
  tmp.df <- read.table(file) %>% as.matrix()
  rownames(tmp.df) <- colnames(tmp.df)
  
  plot.df <- melt(tmp.df) # get long form version of the data
  
  # set new labels
  plot.df <- plot.df %>% mutate(X1=X1, X2=X2, value=value, rounded = round(value,4), 
                                sig = case_when(
                                  value < 0.001 ~ '***',
                                  value < 0.01 ~ '**',
                                  value < 0.05 ~ '*',
                                  TRUE ~ ''))
  # get a clean, mirrored heatmap
  plot.df$X1 <- factor(plot.df$X1, 
                levels=c('bray_curtis','jaccard','unweighted_unifrac','weighted_unifrac',
                         'ctf','phylo_ctf','rpca','phylo_rpca'))
  plot.df$X2 <- factor(plot.df$X2, 
                          levels=c('bray_curtis','jaccard','unweighted_unifrac','weighted_unifrac',
                                   'ctf','phylo_ctf','rpca','phylo_rpca'))
  plot.df <- rm_dups(plot.df)
  
  # make the plot
  plt <- ggplot(plot.df, aes(x=X1, y=X2, fill=value)) +
    geom_tile() + 
    geom_text(aes(label=sig),color='black',size=4) +
    theme_minimal() +
    scale_fill_gradient(low="#1B9E77", high='lightgrey') +
    theme(axis.text = element_text(size=14),
          legend.text = element_text(size=14),
          axis.title = element_blank(),
          axis.text.x = element_text(angle=90, vjust = 0.3),
          legend.title = element_text(size=16, face='bold'),
          plot.title = element_text(size=16, face='bold')) + 
    labs(title=metric, fill="P-Value")
  print(plt)
}
#dev.off()
