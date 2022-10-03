#!/usr/bin/env bash
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=20GB
#PBS -l ncpus=48
#PBS -l wd
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -N AL-genemark
#PBS -o /g/data/xl04/al4518/annotation/scripts/joblogs/genemark-es-aipysurus_laevis.log
#PBS -j oe

# GeneMark
export PATH=$PATH:'/home/566/al4518/al/software/gmes_linux_64'

DIR='/g/data/xl04/al4518/annotation'
REF="/g/data/xl04/al4518/garvin/medaka/aipysurus_laevis/aipysurus_laevis-consensus.fna"
OUT="${DIR}/genemark-es-out/aipysurus_laevis"

mkdir -p ${OUT}

cd ${OUT} || exit 1

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate genemark

gmes_petap.pl \
    --ES \
    --max_intron 150000 \
    --soft_mask 2000 \
    --cores "${PBS_NCPUS}" \
    --sequence "${REF}"

conda deactivate

