#!/usr/bin/env bash
#PBS ...

# Modules/Software
module load singularity

# Directories ---
DIR="/g/data/xl04/al4518/annotation/hydrophis_cyanocinctus"
RNA="/g/data/xl04/al4518/sequence-data/rna/hydrophis_cyanocinctus"
ASM="/g/data/xl04/al4518/sequence-data/ncbi/hydrophis_cyanocinctus-rename.fna"
CONTAINER='/g/data/xl04/al4518/containers'
OUT="${DIR}/annotation-funannotate"

# Concatenate R1/R2 reads
cat ${RNA}/*R1* > "${RNA}/left.fastq.gz"
cat ${RNA}/*R2* > "${RNA}/right.fastq.gz"

# Train ---
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate train \
    --input "${ASM}" \
    --out "${OUT}" \
    --left "${RNA}/left.fastq.gz" \
    --right "${RNA}/right.fastq.gz" \
    --no_trimmomatic \
    --max_intronlen 150000 \
    --species "Hydrophis cyanocinctus" \
    --cpus "${PBS_NCPUS}"

