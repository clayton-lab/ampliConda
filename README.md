# ampliConda: Clayton Lab Workflow for 16S Processing and Analysis

## Overview
The following pipeline uses Snakemake to focus on streamlining current processing methods for 16S rRNA analysis. The pipeline is based upon the generalized methods employed by the QIIME2 platform with additional packages that allow for visual output to exists outside of the QIIME2 system. From a series of fastq files and some user-provided parameters, ampliConda will generated basic visual graphs as well as providing a phyloseq object upon which the user can continue to do more advanced analysis using whichever R packages they'd like.

## Quick Start Guide

### Installation

**Start by cloning the github repository:**

```
$ git clone git@github.com:clayton-lab/ampliConda.git --branch master
cd ampliConda
```

**The workflow has compatibility with conda, so installation of mamba is recommended.**

This can be done either manually:
```
$ conda install -c conda-forge mamba
```
or through whichever HPC environment is being used, provided the module is available:
```
$ module load mamba/x.x      # The x.x suffix denotes specific versions
```

**Next, installation of snakemake is required:**

```
$ mamba env create -n snakemake-env -f workflow/envs/snakemake.yaml
$ conda activate snakemake
```

### File Preparation

**Proper execution of this pipeline requires three key components to be provided by the user.**
1. A **manifest file** is a tab-separated file which maps sample identifiers to the absolute filepaths of the forward and reverse reads for each sample. This means that, provided your filepaths are properly referenced, you do not need to move any samples directly into the pipeline.
2. A **metadata file** uses the same sample identifiers from above and connects them to various variables of interest for the study.
More information about proper formatting of these files can be found in [QIIME2 Documentation](https://docs.qiime2.org/2024.10/tutorials/importing/)
3. The user must also provide a **classifier** through which sequences are assigned taxonomy. Pre-trained classifiers [exist](https://library.qiime2.org/data-resources#naive-bayes-classifiers-1) or the user may choose to train their own through [tutorials](https://docs.qiime2.org/2024.10/tutorials/feature-classifier/)
4. The final piece of the puzzle is the **config file**, where the user will adjust various parameters in the workflow, including trimming and truncation, sampling depth, table filtering parameters, and many more. Here, you also reference where the aforementioned manifest, metadata, and classifier files exist within the workflow.

**For the workflow to run, a target file must be referenced in line 5 of the workflow/Snakefile**

The pipeline can be run completely independently for a "bird's eye view" of the data as well as broken into steps for more meticulous analysis. At the bottom of the config file lies a four step series to run as well as recommended target files for each step. Between each step, simply swap out your target files for those of the next step.

### Running the Pipeline

**Once the files have been properly prepared, you are ready to run the pipeline as follows:**

```
conda install -n base -c conda-forge mamba
```

**Then begin the run using:**
```
snakemake --cores 8 --use-conda
#note that the number of cores may be subject to change based on the demands of your data.
```
