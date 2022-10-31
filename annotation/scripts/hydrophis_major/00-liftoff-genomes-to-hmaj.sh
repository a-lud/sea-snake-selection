#!/usr/bin/env bash

# Directories ---
GFF='/home/a1645424/al/alastair-phd/genome-data/annotations'
REF='/home/a1645424/al/alastair-phd/genome-data/genomes'
ASM='/home/a1645424/al/hydrophis-major/hydmaj-chromosome/hydmaj-p_ctg-v1.fna'
OUT='/home/a1645424/al/hydrophis-major/liftoff-funannotate'

mkdir -p "${OUT}"

# Conda set up ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate liftoff

SMP='anolis_carolinensis naja_naja notechis_scutatus protobothrops_mucrosquamatus pseudonaja_textilis thamnophis_elegans'

for SAMPLE in ${SMP}; do
    mkdir -p "${OUT}/liftoff-${SAMPLE}"

    if [[ ! -f "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-hydrophis_major.gff3" ]]; then
       printf '[LiftOff] %s\n' "${SAMPLE} to H. major"

       liftoff \
           "${ASM}" \
           "${REF}/${SAMPLE}.fna" \
           -g "${GFF}/${SAMPLE}.gff3" \
           -o "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-hydrophis_major.gff3" \
           -u "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-hydrophis_major.unmapped.txt" \
           -exclude_partial \
           -flank 0.1 \
           -dir "${OUT}/${SAMPLE}-intermediates" \
           -p 50 &> "${OUT}/liftoff-${SAMPLE}/${SAMPLE}.log"

        gffread "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-hydrophis_major.gff3" \
            -g "${ASM}" \
            -y "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-hydrophis_major.faa" \
            -x "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-hydrophis_major.fna"
   fi
done

conda deactivate

