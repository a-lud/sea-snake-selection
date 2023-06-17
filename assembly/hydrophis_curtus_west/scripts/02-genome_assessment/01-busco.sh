#!/usr/bin/env bash

# NOTE: This is not the exact script that was used to assess BUSCO completeness at
# each assembly stage. However, these are the arguments that were used when
# running BUSCO.

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate busco

DB='busco_downloads/lineages/tetrapoda_odb10'
STAGES='flye hypo purge 3dDNA'

ulimit -u 100000
for STAGE in ${STAGES}; do
    busco \
        -i "<assembly.fasta>" \
        -o "${STAGE}-<species>" \
        -m 'geno' \
        -l "${DB}" \
        --cpu 16 \
        --metaeuk_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
        --metaeuk_rerun_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
        --out_path "${PWD}" \
        --tar \
        --offline
done

conda deactivate