#!/usr/bin/env bash
#SBATCH ...

GENOMES="/hpcfs/users/a1645424/analysis/repeat-sea-snakes/genomes"
DIR='/hpcfs/users/a1645424/analysis/repeat-sea-snakes'

# Get current snake
ASM=$(find "${GENOMES}" -type f -name '*.fa' | tr '\n' ' ' | cut -d' ' -f "${SLURM_ARRAY_TASK_ID}")
BN=$(basename "${ASM%.*}")

# EDTA DIR
EDTA="${DIR}/resuts/${BN}"
OUT="${EDTA}/lai"

mkdir -p "${OUT}"

cd "${OUT}" || exit 1

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate EDTA

LAI \
    -genome "${EDTA}/${BN}.fa.mod" \
    -intact "${EDTA}/${BN}.fa.mod.EDTA.raw/LTR/${BN}.fa.mod.pass.list" \
    -all "${EDTA}/${BN}.fa.mod.EDTA.anno/${BN}.fa.mod.out" \
    -t "${SLURM_CPUS_PER_TASK}"

conda deactivate

