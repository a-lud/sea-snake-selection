#!/usr/bin/env bash

# Run on a different server to the assemblies

READS='/home/a1645424/al/garvin/nanopore'
ASM="/home/a1645424/al/garvin"

SMP="aipysurus_laevis hydrophis_elegans"

for S in ${SMP}; do

    FASTA="${ASM}/flye-${S}/assembly.fasta"
    OUT="${A}/medaka-${S}"

    medaka_consensus \
        -i "${READS}/${S}.fastq.gz" \
        -d "${FASTA}" \
        -o "${OUT}" \
        -m 'r941_prom_sup_g507'
done

