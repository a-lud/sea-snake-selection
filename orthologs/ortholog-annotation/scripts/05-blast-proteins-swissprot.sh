#!/usr/bin/env bash
#SBATCH --job-name=blast
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 30
#SBATCH -a 1-13
#SBATCH --ntasks-per-core=2
#SBATCH --time=12:00:00
#SBATCH --mem=5GB
#SBATCH -o /hpcfs/users/a1645424/analysis/blast-to-swissProt/scripts/joblogs/%x_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

DIR='/hpcfs/users/a1645424/analysis/blast-to-swissProt'
PROT="${DIR}/proteins"
OUT="${DIR}/results"
DB='/hpcfs/users/a1645424/database/uniprotKB_Swiss-Prot/uniprot_sprot.fasta'

mkdir -p "${OUT}"

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate blast

FILE=$(find "${PROT}" -type f -name '*.faa' | tr '\n' ' ' | cut -d ' ' -f "${SLURM_ARRAY_TASK_ID}")

if [[ ! -f "${OUT}/$(basename "${FILE%.*}").outfmt6" ]]; then
    blastp \
        -query "${FILE}" \
        -db "${DB}" \
        -out "${OUT}/$(basename "${FILE%.*}").outfmt6" \
        -evalue 1e-5 \
        -outfmt "6 qaccver saccver qlen slen length qcovs pident mismatch gapopen qstart qend sstart send evalue bitscore" \
        -max_target_seqs 100 \
        -num_threads "${SLURM_CPUS_PER_TASK}"
fi

conda deactivate
