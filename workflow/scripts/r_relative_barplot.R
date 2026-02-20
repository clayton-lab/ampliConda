phyloseq = readRDS(snakemake@input$phyloseq)
taxalevel = snakemake@params$taxalevel
taxacomparison = snakemake@params$taxacomparison

library(phyloseq)
library(ggplot2)
library(tidyverse)
library(remotes)

remotes::install_github("gmteunisse/fantaxtic")

library(fantaxtic)


top_nested <- nested_top_taxa(phyloseq,
                              top_tax_level = "Phylum",
                              nested_tax_level = taxalevel,
                              n_top_taxa = 4, 
                              n_nested_taxa = 4)

barplot_relative <- plot_nested_bar(ps_obj = top_nested$ps_obj,
                top_level = "Phylum",
                nested_level = taxalevel) + 
            facet_wrap(as.formula(paste("~", taxacomparison)),
             scales = "free_x") + theme(axis.text.x = element_blank(), 
                  axis.ticks.x = element_blank())

ggsave(filename = snakemake@output[[1]], plot = barplot_relative, device = "pdf")