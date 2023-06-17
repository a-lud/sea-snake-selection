# ------------------------------------------------------------------------------------------------ #
# LTR insertion time
#
# This script generates histogram plots of insertion times for the de novo repeat-annotated snakes.
# The mutation rate used here is the same as reported by Li et al. 2021 to make comparisons equal.

# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)

# ------------------------------------------------------------------------------------------------ #
# Read EDTA repeat annotation GFF3 files
gffs <- fs::dir_ls(path = 'assembly', glob = '*.mod.EDTA.intact.gff3.gz', recurse = TRUE) %>%
  as.character() %>%
  set_names(sub('\\.f.*', '', basename(.)))

# Read in as table
gff.tibble <- map(
  gffs, vroom::vroom,
  delim = '\t',
  col_names = FALSE,
  col_types = cols(),
  col_select = c(1,3,9)
)

# ------------------------------------------------------------------------------------------------ #
# Extract the identity field. Insertion time can be estimated using the following equation:
#   T = K/2*Mu -> (1 - identity) / 2 * Mu
# Mu = 4.71e-9
ltr.times <- gff.tibble |>
  map(\(tib) {
    tib |>
      filter(str_detect(X3, 'LTR_retrotransposon')) |>
      mutate(
        X9 = as.numeric(sub('.+ltr_identity=(.*);Method.*', '\\1', X9)),
        K = 1 - X9,
        Time = K/(2 * (4.71e-9) ),
        X3 = sub('_LTR_retrotransposon', '', X3),
        X3 = sub('LTR_retrotransposon', 'Other LTR', X3),
        X3 = factor(x = X3, levels = c('Gypsy', 'Copia', 'Other LTR'))
      ) |>
      select(Type = X3, K, Time)
  }) |>
  list_rbind(names_to = 'sample') |>
  filter(sample != 'aipysurus_laevis') |>
  mutate(
    sample = case_when(
      sample == 'hydmaj-p_ctg-v1' ~ 'Hydrophis major',
      sample == 'hydrophis_curtus-garvin' ~ 'Hydrophis curtus (AG)',
      sample == 'hydrophis_elegans' ~ 'Hydrophis elegans',
      sample == 'hydrophis_ornatus-garvin' ~ 'Hydrophis ornatus'
    ),
    sample = factor(sample, levels = c(
      'Hydrophis major', 'Hydrophis ornatus', 'Hydrophis curtus (AG)', 'Hydrophis elegans')
    )
  )

# ------------------------------------------------------------------------------------------------ #
# Histogram plots where x-axis is the insertion time in Mya and Y axis is the count of elements
options(scipen = 999)
pdf(
  file = 'figures/manuscript/figure-x-repeats-ltr-insertion.pdf',
  width = 8,
  height = 8
)
plt <- ltr.times |>
  ggplot(
    aes(
      x = Time,
      fill = Type
    )
  ) +
  geom_histogram(
    bins = 50,
    alpha = 0.5,
    position = 'identity'
  )

binwidth <- layer_data(plt) %>% mutate(w=xmax-xmin) %>% pull(w) %>% median

plt +
  stat_bin(
    aes(y = after_stat(count)),
    bins = 50,
    geom = 'step',
    # position = 'identity',
    linewidth = 1.4,
    position=position_nudge(x=-0.5*binwidth)
  ) +
  scale_x_continuous(
    labels = scales::label_number(scale = 1e-6),
    breaks = seq(0,15e6, 2.5e6),
  ) +
  scale_y_continuous(expand = c(0.01,0)) +
  scale_fill_manual(values = c('#edae49', '#d1495b', '#00798c')) +
  labs(
    x = '\nInsertion age (Mya)',
    y = 'Repeats (count)\n',
    fill = ''
  ) +
  theme_minimal() +
  facet_wrap(~sample) +
  theme(
    # Axis titles/text
    axis.text = element_text(size = 18),
    axis.title = element_text(size = 20, face = 'bold'),

    # Legend
    legend.title = element_text(size = 20, face = 'bold'),
    legend.text = element_text(size = 18),
    legend.position = 'bottom',
    # legend.position = c(0.92, 0.90),

    # Strip text
    strip.text = element_text(size = 20, face = 'bold.italic')
  )
 invisible(dev.off())

