# conda package is necessary
suppressMessages({
        library("tidyverse")### had to add after the fact
        library("dada2")
        library("gridExtra")### had to add after the fact
        library("phyloseq")
        library("Biostrings")
        library("readr") # not convinced you need this...it's a part of tidyverse
})
no_of_cores = 4

setwd(file.path(Sys.getenv("COMMON"), "repos/ampliConda"))
getwd() #checks for proper working directory

metadata = "data/paired_end_metadata.csv" #config file
metadata_df = read.csv(metadata)

fnFs = metadata_df$Read1
fnRs = metadata_df$Read2
sample.names = metadata_df$sample_id
# begin DADA2 workflow ASV analysis

fPlot <- dada2::plotQualityProfile(fnFs, aggregate = TRUE) + ggtitle("Forward") + geom_hline(yintercept =  30, colour = "blue")
rPlot <- dada2::plotQualityProfile(fnRs, aggregate = TRUE) + ggtitle("Reverse") + geom_hline(yintercept =  30, colour = "blue") 
bothQualityPlots = grid.arrange(fPlot, rPlot, nrow = 1)
ggsave(bothQualityPlots, filename = "bothQualityPlots.pdf", device = "pdf", height = 6, width = 5, units = "in")

# filtering step begins
filt_path <- paste0(getwd(), '/filtered') # don't change this 
filtFs <- file.path(filt_path, paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(filt_path, paste0(sample.names, "_R_filt.fastq.gz"))
names(filtFs) <- sample.names
names(filtRs) <- sample.names


####### manual version
FORWARD_TRUNC <- 280
REVERSE_TRUNC <- 250
out <- dada2::filterAndTrim(fnFs, filtFs, fnRs, filtRs, truncLen=c(FORWARD_TRUNC,REVERSE_TRUNC), trimLeft=c(20, 20), maxEE=c(2,2), matchIDs=TRUE, compress=TRUE, verbose=TRUE)
head(out)

####### automated version truncQ is the key automated variable
out_automated <- dada2::filterAndTrim(fnFs, filtFs, fnRs, filtRs, trimLeft=c(20, 20), maxEE=c(2,2), truncQ=c(20), matchIDs=TRUE, compress=TRUE, verbose=TRUE)
head(out_automated) # displays the number of reads trimmed for each sample

####### Dereplication step begins