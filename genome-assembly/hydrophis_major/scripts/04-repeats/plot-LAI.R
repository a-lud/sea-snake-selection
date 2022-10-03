library(tidyverse)
library(scales)
library(here)

fig <- read_tsv(
  file = here(
    'assembly',
    'repeats',
    'LAI',
    'hydmaj-p_ctg-v1.fna.mod.out.LAI'
  ),
  col_names = TRUE
) %>%
  slice(-1) %>%
  filter(str_detect(string = Chr, pattern = 'chr')) %>%
  mutate(Chr = factor(x = Chr, levels = c(paste0('chr', 1:15), 'chrZ'))) %>%
  mutate(midpoint = as.integer((From + To)/2)) %>%
  ggplot(
    aes(
      x = midpoint,
      y = LAI
    )
  ) +
  geom_point(
    aes(color=ifelse(LAI<10, 'grey', 'black'))
  ) +
  scale_color_identity() +
  geom_hline(
    yintercept = 10,
    colour = 'red',
    linetype = 'dashed'
  ) +
  scale_x_continuous(
    labels = label_number(scale = 1e-6)
  ) +
  facet_wrap(
    . ~ Chr,
    scales = 'free_x'
  ) +
  labs(
    x = '\nChromosome position (Mb)'
  ) +
  theme_bw() +
  theme(
    strip.text.x = element_text(size = 16, face = 'bold'),

    axis.text = element_text(size = 14),

    axis.title = element_text(size = 16, face = 'bold')
  )

# Save PNG
ragg::agg_png(
  filename = here('assembly', 'figures', 'repeats', 'LAI-windowed.png'),
  width = 1400,
  height = 1000,
  units = 'px'
)
print(fig)
invisible(dev.off())
