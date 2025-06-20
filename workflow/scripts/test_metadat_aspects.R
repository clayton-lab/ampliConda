# Manually define the paths for testing
input_file <- "R_output/metadata.RDS"
output_fnFs <- "R_output/fnFs.RDS"
output_fnRs <- "R_output/fnRs.RDS"
output_sample_names <- "R_output/sample_names.RDS"
output_filtFs <- "R_output/filtFs.RDS"
output_filtRs <- "R_output/filtRs.RDS"

# Load the metadata object
metadata <- readRDS(input_file)

# Process the metadata into the parts we need
fnFs <- metadata$Read1
fnRs <- metadata$Read2
sample_names <- metadata$sample_id

# Define filtered paths for each sample
filt_path <- file.path(getwd(), "filtered")
filtFs <- file.path(filt_path, paste0(sample_names, "_F_filt.fastq.gz"))
filtRs <- file.path(filt_path, paste0(sample_names, "_R_filt.fastq.gz"))

# Save each component as an RDS file
saveRDS(fnFs, output_fnFs)
saveRDS(fnRs, output_fnRs)
saveRDS(sample_names, output_sample_names)
saveRDS(filtFs, output_filtFs)
saveRDS(filtRs, output_filtRs)