#!/usr/bin/env bash

## Location of where the pipeline is installed
PIPE='/hpcfs/users/a1645424/software/nf-pipelines'
DIR='/hpcfs/users/a1645424/analysis/selection'
MSA="/hpcfs/users/a1645424/analysis/orthologs/results/orthologs-13-correct/clipkit"

nextflow run "${PIPE}/main.nf" \
    --pipeline 'hyphy_analyses' \
    --outdir "${DIR}/results-correct" \
    --out_prefix 'bustedph' \
    -profile 'conda,phoenix' \
    --partition 'skylake' \
    --msa "${MSA}" \
    --tree "${DIR}/tree/tree-bustedph.nwk" \
    --testLabel 'Marine' \
    --batchFile "BUSTED-PH.bf" \
    --hyphyDev '/hpcfs/users/a1645424/software/hyphy-develop' \
    --hyphyAnalysis '/hpcfs/users/a1645424/software/hyphy-analyses' \
    -resume

