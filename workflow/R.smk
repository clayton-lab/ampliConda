import pandas as pd

configfile: "config/config.yaml"

rule define_metadata: 
    input: config["R_metadata"]
    output: 'R_output/metadata.RDS'
    conda: 'envs/ampliConda_R_2.yml'
    script: 
        'scripts/define_metadata.R'

""" rule read_metadata:
    input: 'metadata'
    output: 'metadata_df'
    conda: 'envs/ampliConda_R_2.yml'
    shell: 
        'metadata_df = read.csv(metadata)' 
"""

rule metadata_aspects:
    input:
        'R_output/metadata.RDS'
    output:
        fnFs = 'R_output/fnFs.RDS',
        fnRs = 'R_output/fnRs.RDS',
        sample_names = 'R_output/sample_names.RDS',
        filtFs = 'R_output/filtFs.RDS',
        filtRs = 'R_output/filtRs.RDS'
    conda: 
        'envs/ampliConda_R_2.yml'
    log:
        'logs/metadata_aspects.log'
    script: 
        'scripts/metadata_aspects.R'

rule separate_plots:
    input: 'R_output/fnFs.RDS','R_output/fnRs.RDS'
    output: 
        fPlot = 'R_output/fPlot.RDS',
        rPlot = 'R_output/rPlot.RDS'
    conda: 'envs/ampliConda_R_2.yml'
    script: 
        'scripts/separate_plots.R'

"""
rule combine_plots:
    input: 
        fPlot = 'R_output/fPlot.RDS',
        rPlot = 'R_output/rPlot.RDS'
    output: 'bothQualityPlots'
    conda: 'envs/ampliConda_R_2.yml'
    shell:
        'bothQualityPlots = grid.arrange(fPlot, rPlot, nrow = 1)'
"""

rule save_quality_plots:
    input: 
        fPlot = 'R_output/fPlot.RDS',
        rPlot = 'R_output/rPlot.RDS'
    output: 
        'R_output/visual_results/bothQualityPlots.pdf'
    conda: 'envs/ampliConda_R_2.yml'
    script:
        'scripts/save_quality_plots.R'

rule manual_trim:
    input:
        fnFs = 'R_output/fnFs.RDS',
        fnRs = 'R_output/fnRs.RDS',
        filtFs = 'R_output/filtFs.RDS',
        filtRs = 'R_output/filtRs.RDS'
    params:
        FORWARD_TRUNC = config["forward_trunc_R"],
        REVERSE_TRUNC = config["reverse_trunc_R"]
    output:
        manual_out = 'R_output/manual_out.RDS'
    conda:
        "envs/ampliConda_R_2.yml"
    script:
        'scripts/manual_trim.R'

rule automated_trim:
    input:
        fnFs = 'R_output/fnFs.RDS',
        fnRs = 'R_output/fnRs.RDS',
        filtFs = 'R_output/filtFs.RDS',
        filtRs = 'R_output/filtRs.RDS'
    params:
        truncQ = config["minimum_sequence_quality"]
    output:
        automated_out = 'R_output/automated_out.RDS'
    conda:
        "envs/ampliConda_R_2.yml"
    script:
        'scripts/manual_trim.R'

rule dereplication:
    input:
        filtFs = 'R_output/filtFs.RDS',
        filtRs = 'R_output/filtRs.RDS'
    params:
        max_reads_processed = config["max_sequences_processed"]
    output:
        'R_output/derepFs.RDS',
        'R_output/derepRs.RDS'
    conda:
        "envs/ampliConda_R_2.yml"
    script:
        'scripts/dereplication.R'
"""
rule error_rates:
    input:
    params:
    output:
    conda:
    script:

rule sample_inference:
    input:
        trimmedFs = 'R_output/automated_out.RDS',
        trimmedFs = 'R_output/manual_out.RDS',
        trimmedRs = 
    params:
    output:
    conda:
    script:

"""