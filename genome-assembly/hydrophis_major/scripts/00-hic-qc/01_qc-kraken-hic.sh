#!/usr/bin/env bash

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate kraken2

KRAKENDB='/home/a1645424/al/databases/k2_standard_20210517'
HIC="/home/a1645424/al/alastair-phd/bpa/hic"
OUTFQ="/home/a1645424/al/alastair-phd/bpa/hic-kraken"
OUT="/home/a1645424/al/alastair-phd/bpa/qc/kraken-hic"

mkdir -p ${OUT} ${OUTFQ}
kraken2 \
    --db ${KRAKENDB} \
    --threads 30 \
    --gzip-compressed \
    --paired \
    --unclassified-out "${OUTFQ}/350845#.fastq" \
    --classified-out "${OUT}/350845-classified#.fastq" \
    --output ${OUT}/350845.output \
    --report ${OUT}/350845.report \
    --use-names \
    ${HIC}/350845_R1.fastq.gz ${HIC}/350845_R2.fastq.gz

pigz -p 20 -9 ${OUTFQ}/*.fastq

conda deactivate

