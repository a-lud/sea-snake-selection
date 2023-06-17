# ------------------------------------------------------------------------------------------------ #
# REVIGO MDS - PANTHER enriched GO terms
#
# REVIGO generates an MDS of the GO terms. GO terms grouped as semantically similar should appear
# in a similar vicinity. Points in the MDS are 'representative' GO terms determined by the
# semantic similarity clustering. The box highlighting multiple terms is taken from the TreeMap
# file, representing a two-level hierarchy. That is, cluster representatives are futher joined into
# high-level groups that can be interpreted with ease.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
  library(fs)
  library(patchwork)
})

# ------------------------------------------------------------------------------------------------ #
# Clean up MDS data
df.mds <- dir_ls(
  path = here('go-enrichment','results','revigo','enriched'),
  glob = '*Scatterplot.tsv'
) |>
  read_tsv(
    col_names = TRUE,
    col_types = cols(),
    id = 'Ontology'
  ) |>
  filter(PC_0 != 'null') |>
  mutate(
    Ontology = toupper(sub('.+_(.*)_Scatterplot.tsv', '\\1', basename(Ontology))),
    across(
      starts_with('PC_'),
      as.numeric
    ),
    Name = str_to_sentence(Name),
    Name = str_replace(Name, 'Trna', 'tRNA')
  ) |>
  select(-Representative)

# ------------------------------------------------------------------------------------------------ #
# Make MDS plots for available ontologies (BP and CC) - Anolis as reference
mds <- df.mds |>
  (\(x) split(x, x$Ontology))() |>
  map(\(df) {
    df |>
    ggplot(
      aes(
        x = PC_0,
        y = PC_1,
        label = Name
      )
    ) +
      geom_point(
        aes(fill = Value, size = LogSize),
        colour = 'black',
        pch=21
        # size = 6
      ) +
      # scale_size_area() +
      scale_size(range=c(0,15),
                 breaks=c(4,5,6,7)) +
      labs(
        x = '\nSemantic space X',
        y = 'Semantic space Y\n',
        fill = expression(paste(plain(Log)[10], "(FDR)")),
        size = expression(paste(plain(Log)[10], "(No. GO Term annotations in GOA DB)")),
      ) +
      ggrepel::geom_label_repel(
        force = 6,
        max.overlaps = 3,
        box.padding = 0.5,
        aes(point.size = LogSize)
      ) +
      viridis::scale_fill_viridis() +
      facet_wrap(~Ontology) +
      theme_bw() +
      theme(
        axis.text = element_text(size = 14),
        axis.title = element_text(size = 16, face = 'bold'),
        # axis.text = element_blank(),
        # axis.title = element_blank(),
        # axis.ticks = element_blank(),

        strip.text = element_text(size = 16, face = 'bold'),

        legend.title = element_text(size = 16),
        legend.text = element_text(size = 14),
        legend.position = 'bottom',
        legend.key.size = unit(2, "cm")
      ) +
      guides(
        fill = guide_colourbar(title.position="top", title.hjust = 0.5),
        size = guide_legend(title.position="top", title.hjust = 0.5)
      )
  })

mds |>
  imap(\(df, id) {
  pdf(
    file = here('figures','manuscript', glue::glue('figure-x-mds-{id}.pdf')),
    width = 8,
    height = 8,
  )
  print(df)
  invisible(dev.off())
})

