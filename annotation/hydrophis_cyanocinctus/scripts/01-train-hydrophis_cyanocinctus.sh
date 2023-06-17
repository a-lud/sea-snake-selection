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
#PBS -N Hcya-Train
#PBS -o /home/566/al4518/al/annotation/scripts/joblogs/funannotate-train-hydrophis_cyanocinctus.log
#PBS -j oe

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

