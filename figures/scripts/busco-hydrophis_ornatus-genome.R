# ------------------------------------------------------------------------------------------------ #
# Plot BUSCO: Hydrophis ornatus
#
# Script to plot all the BUSCO results in a single figure. Adapted from the actual BUSCO script
# responsible for producing these kinds of figures.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(here)
  library(ragg)
  library(fs)
  library(stringr)
  library(purrr)
  library(readr)
  library(tibble)
  library(tidyr)
  library(dplyr)
  library(magrittr)
  library(ggplot2)
})

# ------------------------------------------------------------------------------------------------ #
# Parameterise
my_ouput <- here('figures', 'supplementary', 'figure-x-busco-hydrophis-ornatus-genome.pdf')
my_width <- 30
my_height <- 15
my_unit <- "cm"

# Colors
my_colors <- c("#56B4E9", "#3492C7", "#F0E442", "#F04442")

# Bar height ratio
my_bar_height <- 0.75

# Legend
my_title <- expression(paste("BUSCO assessment: ", italic("Hydrophis ornatus"), ' assembly progress'))

# Font
my_family <- "sans"
my_size_ratio <- 1
labsize = 1

# ------------------------------------------------------------------------------------------------ #
# Load files
files <- dir_ls(
  path = here('assembly', 'other-snakes', 'genome_assessment', 'busco', 'hydrophis_ornatus'),
  glob = '*.txt',
  recurse = TRUE
) %>%
  as.character()

files <- files[str_detect(string = files, 'short_summary.specific')] %>%
  set_names(sub('.+_odb10.(.*).txt', '\\1', basename(.)))

# Clean names
n <- names(files)
n <- n %>%
  sub('hydro-ornatus_', '', .)
names(files) <- n

# Set levels
lvls <- c('3d-DNA', 'Purge', 'HyPo', 'Flye')

# Parse text into a table
dat <- files %>%
  imap_dfr(.id = 'assembly', ~{
    l <- read_lines(.x)

    # Get summary
    sm <- l[9]
    sm <- gsub('\\t|\\t\\s+', '', sm)
    #
    # # Get total number of genes in ortholog set
    n <- as.integer(as.character(sub('.+n:(.*)$', '\\1', sm)))

    # Get table of results
    l[10:15] %>%
      sub('\\t', '', .) %>%
      map_dfr(function(v){
        line <- unlist(str_split(string = v, pattern = '\\t', n = 2))
        tibble(
          measure = line[2],
          value = line[1]
        ) %>%
          mutate(
            measure = sub('\\t.*', '', measure)
          )
      }) %>%
      mutate(
        summary = sm,
        ntotal = n
      )
  }) %>%
  mutate(
    value = as.integer(as.character(value)),
    perc = value/ntotal * 100,
    category = str_extract(string = measure, pattern = '\\(.*\\)'),
    category = gsub('\\(|\\)', '', category),
    assembly = factor(x = assembly, levels = lvls),
    category = factor(x = category, levels = c('C', 'S', 'D', 'F', 'M')),
  ) %>%
  filter(
    !is.na(category),
    measure != 'Complete BUSCOs (C)'
  ) %>%
  arrange(assembly)

# ------------------------------------------------------------------------------------------------ #
# Create figure object
fig <- dat %>%
  ggplot() +
  geom_bar(
    aes(
      y = perc,
      x = assembly,
      fill = category
    ),
    position = position_stack(reverse = TRUE),
    data = dat,
    stat="identity",
    width=my_bar_height
  ) +
  coord_flip() +
  theme_gray(base_size = 8) +
  scale_x_discrete(limits = rev(levels(dat$assembly))) +
  scale_y_continuous(
    labels = c("0","20","40","60","80","100"),
    breaks = c(0,20,40,60,80,100)
  ) +
  scale_fill_manual(
    values = my_colors,
    labels =c(" Complete (C) and single-copy (S)  ",
              " Complete (C) and duplicated (D)",
              " Fragmented (F)  ",
              " Missing (M)")
  ) +
  ggtitle(my_title) +
  xlab("") +
  ylab("\n%BUSCOs") +
  theme(

    # Plot title
    plot.title = element_text(
      family=my_family,
      hjust=0.5,
      colour = "black",
      size = rel(2.2)*my_size_ratio,
      face = "bold"
    ),

    # Legend information
    legend.position = "top", legend.title = element_blank(),
    legend.text = element_text(
      family=my_family,
      size = 14 #rel(1.2) * my_size_ratio
    ),

    # Panel
    panel.background = element_rect(color="#FFFFFF", fill="white"),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),

    # Axis text
    axis.text.y = element_text(
      family = my_family,
      colour = "black",
      size = 14 #rel(1.66) * my_size_ratio
    ),
    axis.text.x = element_text(
      family=my_family,
      colour = "black",
      size = 14 #rel(1.66) * my_size_ratio
    ),

    # Axis lines (x and y)
    axis.line = element_line(linewidth = 1 * my_size_ratio, colour = "black"),

    # Axis ticks
    axis.ticks.y = element_line(colour="white", linewidth = 0),
    axis.ticks.x = element_line(colour="#222222"),
    axis.ticks.length = unit(0.4, "cm"),

    # Axis titles
    axis.title.x = element_text(
      family = my_family,
      face = 'bold',
      size = 16
    )
  ) +
  guides(fill = guide_legend(override.aes = list(colour = NULL))) +
  guides(fill = guide_legend(nrow=2, byrow = TRUE))

# ------------------------------------------------------------------------------------------------ #
# Append names to figures
tmp <- arrange(dat, assembly)
for (i in rev(1:length(lvls)) ) {
  s <- rev(
    distinct(
      .data = tmp,
      assembly,
      .keep_all = TRUE)[['summary']]
  )[i]

  fig <- fig +
    annotate(
      'text',
      label = s,
      y = 3,
      x = i,
      size = labsize * 5 * my_size_ratio,
      colour = "black",
      hjust = 0,
      family = my_family
    )
}

# ------------------------------------------------------------------------------------------------ #
# Save plot to file
grDevices::cairo_pdf(
  filename = my_ouput,
  width = 10,
  height = 10
)
fig
invisible(dev.off())
