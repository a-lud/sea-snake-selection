#!/usr/bin/env bash
#PBS -P xl04
#PBS -q hugemem
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=700GB
#PBS -l ncpus=48
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -N flye
#PBS -o /g/data/xl04/al4518/garvin/scripts/joblog/flye-hydrophis_elegans.log
#PBS -j oe

# Directories ---
DIR='/home/566/al4518/al/garvin'
OUT="${DIR}/assembly/flye-hydrophis_elegans"
SEQ='/home/566/al4518/al/sequence-data/garvin/nanopore'

# conda ---
# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate flye

# Assemble ---
flye \
    --nano-hq "${SEQ}/hydrophis_elegans.fastq.gz" \
    --out-dir "${OUT}" \
    --threads "${PBS_NCPUS}" \
    --scaffold

conda deactivate

