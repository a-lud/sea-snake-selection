#!/usr/bin/env bash

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate KRAKEN2_env


KRAKENDB='/home/a1645424/al/databases/k2_standard_20210517'
RNA="/home/a1645424/al/alastair-phd/bpa/rna"
OUTFQ="/home/a1645424/al/alastair-phd/bpa/rna-kraken"
OUT="/home/a1645424/al/alastair-phd/bpa/qc/kraken"

mkdir -p ${OUT} ${OUTFQ}

for R1 in ${RNA}/*_R1*; do
    R2=${R1/_R1/_R2}
    BN=$(basename ${R1%%_*})

    printf "Current file: %s\n" ${BN}

    kraken2 \
        --db ${KRAKENDB} \
        --threads 40 \
        --gzip-compressed \
	--paired \
        --unclassified-out "${OUTFQ}/${BN}#.fastq" \
        --classified-out "${OUT}/${BN}-classified#.fastq" \
        --output ${OUT}/${BN}.output \
        --report ${OUT}/${BN}.report \
        --use-names \
        ${R1} ${R2}

    pigz -p 20 -9 ${OUTFQ}/*.fastq
done


conda deactivate
