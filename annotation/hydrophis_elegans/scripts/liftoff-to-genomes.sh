#!/usr/bin/env bash

# NOTE: This is adapted from a SLURM submission script.

# Directories ---
DIR='/hpcfs/users/a1645424/analysis/liftoff'

GFFS="${DIR}/gffs"
REFS="${DIR}/genomes"
OUT="${DIR}/results"

# Genomes to annotate
TMP='hydrophis_elegans hydrophis_curtus-AG hydrophis_ornatus'
BN=$(echo "${TMP}" | cut -d ' ' -f "${SLURM_ARRAY_TASK_ID}")

mkdir -p "${OUT}/${BN}"

# Conda set up ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate liftoff

# Set up reference information to lift-over from
QRY_ASM="${REFS}/${BN}.fa"
TGT_ASM="${REFS}/hydrophis_major.fa"
TGT_GFF="${GFFS}/hydrophis_major.gff3"

liftoff \
    "${QRY_ASM}" \
    "${TGT_ASM}" \
    -g "${TGT_GFF}" \
    -o "${OUT}/${BN}/${BN}.gff3" \
    -u "${OUT}/${BN}/${BN}-unmapped.txt" \
    -exclude_partial \
    -dir "${OUT}/${BN}/intermediates" \
    -p "${SLURM_CPUS_PER_TASK}" \
    -polish

conda deactivate

