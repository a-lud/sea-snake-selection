# ------------------------------------------------------------------------------------------------ #
# Plot: Cumulative length plot
#
# Create cumulative length plots to represent the genome assembly quality. The aim is to have as
# much of the genome on a few sequences (chromosomes ideally), meaning a sharp rise before a plateu.
# Further, the contig assembly should take longer to reach the 'actual' genome size, as it'll
# require more sequences (i.e. be further along the x-axis) to get there.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# Read in FAI files
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
      sample == 'hydrophis_curtus-garvin' ~ 'Hydrophis curtus (West)'
    )
  ) |>
  select(
    sample,
    chromosome = X1,
    length = X2
  ) |>
  group_by(sample) |>
  arrange(-length) |>
  mutate(
    idx = 1:n(),
    csum = cumsum(length),
    sample = factor(sample, levels = c(
      'Hydrophis major', 'Hydrophis major (haplotype 1)', 'Hydrophis major (haplotype 2)',
      'Hydrophis ornatus', 'Hydrophis curtus (West)', 'Hydrophis elegans'
    )),
    type = 'Chromosome/Scaffold'
  ) |>
  ungroup()

# Note: I don't currently have access to the contig files for H. curtus/ornatus
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
      sample == 'hydrophis_ornatus-garvin' ~ 'Hydrophis ornatus',
      sample == 'hydrophis_curtus-garvin' ~ 'Hydrophis curtus (West)'
    )
  ) |>
  select(
    sample,
    chromosome = X1,
    length = X2
  ) |>
  group_by(sample) |>
  arrange(-length) |>
  mutate(
    idx = 1:n(),
    csum = cumsum(length),
    sample = factor(sample, levels = c(
      'Hydrophis major', 'Hydrophis major (haplotype 1)', 'Hydrophis major (haplotype 2)',
      'Hydrophis ornatus', 'Hydrophis curtus (West)','Hydrophis elegans'
    )),
    type = 'Contig'
  ) |>
  ungroup()

# Bind together
fai <- fai.chr |>
  bind_rows(fai.contig) |>
  mutate(type = factor(type, levels = c('Chromosome/Scaffold', 'Contig'))) |>
  select(sample, idx, csum, type)

# ------------------------------------------------------------------------------------------------ #
# Cumulative length distribution (limited to the first 1000 sequences)
grDevices::cairo_pdf(
  filename = here('figures','supplementary','figure-x-genome-cumulative-length.pdf'),
    width = 11,
    height = 12,
)
fai |>
  filter(idx <= 1000) |>
  ggplot(
    aes(
      x = idx,
      y = csum,
      colour = sample
    )
  ) +
  geom_step(
    aes(linetype = type),
    linewidth = 2,
    alpha = 0.6
  ) +
  labs(
    x = '\nSequence index',
    y = 'Cumulative sequence length (Gbp)\n',
    colour = 'Genome Assembly',
    linetype = 'Assembly Stage'
  ) +
  scale_colour_manual(values = RColorBrewer::brewer.pal(n = 6, 'Set1')) +
  scale_y_continuous(
    breaks = seq(0, 2.2e9, 2e8),
    labels = scales::label_number(scale = 1e-9),
    expand = c(0.01, 0)
  ) +
  theme_bw() +
  theme(
    # Axis titles
    axis.title = element_text(size = 20, face = 'bold'),

    # Axis text
    axis.text = element_text(size = 18),

    # Legend
    legend.title = element_text(size = 20, face = 'bold'),
    legend.text = element_text(size = 18, face = 'italic'),
    legend.position = c(0.78, 0.17)
  )
invisible(dev.off())
