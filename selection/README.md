Selection Testing
================
Alastair Ludington
2023-01-23

- <a href="#1-introduction" id="toc-1-introduction">1 Introduction</a>
- <a href="#2-selection-testing-software"
  id="toc-2-selection-testing-software">2 Selection testing software</a>
- <a href="#3-selection-testing-models"
  id="toc-3-selection-testing-models">3 Selection testing models</a>
  - <a href="#paml" id="toc-paml">PAML</a>
    - <a href="#codeml-branch-site-test-of-positive-selection"
      id="toc-codeml-branch-site-test-of-positive-selection">Codeml:
      Branch-Site test of positive selection</a>
    - <a href="#codeml-drop-out-test-of-positive-selection-using-site-models"
      id="toc-codeml-drop-out-test-of-positive-selection-using-site-models">Codeml:
      Drop-out test of positive selection using Site models</a>
  - <a href="#hyphy" id="toc-hyphy">HyPhy</a>
    - <a href="#busted-ph-testing-trait-association-with-positive-selection"
      id="toc-busted-ph-testing-trait-association-with-positive-selection">BUSTED-PH:
      Testing trait association with positive selection</a>
    - <a href="#relax-formal-test-for-selective-regime"
      id="toc-relax-formal-test-for-selective-regime">RELAX: Formal test for
      selective regime</a>
- <a href="#4-data-processing" id="toc-4-data-processing">4 Data
  processing</a>
  - <a href="#step-1-selection-testing"
    id="toc-step-1-selection-testing">Step 1: Selection testing</a>
    - <a href="#codeml-pipeline" id="toc-codeml-pipeline">Codeml pipeline</a>
    - <a href="#hyphy-pipeline" id="toc-hyphy-pipeline">Hyphy pipeline</a>
    - <a href="#hyphy-analyses-pipeline"
      id="toc-hyphy-analyses-pipeline">Hyphy-analyses pipeline</a>
  - <a href="#step-2-parse-selection-results"
    id="toc-step-2-parse-selection-results">Step 2: Parse selection
    results</a>
  - <a href="#step-3-identifying-candidate-psgs"
    id="toc-step-3-identifying-candidate-psgs">Step 3: Identifying candidate
    PSGs</a>
  - <a href="#step-4-go-term-enrichment-analysis"
    id="toc-step-4-go-term-enrichment-analysis">Step 4: GO term enrichment
    analysis</a>
  - <a href="#step-5-selection-intensity"
    id="toc-step-5-selection-intensity">Step 5: Selection intensity</a>

# 1 Introduction

