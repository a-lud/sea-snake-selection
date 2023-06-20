GO Term over-representation
================
Alastair Ludington
2023-06-20

- [1 Introduction](#1-introduction)
- [2 MCscan: Genomic synteny](#2-mcscan-genomic-synteny)
  - [Data preparation](#data-preparation)
  - [Initial alignments](#initial-alignments)
  - [Orient chromosome sequences](#orient-chromosome-sequences)
  - [Lift genes to adapted genomes](#lift-genes-to-adapted-genomes)
  - [MCscan](#mcscan)
- [3 Syri: Synteny and structural
  variations](#3-syri-synteny-and-structural-variations)

# 1 Introduction

As *Hydrophis* is a rapidly radiation species, we were interested in
investigating the overall level of synteny between the chromosome-scale
genome assemblies. We used two separate methods to explore both
broad-scale homology, as well as structural variants (SVs) between
genome-pairs.

# 2 MCscan: Genomic synteny

The first approach we used involved running the program [MCscan
(Python)](https://github.com/tanghaibao/jcvi/wiki/MCscan-(Python-version))
between pairs of *Hydrophis* snakes. *MCscan* aligns the coding
sequences (CDS) of a pair of genomes to identify orthologous genes. The
coordinates of these orthologs between the pair of genomes act as
syntenyic-anchors, and can be visualised as a ribbon plot. We performed
comparisons between pairs of *Hydrophis* snakes and outgroup *Thamnophis
elegans* to investigate the overall level of similarity within
*Hydrophis* and how much they differ to a terrestrial outgroup in *T.
elegans*.

## Data preparation

**Scripts:**
[mcscan/scripts](https://github.com/a-lud/sea-snake-selection/tree/main/synteny/mcscan/scripts)
(scripts 1-3 are involved in data preparation)  
**Outdir:** Not uploaded as they were intermediate genome files that are
large

*MCscan* was only run on chromosomal sequences. These were subset from
each assembly FASTA using the program
[seqkit](https://github.com/shenwei356/seqkit).

``` bash
# 01-subset-genomes.sh
seqkit head -n <n chromosomes> genome.fa > genome-chr.fa
```

The genomes were then renamed to use chromosome identifiers rather than
file specific IDs.

``` bash
# 02-rename-headers.sh
for TSV in "${RENAME}/"*.rename; do
    BN=$(basename "${TSV%.*}")
    REF="${GENOMES}/${BN}-chr.fa"

    # Rename
    echo -e "[seqkit] Rename headers"
    seqkit replace -p '(.*)$' -r '{kv}' -k "${TSV}" -o "${OUT}/${BN}.fa" "${REF}"
done
```

Gene annotation files were also edited to use these new names (see
[03-subset-gff3.R](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/mcscan/scripts/03-subset-gff3.R)).

## Initial alignments

**Script:**
[04-mcscan-initial.sh](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/mcscan/scripts/04-mcscan-initial.sh)  
**Outdir:**
[mcscan/results/mcscan-results-initial](https://github.com/a-lud/sea-snake-selection/tree/main/synteny/mcscan/results/mcscan-results-initial)

An initial run of *MCscan* as used to orient chromosomes between the
snakes. This first alignment was also informative for identifying
chromosome sequences that had been assembled in the reverse orientation
relative to the other snakes.

First, we extracted the protein coding sequences from each genome using
[AGAT](https://github.com/NBISweden/AGAT) and then converted the GFF3
files to BED format using the [JCVI](https://github.com/tanghaibao/jcvi)
library.

``` bash
# 1. Extract CDS sequences
for ASM in "${GENOMES}/"*.fa; do
    BN=$(basename "${ASM%.*}")
    if [[ ! -f "${BN}.cds" ]]; then
        GFF="${DIR}/gffs/clean-gff3/${BN}.gff3"

        agat_sp_extract_sequences.pl \
            --clean_final_stop \
            --clean_internal_stop \
            --fasta "${ASM}" \
            --gff "${GFF}" \
            --output "${BN}.cds" \
            --type cds

        # 2. Convert GFF3 to BED
        python3 -m jcvi.formats.gff bed --type=mRNA --key=ID "${GFF}" -o "${BN}.bed"
    fi
done
```

Coding sequences were then aligned between genome pairs using the
*MCscan* pipeline, which is detailed below:

``` bash
# Align CDS between pairs - H. ornatus to H. major as an example
python3 -m jcvi.compara.catalog ortholog \
    --cpus="${SLURM_CPUS_PER_TASK}" \
    --no_strip_names \
    --notex \
    'hydrophis_ornatus' 'hydrophis_major'
   
# Adapt the anchors files
python3 -m jcvi.compara.synteny screen --minspan=30 --simple hydrophis_ornatus.hydrophis_major.anchors hydrophis_ornatus.hydrophis_major.anchors.new

# Generate the karyotype plot
python -m jcvi.graphics.karyotype --chrstyle=roundrect --basepair --outfile=karyotype-initial.png --figsize=10x8 --dpi=500 --format=png seqids layout
```

This resulted in the following alignment

![](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/mcscan/results/mcscan-results-initial/karyotype-initial.png)

## Orient chromosome sequences

**Scripts:**
[05-orient.sh](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/mcscan/scripts/06-liftoff.sh)  
**Outdir:** Too large to upload

The output from the initial alignment was then used to guide which
sequences in each snake needed to be reverse complemented. Sequences
were reverse complemented if their entire length was reversed relative
to the syntenic sequences in the other genomes.

``` bash
# Reverse the sequences 
samtools faidx \
    -o "${TD}/${BN}.revComp" \
    --reverse-complement \
    --mark-strand no \
    "${FA}" \
    ${CHR}        # Variable with the sequence-IDs to reverse

# Remove the reversed sequences from the original genome file
seqkit grep \
    --invert-match \
    -f "${TD}/${BN}.ids" \
    -o "${TD}/${BN}.normal" \
    "${FA}"

# Combine the reversed sequences with the remaining sequences
cat "${TD}/${BN}.normal" "${TD}/${BN}.revComp" |
  seqkit sort -N -o "${OUT}/${BN}.fa"
```

## Lift genes to adapted genomes

**Script:**
[06-liftoff.sh](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/mcscan/scripts/06-liftoff.sh)  
**Outdir:** Too large to upload

As chromsome sequences were reversed, we opted to lift gene annotations
to the adapted references. This was done using the tool
[Liftoff](https://github.com/agshumate/Liftoff).

``` bash
liftoff \
    "${QASM}" \
    "${TASM}" \
    -g "${TGFF}" \
    -o "${OUT}/${BN}/${BN}.gff3" \
    -u "${OUT}/${BN}/${BN}-unmapped.txt" \
    -exclude_partial \
    -dir "${OUT}/${BN}/intermediates" \
    -p "${SLURM_CPUS_PER_TASK}" \
    -polish
```

## MCscan

**Script:**
[07-mcscan-oriented.sh](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/mcscan/scripts/07-mcscan-oriented.sh)  
**Outdir:**
[mcscan/results/mcscan-results-oriented](https://github.com/a-lud/sea-snake-selection/tree/main/synteny/mcscan/results/mcscan-results-oriented)

Finally, the *MCscan* pipeline (see [Initial
alignments](#initial-alignments)) was re-run, this time with the updated
genomes. This resulted in the following (colours are edited in).

![](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/mcscan/results/mcscan-results-oriented/karyotype-edited.png)

# 3 Syri: Synteny and structural variations

[Syri](https://github.com/schneebergerlab/syri) is another tool used for
investigating not only genomic synteny, but also structural variations
(SVs) between pairs of genomes. We used this tool to investigate overall
homology within *Hydrophis* (*T. elegans* was not included in this
analysis due to its evolutionary distance), as well as identify regions
of significant structural variation.
