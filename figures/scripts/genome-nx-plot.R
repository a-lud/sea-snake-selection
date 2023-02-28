# ------------------------------------------------------------------------------------------------ #
# Plot: Cumulative length plot
#
# Create cumulative length plots to represent the genome assembly quality. The aim is to have as
# much of the genome on a few sequences (chromosomes ideally), meaning a sharp rise before a plateu.
# Further, the contig assembly should take longer to reach the 'actual' genome size, as it'll
# require more sequences (i.e. be further along the x-axis) to get there.

# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)
library(here)

# ------------------------------------------------------------------------------------------------ #
# Load FAI files
fai.chr <- fs::dir_ls(
  path = here('data', 'genomes'),
  glob = '*.fai'
) |>
  read_tsv(
    id = 'sample',
    col_names = FALSE,
    col_types = cols()
  ) |>
  mutate(
    sample = sub('\\..*', '', basename(sample)),
    sample = case_when(
      sample == 'hydrophis_major' ~ 'Hydrophis major',
      sample == 'hydrophis_major-haplotype1' ~ 'Hydrophis major (haplotype 1)',
      sample == 'hydrophis_major-haplotype2' ~ 'Hydrophis major (haplotype 2)',
      sample == 'hydrophis_elegans-garvin' ~ 'Hydrophis elegans',
      sample == 'hydrophis_ornatus-garvin' ~ 'Hydrophis ornatus',
      sample == 'hydrophis_curtus-garvin' ~ 'Hydrophis curtus'
    ),
    sample = factor(sample, levels = c(
      'Hydrophis major', 'Hydrophis major (haplotype 1)', 'Hydrophis major (haplotype 2)',
      'Hydrophis elegans', 'Hydrophis ornatus', 'Hydrophis curtus'
    )),
    type = 'Chromosome/Scaffold'
  ) |>
  select(
    sample,
    chromosome = X1,
    length = X2,
    type
  ) |>
  group_by(sample) |>
  arrange(-length) |>
  mutate(
    csum = cumsum(length) - length,
    pct = csum/sum(length) * 100
  ) |>
  ungroup()

# Note: I don't have access to the contig data for H. ornatus/curtus
fai.contig <- fs::dir_ls(
  path = here('data', 'genomes', 'contigs'),
  glob = '*.fai'
) |>
  read_tsv(
    id = 'sample',
    col_names = FALSE,
    col_types = cols()
  ) |>
  mutate(
    sample = sub('\\..*', '', basename(sample)),
    sample = case_when(
      sample == 'hydrophis_major' ~ 'Hydrophis major',
      sample == 'hydrophis_major-haplotype1' ~ 'Hydrophis major (haplotype 1)',
      sample == 'hydrophis_major-haplotype2' ~ 'Hydrophis major (haplotype 2)',
      sample == 'hydrophis_elegans' ~ 'Hydrophis elegans',
    ),
    type = 'Contig'
  ) |>
  select(
    sample,
    chromosome = X1,
    length = X2,
    type
  ) |>
  group_by(sample) |>
  arrange(-length) |>
  mutate(
    csum = cumsum(length) - length,
    pct = csum/sum(length) * 100
  ) |>
  ungroup()

# Bind together
fai <- fai.chr |>
  bind_rows(fai.contig) |>
  mutate(type = factor(type, levels = c('Chromosome/Scaffold', 'Contig'))) |>
  select(sample, length, type, pct)

# ------------------------------------------------------------------------------------------------ #
# Nx plot
png(
  filename = here('figures','supplementary','figure-x-genome-Nx.png'),
  width = 1000,
  height = 1000,
  units = 'px'
)
fai |>
  ggplot(
    aes(
      x = pct,
      y = length,
      colour = sample
    )
  ) +
  geom_step(
    aes(linetype = type),
    linewidth = 2,
    alpha = 0.6
  ) +
  labs(
    x = '\nPercentage of genome',
    y = 'Chr/Scaffold/Contig length (Mbp)\n',
    colour = 'Genome Assembly',
    linetype = 'Assembly Stage'
  ) +
  scale_colour_manual(values = RColorBrewer::brewer.pal(n = 6, 'Set1')) +
  scale_y_continuous(
    breaks = seq(0, 5e8, 2e7),
    labels = scales::label_number(scale = 1e-6),
    expand = c(0.01, 0)
  ) +
  scale_x_continuous(
    limits = c(0, 100),
    expand = expansion(mult = c(0, 0.02))
  ) +
  theme_bw() +
  theme(
    # Axis titles
    axis.title = element_text(size = 16, face = 'bold'),

    # Axis text
    axis.text = element_text(size = 14),

    # Legend
    legend.title = element_text(size = 16, face = 'bold'),
    legend.text = element_text(size = 14, face = 'italic'),
    legend.position = c(0.86, 0.85)
  )
invisible(dev.off())
