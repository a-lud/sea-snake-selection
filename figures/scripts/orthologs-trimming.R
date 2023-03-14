# ------------------------------------------------------------------------------------------------ #
# Sequence gap summary
#
# MSA statistics were generated using the custom program 'msaSummary', which reports a long-form
# CSV file with file name, sample, alignment length, sample sequence length (i.e. without gaps) and
# the position of each gap for a sample.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

lvls <- c(
  "Hydrophis curtus", "Hydrophis curtus-AG", "Hydrophis cyanocinctus",
  "Hydrophis elegans", "Hydrophis major", "Hydrophis ornatus",
  "Notechis scutatus", "Pseudonaja textilis", "Pantherophis guttatus",
  "Crotalus tigris", "Protobothrops mucrosquamatus", "Thamnophis elegans", "Python bivittatus"
)

# ------------------------------------------------------------------------------------------------ #
# Read MSA summary files with gap statistics before/after filtering
csvs <- fs::dir_ls(
  path = here('orthologs', 'ortholog-detection', 'results', 'orthologs-correct', 'msa-summary'),
  glob = '*.csv',
  recurse = TRUE
) %>%
  set_names(sub('.csv', '', basename(.))) |>
  map(vroom::vroom, delim = ',', col_names = TRUE,col_types = cols()) |>
  list_rbind(names_to = 'id') |>
  filter(!is.na(gap_position)) |>
  group_by(id, sample, file, seq_len, msa_length) |>
  summarise(ngaps = n()) |>
  ungroup() |>
  mutate(
    prop = ngaps/seq_len,
    sample = sub('_', ' ', str_to_title(sample)),
    sample = sub('-Ag', '-AG', sample),
    id = str_to_sentence(id),
    id = factor(id, levels = c('Pre-trimming', 'Post-trimming')),
    sample = factor(sample, levels = lvls)
  )

# ------------------------------------------------------------------------------------------------ #
# Identify poorly aligned orthogroups - gap proportion can be high when only a portion of a gene
# has been annotated.
# csvs |>
#   filter(prop > 0.5 & prop < 0.6) |>
#   pull(file)

# ------------------------------------------------------------------------------------------------ #
# Box-plot of gap-number across all orthologs per sample. Values higher than 1 indicate alignments
# where the number of gaps in the alignment is greater than the length of the gene-fragment that
# could be found for a sample. The smaller gene fragments are likely partial gene annotations
# or misclassification.
options(scipen = 999)
png(
  filename = here('figures','supplementary','figure-x-msa-gaps.png'),
  width = 1000,
  height = 1000,
  units = 'px'
)
csvs |>
  ggplot(
    aes(
      x = sample,
      y = prop,
      fill = id
    )
  ) +
  # geom_violin(alpha = 0.6, position = 'dodge') +
  geom_boxplot(alpha = 0.5) +
  scale_fill_manual(values = c('red', 'black')) +
  scale_y_log10(breaks = c(0.001, 0.01, 0.1, 1, 10)) +
  labs(
    y = 'Gaps as a proportion of sequence length'
  ) +
  theme_bw() +
  theme(
    # Axis text/title
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 16, face = 'bold'),

    axis.text.x = element_text(size = 14, angle = 45, hjust = 1, vjust = 0.99, face = 'italic'),
    axis.text.y = element_text(size = 14),

    # Legend
    legend.text = element_text(size = 14),
    legend.title = element_blank(),
    legend.position = 'bottom'
  )
invisible(dev.off())
