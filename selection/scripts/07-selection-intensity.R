# ------------------------------------------------------------------------------------------------ #
# Selection intensity results
#
# This script explores the RELAX results for the 13-sample dataset. The main aims of this script:
#   - Explore the relationship between Hydrophis-PSGs, Terrestrial-PSGs and shared-PSGs and their
#     level of selection intensity.
#
# All significance results have used a FDR (BH) correction to correct for multiple testing,
# along with an adjusted pvalue threshold of p <= 0.01.
# ------------------------------------------------------------------------------------------------ #
# Libraries
library(ComplexUpset)
library(tidyverse)
library(here)
library(patchwork)

# ------------------------------------------------------------------------------------------------ #
# Output directory
outdir <- here('selection','results','results-selection-intensification')
fs::dir_create(path = outdir)

# ------------------------------------------------------------------------------------------------ #
# Import PSGs + insignificant orthogroups + RELAX results

# PSGs/insignificant genes
psg.marine <- read_lines(here('selection','results','results-PSGs','PSGs-marine.txt'))
psg.terrestrial <- read_lines(here('selection','results','results-PSGs','PSGs-terrestrial.txt'))
psg.shared <- read_lines(here('selection','results','results-PSGs','PSGs-shared.txt'))
neutral.genes <- read_lines(here('selection','results','results-PSGs','neutral-genes.txt'))

# Relaxation results: signif (relaxation/intensification)/insignif
relax <- read_csv(
  file = here('selection','results','results-PSGs','relax-corrected.csv'),
  col_names = TRUE,
  col_types = cols()
)

# Significant + intensification (K > 1) # 1663 at p-adj <= 0.01
relax.sig.intense <- relax |>
  filter(signif == 'Significant', grouping == 'Intensification') |>
  pull(orthogroup)

# Significant + relaxation (K < 1) # 443 at p-adj <= 0.01
relax.sig.relax <- relax |>
  filter(signif == 'Significant', grouping == 'Relaxation') |>
  pull(orthogroup)

# Inisignificant # 6546 at p-adj >= 0.01
relax.insignif <- relax |>
  filter(signif == 'Insignificant') |>
  pull(orthogroup)

# Number of orthogroups accounted for = 8652 (3 are known to have failed)
sum(unlist(map(list(relax.sig.intense, relax.sig.relax, relax.insignif), length)))

# ------------------------------------------------------------------------------------------------ #
# Write PSG experiencing significant intersections/relaxation (RELAX) to file
psg.marine[psg.marine %in% relax.sig.intense] |> write_lines(file = here(outdir, 'psg-marine-intensification.txt'))
psg.marine[psg.marine %in% relax.sig.relax] |> write_lines(file = here(outdir, 'psg-marine-relaxation.txt'))

# ------------------------------------------------------------------------------------------------ #
# Upset plot:
# UpSet plots are a great method for visualising overlaps between datasets. Here, I use an UpSet
# plot to examine the overlap between the genes identified as positively selected in Hydrophis
# and genes identified as being under significant intensification/relaxation of selection.
# of the
# all.orthologs <-c(psg.marine, psg.shared, psg.terrestrial, neutral.genes)
#
# input <- tibble(
#   orthogroups = all.orthologs,
# ) |>
#   mutate(
#     # Positively selected genes
#     MarinePSG = orthogroups %in% psg.marine,
#
#     # RELAX results
#     Intensification = orthogroups %in% relax.sig.intense,
#     Relaxation = orthogroups %in% relax.sig.relax,
#     RelaxInsignificant = orthogroups %in% relax.insignif,
#
#     # Classify orthogroups that are shared/psgs in terrestrial
#     grouping = case_when(
#       orthogroups %in% psg.shared ~ 'Shared',
#       orthogroups %in% psg.terrestrial ~ 'Terrestrial',
#       TRUE ~ NA_character_
#     )
#   )
#
# # Save UpSet plot
# ragg::agg_png(
#   filename = here('selection','results-13','results-selection-intensification','upset.png'),
#   width = 1000,
#   height = 1000,
#   units = 'px',
#   # scaling = 144
# )
# upset(
#   # General parameters
#   input,
#   c('RelaxInsignificant', 'Intensification', 'Relaxation', 'MarinePSG'),
#   name = 'Gene set intersections',
#   min_size = 10,
#   group_by = 'sets',
#   stripes = 'white',
#   sort_sets = FALSE,
#
#   # Height/Width ratios between components
#   width_ratio=0.2,
#   height_ratio = 0.7,
#
#   # Intersection matrix
#   matrix = (
#     intersection_matrix(
#       geom = geom_point(size = 5),
#       segment = geom_segment(
#         linewidth = 1.5,
#         linetype = 'dotted'
#       ),
#       outline_color = list(
#         active = 'black',
#         inactive = 'grey90'
#       )
#     )
#   ),
#
#   # Parameters: Set
#   set_sizes = upset_set_size(
#     geom = geom_bar(
#       colour = 'black',
#       # width = 0.8,
#       alpha = 0.7
#     )
#   ),
#
#   # Colour grouped sets
#   queries = list(
#     # Colour 'set size' bars
#     upset_query(set = 'MarinePSG', fill = '#277da1'),
#     upset_query(set = 'Intensification', fill = '#dc2f02'),
#     upset_query(set = 'Relaxation', fill = '#00a896'),
#     upset_query(set = 'RelaxInsignificant', fill = '#22333b'),
#
#     # Colour circles in matrix
#     upset_query(group = 'MarinePSG', color = '#277da1'),
#     upset_query(group = 'Intensification', color = '#dc2f02'),
#     upset_query(group = 'Relaxation', color = '#00a896'),
#     upset_query(group = 'RelaxInsignificant', color = '#22333b')
#   ),
#
#   # Parameters: Intersection bar-plot (top)
#   sort_intersections_by=c('degree'),
#
#   base_annotations = list(
#     'Intersection size' = intersection_size(
#       color = 'black',
#       counts = TRUE,
#       alpha = 0.7,
#       mapping = aes(fill = grouping)
#     ) +
#       scale_fill_manual(
#         values = c(
#           'Shared' = '#2a9d8f',
#           'Terrestrial' = '#ffb703'
#         )
#       ) +
#       labs(
#         fill = 'PSG sets'
#       )
#   ),
#
#   # Themes: Adjust for each plot component
#   themes = upset_modify_themes(
#     list(
#       'Intersection size' = theme(
#         axis.text = element_text(size = 14),
#         axis.title = element_text(size = 20, face = 'bold'),
#         legend.title = element_text(size = 16, face = 'bold'),
#         legend.text = element_text(size = 14)
#       ),
#       'intersections_matrix' = theme(
#         axis.title = element_text(size = 18, face = 'bold'),
#         axis.text = element_text(size = 14)
#       ),
#       'overall_sizes' = theme(
#         axis.title = element_text(size = 18, face = 'bold'),
#         axis.text.x = element_text(size = 14, angle = 45)
#       )
#     )
#   )
# )
# dev.off()

