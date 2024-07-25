# RETURN THE BETA DIVERSITY METHOD EMPLOYED IN THE DATASET
get_beta <- function(file) {
  # make a list of all keywords that need to be removed
  bad.words <- c('distance', 'matrix', 'ordinations', 'permanova', 'results',
                 'ords', 'with', 'meta', 'fromBiplot')
  beta.list <- c() # init empty list to contain multi-word metrics
  
  # break up file name into a string
  file.str <- sub('.tsv','',file) # remove suffix
  file.list <- as.list(strsplit(file.str,"_")[[1]]) # break up the file string into parts
  
  # remove any taxa integers or additional labels
  for(x in file.list){
    # translated: if x NOT in bad.words, and if x is not a number
    if(!(x %in% bad.words) && (is.na(as.numeric(x)))){
      beta.list <- append(beta.list, x)
    }
  }
  
  beta.str <- paste(beta.list, collapse = "_")
  return(beta.str)
}

# RETURN HOW MANY TAXA ARE PRESENT IN THE DATASET
get_n_taxa <- function(file) {
  n.taxa <- "all"
  
  # break up file name into a string
  file.str <- sub('.tsv','',file) # remove suffix
  file.list <- as.list(strsplit(file.str,"_")[[1]]) # break up the file string into parts
  
  # remove any taxa integers or additional labels
  for(x in file.list){
    # translated: if x NOT in bad.words, and if x IS a number
    if(!is.na(as.numeric(x))){
      n.taxa <- x
      if(n.taxa == '1'){n.taxa <- '10'}
      break
    }
  }
  
  return(n.taxa)
}

# RETURN THE PERFORMANCE METRIC USED IN AN ML OUTPUT DATASET
get_ML_metric <- function(file) {
  
  # break up file name into a string
  file.str <- sub('.tsv','',file) # remove suffix
  file.list <- as.list(strsplit(file.str,"_")[[1]]) # break up the file string into parts
  
  metric <- file.list[[1]] # metric is first in the resulting list
  return(metric)
}
