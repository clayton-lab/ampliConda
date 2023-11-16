# Main entrypoint of the workflow. 
# Please follow the best practices: 
# https://snakemake.readthedocs.io/en/stable/snakefiles/best_practices.html,
# in particular regarding the standardized folder structure mentioned there. 
import pandas as pd

configfile: "config/config.yaml"

# still working on this rule
#rule setup:
#    shell:
#        "module load qiime2/2022.2 "
#        "module load snakemake/6.4 "
#        "module load R/4.3"

rule import:
    input:
        "data/paired_end_manifest.tsv"
    output:
        "artifacts/demux-paired-end.qza"
    conda:
        "envs/qiime2.yml"
    log:
        ".snakemake/log/import.log"
    shell:
        "qiime tools import "
        "--type 'SampleData[PairedEndSequencesWithQuality]' "
        "--input-path {input} "
        "--output-path {output} "
        "--input-format PairedEndFastqManifestPhred33V2"

rule demux_summarize:
    input:
        "artifacts/demux-paired-end.qza"
    output:
        "artifacts/demux-paired-end.qzv"
    conda:
        "envs/qiime2.yml"
    log:
        ".snakemake/log/demux_summarize.log"
    shell:
        "qiime demux summarize "
	    "--i-data {input} "
	    "--o-visualization {output}"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~AT THIS POINT, INVESTIGATE THE demux-paired-end.qzv file to specify your trimming parameters~~~~~~~~~~~~~~~~

rule denoise_paired:
    input:
        "artifacts/demux-paired-end.qza"
    output:
        "artifacts/paired-end-demux-trimmed.qza "
        "artifacts/table.qza "
        "artifacts/denoising-stats.qza"
    conda:
        "envs/qiime2.yml"
    shell:
        "qiime dada2 denoise-paired "
        "--i-demultiplexed-seqs {input}"
        "--p-trunc-len-f 270 "
        "--p-trunc-len-r 230 "
        "--p-trim-left-f 110 "
        "--p-trim-left-r 75 "
        "--o-table artifacts/table.qza "
        "--o-representative-sequences artifacts/paired-end-demux-trimmed.qza "
        "--o-denoising-stats artifacts/denoising-stats.qza"

rule trimmed_summarize:
    input:
        "artifacts/paired-end-demux-trimmed.qza"
    output:
        "artifacts/paired-end-demux-trimmed.qzv"
    conda:
        "envs/qiime2.yml"
    shell:
        "qiime demux summarize " 
        "--i-data {input} "
	    "--o-visualization {output}"

rule metadata_tabulate:
    input:
        "artifacts/denoising-stats.qza"
    output:
        "artifacts/denoising-stats-viz-qzv"
    conda:
        "envs/qiime2.yml"
    shell:
        "qiime metadata tabulate "
        "--m-input-file {input} "
        "--o-visualization {output}"

## workflow functions up to this point with data ############################################################################################

rule feature_table_summarize:
    input:
        "artifacts/filtered-table.qza",
        "dog_manifest.tsv"
    output:
        "artifacts/table-viz.qzv"
    shell:
        "scripts/feature_table_summarize.py"

rule tabulate_seqs:
    input:
        "artifacts/rep-seqs.qza"
    output:
        "artifacts/rep-seqs.qzv"
    shell:
        "scripts/tabulate_seqs.py,echo 'starting mafft fasttree and diversity operations'"

rule mafft_fasttree:
    input:
        "artifacts/rep-seqs.qza"
    output:
        "aligned-rep-seqs.qza",
        "artifacts/masked-aligned-rep-seqs.qza",
        "artifacts/unrooted-tree.qza",
        "artifacts/rooted-tree.qza"
    shell:
        "scripts/mafft_fasttree.py"

rule classify_sklearn:
    input:
        "$(classifier)", #put in classifier here
        "artifacts/rep-seqs.qza"
    output:
        "artifacts/taxonomy.qza"
    shell:
        "scripts/classify_sklearn.py"

rule phylogeny_tabulate:
    input:
        "artifacts/taxonomy.qza"
    output:
        "artifacts/taxonomy.qzv"
    shell:
        "scripts/phylogeny_tabulate.py"
        
rule core_metrics_phylogenetic:
    input:
        "artifacts/rooted-tree.qza",
        "artifacts/table.qza",
        "$(sampling_depth)",
        "Dog_metadata.tsv"
    output:
        "core-metrics-results/"
    shell:
        "scripts/core_metrics_phylogenetic.py"

rule bray_curtis:
    input:
        "core-metrics-results/bray_curtis_distance_matrix.qza"
    output:
        "artifacts/bray-curtis-pcoa-matrix.qza"
    shell:
        "scripts/bray_curtis.py"

rule unweighted_unifrac:
    input:
        "core-metrics-results/unweighted_unifrac_distance_matrix.qza"
    output:
        "artifacts/unweighted-unifrac-pcoa-matrix.qza"
    shell:
        "scripts/unweighted_unifrac.py"

rule weighted_unifrac:
    input:
        "core-metrics-results/weighted_unifrac_distance_matrix.qza"
    output:
        "artifacts/weighted-unifrac-pcoa-matrix.qza"
    shell:
        "scripts/weighted_unifrac.py"

rule jaccard:
    input:
        "core-metrics-results/jaccard_distance_matrix.qza"
    output:
        "artifacts/jaccard-pcoa-matrix.qza"
    shell:
        "scripts/jaccard.py"