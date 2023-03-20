#!/usr/bin/env bash

## Location of where the pipeline is installed
PIPE='/hpcfs/users/a1645424/software/nf-pipelines'
DIR='/hpcfs/users/a1645424/analysis/selection'
MSA="/hpcfs/users/a1645424/analysis/orthologs/results/orthologs/clipkit"

nextflow run "${PIPE}/main.nf" \
    --pipeline 'hyphy' \
    --outdir "${DIR}/results" \
    --out_prefix 'relax' \
    -profile 'conda,phoenix' \
    --partition 'skylake' \
    --msa "${MSA}" \
    --tree  "${DIR}/tree/tree-bustedph.nwk" \
    --testLabel 'Marine' \
    --analysis 'RELAX' \
    -resume
