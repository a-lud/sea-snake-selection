#!/usr/bin/env bash
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=190GB
#PBS -l ncpus=48
#PBS -l wd
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -N alev-polish
#PBS -o /g/data/xl04/al4518/analysis/polish-genomes/scripts/joblogs/nextpolish-aipysurus_laevis.log
#PBS -j oe

# Software
NP='/g/data/xl04/al4518/software/NextPolish/lib/nextpolish1.py'
NIB='/g/data/xl04/al4518/software/NextPolish/bin'

DIR='/g/data/xl04/al4518/analysis/polish-genomes'
ASM="${DIR}/genomes/aipysurus_laevis-consensus.fna"
OUT="${DIR}/results-aipysurus"

# Assembly basename
BN=$(basename ${ASM%-*})

R1='/g/data/xl04/al4518/analysis/polish-genomes/seqs/Aipysurus_laevis-KLS1140_R1.fastq.gz'
R2='/g/data/xl04/al4518/analysis/polish-genomes/seqs/Aipysurus_laevis-KLS1140_R2.fastq.gz'

module load bwa-mem2/2.2.1

# Current round - update after running the pipeline
ROUND='1'
OUT_ONE="${OUT}/nextpolish-round-${ROUND}"
mkdir -p "${OUT_ONE}"

# BWA index and FA index
if [[ ! -f "${ASM}.0123" ]]; then
    echo "Round ${ROUND} - [bwa2::index] $(basename ${ASM})"
    bwa-mem2 index "${ASM}"
fi

if [[ ! -f "${ASM}.fai" ]]; then
    echo "Round ${ROUND} - [samtools::index] Index reference genome"
    "${NIB}/samtools" faidx "${ASM}"
fi

# Align Reads using BWA2
if [[ ! -f "${OUT_ONE}/sr.bam" ]]; then
    echo "Round ${ROUND} - [bwa2::mem] Aligning reads"
    bwa-mem2 mem \
        -t 30 \
        "${ASM}" "${R1}" "${R2}" | \
        "${NIB}/samtools" view -u --threads 4 -F 0x4 -b - | \
        "${NIB}/samtools" fixmate -m --threads 4 - - | \
        "${NIB}/samtools" sort -m 2g --threads 5 - | \
        "${NIB}/samtools" markdup -O 'BAM' --threads 5 -r - "${OUT_ONE}/sr.bam"
fi

# Index BAM file
if [[ ! -f "${OUT_ONE}/sr.bam.bai" ]]; then
    echo "Round ${ROUND} - [samtools::index] Index BAM file"
    "${NIB}/samtools" index -@ 16 "${OUT_ONE}/sr.bam"
fi

# Polish genome
if [[ ! -f "${OUT_ONE}/${BN}.round-${ROUND}.fa" ]]; then
    echo "Round ${ROUND} - [NextPolish] Polishing genome with short-read"
    python "${NP}" \
        -g "${ASM}" \
        -t 1 \
        -p 24 \
        -s "${OUT_ONE}/sr.bam" > "${OUT_ONE}/${BN}.round-${ROUND}.fa"
fi

# Remove temporary BAM to save space
# if [ $? -eq 0 ]; then
#     echo "Round ${ROUND} - [NextPolish] Completed with exit-code 0. Removing sr.bam file."
#     rm "${OUT_ONE}/sr.bam"
# fi

# Round 2
ASM="${OUT_ONE}/${BN}.round-${ROUND}.fa"

ROUND='2'
OUT_TWO="${OUT}/nextpolish-round-${ROUND}"
mkdir -p "${OUT_TWO}"

echo "Round is now: ${ROUND}"
echo "Genome is now: $(basename "${ASM}")"

#index the genome file and do alignment
if [[ ! -f "${ASM}.0123" ]]; then
    echo "Round ${ROUND} - [bwa2::index] $(basename "${ASM}")"
    bwa-mem2 index "${ASM}"
fi

if [[ ! -f "${ASM}.fai" ]]; then
    echo "Round ${ROUND} - [samtools::index] Index reference genome"
    "${NIB}/samtools" faidx "${ASM}"
fi

# Align Reads
if [[ ! -f "${OUT_TWO}/sr.bam" ]]; then
    echo "Round ${ROUND} - [bwa2::mem] Aligning reads"
    bwa-mem2 mem \
        -t 30 \
        "${ASM}" "${R1}" "${R2}" | \
        "${NIB}/samtools" view -u --threads 4 -F 0x4 -b - | \
        "${NIB}/samtools" fixmate -m --threads 4 - - | \
        "${NIB}/samtools" sort -m 2g --threads 5 - | \
        "${NIB}/samtools" markdup -O 'BAM' --threads 5 -r - "${OUT_TWO}/sr.bam"
fi

# Index BAM file
if [[ ! -f "${OUT_TWO}/sr.bam.bai" ]]; then
    echo "Round ${ROUND} - [samtools::index] Index BAM file"
    "${NIB}/samtools" index -@ 16 "${OUT_TWO}/sr.bam"
fi

# Polish genome
if [[ ! -f "${OUT_TWO}/${BN}.polished.fa" ]]; then
    echo "Round ${ROUND} - [NextPolish] Polishing genome with short-read"
    python "${NP}" \
        -g "${ASM}" \
        -t 2 \
        -p 24 \
        -s "${OUT_TWO}/sr.bam" > "${OUT_TWO}/${BN}.polished.fa"
fi

# Remove temporary BAM to save space
# if [ $? -eq 0 ]; then
#     echo "Round ${ROUND} - [NextPolish] Completed with exit-code 0. Removing sr.bam file."
#     rm "${OUT_TWO}/sr.bam"
# fi

