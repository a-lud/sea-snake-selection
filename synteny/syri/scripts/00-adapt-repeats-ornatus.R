# ------------------------------------------------------------------------------------------------ #
# Prep H. ornatus repeat sequences for Syri plotting
#
# This script modifies the H. ornatus RepeatMasker repeat annotation file to match the H. ornatus
# reference file used in the Syri analysis. This involves renaming chr14 to chr6 and chr15 to chrZ.
# Further, the repeats on chr14 and chrZ need to be offset, as they are appended to their respective
# match. This is done by adding the length of their respective chromsome + 10Kbp to account for the
# inserted N's beteween concatenated sequences.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# FAI and repeat file
fai <- read_tsv(
  here('synteny','syri','repeats','hydrophis_ornatus.fa.fai'),
  col_names = FALSE,
  col_types = cols(),
  col_select = 1:2
)

gff <- read_tsv(
  file = here('synteny','syri','repeats','hydrophis_ornatus.fa.out.gff'),
  comment = '#',
  col_names = FALSE,
  col_types = cols()
)

# ------------------------------------------------------------------------------------------------ #
# Clean GFF3 file seqids to match syri genome identifiers (i.e. add chr prefix)
gff <- gff |>
  filter(X1 %in% paste0(rep('HiC_scaffold_', 15), 1:16)) |>
  mutate(
    X1 = str_replace(X1, 'HiC_scaffold_', ''),
    X1 = as.numeric(X1)
  )

# Z chromosome
gff.z <- gff |>
  filter(X1 == 5) |>
  mutate(X1 = 'chrZ')

# Clean up autosomes
gff <- gff |>
  filter(X1 != 5) |>
  mutate(X1 = ifelse(X1 > 5, X1 - 1, X1)) |>
  arrange(X1) |>
  mutate(X1 = paste0('chr', X1)) |>
  bind_rows(gff.z)

# ------------------------------------------------------------------------------------------------ #
# Edit chromosomes to match fused chromsomes

# Chr6 + chr14 = chr14 -> chr6 (offset chr14 by length of chr6)
chr6.offset <- fai |> filter(X1 == 'chr6') |> pull(X2) + 10000; # Length of chr6 + 10Kbp of N's appended to end
chr14.to.chr6 <- gff |>
  filter(X1 == 'chr14') |>
  mutate(
    X4 = X4 + chr6.offset,
    X5 = X5 + chr6.offset,
    X1 = 'chr6'
  )

# Chr15 + chrZ = chr15 -> chrZ (offset chrZ by length of chr15)
chrZ.offset <- fai |> filter(X1 == 'chr15') |> pull(X2) + 10000
gff.chrz <- gff |>
  filter(X1 == 'chrZ') |>
  mutate(
    X4 = X4 + chrZ.offset,
    X5 = X5 + chrZ.offset
  )
gff.chr15 <- gff |>
  filter(X1 == 'chr15') |>
  mutate(X1 = 'chrZ')
chr15.to.chrZ <- gff.chr15 |>
  bind_rows(gff.chrz)

# ------------------------------------------------------------------------------------------------ #
# Bind adjusted chromsomes back to rest of GFF (removing the original chr14, chr15 and chrZ)
#   - each of these sequences had their atributes changed in some way - either name or length
gff.syri <- gff |>
  filter(! X1 %in% c('chr14', 'chr15', 'chrZ')) |>
  bind_rows(chr14.to.chr6, chr15.to.chrZ) |>
  mutate(
    X1 = factor(X1, levels = c(paste0(rep('chr', 13), 1:13), 'chrZ'))
  ) |>
  arrange(X1) |>
  mutate(X1 = as.character(X1))

# ------------------------------------------------------------------------------------------------ #
# Sanity checks: repeat positions on chr6 and chrZ don't exceed total possible length
#   - chr6 = len(chr6) + len(chr14) + 10000 = 106426777
#   - chrZ = len(chr15) + len(chrZ) + 10000 = 185574492
chr6.new.len <- fai |> filter(X1 %in% c('chr6', 'chr14')) |> pull(X2) |> sum() + 10000
chrZ.new.len <- fai |> filter(X1 %in% c('chr15', 'chrZ')) |> pull(X2) |> sum() + 10000

gff.syri |>
  filter(X1 == 'chr6') |>
  pull(X5) |>
  max() < chr6.new.len

gff.syri |>
  filter(X1 == 'chrZ') |>
  pull(X5) |>
  max() < chrZ.new.len

# ------------------------------------------------------------------------------------------------ #
# Collapse overlapping repeats
gff.syri.bed <- gff.syri |>
  select(
    chr = X1, start = X4, end = X5, strand = X7
  ) |>
  GenomicRanges::makeGRangesFromDataFrame(keep.extra.columns = TRUE) |>
  plyranges::reduce_ranges() |>
  as_tibble()

# ------------------------------------------------------------------------------------------------ #
# Write to file
gff.syri.bed |>
  select(-width) |>
  mutate(
    X2 = 'RepeatMasker',
    X3 = 'mrna',
    X6 = '.',
    X8 = '.',
    X9 = 'ID=placeholder'
  ) |>
  select(seqnames, X2, X3, start, end, X6, strand, X8, X9) |>
  write_tsv(
    file = here('synteny/syri/repeats/hydrophis_ornatus-garvin.syri.repeats.gff3'),
    quote = 'none', col_names = FALSE
  )

gff.syri.bed |>
  select(-width, -strand) |>
  write_tsv(
    file = here('synteny', 'syri', 'repeats', 'hydrophis_ornatus-garvin.syri.repeats.bed'),
    col_names = FALSE
  )
