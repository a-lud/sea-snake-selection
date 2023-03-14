# ------------------------------------------------------------------------------------------------ #
# Table: Ortholog summary
#
# This script generates summary information for the ortholog detection results.

# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)
library(here)
library(magrittr)

# ------------------------------------------------------------------------------------------------ #
# Per species summary
per.species <- read_lines(
  file = here('orthologs', 'ortholog-detection', 'results', 'orthologs-correct', 'Comparative_Genomics_Statistics' ,'Statistics_PerSpecies.tsv'),
)

# Per species summary
df.per.species <- per.species[1:11] |>
  str_split('\t') |>
  reduce(rbind) |>
  as_tibble()

cnames <- df.per.species |> slice(1) |> unlist(use.names = FALSE)
cnames <- c('Measure', cnames[cnames != ''])
colnames(df.per.species) <- cnames
df.per.species |>
  slice(2:nrow(df.per.species)) |>
  pivot_longer(
    names_to = 'Samples',
    values_to = 'Values',
    2:14
  ) |>
  pivot_wider(names_from = Measure, values_from = Values) |>
  write_csv(
    file = here('figures','supplementary','table-x-orthologs-species.csv'),
    col_names = TRUE
  )

# ------------------------------------------------------------------------------------------------ #
# Overall summary
overall <- read_lines(
  file = here('orthologs', 'ortholog-detection', 'results', 'orthologs-correct', 'Comparative_Genomics_Statistics' ,'Statistics_Overall.tsv')
)

overall |>
  extract(1:18) |>
  str_split('\t') |>
  reduce(rbind) |>
  as_tibble() |>
  rename(Statistic= V1, Value = V2) |>
  write_csv(
    file = here('figures','supplementary','table-x-orthologs-statistics.csv'),
    col_names = TRUE
  )
