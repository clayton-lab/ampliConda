#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --mem=32gb
#SBATCH --time=6:00:00
#SBATCH --job-name=step-2-ampliConda
#SBATCH --error=/work/claytonlab/cschinzel/job.%J.err
#SBATCH --output=/work/claytonlab/cschinzel/job.%J.out

module load qiime2/2022.2
module load snakemake/6.4

cd /common/claytonlab/cschinzel/repos/ampliConda/

snakemake --cores all
