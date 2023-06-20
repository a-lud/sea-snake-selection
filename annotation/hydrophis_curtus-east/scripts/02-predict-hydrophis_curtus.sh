#!/usr/bin/env bash
#PBS ...

# Modules/Software
module load singularity

# Directories ---
DIR="/g/data/xl04/al4518/annotation"
ASM="/g/data/xl04/al4518/sequence-data/ncbi/hydrophis_curtus-rename.fna"
PRO="${DIR}/protein-evidence"
LFT="${DIR}/other-evidence/liftoff/hydrophis_curtus-liftoff"
MTU="${DIR}/other-evidence/metaeuk/hydrophis_curtus"
GMK="${DIR}/genemark-es-out/hydrophis_curtus/genemark.gtf"
CONTAINER='/g/data/xl04/al4518/containers'
OUT="${DIR}/hydrophis_curtus/annotation-funannotate"

# Predict ---
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate predict \
    --input "${ASM}" \
    --out "${OUT}" \
    --species "Hydrophis curtus" \
    --weights genemark:1 \
    --other_gff "${MTU}/hydrophis_curtus-snake-proteins-evm_valid.gff3:3" "${MTU}/hydrophis_curtus-uniprot_sprot-evm_valid.gff3:3" "${LFT}/anolis_carolinensis-to-hydrophis_curtus-evm_valid.gff3:3" "${LFT}/naja_naja-to-hydrophis_curtus-evm_valid.gff3:3" "${LFT}/notechis_scutatus-to-hydrophis_curtus-evm_valid.gff3:3" "${LFT}/protobothrops_mucrosquamatus-to-hydrophis_curtus-evm_valid.gff3:3" "${LFT}/pseudonaja_textilis-to-hydrophis_curtus-evm_valid.gff3:3" "${LFT}/thamnophis_elegans-to-hydrophis_curtus-evm_valid.gff3:3" "${LFT}/hydrophis_major-to-hydrophis_curtus-clean.gff3:3" \
    --database '/home/566/al4518/al/database/funannotate_db' \
    --genemark_gtf "${GMK}" \
    --busco_db 'tetrapoda' \
    --organism 'other' \
    --max_intronlen 150000 \
    --protein_evidence "${PRO}/snake-proteins-clustered_rep_seq.fasta" \
    --repeats2evm \
    --tmpdir "${DIR}" \
    --cpus "${PBS_NCPUS}"
