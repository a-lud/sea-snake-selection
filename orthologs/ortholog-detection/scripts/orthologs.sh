#!/usr/bin/env bash

## Location of where the pipeline is installed
PIPE='/home/a1645424/al/tools_AL/nf-pipelines'
DIR='/home/a1645424/al/analyses/orthologs'
ASM="${DIR}/genomes"
GFF="${DIR}/gff3"
TREE="${DIR}/tree"

nextflow run ${PIPE}/main.nf \
    --pipeline 'orthofinder' \
    -profile 'conda,afw' \
    --partition 'afw' \
    -work-dir "${DIR}/work-dir" \
    -N 'alastair.ludington@adelaide.edu.au' \
    -resume \
    --outdir "${DIR}/results" \
    --out_prefix "orthologs" \
    --gffs "${GFF}" \
    --genomes "${ASM}" \
    --search_prog 'mmseqs' \
    --tree "${TREE}/species.nwk"
