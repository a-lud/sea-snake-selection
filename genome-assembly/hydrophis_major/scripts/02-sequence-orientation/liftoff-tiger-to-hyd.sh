#!/usr/bin/env bash

# Directories ---
MAJ='/home/a1645424/al/hydrophis-major/assembly-manual/pin_hic/hydmaj-p_ctg.fa'
CYA='/home/a1645424/al/alastair-phd/genome-data/genomes/GCA_019473425.1_HCya_v2_genomic.fna'
CUR='/home/a1645424/al/alastair-phd/genome-data/genomes/GCA_019472885.1_HCur_v2_genomic.fna'
QRY='/home/a1645424/al/hydrophis-major/liftoff-for-mcscan/queries'
REF='/home/a1645424/al/hydrophis-major/liftoff-for-mcscan/tiger-data'
OUT='/home/a1645424/al/hydrophis-major/liftoff-for-mcscan/hydmaj-pin_hic'

mkdir -p "${QRY}" "${OUT}"

# Link genomes to query directory ---
#ln -sfv "${MAJ}" "${QRY}"
ln -sfv "${CYA}" "${QRY}/hydcya.fa"
ln -sfv "${CUR}" "${QRY}/hydcur.fa"

# Conda set up ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
#conda activate liftoff

#for f in ${QRY}/*fa; do
#    BN=$(basename "${f%%.*}")
#    printf '[LiftOff] %s\n' "${BN}"
#
#    liftoff \
#        "${f}" \
#        "${REF}/GCF_900518725.1_TS10Xv2-PRI_genomic.fna" \
#        -db "${REF}/GCF_900518725.1_TS10Xv2-PRI_genomic.gff_db" \
#        -o "${OUT}/${BN}-notechisScutatus.gff3" \
#        -u "${OUT}/${BN}-notechisScutatus-unmapped.txt" \
#        -exclude_partial \
#        -flank 0.3 \
#        -dir "${BN}-intermediates" \
#        -p 16 &> "${OUT}/${BN}.log" || exit 1 &
#done
#
#wait
#
## Replace 'rna-'/'id-' with species (prevents each sample having the exact same identifiers) ---
#for f in ${OUT}/*.gff3; do
#    BN=$(basename "${f%-*}")
#    printf "[Cleaning seqids] %s\n" ${BN}
#    sed -i "s/rna-/${BN}-/;s/id-/${BN}-/" "${f}"
#done

# Extract FASTA sequences with GFFread ---
for f in ${QRY}/*fa; do
    BN=$(basename "${f%%.*}")
    printf '[GffRead] %s\n' $BN
    gffread "${OUT}/${BN}-notechisScutatus.gff3" \
        -g "${f}" \
        -y "${OUT}/${BN}-notechisScutatus.faa" \
        -x "${OUT}/${BN}-notechisScutatus.cds"
done

#conda deactivate
