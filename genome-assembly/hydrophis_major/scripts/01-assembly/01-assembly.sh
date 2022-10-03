#!/usr/bin/env bash

## Location of where the pipeline is installed
PIPE="/home/a1645424/hpcfs/software/nf-pipelines"
DIR="/home/a1645424/hpcfs/hydmaj-genome"

mkdir -p ${DIR}

nextflow run ${PIPE}/main.nf \
    --pipeline 'assembly' \
    -profile 'conda,slurm' \
    -work-dir "${DIR}/work-assembly-haplotypes" \
    -with-notification 'alastair.ludington@adelaide.edu.au' \
    --outdir "${DIR}/assembly-results" \
    --out_prefix 'hydmaj' \
    --hifi '/hpcfs/groups/phoenix-hpc-biohub/alastair/bpa/data/hifi' \
    --hic '/hpcfs/groups/phoenix-hpc-biohub/alastair/bpa/data/hic' \
    --assembly 'all' \
    --scaffolder 'pin_hic' \
    --busco_db '/home/a1645424/hpcfs/database/busco_downloads/lineages/tetrapoda_odb10' \
    --partition 'skylakehm' \
    -resume

