#!/usr/bin/env bash

DIR="$(dirname "$(pwd)")"
OUT="${DIR}/results/go-tables-funannotate"
mkdir -p "${OUT}"

# Directory with annotations
ANNO="/Users/alastairludington/Documents/phd/00_papers/sea-snake-selection/annotation/funannotate"

# Software
SOFT="/Users/alastairludington/Documents/software-custom/funAnn2Go"

FILES=$(find "${ANNO}" -type f -name '*annotations.txt')

for f in ${FILES}; do
    BN=$(basename "${f%.annotations.txt}")
    "${SOFT}/funAnn2Go" \
        -i "${f}" \
        -o "${OUT}/${BN}.tsv"
done
