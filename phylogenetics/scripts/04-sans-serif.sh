#!/usr/bin/env bash

DIR=$(pwd)
OUT="${DIR}/sans_serif"

mkdir -p "${OUT}"; cd "${OUT}" || exit 1

# genomes.fofn - contains the paths to the six Hydrophis genomes

# SANS serif - weakly
SANS --input 'genomes.fofn' -output 'weakly-geom-31.tsv' --filter 'weakly' --mean 'geom' 
SANS --input 'genomes.fofn' -output 'weakly-geom2-31.tsv' --filter 'weakly' 

# SANS serif - strict
SANS --input 'genomes.fofn' -output 'strict-geom-61.tsv' --filter 'strict' --mean 'geom' --kmer 61
SANS --input 'genomes.fofn' -output 'strict-geom2-61.tsv' --filter 'strict' --kmer 61