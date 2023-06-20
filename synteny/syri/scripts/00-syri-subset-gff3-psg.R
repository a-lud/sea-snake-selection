# ------------------------------------------------------------------------------------------------ #
# PSG locations in H. ornatus (edits for Syri/PlotSR)
#
# Gene sequences from H. ornatus were lifted over to the edited H. ornatus genome used for syri
# (chromosomes have been merged to be consistent across all snakes). This script extracts the
# marine-PSGs from the GFF3 file and writes a new one with ONLY the PSGs in it.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(here)
  library(tidyverse)
})

# ------------------------------------------------------------------------------------------------ #
# Data
psgs <- read_lines(here('selection','results','results-PSGs','PSGs-marine.txt'))
orthogroups <- read_tsv(
  here('orthologs','ortholog-detection','results','orthologs','Orthogroups','Orthogroups.tsv'),
  col_names = TRUE,
  col_types = cols()
) |>
  filter(Orthogroup %in% psgs) |>
  pull('hydrophis_ornatus') |>
  (\(x) sub('-T.*', '', x))()

read_tsv(
  here('synteny', 'syri', 'results','gffs-syri','hydrophis_ornatus-syri.gff3'),
  col_names = FALSE,
  col_types = cols(),
  comment = '#'
) |>
  mutate(
    ID = sub(';.*', '', X9),
    ID = sub('ID=', '', ID),
    ID = str_remove(ID, '-T.*')
  ) |>
  filter(ID %in% orthogroups) |>
  select(-ID) |>
  write_tsv(
    file = here('synteny','syri', 'results', 'gffs-syri','hydrophis_ornatus-psgs-syri.gff3'),
    col_names = FALSE
  )
