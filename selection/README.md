Selection Testing
================
Alastair Ludington
2023-06-21

- [1 Introduction](#1-introduction)
- [2 Selection testing software](#2-selection-testing-software)
- [3 Selection testing models](#3-selection-testing-models)
  - [PAML](#paml)
    - [Codeml: Branch-Site test of positive
      selection](#codeml-branch-site-test-of-positive-selection)
    - [Codeml: Drop-out test of positive selection using Site
      models](#codeml-drop-out-test-of-positive-selection-using-site-models)
  - [HyPhy](#hyphy)
    - [BUSTED-PH: Testing trait association with positive
      selection](#busted-ph-testing-trait-association-with-positive-selection)
    - [RELAX: Formal test for selective
      regime](#relax-formal-test-for-selective-regime)
- [4 Data processing](#4-data-processing)
  - [Step 1: Selection testing](#step-1-selection-testing)
    - [Codeml pipeline](#codeml-pipeline)
    - [Hyphy-analyses pipeline](#hyphy-analyses-pipeline)
    - [Hyphy pipeline](#hyphy-pipeline)
  - [Step 2: Parse selection results](#step-2-parse-selection-results)
  - [Step 3: Identifying candidate
    PSGs](#step-3-identifying-candidate-psgs)
  - [Step 4: Selection intensity](#step-4-selection-intensity)

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
lineages but remains fixed ( $\omega$<sub>3</sub> = 1 ) in the
background lineages. That is to say: the alternate model allows for
positive selection in the foreground species but not in the background
species. A likelihood ratio test (LRT) is then used to compare the
alternate model to the null model, with the null model being rejected if
the p-value/critical value reaches significance.

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
positive selection at at-least one site on at least one branch ([Murrell
et
al. 2015](https://academic.oup.com/mbe/article/32/5/1365/1134918?login=true),
[website](https://stevenweaver.github.io/hyphy-site/methods/selection-methods/)).
The advantage of `BUSTED` is that it models selection “stochastically”
over branches and sites, which provides it greater power to detect
transient/localised selective events compared to modles that average
$\omega$ over branches, sites or both ([Murrell et
al. 2015](https://academic.oup.com/mbe/article/32/5/1365/1134918?login=true)).
All this is to say, `BUSTED` is a tool that is specifically designed to
test for gene-wide positive selection over a whole phylogeny, or in
specific branches of interest. Importantly, a significant `BUSTED`
result does not mean that a gene has evolved under positive selection
along the entire foreground! Merely, that at some point in time, at
least one site has experienced positive selection somewhere along the
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
  between *test* and *background*
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
their downstream processing. All scripts detailed below can be found in
the
[scripts](https://github.com/a-lud/sea-snake-selection/tree/main/selection/scripts)
directory, while most data inputs and outputs can be found in any of the
[r-data](https://github.com/a-lud/sea-snake-selection/tree/main/selection/r-data)
or
[results](https://github.com/a-lud/sea-snake-selection/tree/main/selection/results)
directories.

The only files I could not upload here are the raw `HyPhy` JSON outputs,
as their cumulative size exceeded the 100Mb limit set by GitHub.

## Step 1: Selection testing

Selection tests were implemented using Nextflow pipelines that I wrote.
The three pipelines are:

- [CodeML](https://github.com/a-lud/nf-pipelines/wiki/CodeML-Pipeline):
  Run `codeml` using [ETE3](https://github.com/etetoolkit/ete), with the
  capability to perform drop-out analyses.
- [HyPhy](https://github.com/a-lud/nf-pipelines/wiki/HyPhy): Run `HyPhy`
  methods in parallel.
- [HyPhy-analyses](https://github.com/a-lud/nf-pipelines/wiki/HyPhy-Analyses):
  Run `HyPhy-analyses` methods in parallel.

Each of these pipelines run the selection tests described above. The
pipelines take multiple sequence alignments of single copy orthologs,
along with a tree file. For each pipeline, the *Hydrophis* snakes were
marked as foreground/test, as can be seen in the `trees` directory.

### Codeml pipeline

**Script:**
[01-codeml.sh](https://github.com/a-lud/sea-snake-selection/blob/main/selection/scripts/01-codeml.sh)  
**Outputs:**
[results/paml](https://github.com/a-lud/sea-snake-selection/tree/main/selection/results/paml)

I’ve detailed the main stages of the `codeml` pipeline that I
implemented in Nextflow. For a more detailed overview, please see the
wiki page linked above.

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

The tree passed to `codeml` is shown below

``` text
# snakes-marked-13-codeml.nwk: Codeml tree using '#1' notation
(python_bivittatus,((crotalus_tigris,protobothrops_mucrosquamatus),((pantherophis_guttatus,thamnophis_elegans),(pseudonaja_textilis,(notechis_scutatus,((hydrophis_elegans #1,hydrophis_cyanocinctus #1) #1,((hydrophis_curtus #1,hydrophis_curtus-AG #1) #1,(hydrophis_major #1,hydrophis_ornatus #1) #1) #1) #1)))));
```

The pipeline emits summary files for the Branch-Site models as well as
for the drop-out Site models. These include:

- BEB results (`beb.csv`)
- Branch information (`branches.csv` - if applicable)
- LRT results between Null/Alternate models (`lrt.csv`)
- Model information (`model-branch-site.csv` - this will take on the
  name of whatever model was run)

PAML results for this analysis can be found in the **Outputs** link
above.

### Hyphy-analyses pipeline

**Script:**
[02-hyphy-bustedph.sh](https://github.com/a-lud/sea-snake-selection/blob/main/selection/scripts/02-hyphy-bustedph.sh)
/
[03-hyphy-bustedph-terrestrial](https://github.com/a-lud/sea-snake-selection/blob/main/selection/scripts/03-hyphy-bustedph-terrestrial.sh)  
**Outputs:** Too large to upload to GitHub

The
[HyPhy-analyses](https://github.com/a-lud/nf-pipelines/wiki/HyPhy-Analyses)
pipeline runs the more custom selection pipelines in parallel. We used
this pipeline to run `BUSTED-PH` to test whether the *Marine* phenotype
is associated with positive selection (I also ran this tool with
terrestrial snakes marked as *test*).

The codon-translated multiple sequence alignment files were provided as
input, along with a newick tree where the *Hydrophis* sea snakes had
been marked as *test* branches (see below).

``` text
# snakes-marked-13-hyphy.nwk: HyPhy tree using '{}' marking notation
(python_bivittatus,((crotalus_tigris,protobothrops_mucrosquamatus),((pantherophis_guttatus,thamnophis_elegans),(pseudonaja_textilis,(notechis_scutatus,((hydrophis_elegans{Marine},hydrophis_cyanocinctus{Marine}){Marine},((hydrophis_curtus{Marine},hydrophis_curtus-AG{Marine}){Marine},(hydrophis_major{Marine},hydrophis_ornatus{Marine}){Marine}){Marine}){Marine})))));
```

The output from the pipeline was a JSON file for every ortholog tested.
These were not processed any further by the Nextflow pipeline.

### Hyphy pipeline

**Script:**
[04-hyphy-relax.sh](https://github.com/a-lud/sea-snake-selection/blob/main/selection/scripts/04-hyphy-relax.sh)  
**Outputs:** Too large to upload to GitHub

The `HyPhy` Nextflow pipeline simply runs selection models in parallel.
It does not run any other downstream processing of the data, as the
default output files from the tool are a Markdown log file and a JSON
output file.

The [HyPhy](https://github.com/a-lud/nf-pipelines/wiki/HyPhy) pipeline
was used to run `RELAX`. This model requires a multiple sequence
alignments and a marked tree file. As is shown below, *Hydrophis* snakes
were marked as *test* (Marine in the tree) while all other branches were
left as *reference*.

``` text
# snakes-marked-13-hyphy.nwk: HyPhy tree using '{}' marking notation
(python_bivittatus,((crotalus_tigris,protobothrops_mucrosquamatus),((pantherophis_guttatus,thamnophis_elegans),(pseudonaja_textilis,(notechis_scutatus,((hydrophis_elegans{Marine},hydrophis_cyanocinctus{Marine}){Marine},((hydrophis_curtus{Marine},hydrophis_curtus-AG{Marine}){Marine},(hydrophis_major{Marine},hydrophis_ornatus{Marine}){Marine}){Marine}){Marine})))));
```

## Step 2: Parse selection results

**Script:**
[05-parse-hyphy.R](https://github.com/a-lud/sea-snake-selection/blob/main/selection/scripts/05-parse-hyphy.R)  
**Outputs:**
[r-data](https://github.com/a-lud/sea-snake-selection/tree/main/selection/r-data)

The `codeml` Nextflow pipeline returns a set of *CSV* files by default
thanks to [eteTools](https://github.com/a-lud/eteTools). The `HyPhy`
pipelines do not have an aggregation step in them, meaning they have to
be processed externally. To help with this, I wrote some parsing
functions in *R*, which can be found in the
[scripts/hyphy-parsing](https://github.com/a-lud/sea-snake-selection/tree/main/selection/scripts/hyphy-parsing)
directory. These functions help convert and aggregate the JSON outputs
to nested lists of tibbles.

Below I’ve provided an example of the list object for the `BUSTED-PH`
results, along with the commands used to generate it. Note that the keys
of the list correspond to the keys in the JSON files.

``` r
# Load all JSON files
jsons.bustedph <- loadJsons(dir = here('selection', 'results', 'hyphy', 'busted-ph'))

# Parse BUSTED-PH results
bustedph <- parseBustedPh(jsons = jsons.bustedph)

# BUSTED-PH list object: Each key matches the keys found in the BUSTED-PH JSON outputs
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

## Step 3: Identifying candidate PSGs

**Script:**
[06-psgs.R](https://github.com/a-lud/sea-snake-selection/blob/main/selection/scripts/06-psg.R)  
**Outputs:**
[results/results-PSGs](https://github.com/a-lud/sea-snake-selection/tree/main/selection/results/results-PSGs)

The results from both `BUSTED-PH` and `codeml` were corrected for
multiple testing using an *fdr* correction implemented in `p.adjust()`.
Selection results were then filtered using an $\alpha =$ 0.01, requiring
the gene to be **only** under positive selection in the *Hydrophis*
snakes, with no significant signal of positive selection in the
*Terrestrial* snakes. Finally, PSGs from both sources were intersected
to find a final, overlapping set of PSGs.

*NOTE*: `BUSTED-PH` reports genes under positive selection in the *test*
branches relative to the *background* branches. It also provides extra
information regarding the potential difference in selective regime that
the `codeml` drop-out method does not. I decided to included `BUSTED-PH`
genes that were associated with the phenotype of interest, even if the
selective regime of the *test* and *background* branches were not
significantly different, as the gene itself is still under positive
selection with respect to the phenotype of interest.

## Step 4: Selection intensity

**Scripts:**
[07-selection-intensity.R](https://github.com/a-lud/sea-snake-selection/blob/main/selection/scripts/07-selection-intensity.R)  
**Outputs:**
[results/results-selection-intensification](https://github.com/a-lud/sea-snake-selection/tree/main/selection/results/results-selection-intensification)

As described in [section 3](#relax-formal-test-for-selective-regime)
above, selection intensity was measured by running the program `RELAX`
from the `HyPhy` package. The `RELAX` program was run with the
*Hydrophis* snakes marked as *test* and Terrestrial snakes marked as
*reference* branches.

Results were parsed using the custom parsing tools I’ve written that can
be found in the `scripts` directory. The `RELAX` object looks similar to
the example shown in Step 2 above, with the contents of the tables being
different to the example above.

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

![](https://github.com/a-lud/sea-snake-selection/blob/main/figures/manuscript/figure-x-upset.png)
