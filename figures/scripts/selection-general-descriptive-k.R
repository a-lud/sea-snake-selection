# ------------------------------------------------------------------------------------------------ #
# Plot: General descriptive K-values (per branch k)
#
# This script explores the per-branch K-values estimated by the RELAX general-descriptive model.
# This model fits a K-parameter to each branch independently, modelling selection intensity to a
# specific region of the tree.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# Import RELAX data

# All relax data
relax <- read_rds(here('selection','r-data','relax.rds'))

# Significant relax results
relax.sig <- read_csv(
  file = here('selection','results','results-PSGs','relax-corrected.csv'),
  col_names = TRUE,
  col_types = cols()
) |>
  pull(orthogroup)

lvls <- relax$grouping |>
  mutate(
    condition = factor(condition, levels = c('Test', 'Reference')),
  ) |>
  arrange(condition, desc(id)) |>
  mutate(
    id = case_when(
      id == 'hydrophis_ornatus' ~ 'H. ornatus',
      id == 'hydrophis_major' ~ 'H. major',
      id == 'hydrophis_elegans' ~ 'H. elegans',
      id == 'hydrophis_cyanocinctus' ~ 'H. cyanocinctus',
      id == 'hydrophis_curtus_AG' ~ 'H. curtus (AG)',
      id == 'hydrophis_curtus' ~ 'H. curtus',
      id == 'thamnophis_elegans' ~ 'T. elegans',
      id == 'python_bivittatus' ~ 'P. bivittatus',
      id == 'pseudonaja_textilis' ~ 'P. textilis',
      id == 'protobothrops_mucrosquamatus' ~ 'P. mucrosquamatus',
      id == 'pantherophis_guttatus' ~ 'P. guttatus',
      id == 'notechis_scutatus' ~ 'N. scutatus',
      id == 'crotalus_tigris' ~ 'C. tigris',
      .default =  id
    )
  ) |>
  pull(id) |>
  unique()

# ------------------------------------------------------------------------------------------------ #
# Format data
options(scipen = 999)
relax.clean <- relax$`branch attributes` |>
  mutate(file = sub('.clean', '', file)) |>
  filter(models == 'k (general descriptive)') |>
  left_join(relax$grouping |> select(id, condition) |> distinct()) |>
  rename(Orthogroup = file) |>
  mutate(
    condition = factor(condition, levels = c('Test', 'Reference')),
    id = case_when(
      id == 'hydrophis_ornatus' ~ 'H. ornatus',
      id == 'hydrophis_major' ~ 'H. major',
      id == 'hydrophis_elegans' ~ 'H. elegans',
      id == 'hydrophis_cyanocinctus' ~ 'H. cyanocinctus',
      id == 'hydrophis_curtus_AG' ~ 'H. curtus (AG)',
      id == 'hydrophis_curtus' ~ 'H. curtus',
      id == 'thamnophis_elegans' ~ 'T. elegans',
      id == 'python_bivittatus' ~ 'P. bivittatus',
      id == 'pseudonaja_textilis' ~ 'P. textilis',
      id == 'protobothrops_mucrosquamatus' ~ 'P. mucrosquamatus',
      id == 'pantherophis_guttatus' ~ 'P. guttatus',
      id == 'notechis_scutatus' ~ 'N. scutatus',
      id == 'crotalus_tigris' ~ 'C. tigris',
      .default =  id
    ),
    id = factor(id, levels = lvls)
  )

relax.stat <- relax.clean |>
  group_by(id, condition) |>
  summarise(mean = mean(values), median = median(values), IQR = IQR(values))

# ------------------------------------------------------------------------------------------------ #
# BoxPlot
ragg::agg_png(
  filename = here('figures','supplementary','figure-x-selection-k-general-boxplot.png'),
  width = 1500,
  height = 1000,
  units = 'px',
  scaling = 1.5
)
relax.clean |>
  ggplot(
    aes(
      x = id,
      y = values,
      fill = condition
    )
  ) +
  geom_violin(alpha = 0.9) +
  geom_boxplot(fill = NA, linewidth = 0.9) +
  labs(
    x = 'Tree id',
    y = 'K (General Descriptive)',
    fill = 'Partition'
  ) +
  scale_y_log10(
    breaks = c(0.001, 0.1, 1, 5, 50),
    expand = expansion(mult = 0.005)
  ) +
  annotation_logticks(sides = 'l') +
  scale_fill_manual(values = RColorBrewer::brewer.pal(n = 12, 'Set3')[c(5,6)]) +
  theme_bw() +
  theme(
    axis.text = element_text(size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 0.98, face = 'italic'),

    axis.title = element_text(size = 16, face = 'bold'),
    axis.title.x = element_blank(),

    legend.title = element_text(size = 16, face = 'bold'),
    legend.text = element_text(size = 14),
    legend.position = 'bottom'
  )
invisible(dev.off())

# ------------------------------------------------------------------------------------------------ #
# Density plot
ragg::agg_png(
  filename = here('figures','supplementary','figure-x-selection-k-general-hist.png'),
  width = 1500,
  height = 1000,
  units = 'px',
  scaling = 1.5
)
relax.clean |>
  ggplot(
    aes(
      x = values,
      fill = condition
    )
  ) +
  geom_histogram(alpha = 0.9, position = 'identity', colour = 'black') +
  scale_x_log10(
    breaks = c(0.001, 0.01, 0.1, 1, 10, 50)
  ) +
  geom_vline(xintercept = 1, linetype = 'dashed', linewidth = 1) +
  scale_fill_manual(values = RColorBrewer::brewer.pal(n = 12, 'Set3')[c(5,6)]) +
  labs(
    x = '\nK (General Descriptive)',
    y = 'Count',
    fill = 'Partition'
  ) +
  facet_wrap(. ~ id) +
  theme_bw() +
  theme(
    # Axis text
    axis.text = element_text(size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 0.98),

    # Axis titles
    axis.title = element_text(size = 16, face = 'bold'),

    # Legend
    legend.title = element_text(size = 16, face = 'bold'),
    legend.text = element_text(size = 14),
    legend.position = c(0.81, 0.04),

    # Strip text
    strip.text = element_text(size = 16, face = 'bold.italic')
  )
invisible(dev.off())
