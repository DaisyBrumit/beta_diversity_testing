library(tidyverse)
library(FSA)

rm(list=ls())

filepath <- '~/beta_diversity_testing/plots/rf_metaMLTable.tsv'
df <- read_table(filepath)

metric.list <- c('accuracy','roc','r2')

for (item in metric.list) {
  tmp.df <- df %>% filter(metric == item) %>% drop_na()
  plt <- ggplot(data=tmp.df,aes(x=beta,y=value)) + geom_boxplot() + 
    labs(title=paste('rf',item))
  print(plt)
  
  kwtest <- kruskal.test(value ~ beta, data = tmp.df)
  
  if (kwtest$p.value < 0.05) {
    dtest <- dunnTest(value~beta, data = tmp.df, method = 'bh')
    dtest <- dtest$res
    
    plot.df <- dtest %>%
      mutate(X1 = str_trim(str_extract(Comparison, "^[^\\-]+")),
             X2 = str_trim(str_extract(Comparison, "[^-]+$")),
             value = P.adj) %>%
      select(X1, X2, value)
    
    plot.df <- plot.df %>%
      mutate(X1 = X1,
             X2 = X2,
             value = value,
             rounded = round(value,4),
             sig = case_when(
               value < 0.01 ~ '**',
               value < 0.05 ~ '*',
               TRUE ~ ''
             ))
    
    plot.df$X1 <- factor(plot.df$X1, 
                         levels=c('bray_curtis','jaccard','unweighted_unifrac','weighted_unifrac',
                                  'ctf','phylo_ctf','rpca','phylo_rpca'))
    plot.df$X2 <- factor(plot.df$X2, 
                         levels=c('bray_curtis','jaccard','unweighted_unifrac','weighted_unifrac',
                                  'ctf','phylo_ctf','rpca','phylo_rpca'))
    
    if (item=='r2') {lower.lim=-1
    } else{lower.lim=0}
    
    plt <- ggplot(plot.df, aes(x=X1, y=X2, fill=value)) +
      geom_tile() + 
      geom_text(aes(label=rounded),color='white',size=2)+
      theme(axis.text.x = element_text(angle=90, vjust = 0.3)) + 
      labs(title=item)
    print(plt)
  } else {print(paste(item,"KW insignificant"))}
}

# FOR EXPANDING AND FILLING A WHOLE HEATMAP
verbose_df <- function(df){
  items <- unique(c(df$X1, df$X2))
  all_pairs <- expand.grid(X1 = items, X2 = items)
  merged_df <- all_pairs %>%
    left_join(df, by = c("X1", "X2")) %>%
    left_join(df, by = c("X1" = "X2", "X2" = "X1"), suffix = c("", ".mirror")) %>%
    mutate(value = coalesce(value, value.mirror, ifelse(X1 == X2, 1, NA))) %>%
    select(X1, X2, value)

  return(merged_df)
}

# FOR COMPARING PY AND R POST HOC PVALUES
pvp <- function(py.df, r.df, metric) {
  py.df <- py.df %>%
    arrange(X1, X2)
  
  r.df <- r.df %>%
    arrange(X1, X2)
  
  # Merge the two dataframes on X1 and X2
  merged_df <- py.df %>%
    inner_join(r.df, by = c("X1", "X2"), suffix = c("_py", "_r"))
  
  ggplot(merged_df, aes(x = value_py, y = value_r)) +
    geom_point() +
    labs(
      title = paste("Comparison of py and r", metric ,"values"),
      x = "py value",
      y = "r value"
    ) +
    theme_minimal()
}
