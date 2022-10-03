#!/usr/bin/env bash
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=06:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=30GB
#PBS -l ncpus=30
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -l wd
#PBS -N emapper
#PBS -o /g/data/xl04/al4518/annotation/scripts/joblogs/emapper-aipysurus_laevis.log
#PBS -j oe

# Directories
PROT='/g/data/xl04/al4518/annotation/aipysurus_laevis/annotation-funannotate/update_results/Aipysurus_laevis.proteins.fa'
OUT='/g/data/xl04/al4518/annotation/aipysurus_laevis/annotation-funannotate/emapper-annotation'

mkdir -p "${OUT}"

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate emapper

export EGGNOG_DATA_DIR=/g/data/xl04/al4518/database/funannotate_db/eggnog_db

emapper.py \
    --cpu "${PBS_NCPUS}" \
    -i "${PROT}" \
    --itype 'proteins' \
    --pident 80 \
    --query_cover 80 \
    --output 'Aipysurus_laevis-emapper' \
    --output_dir "${OUT}" \
    --override

conda deactivate

