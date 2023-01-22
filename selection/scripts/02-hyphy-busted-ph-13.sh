#!/usr/bin/env bash

## Location of where the pipeline is installed
PIPE='/home/a1645424/al/test/nf-pipelines-dev'
DIR='/home/a1645424/al/analyses/selection'
SEQS='/home/a1645424/al/analyses/orthologs/results/orthologs_13/clipkit'

nextflow run "${PIPE}/main.nf" \
    --pipeline 'hyphy_analyses' \
    --outdir "${DIR}/results" \
    --out_prefix 'orthologs-13' \
    -profile 'conda,afw' \
    --partition 'afw' \
    --msa "${SEQS}" \
    --tree "${DIR}/tree/snakes-13.nwk" \
    --testLabel 'Marine' \
    --batchFile "BUSTED-PH.bf" \
    --hyphyDev '/home/a1645424/al/tools_AL/hyphy-develop' \
    --hyphyAnalysis '/home/a1645424/al/tools_AL/hyphy-analyses'
