#!/usr/bin/env bash
#SBATCH ...

GENOMES="/hpcfs/users/a1645424/analysis/repeat-sea-snakes/genomes"
CDS='/hpcfs/users/a1645424/analysis/repeat-sea-snakes/cds'
DIR='/hpcfs/users/a1645424/analysis/repeat-sea-snakes'

# Get current snake
ASM=$(find "${GENOMES}" -type f -name '*.fa' | tr '\n' ' ' | cut -d' ' -f "${SLURM_ARRAY_TASK_ID}")
BN=$(basename "${ASM%.*}")

# Output directory
OUT="${DIR}/resuts/${BN}"

mkdir -p "${OUT}"

cd "${OUT}" || exit 1

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate EDTA

EDTA.pl \
    --genome "${ASM}" \
    --step 'filter' \
    --overwrite 0 \
    --cds "${CDS}/${BN}.cds" \
    --threads "${SLURM_CPUS_PER_TASK}"

conda deactivate

