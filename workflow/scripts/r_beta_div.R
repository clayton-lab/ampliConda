phyloseq = readRDS(snakemake@input$phyloseq)
category = snakemake@params$category

library(phyloseq)
library(ggplot2)

bray_nmds_ordination <- ordinate(phyloseq, 
                           method="NMDS", 
                           distance="bray")

beta_div <- plot_ordination(phyloseq, 
                            bray_nmds_ordination, 
                            color=category) + stat_ellipse(type = "norm", linetype = 2) +
  stat_ellipse(type = "t", level=0.95) +
  theme_grey()

ggsave(filename = snakemake@output[[1]], plot = beta_div, device = "pdf")