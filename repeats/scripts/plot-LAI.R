# ------------------------------------------------------------------------------------------------ #
# LAI landscape
#
# This script plots the LAI scores along longest scaffolds/chromosomes for each de novo repeat-
# masked genome.

# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)
library(scales)
library(here)

# ------------------------------------------------------------------------------------------------ #
# Sequences to keep for each snake - taking top 20 longest sequences in non-chromosomal samples
al <- paste0(rep('contig_', 20), 1:20)
he <- paste0(rep('contig_', 20), 1:20)
hc <- as.character(1:17)
hm <- c(paste0(rep('chr', 15), 1:15), 'chrZ')
ho <- as.character(1:16)

seqs <- tribble(
  ~'dummy', ~'hydrophis_major' ,~'hydrophis_ornatus-garvin', ~'hydrophis_curtus-garvin', ~'aipysurus_laevis', ~'hydrophis_elegans',
  'blah', hm, ho, hc, al, he
) %>%
  pivot_longer(names_to = 'sample', values_to = 'Chr', 2:ncol(.)) %>%
  select(-dummy) %>%
  unnest(cols = Chr)

# ------------------------------------------------------------------------------------------------ #
# Read in LAI files
lai <- fs::dir_ls(
  path = here(),
  recurse = TRUE,
  glob = '*.LAI'
) %>%
  read_tsv(
    col_names = TRUE,
    col_types = cols(),
    id = 'sample'
  ) %>%
  mutate(
    sample = sub('\\..*', '', basename(sample)),
    sample = str_replace(string = sample, pattern = 'hydmaj-p_ctg-v1', 'hydrophis_major')
  )

# Whole genome LAI scores
lai.whole_genome <- lai %>%
  filter(Chr == 'whole_genome')

# Per sequence LAI scores
lai.seqs <- lai %>%
  filter(Chr != 'whole_genome') %>%
  right_join(seqs) %>%
  mutate(
    midpoint = as.integer((From + To)/2)
  )

# Split on sample and generate a plot for each snake
lai.seqs %>%
  split(., .$sample) %>%
  iwalk(~{

    if (.y %in% c('hydrophis_major', 'hydrophis_ornatus-garvin', 'hydrophis_curtus-garvin')) {
      x.label <- 'Chromosome position (Mb)'
    } else {
      x.label <- 'Sequence position (Mb)'
    }

    # Levels for plotting
    lvls <- seqs[seqs$sample == .y,][['Chr']]

    # Generate figure
    fig <- .x %>%
      mutate(Chr = factor(x = Chr, levels = lvls)) %>%
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
        x = x.label
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
  })


# Save PNG
ragg::agg_png(
  filename = here('assembly', 'figures', 'repeats', 'LAI-windowed.png'),
  width = 1400,
  height = 1000,
  units = 'px'
)
print(fig)
invisible(dev.off())
