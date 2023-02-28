GO Term over-representation
================
Alastair Ludington
2023-02-28

- <a href="#1-introduction" id="toc-1-introduction">1 Introduction</a>
  - <a href="#psg-gene-list" id="toc-psg-gene-list">PSG gene-list</a>
  - <a href="#panther-over-representation-and-parsing-results"
    id="toc-panther-over-representation-and-parsing-results">PANTHER
    over-representation and parsing results</a>
  - <a href="#revigo-semantic-similarity-clustering-of-go-terms"
    id="toc-revigo-semantic-similarity-clustering-of-go-terms">REVIGO
    semantic-similarity clustering of GO terms</a>

# 1 Introduction

This document details the GO Term enrichment approach used in this
study. We utilised the online tool
[PANTHER](https://www.nature.com/articles/s41596-019-0128-8) to perform
our over-representation analyses on GO terms associated with our
marine-specific positively selected genes (PSGs). We leverage
gene-symbol mappings between our annotated orthologs to the genes found
in *Anolis carolinensis*, using it’s well annotated gene-list as our
gene universe. Below are the steps to replicate our enrichment approach.

## PSG gene-list

**Script:**
[01-get-psg-symbols.R](https://github.com/a-lud/sea-snake-selection/blob/main/go-enrichment/scripts/01-get-psg-symbols.R)  
**Outputs:**
[results-13/PSG-gene-symbols-for-PANTHER.txt](https://github.com/a-lud/sea-snake-selection/blob/main/go-enrichment/results-13/PSG-gene-symbols-for-PANTHER.txt)

*PANTHER* requires a list of gene identifiers to perfrom enrichment
testing. As specified in the
[ortholog-annotation](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation)
repository, gene symbols were assigned to single-copy orthologs using
multiple sources. The script `01-get-psg-symbols.R` was then used to
extract each orthologs corresponding gene symbol.

A few of the scripts main tasks include:

- Determining how many genes are annotated with a single symbol
- How many genes are annotated with multiple symbols
- How many genes are annotated with un-usable symbols/no symbol at all
- Extract annotated genes

Some of the NCBI annotated genes were found to have locus tags as
annotations e.g. `CUNH6orf58`. These tags are not useful annotations,
and needed to be filtered out. Following the filtering listed above, we
ended up with the following counts for our 1,390 PSGs:

- 99 genes with no annotation
- 18 genes with multiple symbols
- 1,273 genes with a single gene annotation

Genes with multiple annotations were used in the analysis, as one of the
symbols was typically an older version, meaning one of them may match
the annotation used in *A. carolinensis*.

## PANTHER over-representation and parsing results

**Script:**
[02-parse-panther.R](https://github.com/a-lud/sea-snake-selection/blob/main/go-enrichment/scripts/02-parse-panther.R)  
**Outputs:**
[results-13/panther](https://github.com/a-lud/sea-snake-selection/tree/main/go-enrichment/results-13/panther)

The gene list exported in the previous step was provided to the
[PANTHER](https://www.nature.com/articles/s41596-019-0128-8) website to
perform over-representation analysis. The steps to get to the
over-representation page are as follows:

> Go to PANTHER webpage \> Tools \> Gene List Analysis

At this page we uploaded our list of gene identifiers (field 1), before
selecting *A. carolinensis* as our organism (field 2). Finally we
specified that we wanted to conduct a ‘*statistical* *overrepresentation
test*’, whereby we selected each of the three ontologies (BP, MF and CC)
(field 3). After clicking submit, we selected *A. carolinensis* as the
reference set, specified that we wanted to run a Fisher’s Exact test and
to calculate the FDR.

Results for each of the three ontologies were downloaded in table and
JSON format. The JSON files were used for all downstream work as they
retained the hierarchy infromation. Results were parsed using the
`02-parse-panther.R`, which returned a tibble object shown below:

``` text
# A tibble: 170 × 11
   Ontology level GO         label                                           Total Expected Observed `Fold enrichment` `P-value`      FDR Genes                                                                                       
   <chr>    <int> <chr>      <chr>                                           <int>    <dbl>    <int>             <dbl>     <dbl>    <dbl> <chr>                                                                                       
 1 BP           0 GO:0006796 phosphate-containing compound metabolic process  1270     77.6      113              1.46  1.53e- 4 1.77e- 2 PI4K2B NPFFR1 TAMM41 ...
 2 BP           1 GO:0006793 phosphorus metabolic process                     1288     78.7      114              1.45  1.69e- 4 1.90e- 2 PI4K2B NPFFR1 TAMM41 ...
 3 BP           2 GO:0044237 cellular metabolic process                       4481    274.       412              1.50  7.25e-19 2.24e-15 PI4K2B POP5 POP1 ABAT ...
 4 BP           3 GO:0008152 metabolic process                                5705    349.       489              1.40  2.22e-17 5.49e-14 PI4K2B POP5 SERPINE2 ...
 5 BP           3 GO:0009987 cellular process                                10141    620.       777              1.25  2.03e-20 8.35e-17 POP5 POP1 ZFYVE9 ALKBH7 ...
 6 BP           0 GO:0050793 regulation of developmental process              1017     62.1       92              1.48  4.14e- 4 4.02e- 2 BMPR2 SERPINE2 WWC2 SRA1 ...
 7 BP           1 GO:0050789 regulation of biological process                 6906    422.       534              1.27  4.64e-11 3.82e- 8 SERPINE2 ZFYVE9 EMC10 BACH1 ...
 8 BP           2 GO:0065007 biological regulation                            7570    463.       575              1.24  7.37e-11 5.05e- 8 SERPINE2 ZFYVE9 EMC10 ABAT ...
 9 BP           0 GO:0044260 cellular macromolecule metabolic process         1624     99.2      148              1.49  3.04e- 6 6.47e- 4 N6AMT1 SMARCAL1 UBXN2B ...
10 BP           1 GO:0043170 macromolecule metabolic process                  4121    252.       361              1.43  5.12e-13 7.01e-10 SMARCAL1 ...
```

From this tibble, significantly enriched GO terms (FDR $leq$ 0.05) were
extracted and written to file for use with
[REVIGO](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0021800).

## REVIGO semantic-similarity clustering of GO terms

**Scripts:**
[03-treemap-bp.R](https://github.com/a-lud/sea-snake-selection/blob/main/go-enrichment/scripts/03-treemap-bp.R)
/
[04-treemap-cc.R](https://github.com/a-lud/sea-snake-selection/blob/main/go-enrichment/scripts/04-treemap-cc.R)  
**Outputs:**
[results-13/revigo](https://github.com/a-lud/sea-snake-selection/tree/main/go-enrichment/results-13/revigo)

We used the list of over-represented GO terms as input to *REVIGO* to
perfrom semantic-similarity clustering. The idea is that GO terms that
are physically close within the GO-DAG will be somewhat similar.
Therefore, proximal GO terms can be semantically clustered with
consideration of the DAG structure.

*REVIGO* was run using the ‘Medium (0.7)’ setting, with obsolete GO
terms being removed and the whole UniProt database being used as the
‘species’. The ‘SimRel’ semantic-similarity measure was used to cluster
terms. Treemap TSV files (and the corresponding R-scripts) were
downloaded for BP and CC ontologies, along with the cytoscape network
files. The MF ontology was too sparse to be of any biological use (only
2 terms).
