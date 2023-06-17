#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------- #
# Chromosome re-naming
#
# In order to be able to produce a stacked alignment for each chromosome across all snakes, I've had
# to rename the chromosomes in each snake relative to one (i.e. the anchor snake). I've chosen to use
# H. ornatus as the anchor, as it is at the top of the alignment in the synteny plot. Therefore, all
# alignments are relative to it. What does this mean?
#
#   - Chromosomes in subsequent genomes are merged to match the chromosome number in H. ornatus
#   - Chromosome names in subsequent genomes are renamed to match the chromosome IDs in H. ornatus
#
# For example, while only H. major will align to H. ornatus, the next pairwise alignment between
# H. major and H. curtus (AG) will use the ADAPTED H. major reference (i.e. the H. major reference
# that was corrected to match H. ornatus) as input. This means that while H. curtus (AG) will have
# it's chromosomes/IDs adapted to match H. major, in reality it's really being adapted to match
# H. ornatus, as H. major was also adapted to match H. ornatus.
# --------------------------------------------------------------------------------------------------- #

DIR='/home/a1645424/al/analyses/synteny'
GENOMES="${DIR}/genomes-mcscan"
OUT="${DIR}/genomes-syri"

mkdir -p "${OUT}"

# --------------------------------------------------------------------------------------------------- #
# H. ornatus + H. major chromosome modification

## H. ornatus = chr6 + chr14
seqkit grep -p 'chr6' -o "${OUT}/hydrophis_ornatus-tmp1.fa" "${GENOMES}/hydrophis_ornatus.fa"
seqkit grep -p 'chr14' -o "${OUT}/hydrophis_ornatus-tmp2.fa" "${GENOMES}/hydrophis_ornatus.fa"
seqkit grep -p 'chr15' -o "${OUT}/hydrophis_ornatus-tmp3.fa" "${GENOMES}/hydrophis_ornatus.fa"
seqkit grep -p 'chrZ' -o "${OUT}/hydrophis_ornatus-tmp4.fa" "${GENOMES}/hydrophis_ornatus.fa"
seqkit grep -p 'chr6' -p 'chr14' -p 'chr15' -p 'chrZ' --invert-match -o "${OUT}/hydrophis_ornatus-tmp.fa" "${GENOMES}/hydrophis_ornatus.fa"

# Add separator between merged chromosomes
printf 'N%.0s' {1..10000} >> "${OUT}/hydrophis_ornatus-tmp1.fa"
printf 'N%.0s' {1..10000} >> "${OUT}/hydrophis_ornatus-tmp3.fa"

# make chromosome names match up - using longest chromosome ID as final ID
sed -i 's/chr14/chr6/' "${OUT}/hydrophis_ornatus-tmp2.fa"
sed -i 's/chr15/chrZ/' "${OUT}/hydrophis_ornatus-tmp3.fa"

# Merge
seqkit concat "${OUT}/hydrophis_ornatus-tmp1.fa" "${OUT}/hydrophis_ornatus-tmp2.fa" >> "${OUT}/hydrophis_ornatus-tmp.fa"
seqkit concat "${OUT}/hydrophis_ornatus-tmp3.fa" "${OUT}/hydrophis_ornatus-tmp4.fa" >> "${OUT}/hydrophis_ornatus-tmp.fa"
seqkit sort -N -o "${OUT}/hydrophis_ornatus.fa" "${OUT}/hydrophis_ornatus-tmp.fa"

rm -v "${OUT}/"hydrophis_ornatus-tmp*.fa
echo ""

## Hydrophis major
seqkit grep -p 'chr12' -o "${OUT}/hydrophis_major-tmp1.fa" "${GENOMES}/hydrophis_major.fa"
seqkit grep -p 'chr14' -o "${OUT}/hydrophis_major-tmp2.fa" "${GENOMES}/hydrophis_major.fa"
seqkit grep -p 'chr15' -o "${OUT}/hydrophis_major-tmp3.fa" "${GENOMES}/hydrophis_major.fa"
seqkit grep -p 'chrZ' -o "${OUT}/hydrophis_major-tmp4.fa" "${GENOMES}/hydrophis_major.fa"
seqkit grep -p 'chr12' -p 'chr14' -p 'chr15' -p 'chrZ' --invert-match -o "${OUT}/hydrophis_major-tmp.fa" "${GENOMES}/hydrophis_major.fa"

printf 'N%.0s' {1..10000} >> "${OUT}/hydrophis_major-tmp1.fa"
printf 'N%.0s' {1..10000} >> "${OUT}/hydrophis_major-tmp3.fa"
sed -i 's/chr14/chr12/' "${OUT}/hydrophis_major-tmp2.fa"
sed -i 's/chr15/chrZ/' "${OUT}/hydrophis_major-tmp3.fa"

