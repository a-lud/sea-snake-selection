# ------------------------------------------------------------------------------------------------ #
# Plot: Omega distribution
#
# TODO:
#     - Make colour palettes different betweeen PAML and BUSTED
#     - Figure out if there are more clear ways of presenting this information?

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
  library(patchwork)
})

options(scipen = 999)

# ------------------------------------------------------------------------------------------------ #
# Import PAML and BUSTED-PH results
marine.psg <- read_lines(here('selection/results-13/results-PSGs/PSGs-marine.txt'))
paml <- read_csv(
  file = here('figures','supplementary','table-x-selection-paml-branch-site-alternate-model-fit.csv'),
  col_names = TRUE,
  col_types = cols()
) |>
  select(Orthogroup, starts_with('Proportion'), starts_with('Background'), starts_with('Foreground')) |>
  pivot_longer(
    names_to = 'Category',
    values_to = 'values',
    2:13
  ) |>
  separate(
    col = Category,
    into = c('partition', 'category'),
    sep = ' '
  ) |>
  mutate(
    condition = case_when(
      Orthogroup %in% marine.psg ~ 'PSG',
      .default = 'Non-PSG'
    ),
    condition = factor(condition, levels = c('PSG', 'Non-PSG'))
  )

busted <- read_csv(
  file = here('figures','supplementary','table-x-selection-bustedph-unconstrained-model-fit.csv'),
  col_names = TRUE,
  col_types = cols()
) |>
  select(
    Orthogroup,
    starts_with('Proportion'),
    starts_with('Omega'),
  ) |>
  pivot_longer(
    names_to = 'category',
    values_to = 'values',
    2:13
  ) |>
  separate(
    col = category,
    into = c('measure', 'partition', 'category'), sep = ' '
  ) |>
  mutate(
    condition = case_when(
      Orthogroup %in% marine.psg ~ 'PSG',
      .default = 'Non-PSG'
    ),
    condition = factor(condition, levels = c('PSG', 'Non-PSG')),
    partition = str_to_sentence(partition),
    partition = factor(partition, levels = c('Test', 'Background'))
  )

# ------------------------------------------------------------------------------------------------ #
# Plot: BUSTED-PH proportion of sites and avg. omega in each rate category.

busted.prop <- busted |>
  filter(measure == 'Proportion') |>
  ggplot(
    aes(
      x = category,
      y = values,
      fill = partition
    )
  ) +
  geom_boxplot() +
  scale_y_continuous(expand = expansion(mult = 0.01), labels = scales::unit_format(unit = "%")) +
  scale_fill_manual(values = RColorBrewer::brewer.pal(n = 12, 'Set3')[c(5,6)]) +
  labs(
    y = 'Percentage of sites'
  ) +
  facet_wrap(
    . ~ condition
  ) +
  theme_bw() +
  theme(
    # Axis text
    axis.text = element_text(size = 14),
    axis.text.x = element_blank(),

    # Axis title
    axis.title = element_text(size = 16, face = 'bold'),
    axis.title.x = element_blank(),

    # legend to None as this will be handled by PAML plot above
    legend.position = 'none',

    # Strip text
    strip.text = element_text(size = 16, face = 'bold')
  )

# Filter out outliers in each direction - only a few and drastically skew the plot
busted.omega <- busted |>
  filter(measure == 'Omega', values <= 100, values >= 0.0001) |>
  ggplot(
    aes(
      x = category,
      y = values,
      fill = partition
    )
  ) +
  geom_boxplot() +
  labs(
    x = '\u03C9-rate-category',
    y = 'Omega (\u03C9)',
    fill = 'Partition'
  ) +
  scale_fill_manual(values = RColorBrewer::brewer.pal(n = 12, 'Set3')[c(5,6)]) +
  scale_y_log10(
    breaks = c(0.001, 0.01, 0.1, 1, 10, 100),
    expand = expansion(mult = 0.01)
  ) +
  facet_wrap(
    ~ condition
  ) +
  theme_bw() +
  theme(
    # Axis text
    axis.text = element_text(size = 14),

    # Axis title
    axis.title = element_text(size = 16, face = 'bold'),

    # Legend
    legend.title = element_blank(),
    legend.text = element_text(size = 14),
    legend.position = 'bottom',

    # Strip text
    strip.background = element_blank(),
    strip.text = element_blank()
  )


ragg::agg_png(
  filename = here('figures','supplementary','figure-x-selection-bustedph-prop-omega.png'),
  width = 1000,
  height = 1000,
  scaling = 1.2
)
busted.prop / busted.omega
invisible(dev.off())


