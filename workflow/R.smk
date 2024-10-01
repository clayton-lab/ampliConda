import pandas as pd

configfile: "config/config.yaml"

rule define_metadata: 
    input: config["R_metadata"]
    output: 'R_objects/metadata.RDS'
    conda: 'envs/ampliConda_R_2.yml'
    script: 
        'scripts/define_metadata.R'

rule read_metadata:
    input: 'metadata'
    output: 'metadata_df'
    conda: 'envs/ampliConda_R_2.yml'
    shell: 
        'metadata_df = read.csv(metadata)'

rule metadata_aspects:
    input: 'metadata_df'
    output: 'fnFs','fnRs','sample.names'
    conda: 'envs/ampliConda_R_2.yml'
    shell: 
        'fnFs = metadata_df$Read1 '
        'fnRs = metadata_df$Read2 '
        'sample.names = metadata_df$sample_id'

rule separate_plots:
    input: 'fnFs','fnRs'
    output: 'fPlot','rPlot'
    conda: 'envs/ampliConda_R_2.yml'
    shell: 
        'fPlot <- dada2::plotQualityProfile(fnFs, aggregate = TRUE) + ggtitle("Forward") + geom_hline(yintercept =  30, colour = "blue") '
        'rPlot <- dada2::plotQualityProfile(fnRs, aggregate = TRUE) + ggtitle("Reverse") + geom_hline(yintercept =  30, colour = "blue")'

rule combine_plots:
    input: 'fPlot','rPlot'
    output: 'bothQualityPlots'
    conda: 'envs/ampliConda_R_2.yml'
    shell:
        'bothQualityPlots = grid.arrange(fPlot, rPlot, nrow = 1)'

rule save_quality_plots:
    input: 'bothQualityPlots'
    output: 'visual_results/bothQualityPlots.pdf'
    conda: 'envs/ampliConda_R_2.yml'
    shell:
        'ggsave(bothQualityPlots, path = "visual_results/bothQualityPlots.pdf", filename = "bothQualityPlots.pdf", device = "pdf", height = 6, width = 5, units = "in")'