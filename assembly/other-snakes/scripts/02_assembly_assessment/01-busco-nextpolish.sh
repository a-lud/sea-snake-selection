#!/usr/bin/env bash

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate busco

DB='/home/a1645424/al/databases/busco_downloads/lineages/tetrapoda_odb10'
ASM='/home/a1645424/al/garvin/nextpolish/hydrophis_elegans/hydrophis_elegans.polished.fa'
OUT='/home/a1645424/al/garvin/busco'

cd "${NUSCO}" || exit 1

ulimit -u 100000

echo "[BUSCO::NextPolish] started"
busco \
    -i "${ASM}" \
    -o 'hydrophis_elegans-nextpolish' \
    -m 'geno' \
    -l "${DB}" \
    --cpu 50 \
    --metaeuk_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
    --metaeuk_rerun_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
    --out_path "${PWD}" \
    --tar \
    --offline

conda deactivate