# ------------------------------------------------------------------------------------------------ #
# Plot: PAML proportion of sites and avg. omega in each rate category. NOTE: PAML doesn't separate
# % of sites by partition. It meerly reports the % of sites in each category. The omega-estimate
# IS estimated by partition (see below).
paml.prop <- paml |>
  filter(partition == 'Proportion') |>
  mutate(
    partition = factor(partition, levels = c('Foreground', 'Background')),
    values = values * 100
  ) |>
  ggplot(
    aes(
      x = category,
      y = values,
      fill = condition
    )
  ) +
  geom_boxplot() +
  scale_y_continuous(expand = expansion(mult = 0.01), labels = scales::unit_format(unit = "%")) +
  scale_fill_manual(values = RColorBrewer::brewer.pal(n = 12, 'Set3')[c(1,4)]) +
  labs(
    y = 'Percentage of sites'
  ) +
  theme_bw() +
  theme(
    # Axis text
    axis.text = element_text(size = 14),

    # Axis title
    axis.title = element_text(size = 16, face = 'bold'),
    axis.title.x = element_blank(),

    # Legend
    legend.title = element_blank(),
    legend.text = element_text(size = 14)
  )

# Omega plots - separate figures patchworked together so I can colour the strip-backgrounds
paml.omega.psg <- paml |>
  filter(partition != 'Proportion', condition == 'PSG', values <= 100, values >= 0.001) |>
  mutate(partition = factor(partition, levels = c('Foreground', 'Background'))) |>
  ggplot(
    aes(
      x = category,
      y = values,
      fill = partition
    )
  ) +
  geom_boxplot() +
  labs(
    x = '\u03C9-rate-category',
    y = 'Omega (\u03C9)',
  ) +
  scale_fill_manual(values = RColorBrewer::brewer.pal(n = 12, 'Set3')[c(5,6)]) +
  scale_y_log10(
    breaks = c(0.001, 0.01, 0.1, 1,10, 100, 500),
    expand = expansion(mult = 0.01)
  ) +
  facet_wrap(
    . ~ condition
  ) +
  theme_bw() +
  theme(
    # Axis text
    axis.text = element_text(size = 14),

    # Axis title
    axis.title = element_text(size = 16, face = 'bold'),
    axis.title.x = element_blank(),

    # Legend
    legend.title = element_blank(),
    legend.text = element_text(size = 14),
    legend.position = 'bottom',

    # Strip
    strip.text = element_text(size = 16, face = 'bold'),
    strip.background = element_rect(fill = RColorBrewer::brewer.pal(n = 12, 'Set3')[1])
  )

paml.omega.nonpsg <- paml |>
  filter(partition != 'Proportion', condition == 'Non-PSG', values <= 100, values >= 0.001) |>
  mutate(partition = factor(partition, levels = c('Foreground', 'Background'))) |>
  ggplot(
    aes(
      x = category,
      y = values,
      fill = partition
    )
  ) +
  geom_boxplot() +
  labs(
    x = '\u03C9-rate-category',
    y = 'Omega (\u03C9)',
  ) +
  scale_fill_manual(values = RColorBrewer::brewer.pal(n = 12, 'Set3')[c(5,6)]) +
  scale_y_log10(
    breaks = c(0.001, 0.01, 0.1, 1,10, 100, 500),
    expand = expansion(mult = 0.01)
  ) +
  facet_wrap(
    . ~ condition
  ) +
  theme_bw() +
  theme(
    # Axis text
    axis.text = element_text(size = 14),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),

    # Axis title
    # axis.title = element_text(size = 16, face = 'bold'),
    axis.title = element_blank(),

    # Legend
    legend.title = element_blank(),
    legend.text = element_text(size = 14),
    legend.position = 'bottom',

    # Strip
    strip.text = element_text(size = 16, face = 'bold'),
    strip.background = element_rect(fill = RColorBrewer::brewer.pal(n = 12, 'Set3')[4])
  )

# Manually make an x-axis label that spans all plots
x.lab <- ggplot(data.frame(l = '\u03C9-rate-category', x = 1, y = 1)) +
  geom_text(aes(x, y, label = l), size = 6, fontface = 'bold') +
  theme_void() +
  coord_cartesian(clip = "off")

ragg::agg_png(
  filename = here('figures','supplementary','figure-x-selection-paml-prop-omega.png'),
  width = 1000,
  height = 1000,
  scaling = 1.2
)
(paml.prop / (paml.omega.psg + paml.omega.nonpsg)) / x.lab +
  plot_layout(guides = 'collect', heights = c(1,1,0.1)) &
  theme(legend.position = 'bottom')
invisible(dev.off())
