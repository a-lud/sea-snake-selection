# Step 1: Align Nanopore to genome
  # arg1: path to reference assembly
  # arg2: name of reference assempbly file
  # arg3: path to ont reads file
  # arg4: prefix of alignment file
  REF=${1}/${2}
  READS=${3}
minimap2 -t 32 --MD -ax map-ont --secondary=no $REF $READS > ${1}/${4}.sam 
  samtools sort -@ 32 ${1}/${4}.sam -o ${1}/${4}.bam
  samtools index ${1}/${4}.bam

