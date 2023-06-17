#!/usr/bin/env bash
#SBATCH --job-name=anno
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 40
#SBATCH -a 1-2
#SBATCH --ntasks-per-core=1
#SBATCH --time=48:00:00
#SBATCH --mem=100GB
#SBATCH -o /hpcfs/users/a1645424/analysis/repeat-sea-snakes/scripts/joblogs/%x_%a_%A_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

GENOMES="/hpcfs/users/a1645424/analysis/repeat-sea-snakes/genomes"
DIR='/hpcfs/users/a1645424/analysis/repeat-sea-snakes'

# Get current snake
ASM=$(find "${GENOMES}" -type f -name '*.fa' | tr '\n' ' ' | cut -d' ' -f "${SLURM_ARRAY_TASK_ID}")
BN=$(basename "${ASM%.*}")

# Output directory
OUT="${DIR}/resuts/${BN}"

mkdir -p "${OUT}"

cd "${OUT}" || exit 1

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate EDTA

EDTA.pl \
    --genome "${ASM}" \
    --step 'anno' \
    --overwrite 0 \
    --anno 1 \
    --threads "${SLURM_CPUS_PER_TASK}"

conda deactivate

