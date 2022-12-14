#!/usr/bin/env bash

# Create final oriented outputs
# P_CTG chromosome names are based on length
#   - Note that chromosomes were identified by comparing ot H. curtus and H. cyanocinctus
# HAP1/2 chromosome names are based on synteny with P_CTG
#   - I made the key-value files from the synteny plot after naming P_CTG chromosomes
# HAP1/2 are being oriented relative to P_CTG

# P_CTG is final after this point
seqkit replace \
        -p "(.*)" \
        -r '{kv}' \
        -w 100 \
        -U \
        -k hydmaj-p_ctg-ids.txt \
        ../assembly-results/assembly-gapClosed/hydmaj-chromosome-p_ctg/hydmaj-chromosome-p_ctg.fa |
seqkit sort -n -N -w 100 -o hydmaj-p_ctg-v1.fna

samtools faidx -n 100 hydmaj-p_ctg-v1.fna

# HAP1/2 are temporary until some sequences are reversed
seqkit replace \
        -p "(.*)" \
        -r '{kv}' \
        -w 100 \
        -U \
        -k hydmaj-hap1-ids.txt \
        ../assembly-results/assembly-gapClosed/hydmaj-chromosome-hap1/hydmaj-chromosome-hap1.fa > hydmaj-hap1-temp.fna

seqkit replace \
        -p "(.*)" \
        -r '{kv}' \
        -w 100 \
        -U \
        -k hydmaj-hap2-ids.txt \
        ../assembly-results/assembly-gapClosed/hydmaj-chromosome-hap2/hydmaj-chromosome-hap2.fa > hydmaj-hap2-temp.fna

# Make final outputs
for i in *rev.txt; do
    BN=$(basename ${i%-rev*})

    # Reverse complement sequences that are inverted
    echo "[samtools::faidx] reverse complement"
    echo -e "\t${BN}"
    samtools faidx \
        --reverse-complement \
        --mark-strand no \
        -n 100 \
        -o ${BN}-rev.fa \
        ${BN}-temp.fna $(cat ${i} | tr '\n' ' ')
    
    # Extract inverse sequences to above
    echo "[seqkit::grep] forward sequences"
    echo -e "\t${BN}"
     seqkit grep \
        -v \
        -f ${i} \
        -w 100 \
        -o ${BN}-fwd.fa ${BN}-temp.fna

    # Combine cleaned files into final output
    cat ${BN}-fwd.fa ${BN}-rev.fa |
    seqkit sort -n -N -w 100 -o ${BN}-v1.fna

    samtools faidx -n 100 ${BN}-v1.fna
done

rm -v *temp* *fwd.fa* *rev.fa*

