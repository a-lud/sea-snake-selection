#!/usr/bin/env bash
#SBATCH ...

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
