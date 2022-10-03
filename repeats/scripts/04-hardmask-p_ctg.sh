#!/usr/bin/env bash

# Utility scripts ---
export PATH="${PATH}":'/home/a1645424/hpcfs/myconda/pkgs/edta-2.0.0-hdfd78af_0/share/EDTA/util'

# Directories ---
DIR='/home/a1645424/hpcfs/hydmaj-genome/repeats'
EDTADIR="${DIR}/edta-p_ctg-out"
ASM="/home/a1645424/hpcfs/hydmaj-genome/hydmaj-chromosomes/hydmaj-p_ctg-v1.fna"
OUT="${DIR}/hardmasked"

mkdir -p ${OUT}
cd ${OUT} || exit 1

# Conda ---
CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate EDTA

make_masked.pl \
    -genome "${ASM}" \
    -minlen 100 \
    -hardmask 1 \
    -t 4 \
    -rmout "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.anno/hydmaj-p_ctg-v1.fna.mod.EDTA.TEanno.out"

# Move output files to ${OUT}
mv ${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.anno/*TEanno.out.new* ${OUT}
mv $(dirname ${ASM})/*.new.masked ${OUT}/hydmaj-p_ctg-v1.hm.fna

# Count the number of masked bases
echo '[awk::sum] awk {sum+=$3-$2} END {print sum} hydmaj-p_ctg-v1.fna.mod.EDTA.TEanno.out.new.bed' > ${OUT}/masked-bases.txt
MASKED=$(awk '{sum+=$3-$2} END {print sum}' ${OUT}/hydmaj-p_ctg-v1.fna.mod.EDTA.TEanno.out.new.bed)
echo "Bases Masked: ${MASKED}" >> ${OUT}/masked-bases.txt

conda deactivate

