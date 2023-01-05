#!/usr/bin/env bash

DIR='/home/a1645424/al/analyses/blast-to-swissProt'
DB='/home/a1645424/al/databases/uniprotKB_Swiss-Prot'

# Gene Names from 'idmapping.dat.gz'
"${DIR}/scripts/parseIdMap" \
  -a "${DIR}/best-hits.csv" \
  -m "${DB}/idmapping.dat.gz" \
  -i Gene_Name \
  -o "${DIR}/results/idmapping.dat.csv"

# GO Terms from 'idmapping_selected.tab.gz'
"${DIR}/scripts/parseIdMap" \
  -a "${DIR}/best-hits.csv" \
  -m "${DB}/idmapping_selected.tab.gz" \
  -i GO \
  -o "${DIR}/results/idmapping_selected.tab.csv"
