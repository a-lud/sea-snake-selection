# ------------------------------------------------------------------------------------------------ #
# Selection intensity results (adapted from 06-selection-intensity.R in selection directory)
#
# Plot the interactions between the RELAX results and marine-specific PSGs. Aim is to understand
# how the selective strengths of marine-PSGs vary.
#
# All significance results have used a FDR (BH) correction to correct for multiple testing,
# along with an adjusted pvalue threshold of p <= 0.01.
# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(ComplexUpset)
  library(tidyverse)
  library(here)
  library(patchwork)
})

# ------------------------------------------------------------------------------------------------ #
# Import PSGs + insignificant orthogroups + RELAX results

# PSGs/insignificant genes
psg.marine <- read_lines(here('selection','results','results-PSGs','PSGs-marine.txt'))
psg.terrestrial <- read_lines(here('selection','results','results-PSGs','PSGs-terrestrial.txt'))
psg.shared <- read_lines(here('selection','results','results-PSGs','PSGs-shared.txt'))
neutral.genes <- read_lines(here('selection','results','results-PSGs','neutral-genes.txt'))

# Relaxation results: signif (relaxation/intensification) or insignif
relax <- read_csv(
  file = here('selection','results','results-tables','relax-corrected.csv'),
  col_names = TRUE,
  col_types = cols()
)

# Significant + intensification (K > 1) # 1677 at p-adj <= 0.01
relax.sig.intense <- relax |>
  filter(signif == 'Significant', grouping == 'Intensification') |>
  pull(orthogroup)

# Significant + relaxation (K < 1) # 442 at p-adj <= 0.01
relax.sig.relax <- relax |>
  filter(signif == 'Significant', grouping == 'Relaxation') |>
  pull(orthogroup)

# Inisignificant # 6532 at p-adj >= 0.01
relax.insignif <- relax |>
  filter(signif == 'Insignificant') |>
  pull(orthogroup)

# Number of orthogroups accounted for = 8651
sum(unlist(map(list(relax.sig.intense, relax.sig.relax, relax.insignif), length)))

# ------------------------------------------------------------------------------------------------ #
# Upset plot:
# UpSet plots are a great method for visualising overlaps between datasets. Here, I use an UpSet
# plot to examine the overlap between the genes identified as positively selected in Hydrophis
# and genes identified as being under significant intensification/relaxation of selection.
# of the
all.orthologs <-c(psg.marine, psg.shared, psg.terrestrial, neutral.genes)

input <- tibble(
  orthogroups = all.orthologs,
) |>
  mutate(
    # Positively selected genes
    PSG = orthogroups %in% psg.marine,

    # RELAX results
    Intensification = orthogroups %in% relax.sig.intense,
    Relaxation = orthogroups %in% relax.sig.relax,
    Insignificant = orthogroups %in% relax.insignif,

    # Classify orthogroups that are shared/psgs in terrestrial
    grouping = case_when(
      orthogroups %in% psg.shared ~ 'Shared',
      orthogroups %in% psg.terrestrial ~ 'Terrestrial',
      TRUE ~ NA_character_
    )
  )

# Save UpSet plot
# ragg::agg_png(
#   filename = here('figures', 'manuscript', 'figure-x-upset.png'),
#   width = 2000,
#   height = 500,
#   units = 'px',
#   # scaling = 0.8
# )
grDevices::cairo_pdf(
  filename = here('figures','manuscript','upset.pdf'),
  height = 10,
  width = 15
)
upset(
  # General parameters
  input,
  c('Insignificant', 'Intensification', 'Relaxation', 'PSG'),
  name = 'Gene set intersections',
  # group_by = 'sets',
  stripes = 'white',
  sort_sets = FALSE,

  # Height/Width ratios between components
  min_size = 10,
  width_ratio=0.5,
  # height_ratio = 0.7,

  # Intersection matrix
  matrix = (
    intersection_matrix(
      geom = geom_point(size = 5),
      segment = geom_segment(
        linewidth = 1.5,
        # linetype = 'dotted'
      ),
      outline_color = list(
        active = 'black',
        inactive = 'grey90'
      )
    )
  ),

  # Manually set intersections
  intersections = list(
    c('PSG', 'Relaxation'),
    c('PSG', 'Intensification'),
    c('PSG', 'Insignificant'),
    'Relaxation',
    'Intensification',
    'Insignificant'
  ),

  # Intersection size bar plot
  base_annotations = list(
    'Intersection size' = intersection_size(
      fill = 'grey80',
      colour = 'black',
      counts = TRUE,
      text = list(size = 6, fontface = 'bold', vjust = -0.8))
  ),

  # Parameters: Set
  set_sizes = upset_set_size(
    geom = geom_bar(
      colour = 'black',
      width = 0.8,
      alpha = 0.7
    ),
  ) +
    ylab('Gene set sizes') +
    geom_text(
      aes(label = after_stat(count)),
      colour = 'white',
      fontface = 'bold',
      hjust = 1.2,
      stat = 'count',
      size = 7,
      position=position_stack(vjust=1)
    ),

  # Colour grouped sets
  queries = list(
    # Colour 'set size' bars
    upset_query(set = 'PSG', fill = '#4eaf49'),
    upset_query(set = 'Intensification', fill = '#fb807280'),
    upset_query(set = 'Relaxation', fill = '#80b1d380'),
    upset_query(set = 'Insignificant', fill = '#22333b80'),

    # Colour circles in matrix
    upset_query(intersect = c('PSG', 'Relaxation'), color = '#4eaf49'),
    upset_query(intersect = c('PSG', 'Intensification'), color = '#4eaf49'),
    upset_query(intersect = c('PSG', 'Insignificant'), color = '#4eaf49'),
    upset_query(intersect = 'Relaxation', color = '#80b1d3'),
    upset_query(intersect = 'Intensification', color = '#fb8072'),
    upset_query(intersect = 'Insignificant', color = '#22333b')
  ),

  # Parameters: Intersection bar-plot (top)
  sort_intersections_by=c('degree'),

  # Themes: Adjust for each plot component
  themes = upset_modify_themes(
    list(
      'Intersection size' = theme(
        axis.text = element_text(size = 22),
        axis.title = element_text(size = 25, face = 'bold')
      ),
      'intersections_matrix' = theme(
        axis.title = element_text(size = 25, face = 'bold'),
        axis.text = element_text(size = 22)
      ),
      'overall_sizes' = theme(
        axis.title = element_text(size = 25, face = 'bold'),
        axis.text.x = element_text(size = 22, angle = 45, vjust = 0.5)
      )
    )
  )
)
invisible(dev.off())
