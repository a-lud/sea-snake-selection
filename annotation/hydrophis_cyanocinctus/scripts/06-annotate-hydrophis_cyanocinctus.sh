#!/usr/bin/env bash
#PBS ...

# Variables
DIR='/g/data/xl04/al4518/annotation/hydrophis_cyanocinctus'
EGG="${DIR}/annotation-funannotate/emapper-annotation/Hydrophis_cyanocinctus-emapper.emapper.annotations"
IPS="${DIR}/annotation-funannotate/interpro-annotation/Hydrophis_cyanocinctus.xml"
CONTAINER='/g/data/xl04/al4518/containers'

# Modules/Software
module load singularity

singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate annotate \
    -i '/g/data/xl04/al4518/annotation/hydrophis_cyanocinctus/annotation-funannotate' \
    --cpus "${PBS_NCPUS}" \
    --eggnog "${EGG}" \
    --iprscan "${IPS}" \
    --busco_db 'tetrapoda' \
    --database '/home/566/al4518/al/database/funannotate_db' \
    --tmpdir "${PWD}" \
    --no-progress

