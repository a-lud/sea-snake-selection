#!/usr/bin/env bash

PROG='/Users/alastairludington/Documents/software-custom/annotateOrthologs/parseNcbiGFF3'

# Parse NCBI GFF3 files
"${PROG}/parseNcbiGff3.py" \
  $(pwd) \
  '.gff3' \
  'ncbi-gene-symbols.csv'
