# Snakemake inputs and outputs
fnFs <- snakemake@input[["fnFs"]]
fnRs <- snakemake@input[["fnRs"]]
filtFs <- snakemake@output[["filtFs"]]
filtRs <- snakemake@output[["filtRs"]]

# Set truncation lengths and perform filtering
FORWARD_TRUNC <- 280
REVERSE_TRUNC <- 250

out <- dada2::filterAndTrim(
  fwd = fnFs,
  filt = filtFs,
  rev = fnRs,
  filt.rev = filtRs,
  truncLen = c(FORWARD_TRUNC, REVERSE_TRUNC),
  trimLeft = c(20, 20),
  maxEE = c(2, 2),
  matchIDs = TRUE,
  compress = TRUE,
  verbose = TRUE
)
