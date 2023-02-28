# ------------------------------------------------------------------------------------------------ #
# Plot: LAI landscape
#
# This script plots the LAI scores along longest scaffolds/chromosomes for each de novo repeat-
# masked genome.

# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)
library(scales)
library(here)

# ------------------------------------------------------------------------------------------------ #
# Sequences to keep for each snake - taking top 50 longest sequences in non-chromosomal samples
hm <- c(paste0(rep('chr', 15), 1:15), 'chrZ')
hc <- as.character(1:16)
ho <- as.character(1:16)
he <- paste0(rep('contig_', 50), 1:50)

seqs <- tribble(
  ~'dummy', ~'hydrophis_major' ,~'hydrophis_ornatus-garvin', ~'hydrophis_curtus-garvin', ~'hydrophis_elegans',
  'blah', hm, ho, hc, he
) %>%
  pivot_longer(names_to = 'sample', values_to = 'Chr', 2:ncol(.)) %>%
  select(-dummy) %>%
  unnest(cols = Chr)

# ------------------------------------------------------------------------------------------------ #
# Read in LAI files
lai <- fs::dir_ls(
  path = here('assembly'),
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
  ) |>
  filter(sample != 'aipysurus_laevis')

# Whole genome LAI scores
lai.whole_genome <- lai %>%
  filter(Chr == 'whole_genome') %>%
  select(sample, Intact, Total, raw_LAI, LAI)

# Per sequence LAI scores
lai.seqs <- lai %>%
  filter(Chr != 'whole_genome') %>%
  right_join(seqs) %>%
  mutate(
    midpoint = as.integer((From + To)/2),

    # Cleaning up H. ornatus/H. curtus. Arbitrarily setting chromosome names based on length.
    # Chromosome Z identified based on length.
    Chr = ifelse(Chr == '5', 'chrZ', Chr),
    Chr = case_when(
      !str_detect(Chr, 'chr|contig') & as.numeric(Chr) < 5 ~ paste0('chr', Chr),
      !str_detect(Chr, 'chr|contig') & as.numeric(Chr) > 5 ~ paste0('chr', as.character(as.numeric(Chr) - 1)),
      .default = Chr
    ),
    sample = case_when(
      sample == 'hydrophis_major' ~ 'Hydrophis major',
      sample == 'hydrophis_ornatus-garvin' ~ 'Hydrophis ornatus',
      sample == 'hydrophis_curtus-garvin' ~ 'Hydrophis curtus (AG)',
      sample == 'hydrophis_elegans' ~ 'Hydrophis elegans'
    )
  )

# ------------------------------------------------------------------------------------------------ #
# Split on sample and generate a plot for each snake
plt <- lai.seqs %>%
  split(., .$sample) %>%
  iwalk(~{

    if (.y %in% c('Hydrophis major', 'Hydrophis ornatus', 'Hydrophis curtus (AG)')) {
      x.label <- '\nChromosome position (Mb)'
      lvls <- c(paste0(rep('chr', 15), 1:15), 'chrZ')
      nr <- 4
    } else {
      x.label <- '\nSequence position (Mb)\n'
      lvls <- paste0(rep('contig_', 50), 1:50)
      nr <- 5
    }

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
        nrow = nr,
        scales = 'free_x'
      ) +
      labs(
        x = x.label,
        y = 'LAI\n',
        title = glue::glue("LAI: {.y}")
      ) +
      theme_bw() +
      theme(
        strip.text.x = element_text(size = 16, face = 'bold'),

        axis.text = element_text(size = 14),

        axis.title = element_text(size = 16, face = 'bold'),

        plot.title = element_text(size = 16, face = 'bold', hjust = 0.5)
      )

    # Save PNG
    ragg::agg_png(
      filename = here('figures','supplementary', glue::glue('figure-x-LAI-{.y}.png')),
      width = 1000,
      height = 1000,
      units = 'px'
    )
    print(fig)
    invisible(dev.off())
  })

 # ------------------------------------------------------------------------------------------------ #
# Whole genome table
write_csv(
  lai.whole_genome,
  file = here('figures', 'supplementary', 'table-x-lai.csv'),
  col_names = TRUE
)
