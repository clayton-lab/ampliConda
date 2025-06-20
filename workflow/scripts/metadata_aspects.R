# process_metadata.R

# Load the metadata object from the input .RDS file
metadata = readRDS('R_output/metadata.RDS')

# Process the metadata into the parts we need
fnFs = metadata$Read1
fnRs = metadata$Read2
sample_names = metadata$sample_id

# Define filtered paths for each sample
filt_path = file.path(getwd(), "filtered")
filtFs = file.path(filt_path, paste0(sample_names, "_F_filt.fastq.gz"))
filtRs = file.path(filt_path, paste0(sample_names, "_R_filt.fastq.gz"))

# Save each component as an RDS file
saveRDS(fnFs, snakemake@output$fnFs)
saveRDS(fnRs, snakemake@output$fnRs)
saveRDS(sample_names, snakemake@output$sample_names)
saveRDS(filtFs, snakemake@output$filtFs)
saveRDS(filtRs, snakemake@output$filtRs)