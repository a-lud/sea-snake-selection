
#arg1: modified assembly file
#arg2: fasta file
#arg3: merged_nodups file produce by juicer

run-asm-pipeline-post-review.sh --sort-output -s seal -i 500 -r ${1} ${2} ${3}

