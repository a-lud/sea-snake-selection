#!/usr/bin/env bash
#PBS ...

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