seqkit concat "${OUT}/hydrophis_major-tmp1.fa" "${OUT}/hydrophis_major-tmp2.fa" >> "${OUT}/hydrophis_major-tmp.fa"
seqkit concat "${OUT}/hydrophis_major-tmp3.fa" "${OUT}/hydrophis_major-tmp4.fa" >> "${OUT}/hydrophis_major-tmp.fa"
seqkit replace --keep-key --kv-file 'rename-hma.tsv' -p '(.*)' -r '{kv}' -o "${OUT}/hydrophis_major-kv.fa" "${OUT}/hydrophis_major-tmp.fa"
seqkit sort -N -o "${OUT}/hydrophis_major.fa" "${OUT}/hydrophis_major-kv.fa"

rm -v "${OUT}/"hydrophis_major-tmp*.fa "${OUT}/hydrophis_major-kv.fa"
echo ""

# --------------------------------------------------------------------------------------------------- #
# H. major and H. curtus (AG)
#
# Use the adapted H. major from above. Correct H. curtus (AG) to match H. major, which then matches
# H. ornatus.

# H. curtus (AG)
seqkit grep -p 'chr6' -o "${OUT}/hydrophis_curtus-AG-tmp1.fa" "${GENOMES}/hydrophis_curtus-AG.fa"
seqkit grep -p 'chr14' -o "${OUT}/hydrophis_curtus-AG-tmp2.fa" "${GENOMES}/hydrophis_curtus-AG.fa"
seqkit grep -p 'chr13' -o "${OUT}/hydrophis_curtus-AG-tmp3.fa" "${GENOMES}/hydrophis_curtus-AG.fa"
seqkit grep -p 'chr15' -o "${OUT}/hydrophis_curtus-AG-tmp4.fa" "${GENOMES}/hydrophis_curtus-AG.fa"
seqkit grep -p 'chr6' -p 'chr13' -p 'chr14' -p 'chr15' --invert-match -o "${OUT}/hydrophis_curtus-AG-tmp.fa" "${GENOMES}/hydrophis_curtus-AG.fa"

printf 'N%.0s' {1..10000} >> "${OUT}/hydrophis_curtus-AG-tmp1.fa"
printf 'N%.0s' {1..10000} >> "${OUT}/hydrophis_curtus-AG-tmp3.fa"
sed -i 's/chr14/chr6/' "${OUT}/hydrophis_curtus-AG-tmp2.fa"
sed -i 's/chr15/chr13/' "${OUT}/hydrophis_curtus-AG-tmp4.fa"

seqkit concat "${OUT}/hydrophis_curtus-AG-tmp1.fa" "${OUT}/hydrophis_curtus-AG-tmp2.fa" >> "${OUT}/hydrophis_curtus-AG-tmp.fa"
seqkit concat "${OUT}/hydrophis_curtus-AG-tmp3.fa" "${OUT}/hydrophis_curtus-AG-tmp4.fa" >> "${OUT}/hydrophis_curtus-AG-tmp.fa"
seqkit replace --keep-key --kv-file 'rename-hcu-AG.tsv' -p '(.*)' -r '{kv}' -o "${OUT}/hydrophis_curtus-AG-kv.fa" "${OUT}/hydrophis_curtus-AG-tmp.fa"
seqkit sort -N -o "${OUT}/hydrophis_curtus-AG.fa" "${OUT}/hydrophis_curtus-AG-kv.fa"

rm -v "${OUT}/"hydrophis_curtus-AG-tmp*.fa "${OUT}/hydrophis_curtus-AG-kv.fa"
echo ""

# --------------------------------------------------------------------------------------------------- #
# H. curtus (AG) and H. curtus
#
# Use the adapted H. curtus (AG) from above. Correct H. curtus to match H. curtus (AG), which then
# matches H. ornatus.

## H. curtus
seqkit grep -p 'chr11' -o "${OUT}/hydrophis_curtus-tmp1.fa" "${GENOMES}/hydrophis_curtus.fa"
seqkit grep -p 'chr15' -o "${OUT}/hydrophis_curtus-tmp2.fa" "${GENOMES}/hydrophis_curtus.fa"
seqkit grep -p 'chr11' -p 'chr15' -p 'chr16' -p 'chr17' --invert-match -o "${OUT}/hydrophis_curtus-tmp.fa" "${GENOMES}/hydrophis_curtus.fa"

printf 'N%.0s' {1..10000} >> "${OUT}/hydrophis_curtus-tmp1.fa"
sed -i 's/chr15/chr11/' "${OUT}/hydrophis_curtus-tmp2.fa"

