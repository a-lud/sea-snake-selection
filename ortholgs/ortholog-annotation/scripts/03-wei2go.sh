#!/usr/bin/env bash
#SBATCH --job-name=wei2go-output
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -a 1-11
#SBATCH --ntasks-per-core=1
#SBATCH --time=12:00:00
#SBATCH --mem=4GB
#SBATCH -o /hpcfs/users/a1645424/analysis/wei2go/scripts/joblogs/%x_%a_%A_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

DIR='/hpcfs/users/a1645424/analysis/wei2go'
OUT="${DIR}/results"

mkdir -p "${OUT}"

HMM=$(find "${DIR}/homology-output" -type f -name '*.out' | tr '\n' ' ' | cut -d ' ' -f "${SLURM_ARRAY_TASK_ID}")

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate diamond

python /hpcfs/users/a1645424/software/wei2go/wei2go.py \
    "${HMM%.*}.tab" "${HMM}" "${OUT}/$(basename "${HMM%.*}").tsv"

conda deactivate
