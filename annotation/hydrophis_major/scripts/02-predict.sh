#!/usr/bin/env bash
#PBS ...

# Modules/Software
module load singularity

# Directories ---
DIR="/g/data/xl04/al4518/hydmaj-genome/funannotate"
ASM="/g/data/xl04/al4518/hydmaj-genome/hydmaj-chromosome/hydmaj-p_ctg-v1.sm.fna"
PRO="${DIR}/protein-evidence"
OTH="${DIR}/other-evidence"
CONTAINER='/g/data/xl04/al4518/containers'
OUT="${DIR}/annotation-funannotate"

# Predict ---
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate predict \
    --input "${ASM}" \
    --out "${OUT}" \
    --species "Hydrophis major" \
    --weights genemark:1 \
    --other_gff "${OTH}/metaeuk-evm_valid.gff3:3" "${OTH}/anolis_carolinensis-to-hydrophis_major-evm_valid.gff3:3" "${OTH}/naja_naja-to-hydrophis_major-evm_valid.gff3:3" "${OTH}/notechis_scutatus-to-hydrophis_major-evm_valid.gff3:3" "${OTH}/protobothrops_mucrosquamatus-to-hydrophis_major-evm_valid.gff3:3" "${OTH}/pseudonaja_textilis-to-hydrophis_major-evm_valid.gff3:3" "${OTH}/thamnophis_elegans-to-hydrophis_major-evm_valid.gff3:3" \
    --database '/home/566/al4518/al/database/funannotate_db' \
    --busco_db 'tetrapoda' \
    --organism 'other' \
    --max_intronlen 150000 \
    --genemark_gtf "${DIR}/genemark-es-out/genemark.gtf" \
    --protein_evidence "${PRO}/snake-proteins-clustered_rep_seq.fasta" \
    --repeats2evm \
    --tmpdir "${DIR}" \
    --cpus "${PBS_NCPUS}"

