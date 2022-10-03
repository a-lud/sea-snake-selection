#!/usr/bin/env bash

RNA='/home/a1645424/al/alastair-phd/bpa/bpa_d0af4afe_20210827T0331'
RNAAG='/home/a1645424/al/alastair-phd/bpa/rna'
OUT='/home/a1645424/al/alastair-phd/bpa/qc/fastqc'

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate BIOTOOLS_env

mkdir -p "${OUT}/raw-lane"
mkdir -p "${OUT}/raw-merged"

fastqc \
    -o "${OUT}/raw-lane" \
    -k 9 \
    -t 20 \
    ${RNA}/*.gz

fastqc \
    -o "${OUT}/raw-merged" \
    -k 9 \
    -t 20 \
    ${RNAAG}/*.gz

conda deactivate
