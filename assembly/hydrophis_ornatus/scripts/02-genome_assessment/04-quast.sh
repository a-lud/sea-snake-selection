#!/usr/bin/env bash
#SBATCH --job-name=quast
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 20
#SBATCH -a 1-2
#SBATCH --time=02:00:00
#SBATCH --mem=20GB
#SBATCH -o /hpcfs/users/a1645424/analysis/quast/scripts/joblogs/%x_%a_%A_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

DIR='/hpcfs/users/a1645424/analysis/quast'
GENOMES="${DIR}/genomes"
OUT="${DIR}/results"

mkdir -p "${OUT}"

# Get genome
ASM=$(find ${GENOMES} -type l -name '*.fa' | tr '\n' ' ' | cut -d ' ' -f "${SLURM_ARRAY_TASK_ID}")
BN=$(basename "${ASM%.*}")

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate quast

quast \
    --output-dir "${OUT}/${BN}" \
    --threads "${SLURM_CPUS_PER_TASK}" \
    --split-scaffolds \
    --eukaryote \
    --plots-format png \
    --no-icarus \
    "${ASM}"

conda deactivate
