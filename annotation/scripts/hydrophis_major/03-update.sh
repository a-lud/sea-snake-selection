#!/usr/bin/env bash
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=100GB
#PBS -l ncpus=2
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -l wd
#PBS -N update
#PBS -o /g/data/xl04/al4518/hydmaj-genome/funannotate/scripts/joblogs/funannotate-update-no-mask.log
#PBS -j oe

# Variables
CONTAINER='/g/data/xl04/al4518/containers'

# Modules/Software
module load singularity

singularity exec ${CONTAINER}/funannotate-v1.8.11.sif funannotate update \
	-i /g/data/xl04/al4518/hydmaj-genome/funannotate/annotation-funannotate-no-mask \
	--cpus "${PBS_NCPUS}" 
