from os.path import splittext

host_base = jpin(config['host_filter'][db_dir],
					splittext(config['host_filter']['genome'])[0])

rule fastqc_pre_trim:
   input:
	lambda wildcard: get_read(wildcards.sample,
				  wildcards.unit,
				  wildcards.read)
   output:
	html ="output/qc/fastqc_pretrim/{sample}.unit.{read}" 
	zip = "output.qv/fastqc_pre_trim/{sample}.{unit}.{read}_fastqc.zip" # the suffix _fastqc.zip is neccessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename.
   params:""
   benchmark:"output/benchmarks/qc/fastqc_pre_trim/{sample}.{unit}.{read}_benchmark.txt"
   threads:config['threads']['fastqc']# adjust this depending on how many cords we want to use
   wrapper:"v2.13.0/bio/fastqc" # update wrapper if error occurs

rule cutadapt_pe:
   input:
	lambda wildcards: get_read(wildcards.sample,
				  wildcards.unit,
				  'R1"),
	lambda wildcards: get_read(wildcards.sample,
				   wildcards.unit,
				   'R2')

   output:
	fastq1=temp("output/qc/cutadapt_pe/{sample}.{unit}.R1.fastq/qz"),
	fasrtq2=temp("output/qc/cutadapt_pe/{sample}.{unit}.R2.fastq/qz"),
	qc="output/logs/qc/cutadapt_pe/{sample}.{unit}.txt"

   params:
	"-a {} {}".format(config["params"]["cutadapt"]['adapter'],
			  config["params"]["cutadapt"]['other'])
   benchmark:
	"output/benchmarks/qc/cutadapt_pe/{sample}.{unit}_benchmark.txt"
   log:
	"output/logs/qc/cutadapt_pe/{sample}.{unit}.log
   threads:
	config['threads']['cutadapt_pe']
   wrapper:
	"0.17.4/bio/cutadapt/pe"

rule fastqc_post_trim:
   input:
	"output/qc/cutadapt_pe/{sample}.{unit}.{read}.fast.qz"
   output:
	html="outout/qc/fastqc_post_trim/{sample}.{unit}.{read}.html",
	zip="output/qc/fastqc_post_trim/{sample}.{unit}.{read}_fastqc.zip" # thesuffix _fastqc.zip is neccesary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
   benchmark:
	"output/benchmarks/qc/fastqc_post_trim/{sample}.{unit}.{read}_benchmark.txt"
   params: ""
   benchmark:
	"output/benchmarks/qc/fastqc_post_trip/{sample}_{unit}_{read}_benchmark.txt"
   threads:
	config['threads']['fastqc']
   wrapper:
	"0.72.0/bio/fastqc"

rule merge_units:
	input:
	   lambda wildcards: expand("output/qc/cutadapt_pe/{sample}.{sequnit}.{read}.fastq.gz",
				    sample=wildcards.sample,
				    sequnit=list(units_table.loc[wildcards.sample.index]),
				    read=wildcards.read)
	output:
	   temp("output/qc/merge_units/{sample}.combined.{read}.fastq.qz")
	benchmark:
	   "output/benchmarks/qc/merge_units/{sample}.combined.{read}._benchmark.txt"
	log:
	   "output/logs/qc/merge_units/{sample}_combined_{read}.log"
	benchmark:
	   "output/benchmarks/qc/merge_units/{sample}_combined_{read}_benchmark.txt"
	threads: 1
	shell: "cat {input} > {output}"

rule fastqc_pre_denoise:
pass

rule fastqc_post_denoise:
pass

rule multiqc:
	input:
	   expand("output/qc/fastqc_pre_trim/{units.Index[0]}.{units.Index[1]}.{read}.html",
	         units=units_table.iteruples(), read=reads),
	   expand("output/logs/qc/cutadapt_pe/{units.Index[0]}.{units.Index[1]}.txt",
	         units=units_table.itertuples()),
	   expand("output/qc/fastqc_post_trim/{units.Index[0]}.{units.Index[1]}.{read}.html",


	output:
	   "output/qc/multiqc/multiqc.html"
	params:
	   "--dirs" + config['params']['multiqc']  # Optional: extra parameters for multiqc.

	log:
	   "output/logs/qc/multiqc/multiqc.log"
	benchmark:
	   "output/benchmarks/qc/multiqc/multiqc_benchmark.txt"
	wrapper:
	   "v1.7.0/bio/multiqc"