seqkit concat "${OUT}/hydrophis_curtus-tmp1.fa" "${OUT}/hydrophis_curtus-tmp2.fa" >> "${OUT}/hydrophis_curtus-tmp.fa"
seqkit replace --keep-key --kv-file 'rename-hcu.tsv' -p '(.*)' -r '{kv}' -o "${OUT}/hydrophis_curtus-kv.fa" "${OUT}/hydrophis_curtus-tmp.fa"
seqkit sort -N -o "${OUT}/hydrophis_curtus.fa" "${OUT}/hydrophis_curtus-kv.fa"

rm -v "${OUT}/"hydrophis_curtus-tmp*.fa "${OUT}/hydrophis_curtus-kv.fa"
echo ""

# --------------------------------------------------------------------------------------------------- #
# H. curtus and H. cyanocinctus
#
# Use the adapted H. curtus from above. Correct H. cyanoncinctus to match H. curtus, which then
# matches H. ornatus.

# H. cyanocinctus
seqkit grep -p 'chr2' -o "${OUT}/hydrophis_cyanocinctus-tmp1.fa" "${GENOMES}/hydrophis_cyanocinctus.fa"
seqkit grep -p 'chr18' -o "${OUT}/hydrophis_cyanocinctus-tmp2.fa" "${GENOMES}/hydrophis_cyanocinctus.fa"
seqkit grep -p 'chr7' -o "${OUT}/hydrophis_cyanocinctus-tmp3.fa" "${GENOMES}/hydrophis_cyanocinctus.fa"
seqkit grep -p 'chr14' -o "${OUT}/hydrophis_cyanocinctus-tmp4.fa" "${GENOMES}/hydrophis_cyanocinctus.fa"
seqkit grep -p 'chr15' -o "${OUT}/hydrophis_cyanocinctus-tmp5.fa" "${GENOMES}/hydrophis_cyanocinctus.fa"
seqkit grep -p 'chr16' -o "${OUT}/hydrophis_cyanocinctus-tmp6.fa" "${GENOMES}/hydrophis_cyanocinctus.fa"
seqkit grep \
    -p 'chr2' -p 'chr7' -p 'chr14' -p 'chr15' -p 'chr16' -p 'chr17' -p 'chr18' \
    --invert-match \
    -o "${OUT}/hydrophis_cyanocinctus-tmp.fa" "${GENOMES}/hydrophis_cyanocinctus.fa"

printf 'N%.0s' {1..10000} >>"${OUT}/hydrophis_cyanocinctus-tmp2.fa"
printf 'N%.0s' {1..10000} >>"${OUT}/hydrophis_cyanocinctus-tmp3.fa"
printf 'N%.0s' {1..10000} >>"${OUT}/hydrophis_cyanocinctus-tmp5.fa"
sed -i 's/chr18/chr2/' "${OUT}/hydrophis_cyanocinctus-tmp2.fa"
sed -i 's/chr14/chr7/' "${OUT}/hydrophis_cyanocinctus-tmp4.fa"
sed -i 's/chr16/chr15/' "${OUT}/hydrophis_cyanocinctus-tmp6.fa"

{
    seqkit concat "${OUT}/hydrophis_cyanocinctus-tmp2.fa" "${OUT}/hydrophis_cyanocinctus-tmp1.fa"
    seqkit concat "${OUT}/hydrophis_cyanocinctus-tmp3.fa" "${OUT}/hydrophis_cyanocinctus-tmp4.fa"
    seqkit concat "${OUT}/hydrophis_cyanocinctus-tmp5.fa" "${OUT}/hydrophis_cyanocinctus-tmp6.fa"
} >>"${OUT}/hydrophis_cyanocinctus-tmp.fa"

seqkit replace --keep-key --kv-file 'rename-hcy.tsv' -p '(.*)' -r '{kv}' -o "${OUT}/hydrophis_cyanocinctus-kv.fa" "${OUT}/hydrophis_cyanocinctus-tmp.fa"
seqkit sort -N -o "${OUT}/hydrophis_cyanocinctus.fa" "${OUT}/hydrophis_cyanocinctus-kv.fa"

rm -v "${OUT}/hydrophis_cyanocinctus-tmp.fa" "${OUT}/"hydrophis_cyanocinctus-tmp?.fa "${OUT}/hydrophis_cyanocinctus-kv.fa"
# echo ""

