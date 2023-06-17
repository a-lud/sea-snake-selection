# ------------------------------------------------------------------------------------------------ #
# Gene feature summary
#
# This script summarises the gene feature lengths for each of the de novo gene annotated samples
#     - H. major, H. curtus (NCBI), H. cyanocinctus (NCBI), H. elegans, H. ornatus, H. curtus (West)

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(fs)
  library(here)
  library(patchwork)
})

lvls <- c(
  'Hydrophis major', 'Hydrophis curtus', 'Hydrophis cyanocinctus',
  'Hydrophis ornatus', 'Hydrophis curtus (West)', 'Hydrophis elegans'
)

lvls.ncbi <- c(
  'Notechis scutatus', 'Pseudonaja textilis', 'Thamnophis elegans',
  'Crotalus tigris', 'Pantherophis guttatus', 'Protobothrops mucrosquamatus', 'Python bivittatus'
)

# ------------------------------------------------------------------------------------------------ #
# GFF3 files
gene.attributes <- dir_ls(path = here('data','gff3'), glob = '*.gff3') |>
  as.character() |>
  (\(x) set_names(x, sub('\\.gff3', '', basename(x))))() |>
  (\(x) keep(.x = x, names(x) %in% c(
    'hydrophis_major', 'hydrophis_curtus', 'hydrophis_curtus-AG',
    'hydrophis_cyanocinctus', 'hydrophis_elegans', 'hydrophis_ornatus'
  )))() |>
  map(read_tsv, comment = '#', col_names = FALSE, col_types = cols()) |>
  list_rbind(names_to = 'sample') |>
  select(sample, feature = X3, start = X4, end = X5) |>
  filter(feature %in% c('gene','exon', 'CDS')) |>
  mutate(
    width = abs(start - end),
    sample = case_when(
      sample == 'hydrophis_major' ~ 'Hydrophis major',
      sample == 'hydrophis_curtus' ~ 'Hydrophis curtus',
      sample == 'hydrophis_curtus-AG' ~ 'Hydrophis curtus (West)',
      sample == 'hydrophis_cyanocinctus' ~ 'Hydrophis cyanocinctus',
      sample == 'hydrophis_ornatus' ~ 'Hydrophis ornatus',
      sample == 'hydrophis_elegans' ~ 'Hydrophis elegans',
      .default = sample
    ),
    sample = factor(sample, levels = lvls),
    feature = case_when(
      feature == 'gene' ~ 'Gene',
      feature == 'exon' ~ 'Exon',
      .default = feature
    ),
    feature = factor(feature, levels = c('Gene', 'Exon', 'CDS'))
  )

gene.atrributes.ncbi <- dir_ls(path = here('data','gff3'), glob = '*.gff3') |>
  as.character() |>
  (\(x) set_names(x, sub('\\.gff3', '', basename(x))))() |>
  (\(x) x[! names(x) %in% c(
    'hydrophis_major', 'hydrophis_curtus', 'hydrophis_curtus-AG',
    'hydrophis_cyanocinctus', 'hydrophis_elegans', 'hydrophis_ornatus'
  )]
  )() |>
  map(read_tsv, comment = '#', col_names = FALSE, col_types = cols()) |>
  list_rbind(names_to = 'sample') |>
  select(sample, feature = X3, start = X4, end = X5) |>
  filter(feature %in% c('gene','exon', 'CDS')) |>
  mutate(
    width = abs(start - end),
    sample = case_when(
      sample == 'crotalus_tigris' ~ 'Crotalus tigris',
      sample == 'notechis_scutatus' ~ 'Notechis scutatus',
      sample == 'pantherophis_guttatus' ~ 'Pantherophis guttatus',
      sample == 'protobothrops_mucrosquamatus' ~ 'Protobothrops mucrosquamatus',
      sample == 'pseudonaja_textilis' ~ 'Pseudonaja textilis',
      sample == 'python_bivittatus' ~ 'Python bivittatus',
      sample == 'thamnophis_elegans' ~ 'Thamnophis elegans',
      .default = sample
    ),
    sample = factor(sample, levels = lvls.ncbi),
    feature = case_when(
      feature == 'gene' ~ 'Gene',
      feature == 'exon' ~ 'Exon',
      .default = feature
    ),
    feature = factor(feature, levels = c('Gene', 'Exon', 'CDS'))
  )

# ------------------------------------------------------------------------------------------------ #
# Plot gene length distributions
options(scipen = 999)

