library(dada2)

filtFs = readRDS('R_output/filtFs.RDS')
filtRs = readRDS('R_output/filtRs.RDS')
max_reads_processed = snakemake

derepFs = dada2::derepFastq(filtFs, n = max_reads_processed, verbose = TRUE)
derepRs = dada2::derepFastq(filtRs, n = max_reads_processed, verbose = TRUE)

names(derepFs) = sample.names
names(derepRs) = sample.names

saveRDS(derepFs, snakemake@output[[1]])
saveRDS(derepRs, snakemake@output[[2]])