#!/usr/bin/env bash
#PBS ...

# Modules/Software
module load singularity

# Directories ---
DIR="/g/data/xl04/al4518/hydmaj-genome/funannotate"
RNA="${DIR}/rna"
ASM="/g/data/xl04/al4518/hydmaj-genome/hydmaj-chromosome/hydmaj-p_ctg-v1.fna"
CONTAINER='/g/data/xl04/al4518/containers'
OUT="${DIR}/annotation-funannotate-no-mask"

# Train ---
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate train \
    --input "${ASM}" \
    --out "${OUT}" \
    --left "${RNA}/left.fastq.gz" \
    --right "${RNA}/right.fastq.gz" \
    --no_trimmomatic \
    --max_intronlen 150000 \
    --species "Hydrophis major_nm" \
    --cpus "${PBS_NCPUS}"

