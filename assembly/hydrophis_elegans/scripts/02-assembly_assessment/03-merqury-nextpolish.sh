#!/usr/bin/env bash

DIR='/home/a1645424/al/garvin'
READS='/home/a1645424/al/sagc-sequence-data/merged'
ELEG="${DIR}/nextpolish/hydrophis_elegans/hydrophis_elegans.polished.fa"
OUT="${DIR}/genome-assessment-polished"

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate merqury

# Hydrophis elegans turn
mkdir -p "${OUT}/hydrophis_elegans"
cd "${OUT}/hydrophis_elegans" || exit 1

# Create Meryl db
meryl count \
    k=21 \
    threads=8 \
    memory=100 \
    "${READS}/Hydrophis_elegans-KLS1121_R1.fastq.gz" \
    "${READS}/Hydrophis_elegans-KLS1121_R2.fastq.gz" \
    output Hydrophis_elegans-reads.meryl

# Compare genome to reads
merqury.sh \
    Hydrophis_elegans-reads.meryl \
    "${ELEG}" \
    Hydrophis_elegans-to-reads

conda deactivate
