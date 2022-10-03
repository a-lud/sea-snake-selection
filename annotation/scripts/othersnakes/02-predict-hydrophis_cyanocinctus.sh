#!/usr/bin/env bash
#PBS -P xl04
#PBS -q hugemem
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=500GB
#PBS -l ncpus=48
#PBS -l wd
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -N Hcy-predict
#PBS -o /g/data/xl04/al4518/annotation/scripts/joblogs/funannotate-predict-hydrophis_cyanocinctus.log
#PBS -j oe

# Modules/Software
module load singularity

# Directories ---
DIR="/g/data/xl04/al4518/annotation"
ASM="/g/data/xl04/al4518/sequence-data/ncbi/hydrophis_cyanocinctus-rename.fna"
PRO="${DIR}/protein-evidence"
LFT="${DIR}/other-evidence/liftoff/hydrophis_cyanocinctus-liftoff"
MTU="${DIR}/other-evidence/metaeuk/hydrophis_cyanocinctus"
GMK="${DIR}/genemark-es-out/hydrophis_cyanocinctus/genemark.gtf"
CONTAINER='/g/data/xl04/al4518/containers'
OUT="${DIR}/hydrophis_cyanocinctus/annotation-funannotate"

# Predict ---
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate predict \
    --input "${ASM}" \
    --out "${OUT}" \
    --species "Hydrophis cyanocinctus" \
    --weights genemark:1 \
    --other_gff "${MTU}/hydrophis_cyanocinctus-snake-proteins-evm_valid.gff3:3" "${MTU}/hydrophis_cyanocinctus-uniprot_sprot-evm_valid.gff3:3" "${LFT}/anolis_carolinensis-to-hydrophis_cyanocinctus-evm_valid.gff3:3" "${LFT}/naja_naja-to-hydrophis_cyanocinctus-evm_valid.gff3:3" "${LFT}/notechis_scutatus-to-hydrophis_cyanocinctus-evm_valid.gff3:3" "${LFT}/protobothrops_mucrosquamatus-to-hydrophis_cyanocinctus-evm_valid.gff3:3" "${LFT}/pseudonaja_textilis-to-hydrophis_cyanocinctus-evm_valid.gff3:3" "${LFT}/thamnophis_elegans-to-hydrophis_cyanocinctus-evm_valid.gff3:3" "${LFT}/hydrophis_major-to-hydrophis_cyanocinctus-clean.gff3:3"\
    --database '/home/566/al4518/al/database/funannotate_db' \
    --genemark_gtf "${GMK}" \
    --busco_db 'tetrapoda' \
    --organism 'other' \
    --max_intronlen 150000 \
    --protein_evidence "${PRO}/snake-proteins-clustered_rep_seq.fasta" \
    --repeats2evm \
    --tmpdir "${DIR}" \
    --cpus "${PBS_NCPUS}"