Here, I’ve documented the methods used for conducting selection testing.
I used two selection testing tools to identify positively selected genes
(PSGs): [PAML (codeml)](https://github.com/abacus-gene/paml) and
[HyPhy](https://github.com/veg/hyphy). These tools are commonly used in
the literature to test evolutionary hypotheses using protein-coding
sequences. Below I detail each of the two tools, then go into the
pipelines I implemented, the code to run them and the expected outputs.

# 2 Selection testing software

As stated above, the two tools I’ve used for detecting positively
selected genes (PSGs) include [PAML’s
Codeml](https://github.com/abacus-gene/paml) and
[HyPhy](https://github.com/veg/hyphy). `Codeml` is a widely used tool in
evolutionary biology when performing selection testing. It’s been
continually updated since its release and has a range of models that
users can parameterise to test different evolutionary questions of their
sequence data. Broadly, implemented models include *branch*, *site*,
*branch-site*, *clade* and *basic*. Importantly, `codeml` implementes
rate-variation between sites, but assumes that the rate of synonymous
substitutions across sites in a gene is constant.

Alternatively, `HyPhy` is a program that implements its own versions of
the models above, testing similar evolutionary hypotheses, however, the
authors have implemented *synonymous-rate-variation* in a range of their
models (where applicable), which is a differentiating factor to PAML.
Additionally, most `HyPhy` models use an updated version of the MG94
codon substitution model, which is used in most of their methods to get
an initial estimate of branch-length and nucleotide substitution
parameters before running the hypothesis test.

As such, the decision was made to identify genes under positive
selection using both tools and report the overlap between the two.

# 3 Selection testing models

Below, I detail the specific methods used to identify PSGs with each
tool.

## PAML

### Codeml: Branch-Site test of positive selection

To test for PSGs in *Hydrophis* using `codeml`, I ran two Branch-Site
models: BSA and BSA1. The Branch-Site set of models allow $\omega$ to
vary both among sites in the protein sequence and across branches in the
provided tree. The aim of Branch-Site models is to identify positive
selection affecting a few sites along particular lineages (see [PAML
documentation p.g.
30](http://abacus.gene.ucl.ac.uk/software/pamlDOC.pdf)). In this pair of
models, BSA1 is the null model where the $\omega$<sub>3</sub> rate class
is fixed to 1, while BSA is the alternate model, where
$\omega$<sub>3</sub> is allowed to be $\geq$ 1 in the foreground
lineages but remains fixed ($\omega$<sub>3</sub> = 1) in the background
lineages. That is to say: the alternate model allows for positive
selection in the foreground species but not in the background species. A
likelihood ratio test (LRT) is then used to compare the alternate model
to the null model, with the null model being rejected if the
p-value/critical value reaches significance.

The issue with the Branch-Site models is that they only test for
positive selection in the foreground branches. That is,
$\omega$<sub>3</sub> is always limited to being $\leq$ 1 in the
background branches. Therefore, while a significant LRT result may
indicate positive selection by suggesting the BSA model fits the data
better, an even better model fit may be accomplished by allowing
positive selection across the whole tree.

### Codeml: Drop-out test of positive selection using Site models

A pre-print paper by [Kowalczyk et
al. 2021](https://www.biorxiv.org/content/10.1101/2021.10.26.465984v1.full)
explored this idea of positive selection being a tree-wide phenomena
that gets misatrributed to foreground branches due to the implementation
of Branch-Site tests. Consequently, they tested a drop-out method where
by the standard BSA/BSA1 models were run with foregroudn species marked.
They then removed the foreground species from the tree and ran M1a/M2a
Site models. Similar to the Branch-Site models, M1a is the ‘nearly
neutral’ model where $\omega$ is either $\leq$ 1 or $\omega$ = 1, while
M2a is the ‘positive selection’ model with a third $\omega$ rate class
where $\omega$<sub>3</sub> $\gt$ 1 (positive selection). They then used
the LRT results to determine the nature of positive selection in a gene.

- LRT for BSA/BSA1 is significant but not for M2a/M1a = positive
  selection in the foreground only
- LRT for BSA/BSA1 AND M2a/M1a is significant = positive selection
  across the tree

Essentially, any instance where the M2a model fit better than the M1a
model in the drop-out experiment indicated positive selection in the
background branches, a result that could not be determined by the
Branch-Site models alone. As such, this drop-out approach could be used
to better identify genes that are associated with convergent phenotypes,
as it accounts for signal in background branches that was previously
being ignored. Specifically, it prevents misattributing positively
selected genes to a phenotype that they are not contributing to.

## HyPhy

### BUSTED-PH: Testing trait association with positive selection

Unlike PAML, HyPhy has a built in approach to test for positive
selection associated with a phoenotype of interest, which in this case
is being a marine snake. The method was developed with the same lab
group who were responsible for the drop-out test above, and is called
[BUSTED-PH](https://github.com/veg/hyphy-analyses/tree/master/BUSTED-PH).

Briefly, `BUSTED` is a selection testing model that provides a gene-wide
test for positive selection by asking whether a gene has experienced
positive selection at at least one site on at least one branch ([Murrell
et
al. 2015](https://academic.oup.com/mbe/article/32/5/1365/1134918?login=true),
[website](https://stevenweaver.github.io/hyphy-site/methods/selection-methods/)).
By implementing a “stochastic selection” test over tests which average
over branches, codon sites or both, is greater statistical power to
detect transient/localised selective events ([Murrell et
al. 2015](https://academic.oup.com/mbe/article/32/5/1365/1134918?login=true)).
All this is to say, `BUSTED` is a tool that is specifically designed to
test for gene-wide positive selection over a whole phylogeny, or in
specific branches of interest. Importantly, a significant `BUSTED`
result does not mean that a gene has evolved under positive selection
along the entire foreground! Merely that at some point in time at least
one site has experienced positive selection somewhere along the
foreground branches.

The `BUSTED-PH` method is built around the `BUSTED` model, but
implements a series of additional selection tests to formally address
the question:

> Is a specific feature/phenotype/trait associated with positive
> selection?

The documentation for
[BUSTED-PH](https://github.com/veg/hyphy-analyses/tree/master/BUSTED-PH)
details the decision tree that is used to classify the type of
selection. The basic principle of the test is as follows:

1.  Fit an **unconstrained** Branch-Site REL model to the data, with
    *test* and *background* datasets having independent distributions.
    This model allows positive selection in **both** *test* and
    *background*.

2.  Fit a **constrained** model to *test* branches and perform a LRT
    between *unconstrained*/*constrained* models. The LRT statistics
    determines if there is positive selection in the *test* branches or
    not.

3.  Repeat step 2, but this time for the *background* branches. This is
    to determine if there is positive selection in the *background*
    branches.

4.  Finally a **constrained** model is fitted to the *test* and
    *background* branches where the $\omega$ distribution is the same
    for both. A LRT is then performed between this model and the
    *unconstrained* model (step 1) to determine if the **selective
    regimes** differ between the *test* and *background* branches.

From these series of tests, and following a simple decision tree, we can
determine if:

- Positive selection only occurs in *test* and selective regimes differ
- Positive selection only occurs in *test* but selective regimes are the
  same
- Positive selection occurs in both *test* and *background* and
  selective regimes differ
- Positive selection occurs in both *test* and *background* but
  selective regimes are the same
- No positive selection associated with the trait of interest (i.e. no
  positive selection in the foreground)

This pipeline is somewhat similar to the drop-out experiment using PAML.
The whole point is to isolate genes where there is only selection
occurring in the *test* (foreground) species relative to the
*background* species. `BUSTED-PH`, however, runs an additional test to
indicate the selection regime which the PAML approach does not.

### RELAX: Formal test for selective regime

The `RELAX` method is a hypothesis testing framework that asks:

> Has the strength of selection been relaxed or intensified along a
> specified set of test branches relative to a set of background
> branches?

As such, this method pairs nicely with the PAML drop-out/`BUSTED-PH`
methods above, as we can not only identify which genes are associated
with a trait of interest, but also classify their selective regime. The
underlying principle behind testing for selection intensity is that when
selection is ‘relaxed’, $\omega$ will shift towards neutrality, meaning,
$\omega$ shifts closer towards a value of 1. Alternatively, when the
selection intensity increases, $\omega$ will move away from neutrality,
resulting in $\omega$ moving further away from 1.

The `RELAX` method implements a formal framework for testing this.
Branches in a tree are grouped into *test* and *reference* sets, and a
`BS-REL` model is fit to the data in each partition. This is done so
separate, *discrete*, omega distributions are first estimated for both
*test* and *reference* datasets, and are then compared. `RELAX`
implements the constraint that $\omega_{T} = \omega^k_{R}$, meaning each
component of the *test* distribution is obtained by raising the
corresponding component in the *reference* distribution to the power
*k*. This value of *k* is the **selection intensity** **parameter**. The
method fits a null model, whereby *k* = 1, to the alternate model where
*k* is a free parameter. If the introduction of *k* significantly
improves model fit, we reject the null and conclude that selection is
intensified if *k* $\geq$ 1 or relaxed if *k* $\leq$ 1 compared with
background branches.

Again, the `RELAX` method is used to classify the intensity of selection
occurring in the PSGs of interest.

# 4 Data processing

Below I go over the scripts used to run the selection test, along with
their downstream processing.

## Step 1: Selection testing

The first step was to conduct the selection tests. I implemented two
(really three) separate Nextflow pipelines to run the two separate
selection tools:

- [CodeML](https://github.com/a-lud/nf-pipelines/wiki/CodeML-Pipeline):
  Run `codeml` using [ETE3](https://github.com/etetoolkit/ete), with the
  capability to perform drop-out analyses.
- [HyPhy(-analyses)](https://github.com/a-lud/nf-pipelines/wiki/HyPhy):
  Run `HyPhy`/`HyPhy-analyses` methods in parallel.

Each of these pipelines run the selection tests described above. The
pipelines take multiple sequence alignments of single copy orthologs,
along with a tree file. For each pipeline, the *Hydrophis* snakes were
marked as foreground/test, as can be seen in the `trees` directory in
this directory.

### Codeml pipeline

Below is a general overview of how the `codeml` pipeline runs. For a
more detailed breakdown, please visit the wiki linked above.

1.  Run selection models in parallel - `BSA` and `BSA1`

    - Model `M0` is used to get initial branch lengths before running
      more complex models

2.  Summarise `codeml` results for all orthologs into a single table
    using [eteTools](https://github.com/a-lud/eteTools)

3.  Remove *foreground* branches from the tree and run a drop-out
    analysis using `M1a` and `M2a`

4.  Collect drop-out results into a single summary table using
    [eteTools](https://github.com/a-lud/eteTools)

5.  Compare LRT statistics of Branch-Site models to drop-out site models
    using [eteTools](https://github.com/a-lud/eteTools)

Not mentioned above, but the pipeline will also check sequences for
internal stop codons using `HyPhy`’s `CleanStopCodons.bf` tool.

Script `01-codeml.sh` was used to run the `codeml` selection pipeline.

### Hyphy pipeline

The `hyphy` pipeline runs the default models provided by `HyPhy`.
Currently I’ve only implemented the `RELAX` model. The pipeline takes
MSA files and a species tree as input. As I was running the `RELAX`
model, the *Hydrophis* snakes were marked in the tree to represent the
*test* branches.

`HyPhy` returns a markdown formatted log file and JSON output file by
default. As such, these are the two outputs emitted by the pipeline.

The script that was used to run the `hyphy` pipeline was
`03-hyphy-relax-13.sh`.

### Hyphy-analyses pipeline

This pipeline is designed to run the custom workflows that accompany the
`HyPhy` software. To run the `hyphy-analses` batch-files, the `develop`
branch of the `HyPhy` tool needs to be installed. As such, this pipeline
is separate to the above pipeline as it requires a different
installation of `HyPhy` compared to above. So far, I’ve only implemented
support for `BUSTED-PH`.

Regardless, the main inputs and outputs are the same as the above
pipeline. The script used to run the pipeline can be found at
`02-hyphy-busted-ph-13.sh`.

## Step 2: Parse selection results

The `codeml` Nextflow pipeline returns a set of *TSV* files by default
thanks to [eteTools](https://github.com/a-lud/eteTools). The `HyPhy`
pipelines do not have an aggregation step in them, meaning they have to
be processed externally.

To help with this, I wrote some `HyPhy` parsing functions for `R`, which
can be found in the scripts directory at `scripts/hyphy-parsing`. These
general purpose functions read the JSON data from a list of files and
compile the results into a list object. Below is an example of the
`BUSTED-PH` list object:

``` r
# Load all JSON files
jsons.bustedph.13 <- loadJsons(dir = here('selection', 'results-13', 'hyphy', 'busted-ph-13'))

# Parse BUSTED-PH results
bustedph.13 <- parseBustedPh(jsons = jsons.bustedph.13)

# List of 3
#  $ test results     : tibble [26,004 × 4] (S3: tbl_df/tbl/data.frame)
#  $ branch attributes: tibble [656,644 × 4] (S3: tbl_df/tbl/data.frame)
#  $ fits             :List of 6
#   ..$ general      : tibble [39,814 × 5] (S3: tbl_df/tbl/data.frame)
#   ..$ constrained  : tibble [30,852 × 5] (S3: tbl_df/tbl/data.frame)
#   ..$ mg94         :List of 2
#   ..$ nucGTR       :List of 2
#   ..$ shared       : tibble [26,004 × 5] (S3: tbl_df/tbl/data.frame)
#   ..$ unconstrained: tibble [52,008 × 5] (S3: tbl_df/tbl/data.frame)
```

The list element correspond to the keys in the `BUSTED-PH` JSON file.
The same parsing was also carried out for the `RELAX` results. The
script responsible for parsing the `HyPhy` results is
`04-parse-hyphy.R`.

## Step 3: Identifying candidate PSGs

First, corrections for multiple testing were applied to both the
`codeml` and `HyPhy` results, in which the *fdr* correction from
`p.adjust()` was used. Following correction, we set our significance
threshold at $\alpha =$ 0.01.

Orthologs were then filtered on their corrected p-values, keeping only
genes that were reported as under positive selection in the *Hydrophis*
snakes and not in the *background* terrestrial snakes. Finally, the
significant genes from each dataset were joined on common ortholog
identifies, thus forming the final significant gene-sets.

The script responsible for performing these actions is
`05-hyphy-codeml-overlap.R`.

## Step 4: GO term enrichment analysis

After finalising the list of PSGs, GO Term enrichment was performed. The
GO Term annotations came from the ortholog annotation step which can be
found
[here](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation).
The program
[topGO](https://bioconductor.org/packages/release/bioc/html/topGO.html)
was used to perform the enrichment tests as it can work on non-model
organisms as long as you have a GO-to-gene mapping file.

When running `topGO`, we used the default `weight01` algorithm to weight
and prune the GO-DAG before conducting a Fisher’s test statistic. The
`weight01` method was used as it is a combination of an elminiation
algorithm, whereby GO terms that are significantly enriched to a child
node are removed from all ancestral nodes, and a weighting algorithm,
whereby nodes are weighted by their enrichment score relative to
neighbouring terms.

The following settings were applied when running the enrichment test
(which can be seen in the script `06-topGO.R`):

- Ontologies = BP, CC, MF
- Gene universe = 8,886 single copy orthologs that PSGs were obtained
  from
- Enrichment set = 1,390 PSGs as reported by both `codeml` and `HyPhy`
- Statistic = Fisher
- Algorithm = `Weight01`
- Node size = 10 - i.e. how many genes needed to be associated with the
  GO Term for it to be included

The output from `topGO` was then filtered on a $\alpha = 0.05$, along
with a shortest-path distance (in the GO-DAG) of $\geq$ 4. The path
information was obtained from a GO-summaries object that essentially
contains a range of meta-data about each GO Term, including:
longest-path to root, shortest-path to root and wether or not the term
is terminal. An example of the object is shown below.

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

This resulted in a list of significantly enriched GO Terms reported in
table format (see below).

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

## Step 5: Selection intensity

As described in [section 3](#RELAX-Formal-test-for-selective-regime)
above, selection intensity was measured by running the program `RELAX`
from the `HyPhy` package. The `RELAX` program was run by specifying the
*Hydrophis* snakes as the *test* branches and the Terrestrial snakes as
the *reference* branches. The program was run using my Nextflow
implementation of the `HyPhy` software, with the submission script found
at `03-hyphy-relax-13.sh`.

Results were parsed using the custom parsing tools I’ve written that can
be found in the `scripts` directory. The `RELAX` object looks similar to
the example shown in [*Step 2: Parse selection
results*](#Step-2-Parse-selection-results), with the contents of the
tables being different to the example above.

*Hydrophis* PSGs were intersected with the `RELAX` results to obtain
their respective selection-intensity parameter value (*k*). These
results were then visualised using an upset plot to show the amount of
overlap between *Hydrophis* PSGs and genes reported as under
intensification or relaxation by `RELAX`. In the figure below, the
intersection matrix at the bottom shows the combinations, the bar-plot
at the top shows the intersection size, while the bar-plot on the left
show the size of the gene sets that are being intersected. The
green/yellow sections in the top bar-plot show the proportion of that
intersection that can be explained by PSGs that are

- 1)  Under positive selection in both *Hydrophis* and terrestrial
      snakes

- 2)  Under positive selection in terrestrial snakes but not *Hydrophis*

The shared/terrestrial PSGs explain some of the un-accounted for
relaxed, intensified and neutral genes in the intersection plot.

*NOTE*: `RELAX` results are relative! Meaning the *k* parameter was
estimated in *Hydrophis* relative to the *reference* branches -
i.e. terrestrial snakes. This means the results need to be inverted when
making inference about terrestrial PSGs shown in this plot.

All selection intensity results were generated using the script
`07-selection-intensity.R`.

<img src="https://github.com/a-lud/sea-snake-selection/blob/main/selection/results-13/results-selection-intensification/upset.png" width="800" />
