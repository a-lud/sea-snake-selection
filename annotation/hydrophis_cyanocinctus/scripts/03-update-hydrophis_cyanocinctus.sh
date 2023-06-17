#!/usr/bin/env bash
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=50GB
#PBS -l ncpus=2
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -l wd
#PBS -N cy-update
#PBS -o /g/data/xl04/al4518/annotation/scripts/joblogs/funannotate-predict-hydrophis_cyanocinctus.log
#PBS -j oe

# Variables
CONTAINER='/g/data/xl04/al4518/containers'

# Modules/Software
module load singularity

singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate update \
	-i /g/data/xl04/al4518/annotation/hydrophis_cyanocinctus/annotation-funannotate \
	--cpus "${PBS_NCPUS}"
