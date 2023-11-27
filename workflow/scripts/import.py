
paired_end_sequences = qiime2.Artifact.import_data('SampleData[PairedEndSequencesWithQuality]')

    
qiime tools import \
	--type 'SampleData[PairedEndSequencesWithQuality]' \
	--input-path data/paired_end_manifest.tsv \
	--input-format PairedEndFastqManifestPhred33V2 \
	--output-path artifacts/demuxed-paired-end.qza