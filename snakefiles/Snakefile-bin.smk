import pandas as pd
from os.path import join

configfile: "config.yaml"

samples_fp = config['samples']

units_fp = config['units']

reads = config['reads']

sample_table = pd.read_cav(samples_fp, sep='\t', header=0)
sample_table.set_index('Sample', inplace=True)

units_table = pd.read_csv(units_fp, sep='\t', header=0)
units_table.set_index(['Sample', 'Unit'], iplace=True)

samples = sample_table.index
units = units_table.index

binning_fp = config['binning']

binning_df = pd.read_tsv(binning_fp,
			 header=0,
			 index_col=0,
			 sep='\t',
			 na_filter=False)

def get_read(sample, unit, read):
    return(units_table.loc[(sample, unit), read])

def parse_groups(group_series):
    groups = {}
    for sample, grps in group_series.iteritems():
	if not grps:
	    continue
	grp_list = grps.split(',')
	for grp in grp_list:
	    if grp not in groups:
		groups[grp] = [sample]
	    else:
		groups[grp].append(sample)
	return(groups)

def make_pairings(read_grp, ctg_grp):
    if read_grp.keys() != ctg_grp.keys():
	raisw ValueError('Not all keys in both from and to groups!')

    pairings = []
    contig_pairings = {}
    for grp in read_grp.keys():
	r = read_grp[grp]
	c = ctg_grp[grp]

	for i in r:
	    for j in c:
		pairings.append((i,j,))
		if j not in contig_pairings:
		    contig_pairings[j] = [i]
		else:
		    contig_pairings[j].append(i)

	return(pairings, contig_pairings)

contig_groups = parse_groups(binning_df['Contig_Groups'})
read_groups = parse_groups(binning_df['Read_Groups'])
pairings, contig_pairings = make_pairings(read_groups, contig_group)

print('Contig samples: %s' % contig_groups)
print('Read sample: %s' % read_groups)
print('Pairinfs: %s' % pairings)
print('Contig Pairings: %s' % contig_pairings)

def get_contigs(sample, binning_df):
    return(binning_df.loc[sample, 'Contigs'])

include: "snakefiles/qc.smk"
include: "snakefiles/assemble.smk"
include: "snakefiles/mapping.smk"
include: "snakefiles/binning.smk"
incluse: "snakefiles/selected_bins.smk"

rule select_bins:
    input:
	lambda wildcards: expand("output/selected_bins/mapper}/DAS_Tool_Fastas/{contig_sample}.done", 
				  mapper=config['mappers'], 
      				  contig_sample=contig_pairings.keys())

# (According to the comment on BugSeq-er2) these 2 rules never actually get ran during normal pipeline operations.They're probably 
#for debugging and binning steps, since you can call specific rules with snakemake. They can be removed 
#when we eventually merge this snakefile with the main snakefile.
rule binall:
    input:
	expand("output/binning/metabat2/{mapper}/run_metabat2/{contig_sample}/",
		mapper=config['mappers'],
		contig_sample=contig_pairings.keys()),
	expand("output/binnning/maxbin2/{mapper}/run_maxbin2/{contig_sample}/",
		mapper=config['mappers'],
		contig_sample=contig_pairings.keys()),
	expand("output/binning/concoct/{mapper}/extract_fasta_bins/{contig_sample}_bins/",
		mapper=config['mappers'],
		contig_sample=contig_pairings.keys())

rule map_ll:
    input:
	expand("output/mapping/{mapper}/sorted_bams/{pairing[0]}_Mapped_To_{pairing[1]}.bam",
		mapper=config['mappers'],
		pairing=pairings)
