#!/usr/bin/env bash
#PBS ...

# GeneMark
export PATH=$PATH:'/home/566/al4518/al/software/gmes_linux_64'

DIR='/g/data/xl04/al4518/annotation'
REF="/g/data/xl04/al4518/sequence-data/ncbi/hydrophis_cyanocinctus-rename.fna"
OUT="${DIR}/genemark-es-out/hydrophis_cyanocinctus"

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

