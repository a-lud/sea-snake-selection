#!/usr/bin/env bash

DIR='/home/a1645424/al/hydrophis-major/metaeuk'
ASM='/home/a1645424/al/hydrophis-major/repeats/softmasked/hydmaj-p_ctg-v1.sm.fna'
PRO="${DIR}/snake-proteins-clean-header.fasta"
OUT="${DIR}/metaeuk-homology-original-header"

mkdir -p ${OUT}

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate metaeuk

metaeuk easy-predict \
    "${ASM}" \
    "${PRO}" \
    "${OUT}/metaeuk-predictions" \
    "${OUT}" \
    --min-seq-id 0.7 \
    --max-intron 150000 \
    --threads 50 \
    --headers-split-mode 1

conda deactivate

