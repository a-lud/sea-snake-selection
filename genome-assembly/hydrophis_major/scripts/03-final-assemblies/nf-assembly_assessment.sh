#!/usr/bin/env bash

## Location of where the pipeline is installed
PIPE='/home/a1645424/hpcfs/software/nf-pipelines'
DIR="/home/a1645424/hpcfs/hydmaj-genome"

mkdir -p ${DIR}

nextflow run ${PIPE}/main.nf \
    -profile 'conda,slurm' \
    -work-dir "${DIR}/work-assembly_assessment" \
    -N 'alastair.ludington@adelaide.edu.au' \
    -resume \
    --outdir "${DIR}/assembly-results" \
    --out_prefix 'hydmaj-chromosome' \
    --email 'alastair.ludington@adelaide.edu.au' \
    --pipeline 'assembly_assessment' \
    --reviewed_assembly '/home/a1645424/hpcfs/hydmaj-genome/juicebox-edited' \
    --contig '/home/a1645424/hpcfs/hydmaj-genome/assembly-results/assembly-contigs/hydmaj' \
    --filtered_hifi '/home/a1645424/hpcfs/hydmaj-genome/assembly-results/adapter-removed-reads' \
    --assembly 'primary' \
    --length 500 \
    --busco_db '/home/a1645424/hpcfs/database/busco_downloads/lineages/tetrapoda_odb10' \
    --partition 'skylakehm'

