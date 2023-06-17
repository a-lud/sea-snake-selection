#!/usr/bin/env bash

DIR='/home/a1645424/al/analyses/species-tree-estimation'
MSA="${DIR}/04-clean-hydrophis"
OUT1="${DIR}/06-iqtree-single-tree"
OUT2="${DIR}/07-iqtree"

# NOTE: 04-clean-hydrophis has been subset for parsimony informative orthologs

mkdir -p "${OUT1}" "${OUT2}" "${DIR}/logs"

mamba activate iqtree

# IQtree passing single directory as input
iqtree -s "${MSA}" -T 8 --threads-max 8 --prefix ${OUT1}/hydrophis-iqtree --ufboot 1000 --wbtl

# Parallel execution of iqtree on each hydrophis single-copy ortholog
find "${MSA}" -maxdepth 1 -type f -name '*.fa' |
    parallel \
        -j 20 \
        --joblog "${DIR}/logs/iqtree-parallel.log" \
        "iqtree -s {} -T 1 --threads-max 1 --seqtype CODON --prefix ${OUT2}/{/.} --ufboot 1000 --wbtl"

cat "${OUT2}/"*.treefile >"${OUT2}/ml_best.trees"
find "${OUT2}" -type f -name '*.ufboot' >"${OUT2}/ml_boot.txt"

# ASTRAL using all gene trees
java -Xms20g -Xmx40g -jar '/localscratch/al/myconda/envs/iqtree/share/astral-tree-5.7.8-0/astral.5.7.8.jar' \
      -i "${OUT2}/ml_best.trees" \
      -b "${OUT2}/ml_boot.txt" \
      -o "${DIR}/astral-species.tre" &> "${DIR}/astral.log"

mamba deactivate

