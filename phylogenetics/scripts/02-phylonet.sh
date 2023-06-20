#!/usr/bin/env bash
#SBATCH ...

source '/home/a1645424/micromamba/etc/profile.d/micromamba.sh'

micromamba activate base

java -jar PhyloNet_3.8.2.jar "../ml_best-n5-${SLURM_ARRAY_TASK_ID}-reticulations.nex"

micromamba deactivate
