#!/usr/bin/env bash
#PBS -P xl04
#PBS -q hugemem
#PBS -l walltime=16:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=400GB
#PBS -l ncpus=48
#PBS -l wd
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -N Predict-nm
#PBS -o /g/data/xl04/al4518/hydmaj-genome/funannotate/scripts/joblogs/funannotate-predict-no-mask.log
#PBS -j oe

# Modules/Software
module load singularity

# Directories ---
DIR="/g/data/xl04/al4518/hydmaj-genome/funannotate"
ASM="/g/data/xl04/al4518/hydmaj-genome/hydmaj-chromosome/hydmaj-p_ctg-v1.fna"
PRO="${DIR}/protein-evidence"
OTH="${DIR}/other-evidence"
EVM='/home/566/al4518/al/hydmaj-genome/funannotate/annotation-funannotate/predict_misc/evm.cleaned.gff3.sorted.gff3'
CONTAINER='/g/data/xl04/al4518/containers'
OUT="${DIR}/annotation-funannotate-no-mask"

# Predict ---
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate predict \
    --input "${ASM}" \
    --out "${OUT}" \
    --species "Hydrophis major_nm" \
    --weights genemark:1 \
    --other_gff "${OTH}/metaeuk-evm_valid.gff3:3" "${OTH}/anolis_carolinensis-to-hydrophis_major-evm_valid.gff3:3" "${OTH}/naja_naja-to-hydrophis_major-evm_valid.gff3:3" "${OTH}/notechis_scutatus-to-hydrophis_major-evm_valid.gff3:3" "${OTH}/protobothrops_mucrosquamatus-to-hydrophis_major-evm_valid.gff3:3" "${OTH}/pseudonaja_textilis-to-hydrophis_major-evm_valid.gff3:3" "${OTH}/thamnophis_elegans-to-hydrophis_major-evm_valid.gff3:3" "${EVM}:3" \
    --database '/home/566/al4518/al/database/funannotate_db' \
    --busco_db 'tetrapoda' \
    --organism 'other' \
    --max_intronlen 150000 \
    --genemark_gtf "${DIR}/genemark-es-out/genemark.gtf" \
    --protein_evidence "${PRO}/snake-proteins-clustered_rep_seq.fasta" \
    --tmpdir "${DIR}" \
    --cpus "${PBS_NCPUS}" \
    --force

