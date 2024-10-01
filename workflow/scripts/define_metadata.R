# define_metadata.R
# Load the input metadata file
metadata <- read.csv(snakemake@input[[1]])

# Save the R object to the output file specified in the Snakemake rule
saveRDS(R_objects/metadata.RDS, snakemake@output[[1]])
