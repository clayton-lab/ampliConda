phyloseq = readRDS(snakemake@input$phyloseq)
category = snakemake@params$category

library(phyloseq)
library(ggplot2)

alpha_div <- plot_richness(phyloseq, x=category, color=category, measures = c("Shannon")) + geom_point(size = 4) + theme_bw()
ggsave(filename = snakemake@output[[1]], plot = alpha_div, device = "pdf")