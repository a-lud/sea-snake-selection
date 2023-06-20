#!/usr/bin/env bash
#PBS ...

# Variables
CONTAINER='/g/data/xl04/al4518/containers'

# Modules/Software
module load singularity

singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate update \
	-i /g/data/xl04/al4518/annotation/hydrophis_curtus/annotation-funannotate \
	--cpus "${PBS_NCPUS}"
