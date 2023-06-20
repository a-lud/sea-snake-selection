#!/usr/bin/env bash
#PBS ...

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

