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
  file = here('tables', 'table-x-enrichment-panther.csv'),
  col_names = TRUE,
  col_types = cols()
)

# ------------------------------------------------------------------------------------------------ #
# Plot lfc on the x and term on the Y
# ragg::agg_png(
#   filename = here('figures', 'supplementary', 'figure-x-panther-enrichment.png'),
#   width = 1200,
#   height = 1000,
#   units = 'px'
# )
grDevices::cairo_pdf(
  filename = here('figures','supplementary','figure-x-panther-lfc.pdf'),
  width = 20,
  height = 20,
)
sig.panther |>
  filter(level == 0) |>
  arrange(`Fold enrichment`) |>
  mutate(
    label = str_to_sentence(label),
    label = str_replace(label, 'Trna', 'tRNA'),
    label = str_replace(label, 'Rna', 'RNA'),
    label = factor(label, levels = label)
  ) |>
  ggplot(
    aes(
      x = `Fold enrichment`,
      y = label,
      size = `Fold enrichment`
    )
  ) +
  geom_point(aes(fill = FDR), pch=21) +
  scale_size("size_area", range = c(4, 16)) +
  viridis::scale_fill_viridis() +
  labs(
    x = '\nFold enrichment'
  ) +
  facet_wrap(. ~ Ontology) +
  theme_bw() +
  theme(
    # axis titles
    axis.title.y = element_blank(),
    axis.title.x = element_text(size = 20, face = 'bold'),

    # Axis text
    axis.text = element_text(size = 18),

    # Strip text
    strip.text = element_text(size = 20, face = 'bold'),

    # Legend
    legend.title = element_text(size = 20, face = 'bold'),
    legend.text = element_text(size = 18),
    legend.position = 'bottom',
    legend.key.width = unit(2, 'cm')
  ) +
  guides(
    fill = guide_colourbar(title.position="top", title.hjust = 0.5),
    size = guide_legend(title.position="top", title.hjust = 0.5)
  )
invisible(dev.off())
