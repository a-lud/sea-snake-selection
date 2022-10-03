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
#PBS -N Train
#PBS -o /g/data/xl04/al4518/hydmaj-genome/funannotate/scripts/joblogs/funannotate-train.log
#PBS -j oe

# Modules/Software
module load singularity

# Directories ---
DIR="/g/data/xl04/al4518/hydmaj-genome/funannotate"
RNA="${DIR}/rna"
ASM="/g/data/xl04/al4518/hydmaj-genome/hydmaj-chromosome/hydmaj-p_ctg-v1.sm.fna"
CONTAINER='/g/data/xl04/al4518/containers'
OUT="${DIR}/annotation-funannotate"

# Train ---
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate train \
    --input "${ASM}" \
    --out "${OUT}" \
    --left "${RNA}/left.fastq.gz" \
    --right "${RNA}/right.fastq.gz" \
    --no_trimmomatic \
    --max_intronlen 150000 \
    --species "Hydrophis major" \
    --cpus "${PBS_NCPUS}"

