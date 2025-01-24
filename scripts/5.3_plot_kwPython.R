rm(list=ls())
setwd('~/beta_diversity_testing/plots')
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

pdf('rf_posthoc.pdf')
files <- list.files('.','rf_post_hoc')
for (file in files){
  # isolate the performance metric name for title
  metric <- strsplit(file,'_')[[1]][4]
  metric <- gsub('.tsv','',metric)
  
  # read in matrix and mirror labels
  tmp.df <- read.table(file) %>% as.matrix()
  colnames(tmp.df) <- str_replace(colnames(tmp.df), "_", " ")
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
                levels=c('rpca','phylo rpca','jaccard',
                         'bray curtis','unweighted unifrac','weighted unifrac',
                         'lognorm','raw'))
  plot.df$X2 <- factor(plot.df$X2, 
                       levels=c('rpca','phylo rpca','jaccard',
                                'bray curtis','unweighted unifrac','weighted unifrac',
                                'lognorm','raw'))
  plot.df <- rm_dups(plot.df)
  
  # make the plot
  # CHECK HEX CODES
  # library(RColorBrewer)
  # brewer.pal(n=5,"Set1")
  # 377EB8 CTF BLUE | 4DAF4A RPCA GREEN
  
  plt <- ggplot(plot.df, aes(x=X1, y=X2, fill=value)) +
    geom_tile() + 
    geom_text(aes(label=sig),color='white',size=4) +
    theme_minimal() +
    scale_fill_gradient(low="#377EB8", high='lightgrey') +
    theme(axis.text = element_text(size=14),
          legend.text = element_text(size=14),
          axis.title = element_blank(),
          axis.text.x = element_text(angle=90, vjust = 0.3),
          legend.title = element_text(size=14, face='bold'),
          plot.title = element_text(size=14, face='bold')) + 
    labs(title=metric, fill="P-Value")
  print(plt)
}
dev.off()
