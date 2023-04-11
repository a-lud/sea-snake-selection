# ------------------------------------------------------------------------------------------------ #
# Relaxed genes: REVIGO list
#
# Get the GO terms relating to the relaxed marine-PSGs. GO terms are obtained from the 'all results'
# PANTHER output.

# ------------------------------------------------------------------------------------------------ #
# libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# Read in data
orthogroups <- read_csv(
  file = here('orthologs','ortholog-annotation','results','ortholog-annotation','orthologs.csv'),
  col_names = TRUE,
  col_types = cols()
)

marine.relaxed <- read_lines(file = here('selection','results','results-selection-intensification','psg-marine-relaxation.txt'))

# Generated in '02-parse-panther.R'
genes.go.human <- read_csv(
  file = here('go-enrichment','results','genes-annotated-GO.csv'),
  col_names = TRUE,
  col_types = cols()
)

# ------------------------------------------------------------------------------------------------ #
# Built REVIGO table
orthogroups |>
  filter(orthogroup %in% marine.relaxed) |>
  select(orthogroup, Genes = symbol) |>
  filter(!is.na(Genes)) |>
  mutate(Genes = str_split(Genes, ' ')) |>
  unnest(cols = Genes) |>
  distinct() |>
  left_join(genes.go.human, multiple = 'all') |>
  group_by(GO) |>
  summarise(count = n()) |>
  arrange(-count) |>
  filter(!is.na(GO)) |>
  write_tsv(
    file = here('go-enrichment','results','marine-PSG-relaxed-GO-terms-REVIGO.txt'),
    col_names = FALSE
  )
