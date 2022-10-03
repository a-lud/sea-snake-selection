#!/usr/bin/env bash

READS='/home/a1645424/al/sagc-sequence-data/merged'

AIPY='/home/a1645424/al/garvin/flye-aipysurus_laevis/medaka-aipysurus_laevis/aipysurus_laevis-consensus.fna'
ELEG='/home/a1645424/al/garvin/flye-hydrophis_elegans/medaka-hydrophis_major/hydrophis_elegans-consensus.fasta'

DIR='/home/a1645424/al/garvin'
OUT="${DIR}/genome-assessment"

mkdir -p "${OUT}/aipysurus_laevis"

cd "${OUT}/aipysurus_laevis" || exit 1

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate merqury

# Create Meryl db
meryl count \
     k=21 \
     threads=30 \
     memory=100 \
     "${READS}/Aipysurus_laevis-KLS1140_R1.fastq.gz" \
     "${READS}/Aipysurus_laevis-KLS1140_R2.fastq.gz" \
     output Aipysurus_laevis-reads.meryl

# Compare genome to reads
 merqury.sh \
     Aipysurus_laevis-reads.meryl \
     "${AIPY}" \
     Aipysurus_laevis-to-reads

# Hydrophis elegans turn
mkdir -p "${OUT}/hydrophis_elegans"
cd "${OUT}/hydrophis_elegans" || exit 1

# Create Meryl db
meryl count \
    k=21 \
    threads=30 \
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

