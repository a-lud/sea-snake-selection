#!/usr/bin/env bash
#SBATCH --job-name=mcscan-initial
#SBATCH -p skylake
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --time=02:00:00
#SBATCH --mem=5GB
#SBATCH -o /hpcfs/users/a1645424/analysis/synteny-hydrophis-snakes/scripts/joblogs/%x_%j.log
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=alastair.ludington@adelaide.edu.au

# MCscan syteny plot between Hydrophis snakes
# 1. Extract CDS from GFF3 - AGAT
# 2. GFF3 to bed
# 3. Make comparisons beteween snakes
#       - ornatus --> major
#       - major --> curtus-AG
#       - curtus-AG --> curtus
#       - curtus --> cyano
#       - cyano --> Th. elegans

DIR='/hpcfs/users/a1645424/analysis/synteny-hydrophis-snakes'
GENOMES="${DIR}/genomes/genomes-subset/renamed"
OUT="${DIR}/mcscan-results-initial"

mkdir -p "${OUT}"

cd "${OUT}" || exit 1

source "${HOME}/micromamba/etc/profile.d/micromamba.sh"
micromamba activate jcvi

# 1. Extract CDS sequences
for ASM in "${GENOMES}/"*.fa; do
    BN=$(basename "${ASM%.*}")
    if [[ ! -f "${BN}.cds" ]]; then
        micromamba activate agat
        GFF="${DIR}/gffs/clean-gff3/${BN}.gff3"

        agat_sp_extract_sequences.pl \
            --clean_final_stop \
            --clean_internal_stop \
            --fasta "${ASM}" \
            --gff "${GFF}" \
            --output "${BN}.cds" \
            --type cds

        micromamba deactivate

        # 2. Convert GFF3 to BED
        python3 -m jcvi.formats.gff bed --type=mRNA --key=ID "${GFF}" -o "${BN}.bed"
    fi
done

# 3. Comparisons
python3 -m jcvi.compara.catalog ortholog \
    --cpus="${SLURM_CPUS_PER_TASK}" \
    --no_strip_names \
    --notex \
    'hydrophis_ornatus' 'hydrophis_major'

python3 -m jcvi.compara.catalog ortholog \
    --cpus="${SLURM_CPUS_PER_TASK}" \
    --no_strip_names \
    --notex \
    'hydrophis_major' 'hydrophis_curtus-AG'

python3 -m jcvi.compara.catalog ortholog \
    --cpus="${SLURM_CPUS_PER_TASK}" \
    --no_strip_names \
    --notex \
    'hydrophis_curtus-AG' 'hydrophis_curtus'

python3 -m jcvi.compara.catalog ortholog \
    --cpus="${SLURM_CPUS_PER_TASK}" \
    --no_strip_names \
    --notex \
    'hydrophis_curtus' 'hydrophis_cyanocinctus'

python3 -m jcvi.compara.catalog ortholog \
    --cpus="${SLURM_CPUS_PER_TASK}" \
    --no_strip_names \
    --notex \
    'hydrophis_cyanocinctus' 'thamnophis_elegans'

# 4. Create files needed for synteny plots
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_ornatus.hydrophis_major.anchors hydrophis_ornatus.hydrophis_major.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_major.hydrophis_curtus-AG.anchors hydrophis_major.hydrophis_curtus-AG.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_curtus-AG.hydrophis_curtus.anchors hydrophis_curtus-AG.hydrophis_curtus.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_curtus.hydrophis_cyanocinctus.anchors hydrophis_curtus.hydrophis_cyanocinctus.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_cyanocinctus.thamnophis_elegans.anchors hydrophis_cyanocinctus.thamnophis_elegans.anchors.new

# Karyotype plot
python -m jcvi.graphics.karyotype --chrstyle=roundrect --basepair --outfile=karyotype-initial.png --figsize=10x8 --dpi=500 --format=png seqids layout

micromamba deactivate
