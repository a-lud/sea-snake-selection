#!/usr/bin/env bash

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate BIOTOOLS_env

export PYTHONIOENCODING=utf-8

FASTQC="/home/a1645424/al/alastair-phd/bpa/qc/fastqc/raw-merged"
KRAKEN="/home/a1645424/al/alastair-phd/bpa/qc/kraken"
FASTP="/home/a1645424/al/alastair-phd/bpa/qc/fastp"
REPORTDIR="/home/a1645424/al/alastair-phd/bpa/qc/mqc-report"

mkdir -p ${REPORTDIR}

multiqc \
    --config ./mqc.yaml \
    --force \
    --title "Hydrophis Major: Ramaciotti RNA-seq" \
    --filename hydrophis-major-multiqc \
    --outdir ${REPORTDIR} \
    ${FASTQC} ${KRAKEN} ${FASTP}

conda deactivate
