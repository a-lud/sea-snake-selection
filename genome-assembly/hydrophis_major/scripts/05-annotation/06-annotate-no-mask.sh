#!/usr/bin/env bash
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=24:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=80GB
#PBS -l ncpus=30
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -l wd
#PBS -N annotate
#PBS -o /g/data/xl04/al4518/hydmaj-genome/funannotate/scripts/joblogs/funannotate-annotate-no-mask.log
#PBS -j oe

# Variables
DIR='/g/data/xl04/al4518/hydmaj-genome/funannotate'
EGG="${DIR}/annotation-funannotate-no-mask/emapper-annotation/Hydrophis_major-emapper.emapper.annotations"
IPS="${DIR}/annotation-funannotate-no-mask/interpro-annotation/Hydrophis_major.xml"
CONTAINER='/g/data/xl04/al4518/containers'

# Modules/Software
module load singularity

singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate annotate \
    -i '/g/data/xl04/al4518/hydmaj-genome/funannotate/annotation-funannotate-no-mask' \
    --cpus "${PBS_NCPUS}" \
    --eggnog "${EGG}" \
    --iprscan "${IPS}" \
    --busco_db 'tetrapoda' \
    --database '/home/566/al4518/al/database/funannotate_db' \
    --tmpdir "${PWD}" \
    --no-progress

