#!/usr/bin/env bash
#SBATCH ...

# NOTE: I've edited the EDTA.pl script to not run the RAW step.
# All this script does is generate some intermediate files that need to be made
# that aren't created if this step is not run.

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
    --step 'all' \
    --overwrite 0 \
    --threads "${SLURM_CPUS_PER_TASK}"

conda deactivate

