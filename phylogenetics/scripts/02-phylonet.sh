#!/usr/bin/env bash
#SBATCH --job-name=reticualtions
#SBATCH -p skylake
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 40
#SBATCH -a 0-4
#SBATCH --ntasks-per-core=1
#SBATCH --time=48:00:00
#SBATCH --mem=40GB
#SBATCH -o /home/a1645424/hpcfs/analysis/species-tree/scripts/joblogs/%x_%a_%A_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

source '/home/a1645424/micromamba/etc/profile.d/micromamba.sh'

micromamba activate base

java -jar /home/a1645424/hpcfs/software/phylonet/PhyloNet_3.8.2.jar "../ml_best-n5-${SLURM_ARRAY_TASK_ID}-reticulations.nex"

micromamba deactivate
