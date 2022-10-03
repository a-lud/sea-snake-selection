#!/usr/bin/env bash

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate BIOTOOLS_env

RNA="/home/a1645424/al/alastair-phd/bpa/rna-kraken"
OUT="/home/a1645424/al/alastair-phd/bpa/rna-trim"
OUTQC="/home/a1645424/al/alastair-phd/bpa/qc/fastp"

mkdir -p ${OUT} ${OUTQC}

for R1 in ${RNA}/*_1*; do
    R2=${R1/_1/_2}
    BN=$(basename ${R1%_*})

    fastp \
        -i ${R1} \
        -I ${R2} \
        -o ${OUT}/${BN}_R1.fastq.gz \
        -O ${OUT}/${BN}_R2.fastq.gz \
        --detect_adapter_for_pe \
        --thread 16 \
        --compression 9 \
        --length_required 50 \
        --html ${OUTQC}/${BN}.html \
        --json ${OUTQC}/${BN}-fastp.json
done

conda deactivate
