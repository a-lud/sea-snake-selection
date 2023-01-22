#!/usr/bin/env bash

## Location of where the pipeline is installed
PIPE='/home/a1645424/al/tools_AL/nf-pipelines'
DIR='/home/a1645424/al/analyses/selection'
MSA="${DIR}/msa"

nextflow run ${PIPE}/main.nf \
    --pipeline 'codeml' \
    -profile 'conda,afw' \
    --partition 'afw' \
    -work-dir "${DIR}/work-selection" \
    --outdir "${DIR}" \
    --out_prefix "results" \
    --msa "${MSA}" \
    --tree "${DIR}/tree/snakes.nwk" \
    --models 'bsA bsA1' \
    --dropout
