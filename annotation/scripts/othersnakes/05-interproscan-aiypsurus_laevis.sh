#!/usr/bin/env bash
#SBATCH --job-name=ips5
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 20
#SBATCH --ntasks-per-core=1
#SBATCH --time=20:00:00
#SBATCH --mem=40GB
#SBATCH -o /hpcfs/users/a1645424/annotation/scripts/joblogs/%x_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

# Directories
PROT='/hpcfs/users/a1645424/annotation/aipysurus_laevis/annotation-funannotate/update_results/Aipysurus_laevis.proteins.fa'
IPS='/hpcfs/users/a1645424/database/interproscan-5.57-90.0'
OUT='/hpcfs/users/a1645424/annotation/aipysurus_laevis/annotation-funannotate/interpo-annotation'

mkdir -p "${OUT}"

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate interpro

"${IPS}/interproscan.sh" \
    --cpu "${SLURM_CPUS_PER_TASK}" \
    --output-file-base "${OUT}/Aipysurus_laevis" \
    --disable-precalc \
    --goterms \
    --input "${PROT}" \
    --iprlookup \
    --pathways &>"${OUT}/ips5.log"

conda deactivate
