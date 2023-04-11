#!/user/bin/env bash

# Rename the chromosome sequences based on their alignments to H. major.

DIR='/hpcfs/users/a1645424/analysis/synteny-hydrophis-snakes'
GENOMES="${DIR}/genomes/genomes-subset"
OUT="${GENOMES}/renamed"
RENAME="${DIR}/data"

mkdir -p "${OUT}"

for TSV in "${RENAME}/"*.rename; do
    BN=$(basename "${TSV%.*}")
    REF="${GENOMES}/${BN}-chr.fa"

    # Rename
    echo -e "[seqkit] Rename headers"
    seqkit replace -p '(.*)$' -r '{kv}' -k "${TSV}" -o "${OUT}/${BN}.fa" "${REF}"
done

