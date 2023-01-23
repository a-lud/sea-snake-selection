# ------------------------------------------------------------------------------------------------ #
# GO Term enrichment
#
# Perform GO Term enrichment using the PSG identified by both PAML and HyPhy methods. TopGO is used
# to perform the enrichment test, using the default 'weight01' algorithm to prune the GO DAG and
# a 'fisher' test to perform the statistical test.
#
# Weight01 is a mixture of the 'elim' and 'weight' algorithms. 'Elim' starts from the most specific
# terms and moves through the DAG to the most general terms. The algorithm removes all genes that
# are annotated to significantly enriched node from all it's (the node) ancestors. The idea here is
# that a significant child node is more informative than a parent node - biologically more specific.
# Rather than scoring the child and parent node the same, this method scores the child higher due to
# its information content.
#
# The 'weight' method assigns weights to genes to better classify informative terms in a
# 'neighbourhood'. Essentially, the enrichment score of a term (U) that represents some set of genes
# is compared to the children of that node (children of U). Any child node that has a higher
# enrichment score than U better represents the genes of interest. As such, the corresponding genes
# annotated to these children nodes of U should contribute LESS to the score of the ancestral nodes
# of U - the ancestors of U are more general, meaning more genes associated to them resulting in
# smaller contributions towards the enrichment score for each annotated gene. Similarly, the
# children nodes of U that have smaller enrichment scores than U should be reported as insignificant.
# To achive this, genes associated with the insignificant children nodes are also given small
# weights. After the weights have been assigned, the enrichment score is re-computed, taking the
# weights into consideration.
#
# Thefore, 'weight01' being a mix of these two methods implements both a pruning method as seen in
# 'elim', along with a weighting scheme as implemented in 'weights'.

# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)
library(here)
library(topGO)

# ------------------------------------------------------------------------------------------------ #
# GO summaries object: information about GO Terms and the GO DAG
gosummaries <- read_rds(file = here('go-enrichment', 'r-data', 'goSummaries.rds'))

# ------------------------------------------------------------------------------------------------ #
# Single copy orthologs - 8,668 rows x 3 columns
single.copy.orthologs <- read_csv(
  file = here('orthologs','ortholog-annotation','results','ortholog-annotation','orthologs-13.csv'),
  col_names = TRUE,
  col_types = cols()
)

# ------------------------------------------------------------------------------------------------ #
# PSGs: Vector of the 1390 positively selected genes.
psg <- read_csv(
  file = here('selection','results-13','results-PSGs','PSGs-marine.txt'),
  col_names = 'orthogroup',
  col_types = cols()
) |>
  pull(orthogroup)

# ------------------------------------------------------------------------------------------------ #
# GO-Map: Maps gene identifiers to their GO Terms.
# Object is a named list of vectors, where the names correspond to the orthogroup ID and the values
# are the GO Terms associated with that orthogroup.
single.copy.orthologs |>
  mutate(GO = gsub(" ", ", ", GO)) |>
  dplyr::select(orthogroup, GO) |>
  write_tsv(
    file = 'tmp.tsv',
    col_names = FALSE
  )

# Read in temp file directly - easiest approach
geneid2GO <- readMappings('tmp.tsv')
fs::file_delete(path = 'tmp.tsv')

# ------------------------------------------------------------------------------------------------ #
# Enrichment test inputs: Preparing the input objects needed by TopGO

# All SCO - considered the gene-universe, as these are the common genes shared by all samples
# that we performed selection testing on.
geneNames <- names(geneid2GO)

# Specify which genes in the 'gene-universe' are positively selected (1) or not (0)
geneList <- factor(as.integer(geneNames %in% psg))
names(geneList) <- geneNames

# Create a 'topGO' data-object for each ontology: BP, CC, MF.
#   - Minimum node size = 10 (i.e. 10 genes need to be associated with a GO term to be considered)
godata.bp.cc.mf <- map(
  c('BP', 'CC', 'MF'),
  \(ont)
  godata <- new(
    "topGOdata",
    ontology = ont,
    allGenes = geneList,
    nodeSize = 10,
    annot =  annFUN.gene2GO,
    gene2GO = geneid2GO
  )
) |>
  set_names(c('BP', 'CC', 'MF'))

# ------------------------------------------------------------------------------------------------ #
# Perform the enrichment test for each ontology
results.wf <- map(godata.bp.cc.mf, \(topGOdat) runTest(object = topGOdat, statistic = 'fisher'))

# ------------------------------------------------------------------------------------------------ #
# Clean up resulting tables
enriched.go.terms <- map2(
  godata.bp.cc.mf, results.wf, \(topGodata, topGOres)
  GenTable(
    topGodata,
    topGOres,
    orderBy = 'result1',
    topNodes = length(usedGO(topGodata))
  ) |>
    as_tibble() |>
    left_join(gosummaries, by = c('GO.ID' = 'id')) |>
    filter(result1 <= 0.05, shortest_path > 4)
)

# TopGO reports truncated term/definitions fields - updating to be fully fledged
enriched.go.terms <- enriched.go.terms |>
  map(
    \(df)
    mutate(
      df,
      Term = Term(GO.ID),
      Definition = Definition(GO.ID)
    ) |>
      dplyr::select(
        `GO Term` = GO.ID,
        Term, Definition,
        Annotated, Expected, Significant, `P-value` = result1,
        `Path (shortest)` = shortest_path, `Path (longest)` = longest_path,
        `Terminal node` = terminal_node, ontology
      )
  )

# ------------------------------------------------------------------------------------------------ #
# Save enrichment results to file
fs::dir_create(here('go-enrichment','results-13','results-enrichment'), recurse = TRUE)

# Delete REVIGO file if it already exists - don't want to keep appending to existing file
if (fs::file_exists(here('go-enrichment', 'results-13', 'results-enrichment', "revigo.txt"))) {
  fs::file_delete(here('go-enrichment', 'results-13', 'results-enrichment', "revigo.txt"))
}

iwalk(
  enriched.go.terms, \(df, name) {

    # Write a CSV with all data
    write_csv(
      x = df,
      file = here('go-enrichment', 'results-13', 'results-enrichment', glue::glue("{name}-enriched.csv")),
      col_names = TRUE
    )

    # Write ALL GO Terms (only) to a file for REVIGO. REVIGO will classify ontology, so no need
    # for separate files

    write_lines(
      x = paste(df[['GO Term']], df[['P-value']], sep = ' '),
      file = here('go-enrichment', 'results-13', 'results-enrichment', "revigo.txt"),
      append = TRUE
    )
  }
)
