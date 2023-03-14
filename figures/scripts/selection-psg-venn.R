# ------------------------------------------------------------------------------------------------ #
# Plot: Venn Diagram of PAML/BUSTED-PH overlap
#
# Plots the overlap between PSGs reported in BUSTED-PH and PAML

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(ggvenn)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# Read in PAML/BUSTED-PH PSGs
paml <- read_csv(
  file = here('figures','supplementary','table-x-selection-paml-LRT-dropout.csv'),
  col_names = TRUE,
  col_types = cols()
)

bustedph <- read_csv(
  file = here('figures','supplementary','table-x-selection-bustedph-LRT.csv'),
  col_names = TRUE,
  col_types = cols()
)

# ------------------------------------------------------------------------------------------------ #
# Gene sets
all.genes <- paml$Orthogroup
paml.sig.genes <- paml |> filter(Signal == 'PS_fg') |> pull(Orthogroup)
bustedph.sig.genes <- bustedph |> filter(str_detect(Signal, 'Selection associated with trait')) |> pull(Orthogroup)

# ------------------------------------------------------------------------------------------------ #
# Venn diagram
venn.list <- list(
  # 'All orthogroups' = all.genes,
  'PAML' = paml.sig.genes,
  'BUSTED-PH' = bustedph.sig.genes
)

ragg::agg_png(
  filename = here('figures','supplementary','figure-x-selection-venn.png'),
  width = 800,
  height = 800,
  units = 'px'
)
ggvenn::ggvenn(
  data = venn.list,
  fill_color = c('#66c2a5', '#fc8d62'),
  fill_alpha = 0.6,
  stroke_size = 1,
  set_name_size = 8,
  text_size = 7
)
invisible(dev.off())
