#!/usr/bin/env bash

DIR='/home/a1645424/al/garvin'
READS="${DIR}/fastqs"
GENOMES="/home/a1645424/al/analyses/sequence-datasets/genomes"
OUT="${DIR}/genome-assessment-polished"

SAMPLES="hydrophis_ornatus hydrophis_curtus"

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate merqury

for SMP in $SAMPLES; do
    cd "${OUT}/${SMP}" || exit 1
    REF="${GENOMES}/${SMP}-garvin.fa"

    if [[ ${SMP} == 'hydrophis_ornatus' ]]; then
        R1="${READS}/SRR16961054_1.fastq.gz"
        R2="${READS}/SRR16961054_2.fastq.gz"
    else
        R1="${READS}/SRR16961055_1.fastq.gz"
        R2="${READS}/SRR16961055_2.fastq.gz"
    fi

    # Make database
    meryl count \
        k=21 \
        threads=32 \
        memory=100 \
        "${R1}" \
        "${R2}" \
        output "${SMP}-reads.meryl"

    merqury.sh \
        "${SMP}-reads.meryl" \
        "${REF}" \
        "${SMP}-to-reads"

done

conda deactivate
