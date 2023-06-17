#!/usr/bin/env bash

DIR='/home/a1645424/al/hydrophis-major/metaeuk'
TGT="${DIR}/target-files"

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate metaeuk

for TARGET in ${TGT}/*.fna; do
    TARGET_BN=$(basename ${TARGET%.*})
    echo "[Target] ${TARGET_BN}"

    mkdir -p "${DIR}/metaeuk/${TARGET_BN}"

    echo -e "\t- [metaeuk] snake-proteins"
    metaeuk easy-predict \
        "${TARGET}" \
        "${DIR}/snake-proteins-clean-header.fasta" \
        "${DIR}/metaeuk/${TARGET_BN}/${TARGET_BN}-snake-proteins" \
        "${DIR}/metaeuk/${TARGET_BN}" \
        --min-seq-id 0.7 \
        --max-intron 150000 \
        --threads 30 \
        --headers-split-mode 1 &>"${DIR}/metaeuk/${TARGET_BN}/snake-proteins.log" || exit 1

    echo -e "\t- [metaeuk] UniProt-Sprot"
    metaeuk easy-predict \
        "${TARGET}" \
        "${DIR}/uniprot_sprot.release-2022_02.cleaned.fasta" \
        "${DIR}/metaeuk/${TARGET_BN}/${TARGET_BN}-uniprot_sprot" \
        "${DIR}/metaeuk/${TARGET_BN}" \
        --min-seq-id 0.7 \
        --max-intron 150000 \
        --threads 30 \
        --headers-split-mode 1 &>"${DIR}/metaeuk/${TARGET_BN}/uniprot-sprot.log" || exit 1
done

conda deactivate