# ------------------------------------------------------------------------------------------------ #
# BUSTED-PH: dN/dS ratios for groups in tree (MG94xRev)
#
# Aim is to explore the MG94xRev dN/dS ratios with respect to the PSG sets, along with the
# RELAX results. Importantly, the RELAX results must be interpreted with respect to

# mg94.bustedph <- read_rds(here('selection','r-data','busted-ph.rds')) |>
#   pluck('fits') |>
#   pluck('mg94') |>
#   pluck('mg94') |>
#   mutate(file = str_remove(file, '.clean'))
#
# mg94.bustedph |>
#   mutate(
#     # Clean up 'branch' column
#     branch = str_replace(branch, 'test', 'Test (Marine)'),
#     branch = str_replace(branch, 'background', 'Background (Terrestrial)'),
#
#     # Groupings
#     condition = case_when(
#       file %in% relax.insignif ~ 'RELAX Insignificant (Test = Marine)',
#       file %in% relax.sig.intense ~ 'RELAX Intensification (Test = Marine)',
#       file %in% relax.sig.relax ~ 'RELAX Relaxation (Test = Marine)'
#     ),
#     psgSet = case_when(
#       file %in% psg.marine ~ 'Marine PSG',
#       file %in% psg.shared ~ 'Shared PSG',
#       file %in% psg.terrestrial ~ 'Terrestrial PSG',
#       file %in% neutral.genes ~ 'Neutral'
#     ),
#
#     # Order
#     psgSet = factor(psgSet, levels = c('Marine PSG', 'Shared PSG', 'Terrestrial PSG', 'Neutral')),
#     condition = factor(
#       condition, levels = c(
#         'RELAX Intensification (Test = Marine)',
#         'RELAX Relaxation (Test = Marine)',
#         'RELAX Insignificant (Test = Marine)'
#       )
#     )
#   ) |>
#   filter(!is.na(condition)) |>
#   ggplot(
#     aes(
#       x = psgSet,
#       y = dN,
#       fill = branch
#     )
#   ) +
#   geom_boxplot(alpha = 0.7) +
#   scale_fill_manual(values = c('#ffb703', '#277da1')) +
#   ylim(0, 2) +
#   labs(
#     y = 'dN/dS (MG94xRev)',
#     x = 'Gene set',
#     fill = 'BUSTED branch category'
#   ) +
#   facet_wrap(
#     condition ~ .,
#     nrow = 3
#   ) +
#   theme_bw() +
#   theme(
#     axis.text = element_text(size = 14),
#     axis.title = element_text(size = 16, face = 'bold'),
#
#     legend.title = element_text(size = 16, face = 'bold'),
#     legend.text = element_text(size = 14),
#
#     strip.text = element_text(size = 16, face = 'bold')
#   )
