#!/usr/bin/env bash
#SBATCH --job-name=RepeatMasker-TElib
#SBATCH -p skylakehm
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 40
#SBATCH --ntasks-per-core=1
#SBATCH --time=72:00:00
#SBATCH --mem=350GB
#SBATCH -o /home/a1645424/hpcfs/hydmaj-genome/repeats/slurm/%x_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

DIR='/home/a1645424/hpcfs/hydmaj-genome/repeats'
ASM='/home/a1645424/hpcfs/hydmaj-genome/hydmaj-chromosomes/hydmaj-p_ctg-v1.fna'
OUT="${DIR}/repeatmasker-out"

mkdir -p "${OUT}"

cd "${OUT}" || exit 1

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate EDTA

RepeatMasker \
    -e rmblast \
    -pa 8 \
    -s \
    -nolow \
    -norna \
    -div 40 \
    -lib "${DIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.TElib.fa" \
    -cutoff 225 \
    -dir . \
    -a \
    -inv \
    -xsmall \
    -gff \
    "${ASM}"

conda deactivate

