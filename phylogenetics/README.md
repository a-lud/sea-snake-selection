Phylogenetics
================
Alastair Ludington
2023-06-20

- [1 Introduction](#1-introduction)
- [2 Data preparation](#2-data-preparation)
- [3 Species tree inference using
  orthologs](#3-species-tree-inference-using-orthologs)
  - [IQ-TREE and ASTRAL-III](#iq-tree-and-astral-iii)
    - [Gene concordance analysis](#gene-concordance-analysis)
  - [PhyloNet](#phylonet)
- [4 Species tree inference using whole genome
  assemblies](#4-species-tree-inference-using-whole-genome-assemblies)
  - [4.1 SANS serif: Phylogentic
    network](#41-sans-serif-phylogentic-network)

# 1 Introduction

*Hydrophis* has undergone rapid speciation. We set out to resolve the
short internal branches that characterise this rapid radiation. We used
three techniques to approach this problem which are detailed below.

# 2 Data preparation

**Scirpt:**
[00-prep-hydrophis-orthologs.sh](https://github.com/a-lud/sea-snake-selection/blob/main/phylogenetics/scripts/00-prep-hydrophis-orthologs.sh)  
**Outdir:**
[results](https://github.com/a-lud/sea-snake-selection/tree/main/phylogenetics/results)

The order of operations is slightly off here, but two of the following
analyses used the single-copy orthologs that we identified (see
[here](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-detection)).
Specifically, we subset the orthogroups file for single-copy orthologs
in *Hydrophis*, resulting in 14,002 candidate orthologs to progress
with.

*Hydrophis* single-copy orthologs were aligned using
[Mafft](https://mafft.cbrc.jp/alignment/software/) (peptide sequences)
and converted to codon alignments using
[PAL2NAL](http://www.bork.embl.de/pal2nal/) (see
[prot-to-codon.py](https://github.com/a-lud/sea-snake-selection/blob/main/phylogenetics/scripts/prot-to-codon.py)).
Codon alignments were then cleaned dynamically using
[ClipKIT](https://github.com/JLSteenwyk/ClipKIT), with internal stop
codons being removed using `CLN` from
[Hyphy](https://github.com/veg/hyphy). We then screened the single-copy
orthologs for parsimony-informative sites using the software
[PhyKIT](https://github.com/JLSteenwyk/PhyKIT).

``` bash
# MAFFT alignment
find . -name '*.pep' |
    parallel -j 20 "mafft --maxiterate 1000 --globalpair --thread 1 {} > ../01-mafft-hydrophis/{.}.aln"

# Peptide to codon conversion
./prot-to-codon.py -f "${DIR}/cds" -m "${DIR}/01-mafft-hydrophis" -o "${DIR}/02-codon-hydrophis"

# ClipKIT cleaning
clipkit "${FA}" --output "${DIR}/03-clipkit-hydrophis/${BN}.fa"

# Internal stop codon masking
hyphy CLN Universal "${FA}" No/No "${DIR}/04-clean-hydrophis/${BN}.tmp"

# Parsimony-informative sites using PhyKIT 
find "${DIR}/04-clean-hydrophis" -name '*.fa' |
    parallel -j 16 --joblog pis.log "pis {} parsimony-informative-sites.tsv"

# List orthologs with at least one parsimony-informative site
awk '$2 != 0 {print}' parsimony-informative-sites.tsv | cut -f 1 >parsimony-informative-orthologs.txt
```

NOTE: For subsequent steps, we used parsimony-informative sites $\geq$
5. This involved changing the `AWK` command to `$2 > 4`.

# 3 Species tree inference using orthologs

We implemented two methods that utilised the single-copy orthologs:
[IQ-TREE](https://github.com/iqtree/iqtree2) and
[ASTRAL-III](https://github.com/TheBrownLab/astral), and
[PhyloNet](https://phylogenomics.rice.edu/). The *IQ-TREE/ASTRAL-III*
method formed the foundation for the *PhyloNet* method.

## IQ-TREE and ASTRAL-III

**Script:**
[01-species-tree-inference.sh](https://github.com/a-lud/sea-snake-selection/blob/main/phylogenetics/scripts/01-species-tree-inference.sh)  
**Outdir:**
[results/07-iqtree](https://github.com/a-lud/sea-snake-selection/tree/main/phylogenetics/results/07-iqtree)
/
[results/08-astral](https://github.com/a-lud/sea-snake-selection/tree/main/phylogenetics/results/08-astral)

*Hydrophis*-specific single-copy orthologs that had at least one
parsimony-informative site were passed to *IQ-TREE* to estimate
gene-trees. We let *IQ-TREE* estimate the model parameters dynamically
for each ortholog.

``` bash
# Parallel execution of iqtree on each hydrophis single-copy ortholog
find "${MSA}" -maxdepth 1 -type f -name '*.fa' |
    parallel -j 20 --joblog "${DIR}/logs/iqtree-parallel.log" \
        "iqtree -s {} -T 1 --threads-max 1 --seqtype CODON --prefix ${OUT2}/{/.} --ufboot 1000 --wbtl"

# Aggregate the results
cat "${OUT2}/"*.treefile >"${OUT2}/ml_best.trees"
find "${OUT2}" -type f -name '*.ufboot' >"${OUT2}/ml_boot.txt"
```

Trees could be made for 9,299 of the 9,866 parsimony-informative
orthologs using this approach. The trees files and bootstraps were then
passed to *ASTRAL-III* to generate the species tree.

``` bash
java -Xms20g -Xmx40g -jar 'astral.5.7.8.jar' \
      -i "${OUT2}/ml_best.trees" \
      -b "${OUT2}/ml_boot.txt" \
      -o "${DIR}/astral-species.tre" &> "${DIR}/astral.log"
```

### Gene concordance analysis

**Script:**
[02-gCF.sh](https://github.com/a-lud/sea-snake-selection/blob/main/phylogenetics/scripts/02-gCF.sh)  
**Outdir:**
[results/09-concordance](https://github.com/a-lud/sea-snake-selection/tree/main/phylogenetics/results/09-concordance)

To assess the species tree inferred from the gene-trees, we generated
gene concordance data. Gene concordance factors (gCF) represent the
proportion of gene trees (from a set) that support the nodes of a
user-provided species tree. The species tree estimated by *ASTRAL-III*
was used as input for the gCF analysis.

``` bash
iqtree -t astral-no-bootstrap.tree --gcf ml_best.trees --prefix gene_concordance-ml-trees-only
```

## PhyloNet

**Scripts:**
[03-phylonet.sh](https://github.com/a-lud/sea-snake-selection/blob/main/phylogenetics/scripts/03-phylonet.sh)  
**Outdir:**
[results/phylonet](https://github.com/a-lud/sea-snake-selection/tree/main/phylogenetics/results/phylonet)

The second approch we used involved running *PhyloNet* with different
numbers of reticulations. *PhyloNet* was used to infer a species network
from *Hydrophis* orthologs that had at least five parsimony-informative
sites. We filtered the orthologs down to reduce the amount of data that
we had to process, while also ensuring we were using informative
orthologs. We ran `InferNetwork_ML` using five reticulation values: 0 -
4.

``` bash
# Subset parsimony-informative sites files for orthologs with >= 5
awk '$2 > 4 {print}' parsimony-informative-sites.tsv | cut -f 1 >parsimony-informative-orthologs-n5.txt

# Subset of '.nex' file that actually runs the code
BEGIN PHYLONET;

InferNetwork_ML (all) <0..4> -o -pl 40 -di;

END;
```

# 4 Species tree inference using whole genome assemblies

In addition to the single-copy ortholog approaches listed above, we also
used the whole genomes and [SANS
serif](https://gitlab.ub.uni-bielefeld.de/gi/sans) to infer phylogenetic
networks using an alignment-free approach.

## 4.1 SANS serif: Phylogentic network

**Script:**
[04-sans-serif.sh](https://github.com/a-lud/sea-snake-selection/blob/main/phylogenetics/scripts/04-sans-serif.sh)  
**Outdir:** Raw results too large to upload

*SANS serif* is an alignment- and reference-free method that uses common
sub-sequences shared between the provided genomes to infer weighted
splits and reconstruct a species phylogeny. We provided the genomes of
the six *Hydrophis* snakes as input.

``` bash
# 'Weakly' filtering method
SANS --input 'genomes.fofn' -output 'weakly-geom-31.tsv' --filter 'weakly' --mean 'geom' 
SANS --input 'genomes.fofn' -output 'weakly-geom2-31.tsv' --filter 'weakly' 

# 'strict' filtering method
SANS --input 'genomes.fofn' -output 'strict-geom-61.tsv' --filter 'strict' --mean 'geom' --kmer 61
SANS --input 'genomes.fofn' -output 'strict-geom2-61.tsv' --filter 'strict' --kmer 61
```
