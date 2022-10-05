#!/usr/bin/env bash
#SBATCH --job-name=wei2go-homology
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 16
#SBATCH -a 1-11
#SBATCH --ntasks-per-core=1
#SBATCH --time=08:00:00
#SBATCH --mem=20GB
#SBATCH -o /hpcfs/users/a1645424/analysis/wei2go/scripts/joblogs/%x_%a_%A_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

OUT='/hpcfs/users/a1645424/analysis/wei2go/homology-output'
DB='/hpcfs/users/a1645424/analysis/wei2go/temp-db/knowledgebase'
PF='/hpcfs/users/a1645424/database/funannotate_db/Pfam-A.hmm'
PROT='/hpcfs/users/a1645424/analysis/orthologs/agat/cds_proteins'

mkdir -p "${OUT}"

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate diamond

FILE=$(find "${PROT}" -type f -name '*.faa' | tr '\n' ' ' | cut -d ' ' -f "${SLURM_ARRAY_TASK_ID}")

if [[ ! -f "${OUT}/$(basename "${FILE%.*}").tab" ]]; then
    BN=$(basename "${FILE%.*}")
    /hpcfs/users/a1645424/software/diamond/diamond blastp \
        --threads "${SLURM_CPUS_PER_TASK}" \
        --query "${FILE}" \
        --db "${DB}" \
        --out "${OUT}/${BN}.tab"
fi

conda deactivate

conda activate hmmer

if [[ ! -f "${OUT}/$(basename "${FILE%.*}").out" ]]; then
    hmmscan \
        --cpu "${SLURM_CPUS_PER_TASK}" \
        --tblout "${OUT}/${BN}.out" \
        "${PF}" \
        "${FILE}"
fi
conda deactivate
