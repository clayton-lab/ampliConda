FORWARD_TRUNC = snakemake@params$FORWARD_TRUNC
REVERSE_TRUNC = snakemake@params$REVERSE_TRUNC
fnFs = readRDS('R_output/fnFs.RDS')
fnRs = readRDS('R_output/fnRs.RDS')
filtFs = readRDS('R_output/filtFs.RDS')
filtRs = readRDS('R_output/filtRs.RDS')

manual_out = dada2::filterAndTrim(fnFs, filtFs, fnRs, filtRs,
                     truncLen=c(FORWARD_TRUNC,REVERSE_TRUNC), 
                     trimLeft=c(20, 20), maxEE=c(2,2), 
                     matchIDs=TRUE, compress=TRUE, 
                     verbose=TRUE)

saveRDS(manual_out, snakemake@output[[1]])