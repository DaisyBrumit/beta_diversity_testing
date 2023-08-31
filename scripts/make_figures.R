library(tidyverse)
library(optparse)

source('~/scripts/plotting_functions.R')

# define possible cml inputs/arguments as follows
# -s: target study (default: all used in this project)
# -b: beta transformation of interest (default: NULL)
# -m: model of interest (default: rf)
#     options: rf (random forest), knn, perm (permanova)
# -pc: num of PC axes of interest (default: NULL == all)
#      options: integer, 'meta' for comparisons    

arg.options <- list(
  make_option(
    c('-s', '-study'), type = 'character', default = 'all',
    help = 'specify study: assumes study name == study\'s directory name.'
  ),
  
  make_option(
    c('-b', '-beta'), type = 'character', default = NULL,
    help = 'specify beta diversity method to highlight, if any.'
  ),
  
  make_option(
    c('-m', '-model'), type = 'character', default = 'rf',
    help = 'select model: rf, knn, or perma'
  ),
  
  make_option(
    c('-pc'), type = 'character', default = NULL,
    help = 'specify number of PCs used: default=NULL, \'all\' for all, \'meta\' for PC comparison.'
  )
)

# take in the inputs as defined above from command line
args <- parse_args2(OptionParser(usage = 'make_figures.R', option_list = arg.options))

# store arguments 
beta.input <- args$b
model.input <- args$m

study.input <- as.vector(args$s)
if (study.input == 'all') # specify what "all" means
  study.input <- c('Jones', 'Vangay', 'Zeller', 'Noguera-Julian', 'gemelli_ECAM')


pc.input <- args$pc
if (pc.input == 'meta') # specify all possible counts for comparisons
  pc.input <- c('3', '4', '5', '6', '7', '8', '9', '10', 'all')


# verify that cml inputs are valid
valid.betas <- c('jaccard', 'bray_curtis', 'weighted_unifrac', 'unweighted_unifrac',
                 'ctf', 'phylo_ctf', 'rpca', 'phylo_rpca')
valid.models <- c('perm', 'knn', 'rf')
valid.pc.counts <- c('3', '4', '5', '6', '7', '8', '9', '10', 'all', 'meta')

# in case of invalid inputs, print error and quit
# for beta
if (!is.null(beta.input) && !beta.input %in% valid.betas) {
  cat("ERROR: -b input must be one of the following \n", 
      paste(valid.betas), '\nOR left blank')  
  quit(status = 1)
}

# for model
if (!is.null(model.input) && !model.input %in% valid.models) {
  cat("ERROR: -m input must be one of the following \n", 
      paste(valid.models))  
  quit(status = 1)
}

# for