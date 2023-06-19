#!/usr/bin/env bash
#PBS -P xl04
#PBS -q normal
#PBS -l walltime=02:00:00
#PBS -l storage=gdata/xl04+scratch/xl04
#PBS -l mem=4GB
#PBS -l ncpus=20
#PBS -M alastair.ludington@adelaide.edu.au
#PBS -m a
#PBS -N mmseqs2-cluster
#PBS -o /home/566/al4518/al/hydmaj-genome/funannotate/scripts/joblogs/mmseqs2-cluster-snake-proteins.log
#PBS -j oe

# Directories ---
PROT='/home/566/al4518/al/hydmaj-genome/funannotate/protein-evidence'

mkdir -p "${PROT}/mmtemp"

# Conda --
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate mmseqs2

# Cluster proteins
mmseqs easy-cluster \
    "${PROT}/snake-proteins.faa" \
    "${PROT}/snake-proteins-clustered" \
    "${PROT}/mmtemp" \
    --min-seq-id 0.9 \
    -c 0.9 \
    --cluster-reassign \
    --threads "${PBS_NCPUS}"

# Extract representative sequence
# mmseqs createsubdb DB_clu DB DB_clu_rep
# mmseqs convert2fasta DB_clu_rep DB_clu_rep.fasta

conda deactivate

