#!/usr/bin/env bash

DIR='/home/a1645424/al'
OUT="${DIR}/genomescope2"

mkdir -p "${OUT}/hydrophis_elegans"

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate genomescope2

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

genomescope2 -i "hydrophis_elegans-db.kmc.histo" -o . -p 2 -k31 -n "hydrophis_elegans"

conda deactivate
