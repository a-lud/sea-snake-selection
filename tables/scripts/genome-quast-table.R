# ------------------------------------------------------------------------------------------------ #
# Table: QUAST statistics
#
# This script generates the raw table of QUAST statistics that are to be included in the supp.
# material. NOTE that these tables may appear as standalone CSV files or in a larger Excel
# spreadsheet.

# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)
library(here)

# ------------------------------------------------------------------------------------------------ #
# QUAST tables
cnames <- c(
  'Assembly',
  '# contigs',
  'Total length',
  'Largest contig',
  'GC (%)',
  'N50',
  "# N's per 100 kbp"
)

quast.tibble <- fs::dir_ls(
  path = here('assembly'),
  glob = '*_report.tsv',
  recurse = TRUE
) %>%
  map(read_tsv, col_names = TRUE, col_types = cols(), col_select = all_of(cnames)) |>
  list_rbind() |>
  filter(!str_detect(Assembly, '_broken')) |>
  mutate(
    Assembly = case_when(
      Assembly == 'hydmaj_chromosome_p_ctg' ~ 'Hydrophis major',
      Assembly == 'hydmaj_hap1_v1' ~ 'Hydrophis major (haplotype 1)',
      Assembly == 'hydmaj_hap2_v1' ~ 'Hydrophis major (haplotype 2)',
      Assembly == 'hydrophis_curtus-AG' ~ 'Hydrophis curtus (AG)',
      Assembly == 'hydrophis_elegans' ~ 'Hydrophis elegans',
      Assembly == 'hydrophis_ornatus' ~ 'Hydrophis ornatus',
    ),
    Assembly = factor(Assembly, levels = c(
      'Hydrophis major', 'Hydrophis major (haplotype 1)', 'Hydrophis major (haplotype 2)',
      'Hydrophis ornatus', 'Hydrophis curtus (AG)', 'Hydrophis elegans')
    )
  ) |>
  rename(
    Sample = Assembly,
    Contigs = `# contigs`,
    `N's per 100kbp` = `# N's per 100 kbp`
  ) |>
  arrange(Sample)

# ------------------------------------------------------------------------------------------------ #
# Write table to file
quast.tibble |>
  write_csv(
    file = here('figures', 'supplementary', 'table-x-quast.csv'),
    col_names = TRUE
  )
