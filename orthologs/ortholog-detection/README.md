Ortholog Detection
================
Alastair Ludington
2023-06-21

- [1 Introduction](#1-introduction)
- [2 Identifying orthologs](#2-identifying-orthologs)
  - [Pre-processing gene sequences](#pre-processing-gene-sequences)
  - [Identify orthologs](#identify-orthologs)
  - [Cleaning OrthoFinder MSA files](#cleaning-orthofinder-msa-files)

# 1 Introduction

Here I’ll outline the methods used to identify single-copy orthologs
between the snakes of interest. The methods here are encapsulated in a
`Nextflow` pipeline that I wrote that is hosted
[here](https://github.com/a-lud/nf-pipelines). More information about
the pipeline can be found
[here](https://github.com/a-lud/nf-pipelines/wiki/Orthofinder-Pipeline)

# 2 Identifying orthologs

**Scripts:**
[orthologs.sh](https://github.com/a-lud/sea-snake-selection/blob/main/orthologs/ortholog-detection/scripts/orthologs.sh)  
**Outdir:**
[results/orthologs](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-detection/results/orthologs)

There are many methods available for identifying orthologs. I opted to
write a pipeline around the ortholog detection tool
[OrthoFinder](https://github.com/davidemms/OrthoFinder). This tool is
commonly used in the literature and has a good balance of speed and
accuracy. Additionally, it’s got excellent documentation and is easy to
install.

Ortholog detection is limited by how good the input data is. If a genome
assembly has a poor gene annotation, it immediately is a limiting factor
in the analysis. Further, isoforms of genes cause problems in the
single-copy ortholog detection phase, as multiple transcripts from the
same gene confound the results. Additionally, after identifying
orhtologous sequences, there are usually some post-processing steps to
conduct. Below, I detail each stage in the ortholog detection pipeline
used in this paper.

The code to run the ortholog detection pipeline is found in the scripts
directory.

## Pre-processing gene sequences

The first step of the pipeline is to pre-process the gene sequences for
each input organism. This includes generating some gene statistics,
before filtering for and extracting the longest isoform. This is all
accomplished with the software
[AGAT](https://github.com/NBISweden/AGAT). *AGAT* is a tool for working
with GFF/GTF files, providing a feature rich library of functions that
can do nearly anything. Importantly, *AGAT* checks the validity of
GFF/GTF files, ensuring the input and output are accurate.

To extract the longest isoform, the function
`agat_sp_keep_longest_isoform.pl` was used. Next, to extract the longest
sequence, the function `agat_sp_extract_sequences.pl` was used. The
arguments `--clean_final_stop` and `-clean_internal_stop` were both
passed to ensure the output wouldn’t cause issues for downstream
processes. Coding sequences were extracted as both protein and
nucleotide FASTA files.

Additionally, the input genomes were selected based on `BUSCO`
completeness, requiring $\ge$ 85% completeness to be considered for
analysis.

## Identify orthologs

After extracting the longest gene sequence for every gene in every
sample, [OrthoFinder](https://github.com/davidemms/OrthoFinder) was used
to find orthogroups and single-copy orthologs between the query species.
Internally, the tool [MMseqs2](https://github.com/soedinglab/MMseqs2)
was used to perform the pair-wise alignments between species. We also
provided a species tree to the pipeline to assist with ortholog
detection. `OrthoFinder` generates many useful outputs, which are then
used by the subsequent steps.

## Cleaning OrthoFinder MSA files

`OrthoFinder` by default generates MSAs for single-copy orthologs. We
parameterised the pipeline to generate these alignments and then stop.
We also specified for the program to not trim the MSA files. The MSA
files were converted from protein alignments to codon alignments using
the program [Pal2Nal](http://www.bork.embl.de/pal2nal/), before
alignments were dynamically trimmed using
[ClipKIT](https://github.com/JLSteenwyk/ClipKIT/tree/master/clipkit).
Following
