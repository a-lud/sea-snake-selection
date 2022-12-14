#!/usr/bin/env bash
#SBATCH --job-name=EDTA-final
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 40
#SBATCH --ntasks-per-core=1
#SBATCH --time=72:00:00
#SBATCH --mem=80GB
#SBATCH -o /home/a1645424/hpcfs/hydmaj-genome/repeats/slurm/%x_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

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
  --step final \
  --overwrite 0 \
  --sensitive 1 \
  --cds "${CDS}" \
  --threads ${SLURM_CPUS_PER_TASK}

conda deactivate

