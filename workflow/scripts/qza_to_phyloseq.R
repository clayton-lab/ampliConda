
features = snakemake@input$features
tree = snakemake@input$tree
taxonomy = snakemake@input$taxonomy
metadata = snakemake@input$metadata

library(qiime2R)
library(dplyr)

physeq <- qiime2R::qza_to_phyloseq(features=features, tree=tree, taxonomy=taxonomy, metadata=metadata)

saveRDS(physeq, snakemake@output[[1]])

# physeq <- qza_to_phyloseq(features='artifacts/table-filtered.qza', tree='artifacts/rooted-tree.qza', taxonomy='artifacts/taxonomy.qza', metadata='data/soybean_metadata.tsv')