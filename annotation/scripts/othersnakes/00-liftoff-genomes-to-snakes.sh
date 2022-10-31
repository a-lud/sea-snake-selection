#!/usr/bin/env bash

# Directories ---
DIR='/home/a1645424/al/hydrophis-major/liftoff-funannotate/liftoff-for-annotation'
QRY="${DIR}/query-files"
TGT="${DIR}/target-files"

# Conda set up ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate liftoff

# Samples to lift annotations from
SMP='anolis_carolinensis naja_naja notechis_scutatus protobothrops_mucrosquamatus pseudonaja_textilis thamnophis_elegans'

for TARGET in ${TGT}/*.fna; do
    TARGET_BN=$(basename ${TARGET%.*})
    echo "[Target] ${TARGET_BN}"

    mkdir -p "${DIR}/${TARGET_BN}-liftoff"
    OUT="${DIR}/${TARGET_BN}-liftoff"

    # Lift these samples to our target genome
    for SAMPLE in ${SMP}; do
        echo -e "\t- Query: ${SAMPLE}"
        mkdir -p "${OUT}/${SAMPLE}"

        if [[ ! -f "${OUT}/${SAMPLE}/${SAMPLE}-to-${TARGET_BN}.gff3" ]]; then
            echo -e "\t- Running LiftOff...\n"
            liftoff \
                "${TARGET}" \
                "${QRY}/${SAMPLE}.fna" \
                -db "${QRY}/${SAMPLE}.gff3_db" \
                -o "${OUT}/${SAMPLE}/${SAMPLE}-to-${TARGET_BN}.gff3" \
                -u "${OUT}/${SAMPLE}/${SAMPLE}-to-${TARGET_BN}.unmapped.txt" \
                -exclude_partial \
                -flank 0.1 \
                -dir "${QRY}/${SAMPLE}-intermediates" \
                -p 30 &>"${OUT}/${SAMPLE}/liftoff-${SAMPLE}.log" || exit 1

            gffread "${OUT}/${SAMPLE}/${SAMPLE}-to-${TARGET_BN}.gff3" \
                -g "${TARGET}" \
                -y "${OUT}/${SAMPLE}/${SAMPLE}-to-${TARGET_BN}.faa" \
                -x "${OUT}/${SAMPLE}/${SAMPLE}-to-${TARGET_BN}.fna" || exit 1
        fi
    done
done

conda deactivate

