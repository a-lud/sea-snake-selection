#!/urs/bin/env bash

DIR='/home/a1645424/al/analyses/synteny'

# Conda set up ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate syri

cd ${DIR}/genomes-syri || exit 1

syri -c ornatus_major.sam -r hydrophis_ornatus.fa -q hydrophis_major.fa -F S --prefix ornatus_major. --dir ${DIR}/syri --nc 14
syri -c major_curtus-AG.sam -r hydrophis_major.fa -q hydrophis_curtus-AG.fa -F S --prefix major_curtus-AG. --dir ${DIR}/syri --nc 14
syri -c curtus-AG_curtus.sam -r hydrophis_curtus-AG.fa -q hydrophis_curtus.fa -F S --prefix curtus-AG_curtus. --dir ${DIR}/syri --nc 14
syri -c curtus_cyanocinctus.sam -r hydrophis_curtus.fa -q hydrophis_cyanocinctus.fa -F S --prefix curtus_cyanocinctus. --dir ${DIR}/syri --nc 14
syri -c cyanocinctus_th-elegans.sam -r hydrophis_cyanocinctus.fa -q thamnophis_elegans.fa -F S --prefix cyanocinctus_th-elegans. --dir ${DIR}/syri --nc 14 --no-chrmatch

echo "Done"

conda deactivate

