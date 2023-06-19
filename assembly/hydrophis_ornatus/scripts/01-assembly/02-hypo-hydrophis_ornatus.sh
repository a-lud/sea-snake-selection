#!/bin/bash
#$ -S /bin/bash


# arg1: path reference assembly file.
# arg2: path to text file containg the path to illummina libraries
# arg3: path to illumina alignment
# arg4: path to ont alignment to assembly
# arg5: illumina coverage
# arg6: path to output file
# arg7: genome size

REF=${1}
THREADS=64

/usr/bin/time -v hypo \
--draft $REF \
--reads-short @${2} \
--size-ref ${7} \
--coverage-short ${5} \
--bam-sr ${3} \
--bam-lr ${4} \
-p 32 \
--threads $THREADS \
-o ${6}/polished.fasta \
--intermed
