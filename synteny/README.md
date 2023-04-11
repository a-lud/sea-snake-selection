GO Term over-representation
================
Alastair Ludington
2023-04-11

- <a href="#1-introduction" id="toc-1-introduction">1 Introduction</a>
- <a href="#2-prepare-genome-files" id="toc-2-prepare-genome-files">2
  Prepare genome files</a>
  - <a href="#subset-genome-fasta-files-for-chromosome-sequences"
    id="toc-subset-genome-fasta-files-for-chromosome-sequences">Subset
    genome FASTA files for chromosome sequences</a>
  - <a href="#rename-chromosome-sequences"
    id="toc-rename-chromosome-sequences">Rename chromosome sequences</a>
  - <a href="#subset-gff3-files-for-chromosome-sequences-only"
    id="toc-subset-gff3-files-for-chromosome-sequences-only">Subset GFF3
    files for chromosome sequences only</a>
- <a href="#3-mcscan" id="toc-3-mcscan">3 MCscan</a>
  - <a href="#initial-alignment" id="toc-initial-alignment">Initial
    alignment</a>
  - <a href="#oritent-inverted-chromosomes"
    id="toc-oritent-inverted-chromosomes">Oritent inverted chromosomes</a>
  - <a href="#31-lift-over-gene-annotations"
    id="toc-31-lift-over-gene-annotations">3.1 Lift-over gene
    annotations</a>
  - <a href="#32-final-alignments" id="toc-32-final-alignments">3.2 Final
    alignments</a>

# 1 Introduction

We used the program
[MCscan](https://github.com/tanghaibao/jcvi/wiki/MCscan-(Python-version))
to align chromosome sequences between the five chromosome scale sea
snake assemblies. This program is quick and easy to use, and is capable
of generating informative ribbon plots that show the synteny between
pairwise comparisons.

Here I’ll detail each stage of the synteny pipeline that we implemented
to compare overall genome synteny between the five sea snakes.

# 2 Prepare genome files

The program uses genome FASTA files and genome GFF3 annotation files as
input. Typically, a genome assembly has a number of unplaced scaffolds
which, unless they have some specific interest, are typically something
we can ignore. Therefore, we performed some curation of the input files
prior to aligning them.

## Subset genome FASTA files for chromosome sequences

**Script:**
[01-subset-genomes.sh](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/scripts/01-subset-genomes.sh)  
**Outdir:** Too large to upload

We have specifically chosen to look at only genomes that have chromosome
sequences to simplify the visualisation and analysis of sea snake
synteny. We used the program [seqkit
subseq](https://github.com/shenwei356/seqkit) to keep only chromosome
sequences from each sample.

## Rename chromosome sequences

**Script:**
[02-rename-headers.sh](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/scripts/02-rename-headers.sh)  
**Outdir:** Too large to upload

While not totally necessary, we decided to rename chromosome sequences
in each sample to be consistent across all samples. As such, we chose to
label chromosomes using the `chr` prefix.

For NCBI samples *H. cyanocinctus* and *H. curtus*, I used the
chromosome ID mapping tables found on NCBI for each sample. NCBI labels
chromosomes by length - e.g. longest chromosome is chromosome-1 and so
on. The Z-chromosome is the fifth largest chromosome in sea snakes, and
as such is skipped in the NCBI labelling scheme. Consequently, the
`chr5` header is not used in the two NCBI sample FASTAs.

All other snakes are labelled by length, accounting for the Z-chromosome
being the fifth largest - i.e. the `chr5` header is found in all other
snake assemblies.

## Subset GFF3 files for chromosome sequences only

**Script:**
[03-subset-gff3.R](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/scripts/03-subset-gff3.R)  
**Outdir:** Too large to upload

As we’ve limited our analysis to chromosome sequences only, we have to
filter the GFF3 files for only chromosome sequences, which was done in
`R`. The majority of genes in each sample are found on the chromosome
sequences, meaning there is little gene loss/impact on alignment quality
by doing this.

# 3 MCscan

`MCscan` is a tool for generating synteny alignments between pairs of
genomes. Below are all the processes relating to the actual alignment of
genomes using this program.

## Initial alignment

**Script:**
[04-mcscan.sh](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/scripts/04-mcscan.sh)  
**Outdir:**
[results/mcscan-results-initial](https://github.com/a-lud/sea-snake-selection/tree/main/synteny/results/mcscan-results-initial)

An initial alignment was generated between pairs of snakes to get an
indication of overall alignment, along with which sequences needed to be
reverse complemented. Chromosome sequences are often assembled in
reverse orientation between samples. This results in the whole
chromosome looking inverted, when in reality, if we simply reverse
complement one of the sequences in the pair, we’ll end up with a 1:1
alignment.

Running `MCscan` involves the following steps:

- Extracting gene coding sequences using
  [AGAT](https://github.com/NBISweden/AGAT)
- Convert GFF3 files to BED format using
  [JCVI](https://github.com/tanghaibao/jcvi/wiki/MCscan-(Python-version))
  (`jcvi.formats.gff bed`)
- Align genomes using `LAST` (`jcvi.compara.catalog ortholog`)
- Create simplified alignment anchor files for visualisation
  (`jcvi.compara.synteny screen`)
- Plot the alignments

The initial alignments were used to identify which sequences needed
manual orientation due to opposite chromosomal strands being assembled.

![Figure
1](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/results/mcscan-results-initial/karyotype.png)

In the figure above, we can see a number of aligned chromosomes have
‘bowtie’ shapes. This is where the whole chromosome is inverted in the
pairwise alignment.

## Oritent inverted chromosomes

**Script:**
[05-orient.sh](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/scripts/05-orient.sh)  
**Outdir:** Too large to upload

Chromosome sequences that were totally inverted between aligned samples
were reverse complemented to improve figure clarity. As mentioned above,
when chromosomes align 1:1 but are fully inverted, it typically is an
indication that different strands of the same chromosome were assembled
in each sample. As such, reverse complementing one of the strands will
result in a more accurate representation of the homology between the
sequences.

Using the initial ribbon plot generated by `MCscan` above,
fully-inverted chromosomes were identified for each pairwise comparison
and were corrected. The correction pipeline involved:

- Visually identifying which chromosomes were inverted
- Reverse complementing the sequences in one of the samples
  (`samtools faidx --reverse-complement`)
- Merging the reversed sequences with the rest of the chromosome
  sequences that did not need to be reverse-complemented

## 3.1 Lift-over gene annotations

**Script:**
[06-liftoff.sh](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/scripts/06-liftoff.sh)  
**Outdir:** Too large to upload

Following manual orientation of chromosome sequences, gene annotations
needed to be lifted over to the new assemblies. This is so the gene
coordinates in the GFF3 files are correct for the reverse-complemented
chromosomes.

To do this, we used the tool
[Liftoff](https://github.com/agshumate/Liftoff) to lift the original
annotations over to the new assemblies.

## 3.2 Final alignments

**Script:**
[07-mcscan-oriented.sh](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/scripts/07-mcscan-oriented.sh)  
**Outdir:**
[results/mcscan-results-oriented](https://github.com/a-lud/sea-snake-selection/tree/main/synteny/results/mcscan-results-oriented)

With chromosome orientations corrected and gene annotations lifted over,
we re-ran the `MCscan` alignment pipeline with the updated data to
generate the final figure.

![Figure
2](https://github.com/a-lud/sea-snake-selection/blob/main/synteny/results/mcscan-results-oriented/karyotype.png)

In the figure above, we can see that the ‘bowtie’ alignments from the
first figure are no more. This is thanks to getting the chromosome
sequences into the correct orientation.
