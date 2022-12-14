#!/usr/bin/env bash

SEQ="/Users/alastairludington/Desktop/mcscan/seqs"
export PATH=$PATH:'/Users/alastairludington/Desktop/last-1282/bin'

cd "${SEQ}" || exit

for FILE in *.cds; do
    BN=$(basename ${FILE%.*})
    python3 -m jcvi.formats.gff bed --type=mRNA --key=ID "${BN}.gff3" -o "${BN}.bed"
done

# Original code to get mappings between
    #   - haplotypes and p_ctg
    #   - p_ctg and h. curtus/h. cyanocinctus
# hmaj vs hcya
python3 -m jcvi.compara.catalog ortholog \
    --cpus=6 \
    --no_strip_names \
    -n 20 \
    hydrophis_major-p_ctg hydrophis_cyanocinctus

# hmaj-p_ctg vs hcur
python3 -m jcvi.compara.catalog ortholog \
    --cpus=6 \
    --no_strip_names \
    -n 20 \
    hydrophis_major-p_ctg hydrophis_curtus

# p_ctg vs hap1
python3 -m jcvi.compara.catalog ortholog \
    --cpus=6 \
    --no_strip_names \
    -n 20 \
    hydrophis_major-p_ctg hydrophis_major-hap1

 # p_ctg vs hap2
python3 -m jcvi.compara.catalog ortholog \
    --cpus=6 \
    --no_strip_names \
    -n 20 \
    hydrophis_major-p_ctg hydrophis_major-hap2

# asm vs species
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_major-p_ctg.hydrophis_cyanocinctus.anchors hydrophis_major-p_ctg.hydrophis_cyanocinctus.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_major-p_ctg.hydrophis_curtus.anchors hydrophis_major-p_ctg.hydrophis_curtus.anchors.new

# asm vs haps
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_major-p_ctg.hydrophis_major-hap1.anchors hydrophis_major-p_ctg.hydrophis_major-hap1.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_major-p_ctg.hydrophis_major-hap2.anchors hydrophis_major-p_ctg.hydrophis_major-hap2.anchors.new

# Code to get haplotype mappings to chromosome labelled p_ctg (chromosomes verified against h. curtus/h. cyanocinctus)
# p_ctg vs hap1
python3 -m jcvi.compara.catalog ortholog \
    --cpus=6 \
    --no_strip_names \
    -n 20 \
    hydmaj-p_ctg-v1 hydrophis_major-hap1

 # p_ctg vs hap2
python3 -m jcvi.compara.catalog ortholog \
    --cpus=6 \
    --no_strip_names \
    -n 20 \
    hydmaj-p_ctg-v1 hydrophis_major-hap2

python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydmaj-p_ctg-v1.hydrophis_major-hap1.anchors hydmaj-p_ctg-v1.hydrophis_major-hap1.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydmaj-p_ctg-v1.hydrophis_major-hap2.anchors hydmaj-p_ctg-v1.hydrophis_major-hap2.anchors.new

# Verifying nothing has gone wrong in the naming of HAP1/2 from the above step
python3 -m jcvi.compara.catalog ortholog \
    --cpus=6 \
    --no_strip_names \
    -n 20 \
    hydmaj-p_ctg-v1 hydmaj-hap1-v1

 # p_ctg vs hap2
python3 -m jcvi.compara.catalog ortholog \
    --cpus=6 \
    --no_strip_names \
    -n 20 \
    hydmaj-p_ctg-v1 hydmaj-hap2-v1

python3 -m jcvi.graphics.dotplot --skipempty hydmaj-p_ctg-v1.hydmaj-hap1-v1.anchors
python3 -m jcvi.graphics.dotplot --skipempty hydmaj-p_ctg-v1.hydmaj-hap2-v1.anchors

python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydmaj-p_ctg-v1.hydmaj-hap1-v1.anchors hydmaj-p_ctg-v1.hydmaj-hap1-v1.anchors.new
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydmaj-p_ctg-v1.hydmaj-hap2-v1.anchors hydmaj-p_ctg-v1.hydmaj-hap2-v1.anchors.new
