#!/usr/bin/env bash
#SBATCH --job-name=proteins-to-swissprot
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 40
#SBATCH -a 1-11
#SBATCH --ntasks-per-core=1
#SBATCH --time=06:00:00
#SBATCH --mem=20GB
#SBATCH -o /hpcfs/users/a1645424/analysis/blast-to-swissProt/scripts/joblogs/%x_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

OUT='/hpcfs/users/a1645424/analysis/blast-to-swissProt/output'
DB='/hpcfs/users/a1645424/database/uniprotKB_Swiss-Prot/uniprot_sprot.release-2022_02.fasta'
PROT='/hpcfs/users/a1645424/analysis/orthologs/agat/cds_proteins'

mkdir -p "${OUT}"

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate blast

FILE=$(find "${PROT}" -type f -name '*.faa' | tr '\n' ' ' | cut -d ' ' -f "${SLURM_ARRAY_TASK_ID}")

if [[ ! -f "${OUT}/$(basename ${FILE%.*}).outfmt6" ]]; then
    blastp \
        -query "${FILE}" \
        -db "${DB}" \
        -out "${OUT}/$(basename ${FILE%.*}).outfmt6" \
        -evalue 1e-5 \
        -outfmt "6 qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs" \
        -max_target_seqs 100 \
        -num_threads "${SLURM_CPUS_PER_TASK}"
fi

conda deactivate

