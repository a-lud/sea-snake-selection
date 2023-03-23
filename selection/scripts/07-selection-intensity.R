# ------------------------------------------------------------------------------------------------ #
# Selection intensity results
#
# We ran HyPhy's RELAX to identify genes experiencing significant intensification/relaxation of
# selection. This script parses the results and exports
# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(ComplexUpset)
  library(tidyverse)
  library(here)
  library(patchwork)

  source(here('selection', 'scripts', 'hyphy-parsing', 'general.R'))
})

# single-copy ortholog gene annotations
annotations <- read_csv(
  here('orthologs','ortholog-annotation','results','ortholog-annotation','orthologs.csv'),
  col_names = TRUE,
  col_types = cols()
)

# ------------------------------------------------------------------------------------------------ #
# Output directory
outdir <- here('selection','results','results-selection-intensification')
outdir.tables <- here('selection', 'results', 'results-tables')
fs::dir_create(path = outdir)
fs::dir_create(outdir.tables)

# ------------------------------------------------------------------------------------------------ #
# Import RELAX object and PSGs (generated in script 06-psg.R)

# RELAX results
relax <- read_rds(here('selection', 'r-data', 'relax.rds'))

# PSGs/insignificant genes
psg.marine <- read_lines(here('selection','results','results-PSGs','PSGs-marine.txt'))
psg.terrestrial <- read_lines(here('selection','results','results-PSGs','PSGs-terrestrial.txt'))
psg.shared <- read_lines(here('selection','results','results-PSGs','PSGs-shared.txt'))
neutral.genes <- read_lines(here('selection','results','results-PSGs','neutral-genes.txt'))

# ------------------------------------------------------------------------------------------------ #
# RELAX: Multiple correction and classify orthologs
relax$`test results corrected` <- pcorrRELAX(
  relax,
  p = 0.01,
  corrMethod = 'fdr'
) |>
  mutate(file = sub('.clean', '', file)) |>
  rename(k = `relaxation or intensification parameter`) |>
  mutate(
    signif = ifelse(adj_pval <= 0.01, 'Significant', 'Insignificant'),
    grouping = case_when(
      k > 1 ~ 'Intensification',
      k < 1 ~ 'Relaxation',
      k == 1 ~ 'Neutral'
    )
  ) |>
  left_join(annotations[,1:2], by = join_by(file == orthogroup)) |>
  select(orthogroup = file, symbol, everything())

write_csv(
  relax$`test results corrected`,
  file = here(outdir.tables,'relax-corrected.csv'),
  col_names = TRUE
)
write_rds(relax, here('selection', 'r-data', 'relax.rds'), compress = 'gz')

# ------------------------------------------------------------------------------------------------ #
# Relaxation results: signif (relaxation/intensification)/insignif

# Significant # 2,119
relax$`test results corrected` |> filter(signif == 'Significant') |> nrow()

# Significant (K > 1) # 1677 at p-adj <= 0.01
relax.sig.intense <- relax$`test results corrected` |>
  filter(signif == 'Significant', grouping == 'Intensification') |>
  pull(orthogroup)

# Significant (K < 1) # 442 at p-adj <= 0.01
relax.sig.relax <- relax$`test results corrected` |>
  filter(signif == 'Significant', grouping == 'Relaxation') |>
  pull(orthogroup)

# Inisignificant # 6532 at p-adj >= 0.01
relax.insignif <- relax$`test results corrected` |>
  filter(signif == 'Insignificant') |>
  pull(orthogroup)

# Number of orthogroups accounted for = 8651 (3 are known to have failed)
sum(unlist(map(list(relax.sig.intense, relax.sig.relax, relax.insignif), length)))

# ------------------------------------------------------------------------------------------------ #
# Write PSG experiencing significant intersections/relaxation (RELAX) to file
psg.marine[psg.marine %in% relax.sig.intense] |> write_lines(file = here(outdir, 'psg-marine-intensification.txt'))
psg.marine[psg.marine %in% relax.sig.relax] |> write_lines(file = here(outdir, 'psg-marine-relaxation.txt'))

