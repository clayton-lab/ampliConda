truncQ = snakemake@params$truncQ
fnFs = readRDS('R_output/fnFs.RDS')
fnRs = readRDS('R_output/fnRs.RDS')
filtFs = readRDS('R_output/filtFs.RDS')
filtRs = readRDS('R_output/filtRs.RDS')

automated_out = dada2::filterAndTrim(fnFs, filtFs, fnRs, filtRs,
                     truncLen=c(290, 285), 
                     truncQ=c (truncQ),
                     trimLeft=c(20, 20), maxEE=c(2,2), 
                     matchIDs=TRUE, compress=TRUE, 
                     verbose=TRUE)

saveRDS(automated_out, snakemake@output[[1]])