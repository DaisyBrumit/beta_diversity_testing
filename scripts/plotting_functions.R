# LIBRARY OF PLOTTING FUNCTIONS FOR BETA DIVERSITY STUDIES 
# AUTHORED BY DAISY FRY BRUMIT

model_metrics_boxplot <- function(x, y, model="Model", stat="p-value", subtitle=NULL)
{ 
  plt <- ggplot(df, aes(x=x, y=y)) +
    geom_boxplot() +
    labs(title = paste(model,stat,'per Method'), 
         subtitle = subtitle) +
    theme(axis.text.x = element_text(angle=45, hjust=0.5, vjust=0.5), 
          plot.title = element_text(size=10, face = 'bold'))
  
  return(plt)
}

