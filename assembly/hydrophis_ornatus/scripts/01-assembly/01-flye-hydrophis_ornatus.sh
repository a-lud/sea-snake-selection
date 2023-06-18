#!/usr/bin/env bash

DIR=$(pwd)
OUT="${DIR}/Flye"

flye \
  --nano-hq "${SEQ}/hydrophis_ornatus.fastq.gz" \
  --out-dir "${OUT}/hydrophis_ornatus" \
  --threads 30 \
  -i 2