# --------------------------------------------------------------------------------------------------- #
# Th. elegans - Have not bothered splitting certain chromosomes that map inter-chromosomally
echo "Extracting chromosomes"
seqkit grep -p 'chr1' -o "${OUT}/thamnophis_elegans-tmp1.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr4' -o "${OUT}/thamnophis_elegans-tmp2.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr2' -o "${OUT}/thamnophis_elegans-tmp3.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr3' -o "${OUT}/thamnophis_elegans-tmp4.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr8' -o "${OUT}/thamnophis_elegans-tmp5.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr5' -o "${OUT}/thamnophis_elegans-tmp6.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr10' -o "${OUT}/thamnophis_elegans-tmp7.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr15' -o "${OUT}/thamnophis_elegans-tmp8.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr7' -o "${OUT}/thamnophis_elegans-tmp9.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr11' -o "${OUT}/thamnophis_elegans-tmp10.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr6' -o "${OUT}/thamnophis_elegans-tmp11.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr9' -o "${OUT}/thamnophis_elegans-tmp12.fa" "${GENOMES}/thamnophis_elegans.fa"
seqkit grep -p 'chr17' -o "${OUT}/thamnophis_elegans-tmp13.fa" "${GENOMES}/thamnophis_elegans.fa"

echo "Removing extracted chromosomes"
seqkit grep \
    -p 'chr1' -p 'chr2' -p 'chr3' -p 'chr4' -p 'chr5' -p 'chr6' -p 'chr7' \
    -p 'chr8' -p 'chr9' -p 'chr10' -p 'chr11' -p 'chr15' -p 'chr17' \
    --invert-match -o "${OUT}/thamnophis_elegans-tmp.fa" "${GENOMES}/thamnophis_elegans.fa"

echo "Adding N's"
printf 'N%.0s' {1..10000} >>"${OUT}/thamnophis_elegans-tmp1.fa"
printf 'N%.0s' {1..10000} >>"${OUT}/thamnophis_elegans-tmp3.fa"
printf 'N%.0s' {1..10000} >>"${OUT}/thamnophis_elegans-tmp5.fa"
printf 'N%.0s' {1..10000} >>"${OUT}/thamnophis_elegans-tmp7.fa"
printf 'N%.0s' {1..10000} >>"${OUT}/thamnophis_elegans-tmp8.fa"
printf 'N%.0s' {1..10000} >>"${OUT}/thamnophis_elegans-tmp10.fa"
printf 'N%.0s' {1..10000} >>"${OUT}/thamnophis_elegans-tmp12.fa"

echo "Renaming chromosomes in TEMP files"
sed -i 's/chr4/chr1/' "${OUT}/thamnophis_elegans-tmp2.fa"
sed -i 's/chr3/chr2/' "${OUT}/thamnophis_elegans-tmp4.fa"
sed -i 's/chr8/chr5/' "${OUT}/thamnophis_elegans-tmp5.fa"
sed -i 's/chr10/chr7/' "${OUT}/thamnophis_elegans-tmp7.fa"
sed -i 's/chr15/chr7/' "${OUT}/thamnophis_elegans-tmp8.fa"
sed -i 's/chr11/chr6/' "${OUT}/thamnophis_elegans-tmp10.fa"
sed -i 's/chr17/chr9/' "${OUT}/thamnophis_elegans-tmp13.fa"

echo "Concatenating"
{
    seqkit concat "${OUT}/thamnophis_elegans-tmp1.fa" "${OUT}/thamnophis_elegans-tmp2.fa"
    seqkit concat "${OUT}/thamnophis_elegans-tmp3.fa" "${OUT}/thamnophis_elegans-tmp4.fa"
    seqkit concat "${OUT}/thamnophis_elegans-tmp5.fa" "${OUT}/thamnophis_elegans-tmp6.fa"
    seqkit concat "${OUT}/thamnophis_elegans-tmp7.fa" "${OUT}/thamnophis_elegans-tmp8.fa" "${OUT}/thamnophis_elegans-tmp9.fa"
    seqkit concat "${OUT}/thamnophis_elegans-tmp10.fa" "${OUT}/thamnophis_elegans-tmp11.fa"
    seqkit concat "${OUT}/thamnophis_elegans-tmp12.fa" "${OUT}/thamnophis_elegans-tmp13.fa"
} >>"${OUT}/thamnophis_elegans-tmp.fa"

echo "Renaming chromosomes to match ornatus"
seqkit replace --keep-key --kv-file 'rename-tel.tsv' -p '(.*)' -r '{kv}' -o "${OUT}/thamnophis_elegans-kv.fa" "${OUT}/thamnophis_elegans-tmp.fa"
echo "Sorting and final out"
seqkit sort -N -o "${OUT}/thamnophis_elegans.fa" "${OUT}/thamnophis_elegans-kv.fa"

rm -v "${OUT}/"thamnophis_elegans-tmp*.fa "${OUT}/thamnophis_elegans-kv.fa"

