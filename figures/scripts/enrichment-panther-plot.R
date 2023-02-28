# ------------------------------------------------------------------------------------------------ #
# Plot: PANTHER 0-level enriched terms
#
# Plots the LFC of the most specific over-represented GO terms.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# Read in table
sig.panther <- read_csv(
  file = here('figures', 'supplementary', 'table-x-enrichment-panther.csv'),
  col_names = TRUE,
  col_types = cols()
)

# ------------------------------------------------------------------------------------------------ #
# Plot lfc on the x and term on the Y
ragg::agg_png(
  filename = here('figures', 'manuscript', 'figure-x-panther-enrichment.png'),
  width = 1000,
  height = 800,
  units = 'px'
)
sig.panther |>
  filter(level == 0) |>
  arrange(`Fold enrichment`) |>
  mutate(label = factor(label, levels = label)) |>
  ggplot(
    aes(
      x = `Fold enrichment`,
      y = label,
      # color = FDR,
      size = `Fold enrichment`
    )
  ) +
  geom_point(aes(fill = FDR), pch=21) +
  viridis::scale_fill_viridis() +
  facet_wrap(. ~ Ontology) +
  theme_bw() +
  theme(
    # axis titles
    axis.title.y = element_blank(),
    axis.title.x = element_text(size = 16, face = 'bold'),

    # Axis text
    axis.text = element_text(size = 14),

    # Strip text
    strip.text = element_text(size = 16, face = 'bold'),

    # Legend
    legend.title = element_text(size = 16, face = 'bold'),
    legend.text = element_text(size = 14)
  )
invisible(dev.off())
