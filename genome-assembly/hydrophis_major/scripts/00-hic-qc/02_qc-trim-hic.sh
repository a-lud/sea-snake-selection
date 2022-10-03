#!/usr/bin/env bash

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate fastp

HIC="/home/a1645424/al/alastair-phd/bpa/hic-kraken"
OUT="/home/a1645424/al/alastair-phd/bpa/hic-trim"
OUTQC="/home/a1645424/al/alastair-phd/bpa/qc/fastp-hic"

mkdir -p ${OUT} ${OUTQC}

fastp \
    -i ${HIC}/350845_1.fastq.gz \
    -I ${HIC}/350845_2.fastq.gz \
    -o ${OUT}/350845_R1.fastq.gz \
    -O ${OUT}/350845_R2.fastq.gz \
    --thread 16 \
    --compression 9 \
    --length_required 75 \
    --html ${OUTQC}/350845.html \
    --json ${OUTQC}/350845-fastp.json

conda deactivate

