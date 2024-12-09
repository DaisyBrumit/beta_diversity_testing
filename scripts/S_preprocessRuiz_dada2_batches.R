# SCRIPT FOR RUNNING DADA2 IN BATCHES ON THE CLUSTER
rm(list=ls())
library(dada2); packageVersion("dada2")
setwd('~/beta_diversity_testing/Ruiz-Calderon/preprocessing')

# Get arguments passed from SLURM script
args <- commandArgs(trailingOnly = TRUE)
start_idx <- as.integer(args[1])
end_idx <- as.integer(args[2])
files_to_process <- strsplit(args[3], " ")[[1]]  # Convert the space-separated file list into a vector

# Get sample names based on filenames
sample.names <- sapply(basename(files_to_process), function(x) sub("\\_filt\\.fastq$", "", x))

# Check the range of files to process
print(paste("Processing files from index", start_idx, "to", end_idx))
#print(paste("Files to process:", paste(sample.names, collapse=", ")))

# Initialize a list to hold DADA2 results
dds <- vector("list", length = length(files_to_process))

# Process each file in the chunk
for (i in seq_along(files_to_process)) {
	    file <- files_to_process[i]
    print(paste("Processing file:", file))
        
        dadaFs <- NULL
        tryCatch({
		        errF <- dada2::learnErrors(file, multithread = FALSE)  # Learn error rates
			        derepFs <- dada2::derepFastq(file, verbose = TRUE)  # Dereplicate
			        dadaFs <- dada2::dada(derepFs, err = errF, multithread = FALSE)  # Apply DADA2 algorithm
				    }, error = function(e) {
					            message("Error encountered at file ", file, ": ", e$message)
				    })
	    
	    dds[[i]] <- dadaFs  # Save the DADA2 result
}
# Save the results
names(dds) <- sample.names
print(dds)
print(paste("Assigned names to DADA2 object:", paste(names(dds), collapse=", ")))
saveRDS(dds, file = file.path("r_objects", paste0("dada2_dds_batch_", start_idx, "_to_", end_idx, ".rds")))

### AFTER RUNNING IN BATCHES, THE FOLLOWING CODE CAN BE RUN TO COMBINE THE DATA INTO ONE COUNT TABLE:
# batch_dds <- sort(list.files('r_objects', pattern = 'dada2_dds_batch_', full.names = TRUE))
# dds <- batch_dds %>% map(readRDS) %>% flatten()

# did anything fail?
# bad_class_indices <- which(sapply(dds, function(x) class(x)[1] != "dada")) # check
# if (length(bad_class_indices) > 0) {
#   cat("Entries with incorrect class:\n", bad_class_indices, "\n")
# } else { cat("No entries with incorrect class.\n") } # print/notify
# dds <- dds[-c(bad_class_indices)] # remove problem samples

# make the final sequence table!
# seqtab <- dada2::makeSequenceTable(dds) # make ASV table
# seqtab <- dada2::removeBimeraDenovo(seqtab, method="consensus", multithread=FALSE) # remove bimeras
# saveRDS(seqtab, file.path("r_objects","Ruiz-Calderon_ForwardReads_DADA2.rds")) # save r obj

# clean up the table and re-orient to standard
# seqtab <- as.data.frame(t(seqtab))
# seqtab <- rownames_to_column(seqtab,var=' ')

# filter out samples that aren't captured in the metadata
# meta_init <- read.csv('meta.txt', sep='\t', header = TRUE, 
#                       check.names = FALSE)

#filtered_data <- seqtab %>%
#  select(1, any_of(meta_init$sampleid))

# write.table(filtered_data, file.path("Ruiz-Calderon_ForwardReads_DADA2.txt"), sep="\t", row.names = FALSE, quote = FALSE)
