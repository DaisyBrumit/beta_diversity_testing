# Function for getting a percent string from decimals
dec_to_percent <- function(decimal) {
  rounded_dec <- round(decimal, digits=4) # cutoff at 4 figs
  pct <- rounded_dec * 100 # get the percentage
  pct_string = paste0(as.character(pct),'%') # format as a string/char
  
  return(pct_string)
}