phyloseq = readRDS(snakemake@input$phyloseq)
taxalevel = snakemake@params$taxalevel
taxacomparison = snakemake@params$taxacomparison
samplingdepth = snakemake@params$samplingdepth

library(phyloseq)
library(ggplot2)
library(tidyverse)
library(dplyr)

ps_ordered <- tax_glom(phyloseq, taxalevel)
ps_ordered_rare <- rarefy_even_depth(ps_ordered, sample.size = samplingdepth, rngseed = 123, replace = FALSE)

heatmap <- plot_heatmap(ps_ordered_rare, method = NULL, taxa.label = taxalevel, raster = FALSE)

real_heatmap <- heatmap + 
  ggplot2::theme_minimal() +
  ggplot2::theme(panel.grid = ggplot2::element_line(color = "grey80")) +
  ggplot2::geom_tile(color = "black", linewidth = 0.2) +
  ggplot2::facet_wrap(reformulate(taxacomparison), scales = "free_x")

ggsave(filename = snakemake@output[[1]], plot = real_heatmap, device = "pdf")