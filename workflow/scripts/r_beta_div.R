phyloseq = readRDS(snakemake@input$phyloseq)
category = snakemake@params$category

library(phyloseq)
library(ggplot2)

ps_bray <- ordinate(phyloseq, "NMDS", "bray")
beta_div <- plot_ordination(phyloseq, ps_bray, type=category, color=category) + geom_point(size = 4) + theme_bw()
ggsave(filename = snakemake@output[[1]], plot = beta_div, device = "pdf")