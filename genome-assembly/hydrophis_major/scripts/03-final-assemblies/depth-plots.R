suppressPackageStartupMessages({
  library(tidyverse)
  library(magrittr)
  library(here)
  library(scales)
  library(ragg)
})

# Mosdepth results
bed <- read_tsv(
  file = here('assembly', 'hydmaj-chromosomes', 'mosdepth-chromosome', 'hydmaj-p_ctg-v1.per-base.bed.gz'),
  col_names = c('chr', 'start', 'end', 'depth')
) %>%
  filter(
    chr %in% c(paste0('chr', 1:15), 'chrZ')
  ) %>%
  mutate(
    chr = factor(chr, levels = c(paste0('chr', 1:15), 'chrZ'))
  )

# Plotting function
bootstrap_cov <- function(b, n, r) {
  bl <- b %>%
    mutate(
      midpoint = ceiling((start + end)/2)
    ) %>%
    select(chr, midpoint, depth) %>%
    group_by(chr) %>%
    group_split()
  bl %>%
    map_dfr(function(bed) {
      map_dfr(
        integer(r),
        ~ bed %>% slice_sample(n = n), .id = 'iter'
      )
    })
}

# Bootstrap depth values randomly 50 for each chromosome
cov_bootstrap <- bootstrap_cov(bed, 500, 10)
cov <- ggplot(
  cov_bootstrap,
  aes(
    x = midpoint,
    y = depth,
    group = iter
  )
) +
  geom_line(
    alpha = 0.6,
    colour = 'black'
  ) +
  # if I want to highlight one line
  # geom_line(
  #   data = filter(
  #     .data = cov_bootstrap,
  #     iter != 1
  #   ),
  #   aes(
  #     x = midpoint,
  #     y = depth,
  #     group = iter
  #   ),
  #   alpha = 0.5,
  #   linetype = 'dotted',
  #   colour = 'black'
  # ) +
  # geom_line(
  #   data = filter(
  #     .data = cov_bootstrap,
  #     iter == 1
  #   ),
  #   aes(
  #     x = midpoint,
  #     y = depth,
  #     group = iter
  #   ),
  #   alpha = 0.4,
  #   colour = 'red'
  # ) +
  labs(
    x = '\nChromosome position',
    y = 'Coverage\n'
  ) +
  geom_hline(
    yintercept = 30, colour = 'red'
  ) +
  geom_hline(
    yintercept = 15, colour = 'red'
  ) +
  scale_y_log10() +
  scale_x_continuous(
    labels = label_number(scale = 1e-6, suffix = ' Mb')
  ) +
  facet_wrap(
    . ~ chr,
    scales = 'free'
  ) +
  theme_bw() +
  theme(
    # Axes
    axis.title = element_text(size = 16, face = 'bold'),
    axis.text = element_text(size = 14),

    # Strip text
    strip.text = element_text(size = 16, face = 'bold')
  )

# Save PNG
agg_png(
  filename = here('assembly', 'figures', 'assembly-assessment', 'genome-coverage.png'),
  width = 1200,
  height = 1000,
  units = 'px'
)
print(cov)
invisible(dev.off())
