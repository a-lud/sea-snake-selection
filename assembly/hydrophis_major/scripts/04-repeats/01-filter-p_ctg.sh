#!/usr/bin/env bash
#SBATCH ...

ASM='/home/a1645424/hpcfs/hydmaj-genome/hydmaj-chromosomes/hydmaj-p_ctg-v1.fna'
CDS='/home/a1645424/hpcfs/hydmaj-genome/repeats/cds/notechis_scutatus.fna'
OUT="/home/a1645424/hpcfs/hydmaj-genome/repeats/edta-p_ctg-out"

mkdir -p "${OUT}"

cd "${OUT}" || exit 1

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate EDTA

EDTA.pl \
  --genome ${ASM} \
  --step filter \
  --overwrite 0 \
  --cds "${CDS}" \
  --threads ${SLURM_CPUS_PER_TASK}

conda deactivate
