#!/usr/bin/env bash

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate busco

DB='/home/a1645424/al/databases/busco_downloads/lineages/tetrapoda_odb10'

ulimit -u 100000

echo "[BUSCO::funannotate] started"
busco \
    -i "assembly.fasta" \
    -o 'hydrophis_elegans-flye' \
    -m 'geno' \
    -l "${DB}" \
    --cpu 8 \
    --metaeuk_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
    --metaeuk_rerun_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
    --out_path "${PWD}" \
    --tar \
    --offline

conda deactivate

