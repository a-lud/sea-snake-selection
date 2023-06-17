#!/urs/bin/env bash

DIR='/home/a1645424/al/analyses/synteny'
OUT="${DIR}/genomes-syri"

# align genomes
# Conda set up ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate minimap2

minimap2 --eqx -2 -L -t 32 -ax asm5 -o "${OUT}/ornatus_major.sam" "${OUT}/hydrophis_ornatus.fa" "${OUT}/hydrophis_major.fa"
minimap2 --eqx -2 -L -t 32 -ax asm5 -o "${OUT}/major_curtus-AG.sam" "${OUT}/hydrophis_major.fa" "${OUT}/hydrophis_curtus-AG.fa"
minimap2 --eqx -2 -L -t 32 -ax asm5 -o "${OUT}/curtus-AG_curtus.sam" "${OUT}/hydrophis_curtus-AG.fa" "${OUT}/hydrophis_curtus.fa"
minimap2 --eqx -2 -L -t 32 -ax asm5 -o "${OUT}/curtus_cyanocinctus.sam" "${OUT}/hydrophis_curtus.fa" "${OUT}/hydrophis_cyanocinctus.fa"
minimap2 --eqx -2 -L -t 32 -ax asm5 -o "${OUT}/cyanocinctus_th-elegans.sam" "${OUT}/hydrophis_cyanocinctus.fa" "${OUT}/thamnophis_elegans.fa"

echo "Done"

conda deactivate
