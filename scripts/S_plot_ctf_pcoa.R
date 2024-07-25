rm(list=ls())
source('~/beta_diversity_testing/scripts/functions/meta_from_files.R')
library(rlang)

rootdir <- "~/beta_diversity_testing/"
study <- "ECAM"
feat <- "delivery"
repeat.feat <- "month"

# List all files in the ordinations directory
meta <- read.csv(paste0(rootdir, study, '/meta.txt'), sep='\t', header = TRUE, check.names = FALSE)
meta.cols <- meta[, c(feat, repeat.feat)]
rownames(meta.cols) <- meta$`#SampleID`

files <- list.files(path = paste0(rootdir, study, '/ordinations'), pattern = 'ordinations.tsv$', full.names = TRUE)

pdf(paste0(rootdir,'plots/',study,'_ctfPlot.pdf'))
for (file in files){
  ord.tmp <- read.table(file)
  pct.exp <- round(ord.tmp[1,1] * 100, digits=2)
  ord.tmp <- ord.tmp[-1,] %>% select(PC1)
  
  file.sansSuffix <- get_beta(file)
  beta <- basename(file.sansSuffix)
  beta <- str_replace(beta, "_", " ")
  
  plot.table <- merge(ord.tmp, meta.cols, by='row.names')
  plt <- ggplot(data = plot.table, 
                aes(x = !!sym(repeat.feat), y = as.numeric(PC1), color = !!sym(feat))) +
    geom_point() + 
    geom_smooth() +
    scale_color_brewer(palette="Dark2") +
    labs(title=beta, y=paste0("PC1: ",pct.exp,"%")) +
    theme_minimal() +
    theme(legend.title = element_blank())
  print(plt)
}
dev.off()
