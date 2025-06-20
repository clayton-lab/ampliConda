#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --mem=105gb
#SBATCH --time=72:00:00
#SBATCH --job-name=jhernandez
#SBATCH --open-mode=truncate                    # Can change to 'append' to append to existing file
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out
#SBATCH --chdir=/work/claytonlab/jhernandez     # Allows Slurm to automatically change working directories upon starting
# #SBATCH --partition=gpu                        # Use this command the the one below to specify a GPU partition for the job
# #SBATCH --gres=gpu:1                           # Changing the number here requests more GPUs (PER NODE)
# #SBATCH --qos=ac_claytonlab                    # Priority access via claytonlab acknowledgement credits (uncomment to use)

# Makes it so the pipeline fails if an error is encountered
# Normal Bash behavior is to continue even if an error occurs
set -Eeuo pipefail

# Prints basic info about running job(s)
scontrol show job "${SLURM_JOBID}"

### Main script logic starts here ###
base_dir="/mnt/nrdstor/claytonlab/jhernandez"
snakefile="${base_dir}/projects/metaGnosis/Snakefile"
conda_prefix="/work/claytonlab/jhernandez/projects/nih_k01_pilot_aim1/full_shotgun_analysis/conda_envs_2"
output_dir="${base_dir}/projects/metaGnosis"
configfile="${base_dir}/projects/metaGnosis/config.yaml"

# You can also specify a different samples.tsv and units.tsv file by passing these parameters to snakemake:
# --config samples=/path/to/your/samples.tsv units=/path/to/your/units.tsv

echo "Activating environment"
module purge
module load mamba
conda activate snakemake-env

echo "Executing pipeline"
snakemake --cores ${SLURM_NTASKS_PER_NODE} --use-conda --conda-prefix "${conda_prefix}" -d "${output_dir}" -s "${snakefile}" --configfile "${configfile}"

#snakemake --cores 1 --use-conda --conda-prefix "${conda_prefix}" -d "${output_dir}" -s "${snakefile}" --configfile "${configfile}"
echo "Pipeline finished!"
