

#arg1: path to juicer directory
#arg2: genome fasta file

REF=${1}/juicer/references/${2}
MATRIX=${1}/juicer/aligned/merged_nodups.txt

run-asm-pipeline.sh --editor-repeat-coverage 20 ${REF} ${MATRIX}
 
