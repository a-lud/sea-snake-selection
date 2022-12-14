#!/usr/bin/env bash

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate multiqc

export PYTHONIOENCODING=utf-8

KRAKEN="/home/a1645424/al/alastair-phd/bpa/qc/kraken-hic"
FASTP="/home/a1645424/al/alastair-phd/bpa/qc/fastp-hic"
REPORTDIR="/home/a1645424/al/alastair-phd/bpa/qc/mqc-report"

mkdir -p ${REPORTDIR}

multiqc \
    --config ./mqc.yaml \
    --force \
    --title "Arima Hi-C" \
    --filename hydrophis-major-hic-multiqc \
    --outdir ${REPORTDIR} \
    ${KRAKEN} ${FASTP}

conda deactivate
