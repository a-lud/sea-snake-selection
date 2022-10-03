#!/usr/bin/env bash

# Directories ---
MAJ='/home/a1645424/al/hydrophis-major/liftoff-for-mcscan/queries'
REF='/home/a1645424/al/hydrophis-major/liftoff-for-mcscan/tiger-data'
OUT='/home/a1645424/al/hydrophis-major/liftoff-for-mcscan/hydmaj-chromosome-pin_hic'

mkdir -p "${OUT}"

# Conda set up ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate liftoff

for f in ${MAJ}/*.fna; do
    BN=$(basename "${f%.*}")
    if [[ ! -f "${OUT}/${BN}.gff3" ]]; then
       printf '[LiftOff] %s\n' "${BN}"

       liftoff \
           "${f}" \
           "${REF}/GCF_900518725.1_TS10Xv2-PRI_genomic.fna" \
           -db "${REF}/GCF_900518725.1_TS10Xv2-PRI_genomic.gff_db" \
           -o "${OUT}/${BN}.gff3" \
           -u "${OUT}/${BN}.unmapped.txt" \
           -exclude_partial \
           -flank 0.3 \
           -dir "${BN}-intermediates" \
           -p 16 &> "${OUT}/${BN}.log" || exit 1 &
   fi
done

wait

## Replace 'rna-'/'id-' with species (prevents each sample having the exact same identifiers) ---
for f in ${OUT}/*-v1.gff3; do
   BN=$(basename "${f%.*}")
   printf "[Cleaning seqids] %s\n" ${BN}
   sed -i "s/rna-/${BN}-/;s/id-/${BN}-/" "${f}"
done

# Extract FASTA sequences with GFFread ---
for f in ${MAJ}/*.fna; do
    BN=$(basename "${f%.*}")
    printf "[GffRead] %s\n" $BN
    gffread "${OUT}/${BN}.gff3" \
        -g "${f}" \
        -y "${OUT}/${BN}.faa" \
        -x "${OUT}/${BN}.fna"
done

conda deactivate

