#!/usr/bin/env bash

READS='/home/a1645424/al/garvin/nanopore'
ASM="/home/a1645424/al/garvin"

FASTA="${ASM}/flye-hydrophis_elegans/assembly.fasta"
OUT="${ASM}/medaka-hydrophis_elegans"

medaka_consensus \
    -i "${READS}/hydrophis_elegans.fastq.gz" \
    -d "${FASTA}" \
    -o "${OUT}" \
    -m 'r941_prom_sup_g507'
