# PLOTTING BETA DIVERSITY ACCURACY OVER PC AXES
# AUTHORED BY DAISY FRY BRUMIT

library(tidyverse) # for ggplot and df maipulations
library(gridExtra) # for outputting plots as pdf
library(naniar)
library(reshape2)

# Set global vars
beta.div <- c('bray_curtis', 'dada2', 'jaccard', 'phylo_rpca', 'rpca',
              'unweighted_unifrac', 'weighted_unifrac')

rootDir <- '/Users/dfrybrum/git/beta_diversity_testing/' # path to working dir
study.list <- c('Vangay')
#study.list <- c('Vangay', 'Jones', 'Zeller', 'Noguera-Julian') # all studies (also Directories!)
metric <- 'Accuracy' # want to track accuracy performance over time

# create empty dfs
df.vector <- list() # this empty list will hold all dataframes so I don't have to figure out how to call a df by name in a loop

for (beta in beta.div) # one dataframe per beta diversity approach
{
  empty.df <- data_frame() # make an empty dataFrame
  df.vector <- append(df.vector, list(empty.df)) # add it to the list
}

# read in dataframes
for (i in 3:10) # for every PC count available
{
  list.index <- 1 # index through the list of dataframes, ONE per beta diversity metric
  for (beta in beta.div) # for every metric
  {
    for (study in study.list) # read in every study associated with this metric executed on this many PCs 
    {
      df <- read_tsv(paste0(study,'/',metric,'_table_',i,'.txt')) # read in the table
      df['pc_count'] <- paste0(i) # create a variable for PC count
      df['study'] <- paste0(study) # create a variable for study (not used. Sanity check)
      
      df.tmp <- filter(df, method == beta) # filter out only observations with desired diversity metric
      df.vector[[list.index]] <- bind_rows(df.vector[list.index], df.tmp) # append the subsetted values to the final dataframe of interest
    }
    list.index <- list.index + 1 # move into the next dataframe (and the next beta diversity metric) on the list
  }
}

# create a plot for each beta diversity metric
metaDF <- data_frame()
for (item in df.vector)
{
  df <- item
  #for (column in df) 
  #{
    #df <- replace_with_na_all(df, condition = ~.x == 999)
  #}
  
  #feature_names <- colnames(df)[-which(colnames(df) == 'method')]
  
  df <- select(df, !one_of(c('study')))
  feature_names <- select(df, !one_of(c('pc_count', 'method')))
  feature_names <- colnames(feature_names)
  
  # average performance metric values per feature
  feature_avgs <- df %>% group_by(pc_count, method) %>% summarise(across(everything(), mean, na.rm=TRUE))
  
  # expand averages into long form with 3 columns: method, feature name, and average value
  feature_avgs <-feature_avgs %>% mutate(id = row_number()) %>% 
    pivot_longer(cols = !contains('pc_count') & !contains('method'), names_to = "names", values_to = "values") %>%
    filter(names != 'id')
  
  metaDF <- bind_rows(metaDF, feature_avgs)
}

plot <- multi_feature_boxplot(metaDF, '', metric)
