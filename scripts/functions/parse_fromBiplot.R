library(tidyverse)

parse_ords <- function(filepath) {
  # Create an empty tibble for this ordination
  df <- data.frame(index=character(), PC1 = numeric(), PC2 = numeric(), PC3 = numeric())
  
  # Create a vector for index values
  index <- c()
  
  # Write will determine which lines are kept
  write <- 0
  for (line in readLines(filepath)) {
    # Only start storing data after 'Site' label
    if (write == 0 && grepl("^Site", line)) {
      write <- 1
    } else if (write == 1) {
      # Write all Site PCs, stop before Biplot lines
      if (line == '') {
        write <- 0  # Ignore lines after the "Site" block.
      } else {
        line <- strsplit(trimws(line), "\t")[[1]]  # Split the string into PC1-3 values
        line[1] <- as.character(sub("\\.0$", "", line[1])) # convert index to character
        
        df <- bind_rows(df, data.frame(index=as.character(line[1]),PC1 = as.numeric(line[2]), 
                                   PC2 = as.numeric(line[3]), PC3 = as.numeric(line[4])))
      }
    } else {
      next
    }
  }
  
  rownames(df) <- index  # Add indices to finished tibble
  return(df)
}
