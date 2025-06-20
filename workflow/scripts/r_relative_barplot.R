phyloseq = readRDS(snakemake@input$phyloseq)
taxalevel = snakemake@params$taxalevel
taxacomparison = snakemake@params$taxacomparison

library(phyloseq)
library(ggplot2)
library(tidyverse)

ps_relabund <- transform_sample_counts(phyloseq, function(x) x / sum(x))

barplot_relative <- plot_bar(ps_relabund, x="Sample", y="Abundance", fill=taxalevel) +
geom_bar(aes(fill = .data[[taxalevel]], color = .data[[taxalevel]]), stat = "identity", position = "stack") +
facet_wrap(reformulate(taxacomparison), scales = "free_x") + theme_bw()

ggsave(filename = snakemake@output[[1]], plot = barplot_relative, device = "pdf")