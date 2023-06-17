#!/usr/bin/env bash
#SBATCH --job-name=liftoff-to-oriented
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 30
#SBATCH -a 1-2
#SBATCH --ntasks-per-core=1
#SBATCH --time=02:00:00
#SBATCH --mem=80GB
#SBATCH -o /hpcfs/users/a1645424/analysis/synteny-hydrophis-snakes/scripts-2/joblogs/%x_%a_%A_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

# Directories ---
DIR='/hpcfs/users/a1645424/analysis/synteny-hydrophis-snakes'
REFS="${DIR}/genomes-mcscan"
OUT="${DIR}/liftoff-oriented-genomes"
MCS='/hpcfs/users/a1645424/analysis/synteny-hydrophis-snakes/gffs-mcscan'

TGFFS='/hpcfs/groups/phoenix-hpc-biohub/alastair/sequence-db/gffs'
TREFS="/hpcfs/groups/phoenix-hpc-biohub/alastair/sequence-db/genomes"


# Genomes to annotate
QASM=$(find "${REFS}" -type f -name '*.fa' | tr '\n' ' ' | cut -d ' ' -f "${SLURM_ARRAY_TASK_ID}")
BN=$(basename "${QASM%.*}")
echo "Sample: ${BN}"
mkdir -p "${OUT}/${BN}"

# Conda set up ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate liftoff

# Set up reference information to lift-over from
case ${BN} in
    'hydrophis_curtus')
        TASM="${TREFS}/hydrophis_curtus-ncbi.fa"
        TGFF="${TGFFS}/hydrophis_curtus-ncbi.gff3"
        ;;
    'hydrophis_curtus-AG')
        TASM="${TREFS}/hydrophis_curtus-garvin.fa"
        TGFF="${TGFFS}/hydrophis_curtus-garvin.gff3"
        ;;
    'hydrophis_cyanocinctus')
        TASM="${TREFS}/hydrophis_cyanocinctus-ncbi.fa"
        TGFF="${TGFFS}/hydrophis_cyanocinctus-ncbi.gff3"
        ;;
    'hydrophis_ornatus')
        TASM="${TREFS}/hydrophis_ornatus-garvin.fa"
        TGFF="${TGFFS}/hydrophis_ornatus-garvin.gff3"
        ;;
    'hydrophis_major')
        TASM="${TREFS}/hydmaj-p_ctg-v1.fa"
        TGFF="${TGFFS}/hydrophis_major.gff3"    
        ;;
    *)
        echo -e "[Skipping]\t${BN}"
        exit 0
        ;;
esac

# Map genes from original assembly to renamed, reoriented chromosome assemblies
liftoff \
    "${QASM}" \
    "${TASM}" \
    -g "${TGFF}" \
    -o "${OUT}/${BN}/${BN}.gff3" \
    -u "${OUT}/${BN}/${BN}-unmapped.txt" \
    -exclude_partial \
    -dir "${OUT}/${BN}/intermediates" \
    -p "${SLURM_CPUS_PER_TASK}" \
    -polish

cp "${OUT}/${BN}/${BN}.gff3_polished" "${MCS}/${BN}.gff3"

conda deactivate

