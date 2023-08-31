# LIBRARY OF PLOTTING FUNCTIONS FOR BETA DIVERSITY STUDIES 
# AUTHORED BY DAISY FRY BRUMIT

### FILTERING FUNCTIONS ###

# remove columns populated by all NA values 
# columns are model output values (accuracy, p-value)
# rows are classes (# of PCs, beta transformation labels)

filter.na.cols <- function(df) {
  df.nas <- df %>% mutate(across(everything(), ~ifelse(.x == 999, NA, .x))) # turn all 999 into na
  df.filtered <- df.nas %>% dplyr::select_if(~ !all(is.na(.))) # remove whole column if all labels are na
  
  removed.cols <- df.nas %>% dplyr::select_if(~ all(is.na(.))) # get list of na cols
  
  # print removed column names
  print(paste(ncol(removed.cols), 'features removed:')) 
  print(colnames(removed.cols))
  
  return(df.filtered)
}

### PLOTS ###

make.boxplot <- function(df, x, y, title=NULL, subtitle=NULL)
{ 
  # boxplot figure where
  # df: dataframe containing other parameters
  # x: metric of interest (accuracy)
  # y: classes of interest (beta diversity method)
  
  plt <- ggplot(df, aes(x=x, y=y, color=group, group=group)) +
    geom_boxplot() +
    labs(title = title, subtitle = subtitle) +
    theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
          plot.title = element_text(size=10, face = 'bold'))
  
  return(plt)
}

make.linegraph <- function(df, x, y, group=NULL, scale=NULL, title=NULL, subtitle=NULL)
{
  # line graph where
  # df: dataframe containing other parameters
  # x: metric of interest (accuracy)
  # y: derived trend to observe (# of principle components)
  # group: classes of interest (beta diversity method)
  # scale: a vector containing min and max Y-axis values
  
  plt <- ggplot(df, aes(x=x, y=y, color=group, group=group)) +
    geom_smooth(na.rm=TRUE, se=FALSE) +
    scale_y_continuous(limits=scale) +
    labs(title=title, subtitle=subtitle) +
    theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
          plot.title = element_text(size=10, face = 'bold'))
  
  return(plt)
}

