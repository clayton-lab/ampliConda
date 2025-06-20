# separate_plots.R

# Load the input .RDS files
fnFs = readRDS(snakemake@input[[1]])
fnRs = readRDS(snakemake@input[[2]])

# Process the data (replace with your actual data processing logic)
# For example, create plots or process fnFs and fnRs
fPlot = dada2::plotQualityProfile(fnFs, aggregate = TRUE) + ggplot2::ggtitle("Forward") + ggplot2::geom_hline(yintercept =  30, colour = "blue")
rPlot = dada2::plotQualityProfile(fnRs, aggregate = TRUE) + ggplot2::ggtitle("Reverse") + ggplot2::geom_hline(yintercept =  30, colour = "blue")

# Save the processed plots or data as .RDS files
saveRDS(fPlot, snakemake@output$fPlot)
saveRDS(rPlot, snakemake@output$rPlot)