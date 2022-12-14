#!/usr/bin/env bash
#SBATCH --job-name=EDTA-p_ctg-ltr
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 40
#SBATCH --ntasks-per-core=2
#SBATCH --time=24:00:00
#SBATCH --mem=40GB
#SBATCH -o /home/a1645424/hpcfs/hydmaj-genome/repeats/slurm/%x_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

ASM='/home/a1645424/hpcfs/hydmaj-genome/hydmaj-chromosomes/hydmaj-p_ctg-v1.fna'
OUT="/home/a1645424/hpcfs/hydmaj-genome/repeats/edta-p_ctg-out"

mkdir -p "${OUT}"

cd "${OUT}" || exit 1

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate EDTA

EDTA_raw.pl \
    --genome ${ASM} \
    --type 'ltr' \
    --threads ${SLURM_CPUS_PER_TASK}

conda deactivate

