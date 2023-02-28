# ------------------------------------------------------------------------------------------------ #
# Ortholog annotation summary
#
# Get some basic annotation information about the annotated single-copy orthologs.

# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)

# ------------------------------------------------------------------------------------------------ #
# Annotation file
anno <- read_csv(file = 'orthologs/ortholog-annotation/results/ortholog-annotation/orthologs-13.csv')

# 7820 orthologs with one gene symbol assigned
orth.single.name <- anno %>%
  filter(!is.na(symbol)) |>
  filter(!str_detect(symbol, ' ')) |>
  nrow()

# 22 genes with single annotations after removing CUNH/C...H...ORF... annotations junk
# Add this to total
orth.single.name.cleaned <- anno %>%
  filter(!is.na(symbol)) %>%
  filter(str_detect(symbol, ' ')) |>
  filter(str_detect(symbol, 'CUNH|ORF')) |>
  # Some of the annotations are these locus tags that aren't super helpful.
  mutate(
    symbol = sub('CUNH.+ | CUNH.+', '', symbol),
    symbol = sub('C\\d+H\\d+ORF\\d+|CZH\\d+ORF\\d+|C\\d+HXORF\\d+', '', symbol)
  ) |>
  filter(symbol != '') |>
  nrow()

# 111 genes with two annotations
ortho.two.name <- anno %>%
  filter(!is.na(symbol)) %>%
  filter(str_detect(symbol, ' ')) |>
  filter(!str_detect(symbol, 'CUNH|ORF')) |>
  nrow()

# 95 genes whose annotations are actually just loci names (CHUN/C..H...ORF...)
orth.no.name.after.cleaning <- anno %>%
  filter(!is.na(symbol)) %>%
  filter(str_detect(symbol, ' ')) |>
  filter(str_detect(symbol, 'CUNH|ORF')) |>
  mutate(
    symbol = sub('CUNH.+ | CUNH.+', '', symbol),
    symbol = sub('C\\d+H\\d+ORF\\d+|CZH\\d+ORF\\d+|C\\d+HXORF\\d+', '', symbol)
  ) |>
  filter(symbol == '') |>
  nrow()

# 620 orthologs with no annotation
orth.no.name <- anno %>%
  filter(is.na(symbol)) |>
  nrow()

# ------------------------------------------------------------------------------------------------ #
# Totals
orth.single.name + orth.single.name.cleaned + ortho.two.name # 7953 = some form of annotation
orth.single.name + orth.single.name.cleaned # 7842 = Single gene symbol assigned
ortho.two.name # 111 = orthoglogs with two symbols assigned
orth.no.name.after.cleaning + orth.no.name # 715 = orthologs with no gene symbol
orth.single.name + orth.single.name.cleaned + ortho.two.name + orth.no.name.after.cleaning + orth.no.name # 8668 = Total number of orthologs
