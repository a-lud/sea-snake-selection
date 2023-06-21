#arg1: bam file containing ONT reads against fasta
#arg2: genome fasta file
#arg3: read depth low cutoff 
#arg4: low point between the haploid and diploid peaks
#arg5: read depth high cutoff

# Step 1: Coverage histogram
purge_haplotigs hist -b ${1} -g ${2}

# Step 2: Contig coverage stats (mark suspect contigs)
purge_haplotigs cov -i ${1}.genecov -l ${3} -m ${4} -h ${5}

# Step 3: Purge the haplotigs
purge_haplotigs purge -g ${2} -c coverage_stats.csv
