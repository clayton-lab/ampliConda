phyloseq = readRDS(snakemake@input$phyloseq)
taxalevel = snakemake@params$taxalevel
taxacomparison = snakemake@params$taxacomparison

library(phyloseq)
library(ggplot2)
library(tidyverse)


barplot_absolute <- plot_bar(phyloseq, x="Sample", y="Abundance", fill=taxalevel) +
geom_bar(aes(fill = .data[[taxalevel]], color = .data[[taxalevel]]), stat = "identity", position = "stack") +
facet_wrap(reformulate(taxacomparison), scales = "free_x") + theme_bw() + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))

ggsave(filename = snakemake@output[[1]], plot = barplot_absolute, device = "pdf")
