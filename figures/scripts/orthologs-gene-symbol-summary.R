# ------------------------------------------------------------------------------------------------ #
# Ortholog annotation summary
#
# Get some basic annotation information about the annotated single-copy orthologs.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# Annotation file
anno <- read_csv(
  file = here('orthologs','ortholog-annotation','results','ortholog-annotation','orthologs.csv'),
  col_names = TRUE,
  col_types = cols()
)

# 7812 orthologs with one gene symbol assigned
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

# 108 genes with two annotations
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

# 617 orthologs with no annotation
orth.no.name <- anno %>%
  filter(is.na(symbol)) |>
  nrow()

# ------------------------------------------------------------------------------------------------ #
# Totals
orth.single.name + orth.single.name.cleaned + ortho.two.name # 7942 = some form of annotation
orth.single.name + orth.single.name.cleaned # 7834 = Single gene symbol assigned
ortho.two.name # 108 = orthoglogs with two symbols assigned
orth.no.name.after.cleaning + orth.no.name # 712 = orthologs with no gene symbol
orth.single.name + orth.single.name.cleaned + ortho.two.name + orth.no.name.after.cleaning + orth.no.name # 8654 = Total number of orthologs
