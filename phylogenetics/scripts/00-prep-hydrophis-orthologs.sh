#!/usr/bin/env bash

DIR='/home/a1645424/al/analyses/species-tree-estimation'
OUT="${DIR}/00-seqs"
MSA='/home/a1645424/al/analyses/orthologs/results/orthologs/orthofinder/Results_mmseqs/MultipleSequenceAlignments'

# Function - convert MSA back to protein with only hydrophis snakes
function cleanMsa() {
    BN=$(basename "${1%.fa}")
    seqkit grep -p 'hydrophis_' -r "$1" |
        seqkit seq -g -o "${BN}.pep"
}

function pis() {
    BN=$(basename "${1%.fa}")
    RES=$(phykit pis "${1}")
    echo -e "${BN}\t${RES}" >>"${2}"
}

# export -f cleanMsa
export -f pis
export OPENBLAS_NUM_THREADS=1

mkdir -p "${OUT}"
cd "${OUT}" || exit 1

# Copy MSA files to working directory
parallel -j 20 -a "${DIR}/hydrophis-specific-single-copy-orthologs.txt" \
    "cp ${MSA}/{}.fa" "${OUT}"

# Remove non-hydrophis snakes and gaps
echo "Cleaning"
find . -name '*.fa' |
    parallel -j 10 "cleanMsa {}"

# Align cleaned peptide sequences for hydrophis snakes
echo "Aligning"
find . -name '*.pep' |
    parallel -j 20 "mafft --maxiterate 1000 --globalpair --thread 1 {} > ../01-mafft-hydrophis/{.}.aln"

# Convert protein alignments to codon alignments
./prot-to-codon.py -f "${DIR}/cds" -m "${DIR}/01-mafft-hydrophis" -o "${DIR}/02-codon-hydrophis"

# Clean codon alignment
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate clipkit
for FA in "${DIR}/02-codon-hydrophis/codon_alignments"/*.fa; do
    BN=$(basename "${FA%.*}")
    clipkit "${FA}" --output "${DIR}/03-clipkit-hydrophis/${BN}.fa"
done
conda deactivate

# Clean stop codons and format file (hyphy CLN inserts spaces between sequences...)
conda activate hyphy
mkdir -p "${DIR}/04-clean-hydrophis"
for FA in "${DIR}/03-clipkit-hydrophis"/*.fa; do
    BN=$(basename "${FA%.*}")
    hyphy CLN Universal "${FA}" No/No "${DIR}/04-clean-hydrophis/${BN}.tmp"
    seqkit seq -o "${DIR}/04-clean-hydrophis/${BN}.fa" "${DIR}/04-clean-hydrophis/${BN}.tmp"
    rm "${DIR}/04-clean-hydrophis/${BN}.tmp"
done
mamba deactivate

# Parsimony informative sites
mamba activate phykit
mkdir -p "${DIR}/05-parsimony-informative-orthologs"
cd "${DIR}/05-parsimony-informative-orthologs" || exit 1
find "${DIR}/04-clean-hydrophis" -name '*.fa' |
    parallel -j 16 --joblog pis.log "pis {} parsimony-informative-sites.tsv"

awk '$2 != 0 {print}' parsimony-informative-sites.tsv | cut -f 1 >parsimony-informative-orthologs.txt

conda deactivate
