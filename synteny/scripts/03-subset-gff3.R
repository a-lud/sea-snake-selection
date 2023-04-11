# ------------------------------------------------------------------------------------------------ #
# Filter GFF3 files
#
# After renaming the genome files to have consisten chromosome ids, the corresponding GFF3 files
# need to be adapted to match the reference sequences. This script uses the same key-value table
# that was used to rename the FASTA files to rename the chromosome ids in the GFF3 files.

# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)
library(here)

# ------------------------------------------------------------------------------------------------ #
# Key-value tables
kv <- fs::dir_ls(
  path = here('synteny', 'data'),
  glob = "*.rename"
) |>
  as.character() |>
  (\(x) set_names(x, sub('.rename', '', basename(x))))() |>
  map(read_tsv, col_names = c('from', 'to'), col_types = cols())

# ------------------------------------------------------------------------------------------------ #
# GFF files
outdir <- here('synteny','results','clean-gff3')
fs::dir_create(path = outdir)

fs::dir_ls(
  path = here('data', 'gff3'),
  glob = "*gff3"
) |>
  as.character() |>
  (\(x) set_names(x, sub('.gff3', '', basename(x))))() |>
  magrittr::extract(names(kv)) |>
  map(read_tsv, col_names = FALSE, col_types = cols(), comment = '#') |>
  map2(.y = kv, \(g, k) {
    g |>
      left_join(k, by = join_by(X1 == from)) |>
      select(-X1) |>
      select(X1 = to, everything()) |>
      filter(!is.na(X1))
  }) |>
  iwalk(\(df, nm) {
    write_lines(
      '##gff-version 3',
      file = here(outdir, glue::glue("{nm}.gff3")),
    )

    df |>
      write_tsv(
        file = here(outdir, glue::glue("{nm}.gff3")),
        col_names = FALSE,
        append = TRUE
      )
  })

# ------------------------------------------------------------------------------------------------ #
# Subset the H. major and H. elegans annotation files (not renamed but subseq)
hmaj <- read_tsv(
  file = here('data/gff3/hydrophis_major.gff3'),
  col_names = FALSE,
  col_types = cols(),
  comment = '#'
) |>
  filter(str_detect(X1, 'chr'))

write_lines('##gff-version 3', here(outdir, 'hydrophis_major.gff3'))
write_tsv(hmaj, file = here(outdir, 'hydrophis_major.gff3'), col_names = FALSE, append = TRUE)

hele <- read_tsv(
  file = here('data/gff3/hydrophis_elegans.gff3'),
  col_names = FALSE,
  col_types = cols(),
  comment = '#'
) |>
  filter(X1 %in% paste0(rep('contig_', 100), 1:100))

write_lines('##gff-version 3', here(outdir, 'hydrophis_elegans.gff3'))
write_tsv(hele, file = here(outdir, 'hydrophis_elegans.gff3'), col_names = FALSE, append = TRUE)
