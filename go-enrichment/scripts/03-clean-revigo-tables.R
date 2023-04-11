# ------------------------------------------------------------------------------------------------ #
# Clean up REVIGO tables
#
# Make a nicer REVIGO summary table with a bit of extra information about the GO terms.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# GO database
go <- as.list(GO.db::GOTERM)
go <- tibble(
  GO = names(go),
  Description = unlist(map(go, AnnotationDbi::Definition))
)

# ------------------------------------------------------------------------------------------------ #
# Clean up semantic clustering - bit janky but does the trick
fs::dir_ls(
  path = here('go-enrichment','results','revigo','enriched'),
  glob = '*Table.tsv'
) |>
  read_tsv(col_names = TRUE, col_types = cols(), id = 'ontology') |>
  mutate(
    ontology = sub('Revigo_(.*)_Table.tsv', '\\1', basename(ontology)),
    Representative = ifelse(Representative == 'null', Name, Representative),
    Representative = ifelse(is.na(as.numeric(Representative)), Representative, NA_character_)
  ) |>
  fill(Representative, .direction = 'down') |>
  left_join(go, join_by(TermID == GO)) |>
  select(Ontology= ontology, GO = TermID, Name, Description, Representative, everything()) |>
  write_csv(
    file = here('figures','supplementary','table-x-revigo.csv'),
    col_names = TRUE
  )
