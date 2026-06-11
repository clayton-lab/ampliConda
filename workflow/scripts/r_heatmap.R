phyloseq = readRDS(snakemake@input$phyloseq)
taxalevel = snakemake@params$taxalevel
taxacomparison = snakemake@params$taxacomparison
samplingdepth = as.integer(snakemake@params$samplingdepth)

library(phyloseq)
library(ggplot2)
library(tidyverse)
library(dplyr)

ps_ordered <- tax_glom(phyloseq, taxalevel)

heatmap <- plot_heatmap(ps_ordered, method = NULL, taxa.label = taxalevel, raster = FALSE)

real_heatmap <- heatmap + 
  ggplot2::theme_minimal() +
  ggplot2::theme(panel.grid = ggplot2::element_line(color = "grey80")) +
  ggplot2::geom_tile(color = "black", linewidth = 0.2) +
  ggplot2::facet_wrap(reformulate(taxacomparison), scales = "free_x") + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))

ggsave(filename = snakemake@output[[1]], plot = real_heatmap, device = "pdf")
