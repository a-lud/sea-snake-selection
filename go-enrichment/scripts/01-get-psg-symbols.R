# ------------------------------------------------------------------------------------------------ #
# Create gene list for PANTHER
#
# This script generates the gene list that was passed to PANTHER. Most single-copy orthologs were
# able to be assigned one gene symbol. In instances where there are multiple, this script aims to
#     1) Determine if the 'extra' gene symbols are just locus tages (e.g. CUNH...)
#     2) If there are genuinely two symbols, choose one

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# PSGs
orthogroups <- read_csv(
  file = here('orthologs','ortholog-annotation','results','ortholog-annotation','orthologs.csv'),
  col_names = TRUE,
  col_types = cols()
)

psgs <- read_lines(file = here('selection','results','results-PSGs','PSGs-marine.txt'))

# 99 PSGs with no gene symbol (85 with NA, 16 with locus tags (CUNH.../C...H...ORF...))
orthogroups |>
  filter(orthogroup %in% psgs, is.na(symbol)) |>
  nrow()

orthogroups |>
  filter(orthogroup %in% psgs, !is.na(symbol), str_detect(symbol, ' ')) |>
  mutate(
    symbol = sub('CUNH.+ | CUNH.+', '', symbol),
    symbol = sub('C\\d+H\\d+ORF\\d+|CZH\\d+ORF\\d+|C\\d+HXORF\\d+', '', symbol)
  ) |>
  filter(symbol == '') |>
  nrow()

# 18 PSGs with multiple symbols
ids.multiple <- orthogroups |>
  filter(orthogroup %in% psgs, !is.na(symbol), str_detect(symbol, ' ')) |>
  mutate(
    symbol = sub('CUNH.+ | CUNH.+', '', symbol),
    symbol = sub('C\\d+H\\d+ORF\\d+|CZH\\d+ORF\\d+|C\\d+HXORF\\d+', '', symbol)
  ) |>
  filter(symbol != '') |>
  pull(symbol) |>
  str_split(' ') |>
  unlist()

# 1,279 genes with a single symbol
ids.genes <- orthogroups |>
  filter(orthogroup %in% psgs, !is.na(symbol), !str_detect(symbol, ' ')) |>
  pull(symbol)

# ------------------------------------------------------------------------------------------------ #
# Write gene symbols to file for use in PANTHER
c(ids.genes, ids.multiple) |>
  write_lines(file = here('go-enrichment','results','PSG-gene-symbols-for-PANTHER.txt'))

