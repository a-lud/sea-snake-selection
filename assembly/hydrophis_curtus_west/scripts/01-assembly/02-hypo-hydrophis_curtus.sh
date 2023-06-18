#!/usr/bin/env bash

DIR=$(pwd)
ASM="${DIR}/flye/hydrophis_curtus/assembly.fasta"
READS="${DIR}/data/illumina-hydrophis_curtus.fofn"
BAM="${DIR}/data/bam"
OUT="${DIR}/hypo"

mkdir -p "${OUT}/hydrophis_curtus"

hypo \
  --reads-short "@${READS}" \
  --draft "${ASM}" \
  --bam-sr "${BAM}/hydrophis_curtus-sr.bam" \
  --coverage-short 60 \
  --size-ref '2g' \
  --bam-lr "${BAM}/hydrophis_curtus-lr.bam" \
  --output "${OUT}/hydrophis_curtus.fasta" \
  --threads 30
