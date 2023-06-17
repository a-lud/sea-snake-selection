#!/usr/bin/env bash

DB='/home/a1645424/al/databases/busco_downloads/lineages/tetrapoda_odb10'
OUT="/home/a1645424/al/analyses/sequence-datasets/busco/genomes/hardmask-RM"
GENOMES='/home/a1645424/al/analyses/repeat-sea-snakes/results'

mkdir -p "${OUT}"
ulimit -u 100000

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate busco

ASSEMBLIES=$(find "${GENOMES}" -name '*.hardMasked')

for ASM in ${ASSEMBLIES}; do
    BN=$(basename "${ASM%%.*}")

    if [[ ! -d "${OUT}/busco-${BN}" ]]; then
        echo "[BUSCO] Hardmask run of ${BN}"
        busco \
            -i "${ASM}" \
            -o "busco-${BN}" \
            -m 'geno' \
            -l "${DB}" \
            --cpu 30 \
            --metaeuk_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
            --metaeuk_rerun_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
            --out_path "${OUT}" \
            --tar \
            --offline
    fi
done

conda deactivate
