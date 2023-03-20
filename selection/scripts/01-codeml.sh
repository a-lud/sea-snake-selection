#!/usr/bin/env bash

## Location of where the pipeline is installed
PIPE='/hpcfs/users/a1645424/software/nf-pipelines'
DIR='/hpcfs/users/a1645424/analysis/selection'
MSA='/hpcfs/users/a1645424/analysis/orthologs/results/orthologs/clipkit'

nextflow run ${PIPE}/main.nf \
    --pipeline 'codeml' \
    -profile 'conda,phoenix' \
    --partition 'skylake' \
    -work-dir "${DIR}/work-codeml" \
    -resume \
    --outdir "${DIR}/results" \
    --out_prefix "paml" \
    --msa "${MSA}" \
    --tree "${DIR}/tree/snakes-marked-13.nwk" \
    --models 'bsA bsA1' \
    --dropout
