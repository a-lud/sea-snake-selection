#!/usr/bin/env bash
#SBATCH --job-name=mcscanx-2
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 20
#SBATCH --time=02:00:00
#SBATCH --mem=25GB
#SBATCH -o /hpcfs/users/a1645424/analysis/synteny-hydrophis-snakes/scripts-2/joblogs/%x_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

# MCscan syteny plot between Hydrophis snakes
# 1. Extract CDS from GFF3 - AGAT
# 2. GFF3 to bed
# 3. Make comparisons beteween snakes
#       - ornatus --> curtus-AG
#       - curtus-AG --> curtus
#       - curtus --> cyano
#       - cyano --> major

DIR='/hpcfs/users/a1645424/analysis/synteny-hydrophis-snakes'
GENOMES="${DIR}/genomes/genomes-subset/renamed"
OUT="${DIR}/mcscan-results-2"

mkdir -p "${OUT}"

cd "${OUT}" || exit 1

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate mcscan

# 1. Extract CDS sequences
for ASM in "${GENOMES}/"*.fa; do
    BN=$(basename "${ASM%.*}")
    if [[ ! -f "${BN}.cds" ]]; then
        GFF="${DIR}/gffs/clean-gff3/${BN}.gff3"

        agat_sp_extract_sequences.pl \
            --clean_final_stop \
            --clean_internal_stop \
            --fasta "${ASM}" \
            --gff "${GFF}" \
            --output "${BN}.cds" \
            --type cds

        # 2. Convert GFF3 to BED
        python3 -m jcvi.formats.gff bed --type=mRNA --key=ID "${GFF}" -o "${BN}.bed"
    fi
done

# 3. Comparisons

## H. ornatus to H. curtus (AG)
python3 -m jcvi.compara.catalog ortholog \
    --cpus="${SLURM_CPUS_PER_TASK}" \
    --no_strip_names \
    --notex \
    'hydrophis_ornatus' 'hydrophis_curtus-AG'

## H.Curtus-AG to H. curtus
python3 -m jcvi.compara.catalog ortholog \
    --cpus="${SLURM_CPUS_PER_TASK}" \
    --no_strip_names \
    --notex \
    'hydrophis_curtus-AG' 'hydrophis_curtus'

## H. curtus to H. cyanocinctus
python3 -m jcvi.compara.catalog ortholog \
    --cpus="${SLURM_CPUS_PER_TASK}" \
    --no_strip_names \
    --notex \
    'hydrophis_curtus' 'hydrophis_cyanocinctus'

## H. cyanocinctus to H. major
python3 -m jcvi.compara.catalog ortholog \
    --cpus="${SLURM_CPUS_PER_TASK}" \
    --no_strip_names \
    --notex \
    'hydrophis_cyanocinctus' 'hydrophis_major'

# ## H. elegans to H. cyano
# python3 -m jcvi.compara.catalog ortholog \
#     --cpus="${SLURM_CPUS_PER_TASK}" \
#     --no_strip_names \
#     --notex \
#     'hydrophis_cyanocinctus' 'hydrophis_elegans'

# 4. Create files needed for synteny plots
# asm vs species
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_ornatus.hydrophis_curtus-AG.anchors hydrophis_ornatus.hydrophis_curtus-AG.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_curtus-AG.hydrophis_curtus.anchors hydrophis_curtus-AG.hydrophis_curtus.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_curtus.hydrophis_cyanocinctus.anchors hydrophis_curtus.hydrophis_cyanocinctus.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_cyanocinctus.hydrophis_major.anchors hydrophis_cyanocinctus.hydrophis_major.anchors.new
# python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_cyanocinctus.hydrophis_elegans.anchors hydrophis_cyanocinctus.hydrophis_elegans.anchors.new
