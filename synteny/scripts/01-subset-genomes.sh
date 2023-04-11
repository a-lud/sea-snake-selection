#!/user/bin/env bash
DIR='/hpcfs/users/a1645424/analysis/synteny-hydrophis-snakes'
GENOMES="${DIR}/genomes"
SUBGEN="${GENOMES}/genomes-subset"

mkdir -p "${SUBGEN}"

# 1. Extract chromosome sequences and rename them to H. major ids
seqkit head -n 16 "${GENOMES}/hydrophis_major.fa" > "${SUBGEN}/hydrophis_major-chr.fa"
seqkit head -n 17 "${GENOMES}/hydrophis_curtus.fa" > "${SUBGEN}/hydrophis_curtus-chr.fa"
seqkit head -n 18 "${GENOMES}/hydrophis_cyanocinctus.fa" > "${SUBGEN}/hydrophis_cyanocinctus-chr.fa"
seqkit head -n 16 "${GENOMES}/hydrophis_ornatus.fa" > "${SUBGEN}/hydrophis_ornatus-chr.fa"
seqkit head -n 16 "${GENOMES}/hydrophis_curtus-AG.fa" > "${SUBGEN}/hydrophis_curtus-AG-chr.fa"
seqkit head -n 100 "${GENOMES}/hydrophis_elegans.fa" > "${SUBGEN}/hydrophis_elegans-chr.fa"
