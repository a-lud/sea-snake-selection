#!/usr/bin/env bash
DIR='/home/a1645424/al/analyses/repeat-sea-snakes'
GENOMES='/home/a1645424/al/analyses/sequence-datasets/genomes'

# Get current snake
ASM="${GENOMES}/hydrophis_elegans-garvin.fa"
BN=$(basename "${ASM%.*}")

# Output directory
OUT="${DIR}/results/${BN}"

mkdir -p "${OUT}"

cd "${OUT}" || exit 1

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate repeatmasker

RepeatMasker \
    -e rmblast \
    -pa 4 \
    -no_is \
    -norna \
    -div 40 \
    -lib "${DIR}/edta-libraries/${BN}.edta-repbase.fa" \
    -dir . \
    -xsmall \
    -gff \
    -a \
    -inv \
    "${ASM}" &> "${BN}-rm.log"

conda deactivate