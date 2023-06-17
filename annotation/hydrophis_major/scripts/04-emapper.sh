#!/usr/bin/env bash
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=24:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=50GB
#PBS -l ncpus=30
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -l wd
#PBS -N EGGnog
#PBS -o /g/data/xl04/al4518/hydmaj-genome/funannotate/scripts/joblogs/egnogg.log
#PBS -j oe

# Directories
PROT='/home/566/al4518/al/hydmaj-genome/funannotate/annotation-funannotate-no-mask/update_results/Hydrophis_major_nm.proteins.fa'
OUT='/home/566/al4518/al/hydmaj-genome/funannotate/annotation-funannotate-no-mask/emapper-annotation'

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
    --output 'Hydrophis_major-emapper' \
    --output_dir "${OUT}"

conda deactivate

