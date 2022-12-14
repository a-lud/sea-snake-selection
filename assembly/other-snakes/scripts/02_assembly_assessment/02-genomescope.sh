#!/usr/bin/env bash

DIR='/home/a1645424/al/garvin'
OUT="${DIR}/genomescope2"

mkdir -p "${OUT}/aipysurus_laevis" "${OUT}/hydrophis_elegans"

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate genomescope2

cd "${OUT}/aipysurus_laevis" || exit 1
cp /home/a1645424/al/garvin/scripts/al-reads.fofn .

kmc \
    -k31 \
    -t16 \
    -m64 \
    -ci2 \
    -cs100000 \
    '@al-reads.fofn' \
    'aipysurus_laevis-db' .
        
kmc_tools transform \
    'aipysurus_laevis-db' \
    histogram \
    'aipysurus_laevis-db.kmc.histo' \
    -ci2 \
    -cx100000


cd "${OUT}/hydrophis_elegans" || exit 1
cp /home/a1645424/al/garvin/scripts/he-reads.fofn .

kmc \
    -k31 \
    -t16 \
    -m64 \
    -ci2 \
    -cs100000 \
    '@he-reads.fofn' \
    'hydrophis_elegans-db' .
        
kmc_tools transform \
    'hydrophis_elegans-db' \
    histogram \
    'hydrophis_elegans-db.kmc.histo' \
    -ci2 \
    -cx100000

conda deactivate

