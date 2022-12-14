Ortholog Detection
================
Alastair Ludington
2022-12-14

- <a href="#1-introduction" id="toc-1-introduction">1 Introduction</a>
- <a href="#2-identifying-orthologs" id="toc-2-identifying-orthologs">2
  Identifying orthologs</a>
  - <a href="#21-pre-processing-gene-sequences"
    id="toc-21-pre-processing-gene-sequences">2.1 Pre-processing gene
    sequences</a>
  - <a href="#22-identify-orthologs" id="toc-22-identify-orthologs">2.2
    Identify orthologs</a>
  - <a href="#23-protein-to-codon-alignments"
    id="toc-23-protein-to-codon-alignments">2.3 Protein to codon
    alignments</a>
  - <a href="#24-cleaning-msas" id="toc-24-cleaning-msas">2.4 Cleaning
    MSAs</a>
- <a href="#3-summary" id="toc-3-summary">3 Summary</a>

# 1 Introduction

Here I’ll outline the methods used to identify single-copy orthologs
between the snakes of interest. The methods here are encapsulated in a
`Nextflow` pipeline that I wrote that is hosted
[here](https://github.com/a-lud/nf-pipelines).

# 2 Identifying orthologs

There are many methods available for identifying orthologs. I opted to
write a pipeline around the ortholog detection tool [OrthoFinder
(v2.5.2)](https://github.com/davidemms/OrthoFinder). This tool is
commonly used in the literature and has a good balance of speed and
accuracy. Additionally, it’s got excellent documentation and is easy to
install.

Ortholog detection is limited by how good the input data is. If a genome
assembly has a poor gene annotation, it immediately is a limiting factor
in the analysis. Further, isoforms of genes cause problems in the
single-copy ortholog detection phase, as multiple transcripts from the
same gene confound the results. Additionally, after identifying
orhtologous sequences, there are usually some post-processing steps to
conduct. Below, I detail each stage in the Ortholog detection pipeline
used in this paper.

The code to run the orhtolog detection pipeline is found in the scripts
directory.

## 2.1 Pre-processing gene sequences

The first step of the pipeline is to pre-process the gene sequences for
each input organism. This includes generating some gene statistics,
before filtering for and extracting the longest isoform. This is all
accomplished with the software [AGAT
(v0.9.2)](https://github.com/NBISweden/AGAT). `AGAT` is a tool for
working with GFF/GTF files, providing a feature rich library of
functions that can do nearly anything. Importantly, `AGAT` checks the
validity of GFF/GTF files, ensuring the input and output are accurate.

To extract the longest isoform, the function `agat_sp_longest_iso` was
used. Next, to extract the longest sequence, the function
`agat_sp_extract` was used. The arguments `--clean_final_stop` and
`-clean_internal_stop` were both passed to ensure the output wouldn’t
cause issues for downstream processes. Coding sequences were extracted
as both protein and nucleotide sequences.

Additionally, the input genomes were selected based on `BUSCO`
completeness, requiring $\ge$ 85% completeness to be considiered for
analysis.

## 2.2 Identify orthologs

After extracting the longest gene sequence for every gene, for every
sample, [OrthoFinder (v2.5.2)](https://github.com/davidemms/OrthoFinder)
was used to find orthogroups and single-copy orthologs between the query
species. Internally, the tool [MMseqs2
(v13.45111)](https://github.com/soedinglab/MMseqs2) was used to perform
the pairwise alignments between sepecies. `OrthoFinder` generates many
useful outputs, which are then used by the subsequent steps.

## 2.3 Protein to codon alignments

`OrthoFinder` by default generates MSAs for single-copy orthologs. These
MSAs are protein alignments, and are converted to codon alignments by
using the tool [Pal2Nal v(14.1)](http://www.bork.embl.de/pal2nal/). This
tool retains gap positions in the MSA (if there are any), whilst still
translating the protein sequences by using the complementary nucleotide
CDS sequences that we generated using `AGAT`.

## 2.4 Cleaning MSAs

Finally, the MSAs are cleaned for gaps using [ClipKIT
(v1.3.0)](https://github.com/JLSteenwyk/ClipKIT/tree/master/clipkit).
This tool aims to identify parsimony-informative sites in the alignment,
and keep them if possible, rather than doing what most other trimming
tools do which is find low-quality uninformative sites. Further, clipkit
dynamically determines a missing-data threshold on-the-fly for each
individual alignment, meaning no global quality cut-off needs to be
applied to a range of diverse sequences.

# 3 Summary

This document provides a brief overview of the ortholog detection
pipeline. The aim of this pipeline was to generate a single interface to
produce high-quality orthogroups and orthologs, along with useful
outputs which are commonly needed for downstream analyses e.g. trimmed,
codon alignments. Further information relating to the pipeline can be
found at the pipelines wiki,
[here](https://github.com/a-lud/nf-pipelines/wiki/Orthofinder-Pipeline).
