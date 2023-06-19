#!/usr/bin/env bash
#SBATCH ...

# Directories ---
DIR='/home/a1645424/hpcfs/hydmaj-genome/repeats'
EDTADIR="${DIR}/edta-p_ctg-out"
OUT="${DIR}/LAI"

mkdir -p ${OUT}
cd ${OUT} || exit 1

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate EDTA

LAI \
    -genome "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod" \
    -intact "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.raw/LTR/hydmaj-p_ctg-v1.fna.mod.pass.list" \
    -all "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.anno/hydmaj-p_ctg-v1.fna.mod.out" \
    -t ${SLURM_CPUS_PER_TASK}

conda deactivate

