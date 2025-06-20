# define_metadata.R
print(snakemake@input[[1]])
print(snakemake@output[[1]])
# Load the input metadata file
metadata = read.csv(snakemake@input[[1]])

# Save the R object to the output file specified in the Snakemake rule
saveRDS(metadata, snakemake@output[[1]])