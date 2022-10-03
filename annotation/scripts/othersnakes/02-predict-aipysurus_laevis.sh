#!/usr/bin/env bash
#PBS -P xl04
#PBS -q hugemem
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=360GB
#PBS -l ncpus=48
#PBS -l wd
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -N AL-predict
#PBS -o /g/data/xl04/al4518/annotation/scripts/joblogs/funannotate-predict-aipysurus_laevis.log
#PBS -j oe

# Modules/Software
module load singularity

# Directories ---
DIR="/g/data/xl04/al4518/annotation"
ASM="/g/data/xl04/al4518/garvin/medaka/aipysurus_laevis/aipysurus_laevis-consensus.fna"
PRO="${DIR}/protein-evidence"
LFT="${DIR}/other-evidence/liftoff/aipysurus_laevis-liftoff"
MTU="${DIR}/other-evidence/metaeuk/aipysurus_laevis"
GMK="${DIR}/genemark-es-out/aipysurus_laevis/genemark.gtf"
CONTAINER='/g/data/xl04/al4518/containers'
OUT="${DIR}/aipysurus_laevis/annotation-funannotate"

# Predict ---
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate predict \
    --input "${ASM}" \
    --out "${OUT}" \
    --species "Aipysurus laevis" \
    --weights genemark:1 \
    --other_gff "${MTU}/aipysurus_laevis-snake-proteins-evm_valid.gff3:3" "${MTU}/aipysurus_laevis-uniprot_sprot-evm_valid.gff3:3" "${LFT}/anolis_carolinensis-to-aipysurus_laevis-evm_valid.gff3:3" "${LFT}/naja_naja-to-aipysurus_laevis-evm_valid.gff3:3" "${LFT}/notechis_scutatus-to-aipysurus_laevis-evm_valid.gff3:3" "${LFT}/protobothrops_mucrosquamatus-to-aipysurus_laevis-evm_valid.gff3:3" "${LFT}/pseudonaja_textilis-to-aipysurus_laevis-evm_valid.gff3:3" "${LFT}/thamnophis_elegans-to-aipysurus_laevis-evm_valid.gff3:3" "${LFT}/hydrophis_major-to-aipysurus_laevis-clean.gff3:3" \
    --database '/home/566/al4518/al/database/funannotate_db' \
    --genemark_gtf "${GMK}" \
    --busco_db 'tetrapoda' \
    --organism 'other' \
    --max_intronlen 150000 \
    --protein_evidence "${PRO}/snake-proteins-clustered_rep_seq.fasta" \
    --tmpdir "${DIR}" \
    --cpus "${PBS_NCPUS}"
