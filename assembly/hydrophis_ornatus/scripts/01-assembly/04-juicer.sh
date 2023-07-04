
# directory structure must be set out, as specified in https://github.com/aidenlab/juicer
#arg1: genomeID
#arg2: fasta file

dir=juicer
juicer.sh -g ${1} -d ${dir} -D ${dir} -p ${dir}/chrom.sizes -s none -z ${dir}/references/${2}
