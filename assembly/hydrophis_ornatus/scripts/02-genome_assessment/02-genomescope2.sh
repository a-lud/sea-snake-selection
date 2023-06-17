#!/usr/bin/env bash

DIR='/home/a1645424/al'
OUT="${DIR}/genomescope2"
SAMPLES='hydrophis_ornatus hydrophis_curtus'

mkdir -p "${OUT}/hydrophis_ornatus" "${OUT}/hydrophis_curtus"

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate genomescope2

cd "${OUT}" || exit 1

for SAMPLE in ${SAMPLES}; do
    kmc \
        -k31 \
        -t16 \
        -m64 \
        -ci2 \
        -cs100000 \
        "@${SAMPLE}.fofn" \
        "${SAMPLE}-db" .

    kmc_tools transform \
        'hydrophis_elegans-db' \
        histogram \
        "${SAMPLE}-db.kmc.histo" \
        -ci2 \
        -cx100000
    
    genomescope2 -i "${SAMPLE}-db.kmc.histo" -o . -p 2 -k31 -n "${SAMPLE}"

    conda deactivate
done
