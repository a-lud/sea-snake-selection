#!/usr/bin/env bash

SOFT='/Users/alastairludington/Documents/software-custom/annotateBlast'

GFF="/Users/alastairludington/Documents/phd/analyses/sea-snake-selection/results/orthologs/agat/longest-isoforms/ncbi-annotated"

DIR='/Users/alastairludington/Documents/phd/analyses/sea-snake-selection/results/blast-to-swissProt'
BLASTDIR="${DIR}/proteins-to-uniprot"
DB="${DIR}/uniprotKB_Swiss-Prot"
OUT="${DIR}/annotate-blast-hits"
TMP="${OUT}/intermediate-files"

"${SOFT}/annotateBlast.py" \
    "${BLASTDIR}" \
    "${DB}/idmapping_selected.GO.tab.gz" \
    'blast-GO-annotations.csv' \
    "${OUT}" \
    -g "${GFF}" \
    -a "${DB}/idmapping.geneNames.dat" \
    -t "${TMP}"
