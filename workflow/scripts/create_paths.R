sample_names <- readRDS(snakemake@input[["sample_names_file"]])
fnFs <- readRDS(snakemake@input[["fnFs"]])
fnRs <- readRDS(snakemake@input[["fnRs"]])

# Define paths for filtered forward and reverse reads
filt_path <- file.path(getwd(), "filtered")
filtFs <- file.path(filt_path, paste0(sample_names, "_F_filt.fastq.gz"))
filtRs <- file.path(filt_path, paste0(sample_names, "_R_filt.fastq.gz"))

# Save paths in a list and write to an RDS file
file_paths <- list(fnFs = fnFs, fnRs = fnRs, filtFs = filtFs, filtRs = filtRs)
saveRDS(file_paths, snakemake@output[[1]])