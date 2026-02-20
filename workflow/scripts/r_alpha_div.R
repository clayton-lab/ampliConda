phyloseq = readRDS(snakemake@input$phyloseq)
color = snakemake@params$color
xaxis = snakemake@params$xaxis

library(phyloseq)
library(ggplot2)

full_shannon <- plot_richness(
  phyloseq,
  x = xaxis,
  measures = "Shannon",
  color = color
)

full_shannon$layers[[1]]$aes_params$alpha <- 0.3

alpha_div <- full_shannon +
  stat_smooth(
    method = "gam",
    se = TRUE,
    level = 0.95,
    linewidth = 1.2
  ) +
  theme_grey()
  
ggsave(filename = snakemake@output[[1]], plot = alpha_div, device = "pdf")