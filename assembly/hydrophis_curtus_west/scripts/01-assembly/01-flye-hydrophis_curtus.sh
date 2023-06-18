#!/usr/bin/env bash

DIR=$(pwd)
OUT="${DIR}/Flye"

flye \
  --nano-hq "${SEQ}/hydrophis_curtus.fastq.gz" \
  --out-dir "${OUT}/hydrophis_curtus" \
  --threads 30 \
  -i 2
  