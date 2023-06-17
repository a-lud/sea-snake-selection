# ------------------------------------------------------------------------------------------------ #
# Mean omega
#
# Mean omega as estimated by the MG94xREV model. This is run as part of the BUSTED-PH method to
# help improve initial model fit before running more complex models (unconstrained etc...). These
# omega values are a single MEAN estimate for each ortholog.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(ggExtra)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# Data
busted <- read_rds(here('selection','r-data','busted-ph.rds'))
psg <- read_lines(here('selection','results','results-PSGs','PSGs-marine.txt'))

# ------------------------------------------------------------------------------------------------ #
# Scatterplot - Mean omega Test vs Brackground branches
# ragg::agg_png(
#   filename = here('figures','manuscript','figure-x-mean-omega-scatter.png'),
#   width = 1000,
#   height = 1000,
#   units = 'px',
#   scaling = 1.2
# )
grDevices::cairo_pdf(
  filename = here('figures', 'manuscript', 'figure-x-mean-omega-scatter.pdf'),
  width = 8,
  height = 8
)
p1 <- busted$fits$mg94$mg94 |>
  mutate(
    file = str_remove(file, '.clean'),
    branch = str_to_title(branch),
    grouping = ifelse(file %in% psg, 'PSG', 'Non-PSG')
  ) |>
  pivot_wider(names_from = branch, values_from = dN) |>
  ggplot(aes(x = Test, y = Background, colour = grouping, alpha = grouping)) +
  geom_vline(xintercept = 1, colour = 'black', linewidth = 1.5, alpha = 0.5) +
  geom_hline(yintercept = 1, colour = 'black', linewidth = 1.5, alpha = 0.5) +
  geom_point(size = 4) +
  scale_colour_manual(values = c('grey', '#4eaf49')) +
  scale_alpha_discrete(range = c(0.1, 0.5)) +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    x = expression(bold(atop("", "log"[10]*" \u03C9 (Test)"))),
    y = expression(bold(atop("", "log"[10]*" \u03C9 (Background)"))),
    # x = '\nMean \u03C9 (Test)',
    # y = 'Mean \u03C9 (Background)\n',
  ) +
  theme_bw() +
  theme(
    # Axis
    axis.title = element_text(size = 20, face = 'bold'),
    axis.text = element_text(size = 18),

    # Legend
    legend.position = 'bottom',
    legend.title = element_blank(),
    legend.text = element_text(size = 18)
  )
ggExtra::ggMarginal(p = p1, groupColour = TRUE, groupFill = TRUE, bins = 30)
invisible(dev.off())


# busted$fits$mg94$mg94 |>
#   mutate(
#     file = str_remove(file, '.clean'),
#     branch = str_to_title(branch),
#     grouping = ifelse(file %in% psg, 'PSG', 'Non-PSG')
#   ) |>
#   pivot_wider(names_from = branch, values_from = dN) |>
#   group_by(grouping) |>
#   summarise(
#     mean_background = mean(Background),
#     mean_test = mean(Test)
#   )

