#!/usr/bin/env bash
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=30GB
#PBS -l ncpus=1
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -l wd
#PBS -N IPS5
#PBS -o /g/data/xl04/al4518/hydmaj-genome/funannotate/scripts/joblogs/ips5.log
#PBS -j oe

# Directories
# PROT='/home/566/al4518/al/hydmaj-genome/funannotate/annotation-funannotate-no-mask/update_results/Hydrophis_major_nm.proteins.fa'
IPS='/home/566/al4518/al/database/interproscan-5.57-90.0'
OUT='/home/566/al4518/al/hydmaj-genome/funannotate/annotation-funannotate-no-mask/interpro-annotation'

mkdir -p "${OUT}"

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate interpro

for FA in "${OUT}/split-proteins"/*.fa; do
    BN=$(basename "${FA%.*}")
    echo "[Current] ${BN}"
    "${IPS}/interproscan.sh" \
        --cpu "${PBS_NCPUS}" \
        --output-file-base "${OUT}/${BN}" \
        --disable-precalc \
        --goterms \
        --input "${FA}" \
        --iprlookup \
        --pathways \
        --verbose \
        --tempdir '/home/566/al4518/al/altemp' &> "${OUT}/ips5.log"
done
conda deactivate

