#!/usr/bin/env bash
#PBS ...

# Directories
PROT='/g/data/xl04/al4518/annotation/hydrophis_curtus/annotation-funannotate/update_results/Hydrophis_curtus.proteins.fa'
OUT='/g/data/xl04/al4518/annotation/hydrophis_curtus/annotation-funannotate/emapper-annotation'

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
    --output 'Hydrophis_curtus-emapper' \
    --output_dir "${OUT}" \
    --override

conda deactivate

