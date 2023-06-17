# ------------------------------------------------------------------------------------------------ #
# Difference in repeat content
#
# This script identifies repeat elements that are unique to RepeatMasker (EDTA + RepBase) relative
# to the purely EDTA results (no RepBase). The intersect between the RepeatMasker and EDTA results
# are taken, with non-overlapping regions being returned. These regions are then summarised by their
# broad familial grouping.
#
# The ouput table is simply the species as columns, the repeat families as rows and the total length
# and counts (in brackets) as values.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
  library(fs)
})

# ------------------------------------------------------------------------------------------------ #
# Data

# FASTA index files
df.fai <- dir_ls(
  path = here('data','genomes'),
  glob = '*.fai'
) |>
  as.character() |>
  (\(x) set_names(x, sub('\\..*|-garvin.*', '', basename(x))))() |>
  map(read_tsv, col_names = c('seqnames', 'length'), col_types = cols(), col_select = 1:2)

# RM annotations
gff.rm <- dir_ls(
  path = here('assembly'),
  glob = '*.simplified',
  recurse = TRUE
) |>
  as.character() |>
  (\(x) set_names(x, sub('\\..*|-garvin.*', '', basename(x))))() |>
  map(\(x) {
    x |>
      read_delim(
        col_names = c('div', 'chr', 'start', 'end', 'type', 'family'),
        col_types = cols(),
        skip = 3
      ) |>
      GenomicRanges::makeGRangesFromDataFrame(keep.extra.columns = TRUE)
  })

# EDTA GFF3 files
gff.edta <- dir_ls(
  path = here('assembly'),
  glob = '*.TEanno.gff3.gz',
  recurse = TRUE
) |>
  as.character() |>
  (\(x) set_names(x, sub('\\..*|-garvin.*', '', basename(x))))() |>
  (\(x) x[names(x) != 'aipysurus_laevis'])() |>
  imap( \(x, y) {
    df <- vroom(
      x,
      col_names = FALSE,
      col_types = cols(),
      delim = '\t',
      comment = '#',
      col_select = c(1,4,5,3)
    ) |>
      rename(chr = X1, start = X4, end = X5, type = X3)

    if (y %in% c('hydrophis_curtus', 'hydrophis_ornatus')) {
      df <- df |>
        mutate(chr = paste0('HiC_scaffold_', chr))
    }
    GenomicRanges::makeGRangesFromDataFrame(df, keep.extra.columns = TRUE)
  })

names(gff.edta) <- c('hydrophis_major', "hydrophis_curtus","hydrophis_elegans","hydrophis_ornatus")

# ------------------------------------------------------------------------------------------------ #
# Regions in RM that don't overlap with EDTA output
df.rm.unique <- map2(gff.rm, gff.edta, \(rm, edta) {
  plyranges::filter_by_non_overlaps(rm, edta, maxgap = 10) |>
    as.data.frame() |>
    as_tibble()
}) |>
  map(mutate, sub_family = str_remove(family, '.*/'), family = str_remove(family, '/.*')) |>
  list_rbind(names_to = 'sample') |>
  group_by(sample, family) |>
  summarise(
    family_length = sum(width),
    family_count = n()
  ) |>
  arrange(sample, -family_length)

# ------------------------------------------------------------------------------------------------ #
# Output: Summary table of unmatched repeat elements - length (count)
df.rm.unique |>
  mutate(family_count = paste0('(', family_count, ')')) |>
  unite(col = 'length_count', sep = ' ', family_length, family_count) |>
  pivot_wider(names_from = sample, values_from = length_count) |>
  write_csv(
    file = here('figures','supplementary','table-x-repeats-rm-unique.csv'),
    col_names = TRUE,
    na = ''
  )
