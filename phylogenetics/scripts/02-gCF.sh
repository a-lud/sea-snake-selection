#!/usr/bin/env bash

mamba activate iqtree

iqtree -t astral-no-bootstrap.tree --gcf ml_best.trees --prefix gene_concordance-ml-trees-only 
iqtree -t astral-species.tre --gcf ml_best.trees --prefix gene_concordance

mamba deactivate
