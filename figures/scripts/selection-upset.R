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
    MarinePSG = orthogroups %in% psg.marine,

    # RELAX results
    Intensification = orthogroups %in% relax.sig.intense,
    Relaxation = orthogroups %in% relax.sig.relax,
    RelaxInsignificant = orthogroups %in% relax.insignif,

    # Classify orthogroups that are shared/psgs in terrestrial
    grouping = case_when(
      orthogroups %in% psg.shared ~ 'Shared',
      orthogroups %in% psg.terrestrial ~ 'Terrestrial',
      TRUE ~ NA_character_
    )
  )

# Save UpSet plot
ragg::agg_png(
  filename = here('figures', 'manuscript', 'figure-x-upset.png'),
  width = 1000,
  height = 1000,
  units = 'px',
  # scaling = 144
)
upset(
  # General parameters
  input,
  c('RelaxInsignificant', 'Intensification', 'Relaxation', 'MarinePSG'),
  name = 'Gene set intersections',
  min_size = 10,
  group_by = 'sets',
  stripes = 'white',
  sort_sets = FALSE,

  # Height/Width ratios between components
  width_ratio=0.2,
  height_ratio = 0.7,

  # Intersection matrix
  matrix = (
    intersection_matrix(
      geom = geom_point(size = 5),
      segment = geom_segment(
        linewidth = 1.5,
        linetype = 'dotted'
      ),
      outline_color = list(
        active = 'black',
        inactive = 'grey90'
      )
    )
  ),

  # Parameters: Set
  set_sizes = upset_set_size(
    geom = geom_bar(
      colour = 'black',
      # width = 0.8,
      alpha = 0.7
    )
  ),

  # Colour grouped sets
  queries = list(
    # Colour 'set size' bars
    upset_query(set = 'MarinePSG', fill = '#277da1'),
    upset_query(set = 'Intensification', fill = '#dc2f02'),
    upset_query(set = 'Relaxation', fill = '#00a896'),
    upset_query(set = 'RelaxInsignificant', fill = '#22333b'),

    # Colour circles in matrix
    upset_query(group = 'MarinePSG', color = '#277da1'),
    upset_query(group = 'Intensification', color = '#dc2f02'),
    upset_query(group = 'Relaxation', color = '#00a896'),
    upset_query(group = 'RelaxInsignificant', color = '#22333b')
  ),

  # Parameters: Intersection bar-plot (top)
  sort_intersections_by=c('degree'),

  base_annotations = list(
    'Intersection size' = intersection_size(
      color = 'black',
      counts = TRUE,
      alpha = 0.7,
      mapping = aes(fill = grouping)
    ) +
      scale_fill_manual(
        values = c(
          'Shared' = '#2a9d8f',
          'Terrestrial' = '#ffb703'
        )
      ) +
      labs(
        fill = 'PSG sets'
      )
  ),

  # Themes: Adjust for each plot component
  themes = upset_modify_themes(
    list(
      'Intersection size' = theme(
        axis.text = element_text(size = 14),
        axis.title = element_text(size = 20, face = 'bold'),
        legend.title = element_text(size = 16, face = 'bold'),
        legend.text = element_text(size = 14)
      ),
      'intersections_matrix' = theme(
        axis.title = element_text(size = 18, face = 'bold'),
        axis.text = element_text(size = 14)
      ),
      'overall_sizes' = theme(
        axis.title = element_text(size = 18, face = 'bold'),
        axis.text.x = element_text(size = 14, angle = 45)
      )
    )
  )
)
dev.off()

# ------------------------------------------------------------------------------------------------ #
# Get GO terms for the 20 relaxed marine-PSGs
# read_csv(
#   file = here('orthologs/ortholog-annotation/results/ortholog-annotation/orthologs-13.csv'),
#   col_names = TRUE,
#   col_types = cols()
# ) |>
#   filter(orthogroup %in% (relax.sig.relax[relax.sig.relax %in% psg.marine]))|>
#   pull(GO) |>
#   str_split(' ') |>
#   unlist() |>
#   unique() |>
#   write_lines(here('selection/'))
#
# options(scipen = 999)
# relax |>
#   filter(orthogroup %in% relax.sig.relax[relax.sig.relax %in% psg.marine]) |>View()
