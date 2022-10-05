#!/usr/bin/env bash

DIR="/Users/alastairludington/Documents/phd/analyses/sea-snake-selection"
OUT="${DIR}/results/go-tables-funannotate"

# Directory with annotations
ANNO="/Users/alastairludington/Documents/phd/analyses/annotations/funannotate"

# Software
SOFT="/Users/alastairludington/Documents/software-custom/funAnn2Go"

mkdir -p "${OUT}"

FILES=$(find "${ANNO}" -type f -name '*annotations.txt')

for f in ${FILES}; do
    BN=$(basename "${f%.annotations.txt}")
    "${SOFT}/funAnn2Go" \
        -i "${f}" \
        -o "${OUT}/${BN}.tsv"
done
