#!/usr/bin/env bash

DIR=$(pwd)
READS="${DIR}/data/nanopore-hydrophis_ornatus.fastq.gz"
ASM="${DIR}/hypo/hydrophis_ornatus/hydrophis_ornatus.fasta"
OUT="${DIR}/purge_haplotigs/hydrophis_ornatus"

mkdir -p "${OUT}"

# Step 1: Align Nanopore to genome
minimap2 -t 4 -ax map-ont "${ASM}" "${READS}" --secondary=no |
  samtools sort -m 1G -o "${OUT}/hydrophis_ornatus-lr.bam"

# Step 2: Coverage histogram
purge_haplotigs hist -t 30 -b "${OUT}/hydrophis_ornatus-lr.bam" -g "${ASM}"

# Step 3: Contig coverage stats (mark suspect contigs)
purge_haplotigs cov -i aligned.bam.genecov -l ... -m ... -h ... -o "${OUT}/coverage_stats.csv"

# Step 4: Purge the haplotigs
purge_haplotigs purge -g "${ASM}" -c "${OUT}/coverage_stats.csv" 
