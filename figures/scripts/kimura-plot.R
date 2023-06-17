# ------------------------------------------------------------------------------------------------ #
# Repeat annotation summary
#
# Simple figure to summarise repeat families within each genome assembly

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(magrittr)
  library(here)
  library(scales)
  library(ragg)
})

# ------------------------------------------------------------------------------------------------ #
# genome sizes
genome.sizes <- tibble(
  sample = c('Hydrophis major', 'Hydrophis ornatus', 'Hydrophis curtus (AG)', 'Hydrophis elegans'),
  size = c(2166655682, 1925339083, 1923830333, 2014968974)
)

pal <- colorRampPalette(RColorBrewer::brewer.pal(n = 7, 'Set3'))

# ------------------------------------------------------------------------------------------------ #
# Kimura divergence tables
df.kimura <- fs::dir_ls(
  path = 'assembly',
  glob = '*distance',
  recurse = TRUE
) |>
  map(read_delim, delim = ' ', col_names = TRUE, col_types = cols()) |>
  list_rbind(names_to = 'sample') |>
  mutate(
    sample = sub('\\..*', '', basename(sample)),
    sample = case_when(
      sample == 'hydrophis_major' ~ 'Hydrophis major',
      sample == 'hydrophis_ornatus' ~ 'Hydrophis ornatus',
      sample == 'hydrophis_curtus-AG' ~ 'Hydrophis curtus (AG)',
      sample == 'hydrophis_elegans-garvin' ~ 'Hydrophis elegans',
      .default = sample
    )
  ) |>
  filter(sample != 'aipysurus_laevis') |>
  select(-starts_with('...')) |>
  # select(1:21) |>
  (\(x) pivot_longer(data = x, names_to = 'repeat_type', values_to = 'value', cols = 3:ncol(x)))() %>%
  left_join(genome.sizes) |>
  mutate(
    percentage = (value/size) * 100,
    sample = factor(sample, levels = c('Hydrophis major', 'Hydrophis ornatus', 'Hydrophis curtus (AG)', 'Hydrophis elegans'))
  ) |>
  separate(col = repeat_type, into = c('Family', 'Sub-family'), sep = '/') |>
  mutate(`Sub-family` = ifelse(is.na(`Sub-family`), Family, `Sub-family`))

# Temporary while I re-run repeat masker with repbase
tmp <- df.kimura |>
  filter(!is.na(value), !str_detect(Family, '\\?')) |>
  group_by(sample, Div, Family) |>
  mutate(total_family = sum(value), percentage_family = (total_family/size) * 100) |>
  select(sample, Div, Family, percentage_family) |>
  ungroup() |>
  distinct()

# ------------------------------------------------------------------------------------------------ #
# Plot divergence plots
kimura.gg <- tmp |>
  filter( percentage_family > 0.01) |>
  mutate(
    colour = case_when(
      Family == 'DNA' ~ '#4eaf49',
      Family == 'LINE' ~ '#984f9f',
      Family == 'LTR' ~ '#397fb9',
      Family == 'MITE' ~ '#f7941d',
      Family == 'Unknown' ~ '#737e76'
    )
  ) |>
  ggplot(
    aes(
      x = Div,
      y = percentage_family,
      fill = colour
    )
  ) +
  geom_bar(
    position = 'stack',
    stat = 'identity',
    alpha = 0.6
  ) +
  scale_fill_identity(guide = "legend") +
  labs(
    x = '\nKimura substitution level',
    y = 'Genome percentage\n',
    fill = 'Repeat family\n'
  ) +
  scale_y_continuous(
    labels = label_number(suffix = '%')
  ) +
  scale_x_continuous(
    breaks = seq(0, 50, 5),
    limits = c(0, 55),
    expand = c(0,0)
  ) +
  coord_cartesian(xlim = c(0, 51)) +
  theme_minimal() +
  theme(
    # Axis
    axis.title = element_text(size = 20, face = 'bold'),
    axis.text = element_text(size = 18),

    # legend
    legend.position = 'bottom',
    legend.title = element_blank(),
    legend.text = element_text(size = 18),

    # Strip text
    strip.text = element_text(size = 20, face = 'bold.italic')
  ) +
  facet_wrap(~sample, nrow = 4)

# Save PNG
pdf(
  file = here('figures','manuscript','figure-x-kimura.pdf'),
  width = 9,
  height = 8
)
print(kimura.gg)
invisible(dev.off())
