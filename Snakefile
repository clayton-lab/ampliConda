# Main entrypoint of the workflow. 
# Please follow the best practices: 
# https://snakemake.readthedocs.io/en/stable/snakefiles/best_practices.html,
# in particular regarding the standardized folder structure mentioned there. 
import pandas as pd

configfile: "config/config.yaml"

if config["Qiime2"]:
    target = #insert target artifacts here
elif config["DADA2"]:
    target = #insert target 
elif config["Mothur"]:
    target = #target
elif config["Pathoscope2"]:
    target = #target
else config["Kraken"]:
    target = #target

# still working on this rule
#rule setup:
#    shell:
#        "module load qiime2/2022.2 "
#        "module load snakemake/6.4 "
#        "module load R/4.3"

rule all:
    input:
        target


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ BEGINNING OF QIIME2 ANALYSIS SECTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
        "artifacts/paired-end-demux-trimmed.qza "
        "artifacts/table.qza "
        "artifacts/denoising-stats.qza"
    params:
        trunc-len-f = config["trunc-len-f"]
        trunc-len-r = config["trunc-len-r"]
    conda:
        "envs/qiime2.yml"
    shell:
        "qiime dada2 denoise-paired "
        "--i-demultiplexed-seqs {input}"
        "--p-trunc-len-f 260 "
        "--p-trunc-len-r 230 "
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
        "--i-table artifacts/table.qza ""
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
        "{classifier}", #put in classifier here
        "artifacts/rep-seqs.qza"
    output:
        "artifacts/taxonomy.qza"
    params:
        classifier = config["classifier"]
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
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END OF QIIME2 ANALYSIS SECTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ BEGINNING OF DADA2 ANALYSIS SECTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~