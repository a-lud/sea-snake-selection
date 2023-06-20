#!/usr/bin/env bash
#SBATCH ...

# Directories
PROT='/hpcfs/users/a1645424/hydmaj-genome/funannotate/annotation-funannotate-no-mask/update_results/Hydrophis_major_nm.proteins.fa'
IPS='/hpcfs/users/a1645424/database/interproscan-5.57-90.0'
OUT='/hpcfs/users/a1645424/hydmaj-genome/funannotate/annotation-funannotate-no-mask/interpro-annotation'

mkdir -p "${OUT}"

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate interpro

"${IPS}/interproscan.sh" \
    --cpu "${SLURM_CPUS_PER_TASK}" \
    --output-file-base "${OUT}/Hydrophis_major" \
    --disable-precalc \
    --goterms \
    --input "${PROT}" \
    --iprlookup \
    --pathways &>"${OUT}/ips5.log"

conda deactivate
