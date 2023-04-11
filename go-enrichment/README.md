GO Term over-representation
================
Alastair Ludington
2023-04-11

- <a href="#1-introduction" id="toc-1-introduction">1 Introduction</a>
- <a href="#2-extract-gene-symbols-psgs"
  id="toc-2-extract-gene-symbols-psgs">2 Extract gene symbols (PSGs)</a>
- <a href="#3-panther-over-representation-and-parsing-results"
  id="toc-3-panther-over-representation-and-parsing-results">3 PANTHER
  over-representation and parsing results</a>
- <a href="#4-revigo-semantic-similarity-clustering-of-go-terms"
  id="toc-4-revigo-semantic-similarity-clustering-of-go-terms">4 REVIGO
  semantic-similarity clustering of GO terms</a>

# 1 Introduction

This document details the GO Term enrichment approach used in this
study. We utilised the online tool
[PANTHER](https://www.nature.com/articles/s41596-019-0128-8) to perform
our over-representation analyses on GO terms associated with our
marine-specific positively selected genes (PSGs). We leverage
gene-symbol mappings between our annotated orthologs to the genes found
in *Homo sapiens*, using it’s well annotated gene-list as our gene
universe. Below are the steps to replicate our enrichment approach.

# 2 Extract gene symbols (PSGs)

**Script:**
[01-get-psg-symbols.R](https://github.com/a-lud/sea-snake-selection/blob/main/go-enrichment/scripts/01-get-psg-symbols.R)  
**Outputs:**
[results/PSG-gene-symbols-for-PANTHER.txt](https://github.com/a-lud/sea-snake-selection/tree/main/go-enrichment/results)

*PANTHER* requires a list of gene identifiers to perform enrichment
testing. As specified in the
[ortholog-annotation](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation)
repository, gene symbols were assigned to single-copy orthologs using
multiple sources. The script `01-get-psg-symbols.R` was then used to
extract each ortholog’s corresponding gene symbol.

A few of the scripts main tasks include:

- Determining how many genes are annotated with a single symbol
- How many genes are annotated with multiple symbols
- How many genes are annotated with un-usable symbols/no symbol at all
- Extract annotated genes

Some of the NCBI annotated genes were found to have locus tags as
annotations e.g. `CUNH6orf58`. These tags are not useful annotations,
and needed to be filtered out. Following the filtering listed above, we
ended up with the following counts for our 1,402 PSGs:

- 100 genes with no annotation
- 18 genes with multiple symbols
- 1,284 genes with a single gene annotation

Genes with multiple annotations were used in the analysis, as one of the
symbols was typically an older version, meaning one of them may match
the annotation used in *H. sapiens*.

# 3 PANTHER over-representation and parsing results

**Script:**
[02-parse-panther.R](https://github.com/a-lud/sea-snake-selection/blob/main/go-enrichment/scripts/02-parse-panther.R)  
**Outputs:**
[results/panther](https://github.com/a-lud/sea-snake-selection/tree/main/go-enrichment/results/panther)
/
[results/enriched-GO-terms-REVIGO.txt](https://github.com/a-lud/sea-snake-selection/tree/main/go-enrichment/results)
/
[results/genes-annotated-GO.csv](https://github.com/a-lud/sea-snake-selection/tree/main/go-enrichment/results)

The gene list exported in the previous step was provided to the
[PANTHER](https://www.nature.com/articles/s41596-019-0128-8) website to
perform over-representation analysis. The steps to get to the
over-representation page are as follows:

> Go to PANTHER webpage \> Tools \> Gene List Analysis

At this page we uploaded our list of gene identifiers (field 1), before
selecting *H. sapiens* as our organism (field 2). Finally we specified
that we wanted to conduct a ‘*statistical* *over-representation test*’,
whereby we selected each of the three ontologies (BP, MF and CC) (field
3). After clicking submit, we selected *H. sapiens* as the reference
set, specified that we wanted to run a Fisher’s Exact test and to
calculate the FDR.

*H. sapiens* was selected as the reference organism as it is the best
annotated, and our annotations best match *H. sapien*. Other organisms
in the *PANTHER* database are evolutionarily distant to our snake, and
are less well annotated. Consequently, we decided to prioritise
annotation quality over a slight decrease in evolutionary distance.

Results for each of the three ontologies were downloaded JSON format for
both significant results only, along with all genes passed to the
program. Results were parsed using the script `02-parse-panther.R`,
which returned a tibble object shown below:

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

From this tibble, significantly enriched GO terms (FDR $\leq$ 0.05) were
extracted and written to file for use with
[REVIGO](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0021800).

# 4 REVIGO semantic-similarity clustering of GO terms

**Script:**
[02-parse-panther.R](https://github.com/a-lud/sea-snake-selection/blob/main/go-enrichment/scripts/02-parse-panther.R)
/
[03-clean-revigo-tables.R](https://github.com/a-lud/sea-snake-selection/blob/main/go-enrichment/scripts/03-clean-revigo-tables.R)  
**Outputs:**
[results/revigo/enriched](https://github.com/a-lud/sea-snake-selection/tree/main/go-enrichment/results/revigo/enriched)

We used the list of over-represented GO terms as input to *REVIGO* to
perfrom semantic-similarity clustering. The idea is that GO terms that
are physically close within the GO-DAG will be somewhat similar.
Therefore, proximal GO terms can be semantically clustered with
consideration of the DAG structure.

*REVIGO* was run using the ‘small (0.5)’ setting, with obsolete GO terms
being removed and the whole UniProt database being used as the
‘species’. The ‘SimRel’ semantic-similarity measure was used to cluster
terms. For each ontology, summary files were downloaded and parsed into
summary tables/figures.

``` text
# A tibble: 46 × 10                                                                                                                                                                                                                                                                                                                                                                                                                                   
   Ontology GO         Name                                                   Description                                                                                                                                                                                                                                                                             Repre…¹ Value LogSize Frequ…² Uniqu…³ Dispe…⁴
   <chr>    <chr>      <chr>                                                  <chr>                                                                                                                                                                                                                                                                                   <chr>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
 1 BP       GO:0002250 adaptive immune response                               An immune response mediated by cells expressing specific receptors for antigen produced through a somatic diversification process, and allowing for an enhanced secondary response to subsequent exposures to the same antigen (immunological memory).                                  adapti… -4.10    4.26 6.04e-2   0.885  0.254 
 2 BP       GO:0019730 antimicrobial humoral response                         An immune response against microbes mediated through a body fluid. Examples of this process are seen in the antimicrobial humoral response of Drosophila melanogaster and Mus musculus.                                                                                                 adapti… -1.58    3.45 9.30e-3   0.855  0.659 
 3 BP       GO:0006796 phosphate-containing compound metabolic process        The chemical reactions and pathways involving the phosphate group, the anion or salt of any phosphoric acid.                                                                                                                                                                            phosph… -2.10    6.60 1.31e+1   0.957  0.0869
 4 BP       GO:0006974 cellular response to DNA damage stimulus               Any process that results in a change in state or activity of a cell (in terms of movement, secretion, enzyme production, gene expression, etc.) as a result of a stimulus indicating damage to its DNA from environmental insults or errors during metabolism.                          cellul… -2.06    5.89 2.55e+0   0.853  0.479 
 5 BP       GO:0042742 defense response to bacterium                          Reactions triggered in response to the presence of a bacterium that act to protect the cell or organism.                                                                                                                                                                                cellul… -1.48    4.50 1.06e-1   0.869  0.547 
 6 BP       GO:0007186 G protein-coupled receptor signaling pathway           A series of molecular signals that proceeds with an activated receptor promoting the exchange of GDP for GTP on the alpha-subunit of an associated heterotrimeric G-protein complex. The GTP-bound activated alpha-G-protein then dissociates from the beta- and gamma-subunits to fur… G prot… -3.42    5.68 1.58e+0   0.705  0.340 
 7 BP       GO:0008104 protein localization                                   Any process in which a protein is transported to, or maintained in, a specific location.                                                                                                                                                                                                protei… -3.41    5.96 3.05e+0   0.935  0     
 8 BP       GO:0046907 intracellular transport                                The directed movement of substances within a cell.                                                                                                                                                                                                                                      protei… -2.35    5.79 2.03e+0   0.936  0.856 
 9 BP       GO:0010605 negative regulation of macromolecule metabolic process Any process that decreases the frequency, rate or extent of the chemical reactions and pathways involving macromolecules, any molecule of high relative molecular mass, the structure of which essentially comprises the multiple repetition of units derived, actually or conceptuall… negati… -2.34    5.66 1.51e+0   0.690  0.260 
10 BP       GO:0031327 negative regulation of cellular biosynthetic process   Any process that stops, prevents, or reduces the frequency, rate or extent of the chemical reactions and pathways resulting in the formation of substances, carried out by individual cells.                                                                                            negati… -1.30    5.42 8.67e-1   0.698  0.911
```
