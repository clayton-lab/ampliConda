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

target = "core-metrics-results/faith_pd.qzv"

rule all:
    input:
        target

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ BEGINNING OF QIIME2 ANALYSIS SECTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rule qiime2_import:
    input:
        config["manifest"]
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

rule qiime2_demux_summarize:
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

#AT THIS POINT, INVESTIGATE THE demux-paired-end.qzv file to specify your trimming parameters

rule qiime2_denoise_paired:
    input:
        "artifacts/demux-paired-end.qza"
    output:
        "artifacts/paired-end-demux-trimmed.qza",
        "artifacts/table.qza",
        "artifacts/denoising-stats.qza"
    conda:
        "envs/qiime2.yml"
    shell:
        "qiime dada2 denoise-paired "
        "--i-demultiplexed-seqs {input}"
        "--p-trunc-len-f 260 "
        "--p-trunc-len-r 230 " #modularization
        "--p-trim-left-f 112 "
        "--p-trim-left-r 77 "
        "--o-table artifacts/table.qza "
        "--o-representative-sequences artifacts/paired-end-demux-trimmed.qza "
        "--o-denoising-stats artifacts/denoising-stats.qza "
        "--p-n-threads 4" #subject to change, may make into a wildcard

rule qiime2_trimmed_summarize:
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

# DADA2 return code -9 is a memory issue; run with more cores

rule qiime2_metadata_tabulate:
    input:
        "data/paired_end_metadata.tsv" # must be a .tsv NOT a .csv
    output:
        "artifacts/metadata_tabulated.qzv"
    conda:
        "envs/qiime2.yml"
    shell:
        "qiime metadata tabulate "
        "--m-input-file {input} "
        "--o-visualization {output}"

rule feature_table_summarize:
    input:
        "artifacts/filtered-table.qza",
        "data/paired_end_metadata.tsv"
    output:
        "artifacts/table-viz.qzv"
    conda:
        "envs/qiime2.yml"
    shell:
        "qiime feature-table summarize "
        "--i-table artifacts/table.qza "
        "--o-visualization artifacts/table-viz.qzv "
        "--m-sample-metadata-file data/paired_end_metadata.tsv"

rule tabulate_seqs:
    input:
        "artifacts/demux-paired-end.qza"
    output:
        "artifacts/demux-paired-end.qzv"
    shell:
        "qiime feature-table tabulate-seqs "
        "--i-data {input} "
        "--o-visualization {output}"

rule mafft_fasttree:
    input:
        "artifacts/paired-end-demux-trimmed.qza"
    output:
        "aligned-rep-seqs.qza",
        "artifacts/masked-aligned-rep-seqs.qza",
        "artifacts/unrooted-tree.qza",
        "artifacts/rooted-tree.qza"
    shell:
        "qiime phylogeny align-to-tree-mafft-fasttree "
        "--i-sequences {input} "
        "--o-alignment artifacts/aligned-rep-seqs.qza "
        "--o-masked-alignment artifacts/masked-aligned-rep-seqs.qza "
        "--o-tree artifacts/unrooted-tree.qza "
        "--o-rooted-tree artifacts/rooted-tree.qza"

## workflow functions up to this point with data ############################################################################################

rule classify_sklearn:
    input:
        classifier = "classifier/silva-138-99-nb-classifier.qza",
        seq = "artifacts/rep-seqs.qza"
    output:
        "artifacts/taxonomy.qza"
    shell:
        "qiime feature-classifier classify-sklearn "
        "--i-classifier {input.classifier} "
        "--i-reads {input.seq} "
        "--o-classification artifacts/taxonomy.qza"

rule phylogeny_tabulate:
    input:
        "artifacts/taxonomy.qza"
    output:
        "artifacts/taxonomy.qzv"
    shell:
        "qiime metadata tabulate "
        "--m-input-file artifacts/taxonomy.qza "
        "--o-visualization artifacts/taxonomy.qzv"

rule core_metrics_phylogenetic:
    input:
        "artifacts/rooted-tree.qza",
        "artifacts/table.qza",
        "data/paired_end_metadata.tsv"
    output:
        "core-metrics-results/bray_curtis_distance_matrix.qza",
        "core-metrics-results/unweighted_unifrac_distance_matrix.qza",
        "core-metrics-results/evenness_vector.qza",
        "core-metrics-results/faith_pd_vector.qza"
    params:
        config = 1103 #config["sampling_depth"],#download the table.qzv file to choose a proper sampling depth"
    shell:
        "qiime diversity core-metrics-phylogenetic "
        "--i-phylogeny rooted-tree.qza "
        "--i-table table.qza "
        "--p-sampling-depth {params.config} " #should be 1103
        "--m-metadata-file sample-metadata.tsv "
        "--output-dir core-metrics-results"

rule bray_curtis_beta:
    input:
        "core-metrics-results/bray_curtis_distance_matrix.qza"
    output:
        "artifacts/bray-curtis-pcoa-matrix.qza"
    shell:
        "qiime diversity beta-group-significance "
        "--i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza "
        "--m-metadata-file data/paired_end_metadata.tsv "
        "--m-metadata-column Groups " #another thing that we can modularize
        "--o-visualization core-metrics-results/bray-curtis-Group-significance.qzv "
        "--p-pairwise"

rule unweighted_unifrac_beta:
    input:
        "core-metrics-results/unweighted_unifrac_distance_matrix.qza"
    output:
        "artifacts/unweighted-unifrac-pcoa-matrix.qza"
    shell:
        "qiime diversity beta-group-significance "
        "--i-distance-matrix core-metrics-results/unweighted_unifrac_distance_matrix.qza "
        "--m-metadata-file data/paired_end_metadata.tsv "
        "--m-metadata-column Groups " #modularize
        "--o-visualization core-metrics-results/unweighted-unifrac-Group-significance.qzv "
        "--p-pairwise"

rule evenness_alpha:
    input:
        "core-metrics-results/evenness_vector.qza"
    output:
        "acore-metrics-results/evenness-group-significance.qzv"
    shell:
        "qiime diversity alpha-group-significance "
        "--i-alpha-diversity core-metrics-results/evenness_vector.qza "
        "--m-metadata-file data/paired_end_metadata.tsv "
        "--o-visualization core-metrics-results/evenness-group-significance.qzv"

rule faith_alpha:
    input:
        "core-metrics-results/faith_pd_vector.qza"
    output:
        "core-metrics-results/faith_pd.qzv"
    shell:
        "qiime diversity alpha-group-significance "
        "--i-alpha-diversity core-metrics-results/faith_pd_vector.qza "
        "--m-metadata-file data/paired_end_metadata.tsv "
        "--o-visualization core-metrics-results/faith_pd.qzv"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END OF QIIME2 ANALYSIS SECTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ BEGINNING OF DADA2 ANALYSIS SECTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~