# Genes
plt.gene <- gene.attributes |>
  filter(feature == 'Gene') |>
  ggplot(
    aes(x = width, colour = sample)
  ) +
  stat_bin(
    data = gene.atrributes.ncbi |> filter(feature == 'Gene'),
    aes(x = width, y = after_stat(count), group = sample),
    geom = 'step',
    position = 'identity',
    linewidth = 0.6,
    alpha = 0.7,
    colour = 'black'
  ) +
  stat_bin(
    aes(y = after_stat(count)),
    geom = 'step',
    position = 'identity',
    linewidth = 1.5,
    alpha = 0.7
  ) +
  labs(
    x = '\nFeature length (Kbp)',
    y = 'Count (Thousands)\n'
  ) +
  scale_x_log10(
    breaks = c(0.1, 1, 10, 1e2, 1e3, 1e4, 1e5, 1e6),
    # labels = scales::trans_format("log10", scales::math_format(10^.x)),
    expand = c(0,0)
  ) +
  scale_y_continuous(
    breaks = seq(0, 3e3, 1e3),
    labels = scales::label_number(scale = 1e-3)
  ) +
  coord_cartesian(ylim = c(0,3e3), xlim = c(1, 1.5e6)) +
  scale_color_manual(values = RColorBrewer::brewer.pal(6, 'Set2')) +
  theme_bw() +
  theme(
    # Strip text
    strip.text = element_text(face = 'bold', size = 20),

    # Axis
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title = element_blank(),
    axis.text.y = element_text(size = 18),
    # axis.title = element_text(size = 20, face = 'bold'),

    # legend
    legend.position = 'none'
  ) +
  facet_wrap(~feature)

# Exons
plt.exon <- gene.attributes |>
  filter(feature == 'Exon') |>
  ggplot(
    aes(x = width, colour = sample)
  ) +
  stat_bin(
    data = gene.atrributes.ncbi |> filter(feature == 'Exon'),
    aes(x = width, y = after_stat(count), group = sample),
    geom = 'step',
    position = 'identity',
    linewidth = 0.6,
    alpha = 0.7,
    colour = 'black'
  ) +
  stat_bin(
    aes(y = after_stat(count)),
    geom = 'step',
    position = 'identity',
    linewidth = 1.5,
    alpha = 0.7
  ) +
  labs(
    x = '\nFeature length (Kbp)',
    y = 'Count (Thousands)\n'
  ) +
  scale_x_log10(
    breaks = c(0.1, 1, 10, 1e2, 1e3, 1e4, 1e5, 1e6),
    expand = c(0,0)
  ) +
  scale_y_continuous(
    breaks = seq(0, 2.25e5, 5e4),
    labels = scales::label_number(scale = 1e-3)
  ) +
  coord_cartesian(ylim = c(0,2.1e5), xlim = c(1, 1.5e6)) +
  scale_color_manual(values = RColorBrewer::brewer.pal(6, 'Set2')) +
  theme_bw() +
  theme(
    # Strip text
    strip.text = element_text(face = 'bold', size = 20),

    # Axis
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title = element_blank(),
    axis.text.y = element_text(size = 18),
    # axis.title = element_text(size = 20, face = 'bold'),

    # legend
    legend.position = 'none'
  ) +
  facet_wrap(~feature)

# CDS
plt.cds <- gene.attributes |>
  filter(feature == 'CDS') |>
  ggplot(
    aes(x = width, colour = sample)
  ) +
  stat_bin(
    data = gene.atrributes.ncbi |> filter(feature == 'CDS'),
    aes(x = width, y = after_stat(count), group = sample),
    geom = 'step',
    position = 'identity',
    linewidth = 0.6,
    alpha = 0.7,
    colour = 'black'
  ) +
  stat_bin(
    aes(y = after_stat(count)),
    geom = 'step',
    position = 'identity',
    linewidth = 1.5,
    alpha = 0.7
  ) +
  labs(
    x = '\nFeature length (Kbp)',
    y = 'Count (Thousands)\n'
  ) +
  scale_x_log10(
    breaks = c(0.1, 1, 10, 1e2, 1e3, 1e4, 1e5, 1e6),
    labels = scales::trans_format("log10", scales::math_format(10^.x)),
    expand = c(0,0)
  ) +
  scale_y_continuous(
    breaks = seq(0, 2.25e5, 5e4),
    labels = scales::label_number(scale = 1e-3)
  ) +
  coord_cartesian(ylim = c(0,2e5), xlim = c(1, 1.5e6)) +
  scale_color_manual(values = RColorBrewer::brewer.pal(6, 'Set2')) +
  theme_bw() +
  theme(
    # Strip text
    strip.text = element_text(face = 'bold', size = 20),

    # Axis
    axis.text = element_text(size = 18),
    axis.title = element_text(size = 20, face = 'bold'),
    axis.title.y = element_blank(),

    # legend
    legend.position = 'bottom',
    legend.text = element_text(size = 18, face = 'italic'),
    legend.title = element_blank()
  ) +
  facet_wrap(~feature)

# Shared Y-axis label
y.lab <- ggplot() +
  annotate(geom = "text", x = 1, y = 1, label = 'Count (Thousands)', angle = 90, size = 8, fontface = 'bold') +
  coord_cartesian(clip = "off")+
  theme_void()

# ------------------------------------------------------------------------------------------------ #
# Save plot
grDevices::cairo_pdf(
  filename = here('figures','supplementary','figure-x-gene-feature-lengths.pdf'),
  width = 10,
  height = 10
)
y.lab + (plt.gene / plt.exon / plt.cds) + plot_layout(widths = c(0.1, 2))
invisible(dev.off())

