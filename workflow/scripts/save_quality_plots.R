

fPlot = readRDS(snakemake@input$fPlot)
rPlot = readRDS(snakemake@input$rPlot)

bothQualityPlots = gridExtra::grid.arrange(fPlot, rPlot, nrow = 1)

ggplot2::ggsave(filename = snakemake@output[[1]], plot = bothQualityPlots, device = "pdf", height = 6, width = 10, units = "in")