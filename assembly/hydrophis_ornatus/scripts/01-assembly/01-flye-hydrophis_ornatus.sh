#!/bin/bash
#$ -S /bin/bash

#arg1: path to ONT reads
#arg2: path to output directory
READS=${1}
FLYE_OUT=${2}
THREADS=32
GENOME_SIZE=2.0g

/usr/bin/time -v flye --threads ${THREADS} -g ${GENOME_SIZE} --nano-raw ${READS} --iterations 2 --out-dir ${FLYE_OUT} --trestle

