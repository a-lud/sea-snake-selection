#!/usr/bin/env bash

DIR=$(pwd)
ASM="${DIR}/flye/hydrophis_ornatus/assembly.fasta"
READS="${DIR}/data/illumina-hydrophis_ornatus.fofn"
BAM="${DIR}/data/bam"
OUT="${DIR}/hypo"

mkdir -p "${OUT}/hydrophis_ornatus"

hypo \
  --reads-short "@${READS}" \
  --draft "${ASM}" \
  --bam-sr "${BAM}/hydrophis_ornatus-sr.bam" \
  --coverage-short 60 \
  --size-ref '2g' \
  --bam-lr "${BAM}/hydrophis_ornatus-lr.bam" \
  --output "${OUT}/hydrophis_ornatus.fasta" \
  --threads 30
