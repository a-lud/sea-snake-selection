GO Term Enrichment
================
Alastair Ludington
2023-01-23

- <a href="#1-introduction" id="toc-1-introduction">1 Introduction</a>
  - <a href="#go-term-enrichment-analysis"
    id="toc-go-term-enrichment-analysis">GO Term enrichment analysis</a>

# 1 Introduction

This document details the GO Term enrichment approach used in this
study.

## GO Term enrichment analysis

**Script:**
[01-topGO.R](https://github.com/a-lud/sea-snake-selection/blob/main/go-enrichment/scripts/01-topGO.R)  
**Outputs:**
[results-13/results-enrichment](https://github.com/a-lud/sea-snake-selection/tree/main/go-enrichment/results-13/results-enrichment)

GO Term enrichment was performed on the *Hydrophis* PSGs. For
information on the selection-testing methodologies and filtering, see
the [Selection
Testing](https://github.com/a-lud/sea-snake-selection/tree/main/selection)
documentation here. GO Terms were assigned to orthologous genes by
integrating evidence from multiple different sources, which is detailed
in the [Ortholog
Annotation](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation)
section. The program
[topGO](https://bioconductor.org/packages/release/bioc/html/topGO.html)
was used to perform the enrichment test as it is suited to working with
non-model organisms as long as you have the gene-to-go mapping file.

When running `topGO`, we used the default `weight01` algorithm along
with a *fisher* test. The parameters used are detailed below.

- Ontologies tested = BP, CC, MF
- Gene universe = The 8,886 single copy orthologs that PSGs were
  obtained from
- Enrichment set = 1,390 PSGs (overlapping genes between `codeml` and
  `HyPhy`)
- Statistic = Fisher test
- Algorithm = `Weight01`
- Node size = 10 - how many genes needed to be associated with the GO
  Term for it to be included

The output from `topGO` was then filtered on a $\alpha = 0.05$, along
with a shortest-path distance (in the GO-DAG) of $\geq$ 4. The path
information was obtained from a GO-summaries object that essentially
contains a range of meta-data about each GO Term, including:
longest-path to root, shortest-path to root and whether or not the term
is terminal. These filters were applied to not only keep significant
terms, but to also ensure the terms we investigates further are
specific, rather than general, higher level terms.

An example of the GO-summaries object is shown below

``` text
A tibble: 43,704 × 5
id         shortest_path longest_path terminal_node ontology
<chr>              <dbl>        <dbl> <lgl>         <chr>   
  1 GO:0000001             6            7 TRUE          BP      
2 GO:0000002             6            6 FALSE         BP      
3 GO:0000003             1            1 FALSE         BP      
4 GO:0000011             6            6 TRUE          BP      
5 GO:0000012             6            8 FALSE         BP      
6 GO:0000017             8            8 TRUE          BP      
7 GO:0000018             5            8 FALSE         BP      
8 GO:0000019             6            9 FALSE         BP      
9 GO:0000022             4            9 FALSE         BP      
10 GO:0000023             5            6 FALSE         BP
...
```

Applying the filters that we did resulted in significance tables as is
shown below (for BP ontology).

``` text
A tibble: 112 × 11
`GO Term`  Term                                                             Definition                                                                                                          Annot…¹ Expec…² Signi…³ P-val…⁴ Path …⁵ Path …⁶ Termi…⁷ ontol…⁸
<chr>      <chr>                                                            <chr>                                                                                                                 <int>   <dbl>   <int> <chr>     <dbl>   <dbl> <lgl>   <chr>  
  1 GO:0002098 tRNA wobble uridine modification                                 The process in which a uridine in position 34 of a tRNA is post-transcriptionally modified.                              24    3.85      12 0.00011       8      12 FALSE   BP     
2 GO:0051058 negative regulation of small GTPase mediated signal transduction Any process that stops, prevents, or reduces the frequency, rate or extent of small GTPase mediated signal transdu…     134   21.5       22 0.00028       5       8 FALSE   BP     
3 GO:1902857 positive regulation of non-motile cilium assembly                NA                                                                                                                       16    2.57       8 0.00166       6      10 TRUE    BP     
4 GO:2000467 positive regulation of glycogen (starch) synthase activity       NA                                                                                                                       13    2.09       7 0.00190       6       6 TRUE    BP     
5 GO:0099151 regulation of postsynaptic density assembly                      Any process that modulates the frequency, rate or extent of postsynaptic density assembly, the aggregation, arrang…      56    8.99      18 0.00210       6      10 TRUE    BP     
6 GO:0042304 regulation of fatty acid biosynthetic process                    Any process that modulates the frequency, rate or extent of the chemical reactions and pathways resulting in the f…     105   16.9       20 0.00218       5       9 FALSE   BP     
7 GO:0098883 synapse pruning                                                  A cellular process that results in the controlled breakdown of synapse. After it starts the process is continuous …      24    3.85      10 0.00247       6       6 FALSE   BP     
8 GO:0051261 protein depolymerization                                         The process in which protein polymers, compounds composed of a large number of component monomers, are broken down…     211   33.9       39 0.00287       6       6 FALSE   BP     
9 GO:0031580 membrane raft distribution                                       The process that establishes the spatial arrangement of membrane rafts within a cellular membrane.                       19    3.05       5 0.00290       5       6 FALSE   BP     
10 GO:0032469 endoplasmic reticulum calcium ion homeostasis                    Any process involved in the maintenance of an internal steady state of calcium ions within the endoplasmic reticul…      29    4.66      11 0.00367       8      10 FALSE   BP 
...
```
