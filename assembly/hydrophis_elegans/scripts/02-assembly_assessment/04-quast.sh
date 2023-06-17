#!/usr/bin/env bash

DIR='/home/a1645424/al/analyses/sequence-datasets'
GENOMES="${DIR}/genomes"
OUT="${DIR}/quast"

mkdir -p "${OUT}"

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate quast

for ASM in "${GENOMES}"/*.fa; do
    BN=$(basename "${ASM%.*}")
    mkdir "${OUT}/${BN}"
    
    quast \
        --output-dir "${OUT}/${BN}" \
        --threads 16 \
        --split-scaffolds \
        --plots-format png \
        --no-icarus \
        "${ASM}" &
done

wait 

conda deactivate

