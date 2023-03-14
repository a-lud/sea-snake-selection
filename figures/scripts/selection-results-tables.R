# ------------------------------------------------------------------------------------------------ #
# Table: Selection tables
#
# Generate tables for the selection results. These tables have all single-copy orthologs present
# and provide a single reference point. The LRT CSV files imported below have been generated from the
# '05-hyphy-codeml-overlap.R' script in the 'selection' directory.
#
# This script will generate a number of CSV files for each selection method (HyPhy and PAML).
# The idea is that these tables will be separate pages in an Excel spreadsheet provided as supp.
# data when published.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# Tables: Write selection results to supplementary directory
#   - PAML
#       - Branch-Site model results
#       - Site model results
#       - Drop-out LRT results
#   - BUSTED-PH
#       - Model fit table
#           - Constrained
#           - Unconstrained
#           - Shared
#       - LRT table between three conditions
#   - Marine PSGs (shared between above methods)
#       - Orthogroup, Gene, LRT, DF, P-value etc...
#   - RELAX results
#       -

annotation <- read_csv(
  file = here('orthologs','ortholog-annotation','results','ortholog-annotation','orthologs.csv'),
  col_names = TRUE,
  col_types = cols()
) |>
  select(file = orthogroup, symbol)

paml.bs <- read_csv(
  file = here('selection','results','paml','ete-standard-summary','model-branch-site.csv'),
  col_names = TRUE,
  col_types = cols()
)

paml.s <- read_csv(
  file = here('selection','results','paml','ete-dropout-summary','model-site.csv'),
  col_names = TRUE,
  col_types = cols()
)

paml.lrt <- read_csv(
  file = here('selection','results','results-PSGs','PSGs-paml-corrected.csv'),
  col_names = TRUE,
  col_types = cols()
)

bustedph.obj <- read_rds(here('selection','r-data','busted-ph.rds'))

busted.lrt <- read_csv(
  file = here('selection','results','results-PSGs','PSGs-bustedph-corrected.csv'),
  col_names = TRUE,
  col_types = cols()
)

# Contains AIC-c/Df values
busted.general <- bustedph.obj$fits$general |>
  mutate(file = sub('.clean', '', file))

relax <- read_rds(here('selection','r-data','relax.rds'))

relax.lrt <- read_csv(
  file = here('selection','results','results-PSGs','relax-corrected.csv'),
  col_names = TRUE,
  col_types = cols()
)

# ------------------------------------------------------------------------------------------------ #
# PAML

# Branch-Site model results - separate files for Null and Alt runs
paml.bs |>
  left_join(annotation) |>
  (\(x) split(x, x$model))() |>
  map(
    select,
    Orthogroup = file, Gene = symbol, Model = model, `Tree length` = `tree-length`,
    Lnl, Df = np, Kappa = kappa,
    `Proportion 0` = proportion_0, `Background 0` = background_0, `Foreground 0` = foreground_0,
    `Proportion 1` = proportion_1, `Background 1` = background_1, `Foreground 1` = foreground_1,
    `Proportion 2a` = proportion_2, `Background 2a` = background_2, `Foreground 2a` = foreground_2,
    `Proportion 2b` = proportion_3, `Background 2b` = background_3, `Foreground 2b` = foreground_3,
  ) |>
  iwalk(\(df, nm) {
    # File name
    name = ifelse(
     nm == 'bsA',
     'table-x-selection-paml-branch-site-alternate-model-fit.csv',
     'table-x-selection-paml-branch-site-null-model-fit.csv'
    )

    write_csv(
      x = df,
      file = here('figures', 'supplementary', name),
      col_names = TRUE,
      na = ''
    )
  })

# Site model results - separate files for Null and Alt runs
paml.s |>
  left_join(annotation) |>
  (\(x) split(x, x$model))() |>
  imap(\(df, nm) {
    if (nm == 'M1') {
      df.filt <- df |>
        select(
          Orthogroup = file, Gene = symbol, Model = model, `Tree length` = `tree-length`,
          Lnl, Df = np, Kappa = kappa, `Site class model` = siteClassModel,
          `Proportion 0` = proportion_0, `Omega 0` = omega_0,
          `Proportion 1` = proportion_1, `Omega 1` = omega_1
        )
    } else {
      df.filt <- df |>
        select(
          Orthogroup = file, Gene = symbol, Model = model, `Tree length` = `tree-length`,
          Lnl, Df = np, Kappa = kappa, `Site class model` = siteClassModel,
          `Proportion 0` = proportion_0, `Omega 0` = omega_0,
          `Proportion 1` = proportion_1, `Omega 1` = omega_1,
          `Proportion 2` = proportion_2, `Omega 2` = omega_2

        )
    }
  }) |>
  iwalk(\(df, nm) {
    # File name
    name = ifelse(
      nm == 'M2',
      'table-x-selection-paml-site-alternate-model-fit.csv',
      'table-x-selection-paml-site-null-model-fit.csv'
    )

    write_csv(
      x = df,
      file = here('figures', 'supplementary', name),
      col_names = TRUE,
      na = ''
    )
  })

# Drop-out LRT results - Branch-Site and Site models (drop-out) are in the same table
paml.lrt |>
  left_join(annotation) |>
  unite(
    col = 'Branch-Site (null/alt)',
    sep = '/',
    remove = TRUE,
    c(null_x, alt_x)
  ) |>
  unite(
    col = 'Site (null/alt)',
    sep = '/',
    remove = TRUE,
    c(null_y, alt_y)
  ) |>
  mutate(
    across(
      .cols = where(is.numeric),
      .fns = ~ round(.x, digits = 3)
    )
  ) |>
  select(
    Orthogroup = file,
    Gene = symbol,
    `Branch-Site (null/alt)`,
    `LRT (BS)` = lrt_x,
    `P-value (BS)` = pval_x,
    `Adj. P-value (BS)` = pval_x_adj,
    `Site (null/alt)`,
    `LRT (S)` = lrt_y,
    `P-value (S)` = pval_y,
    `Adj. P-value (S)` = pval_y_adj,
    Signal = signal
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-paml-LRT-dropout.csv'),
    col_names = TRUE,
    na = ''
  )

# ------------------------------------------------------------------------------------------------ #
# BUSTED-PH

# Constrained model - Constrained model only run if unconstrained model shows some signal of PS
# Therefore, the number of genes in this table will be less than total number of orthologs
bustedph.obj$fits$constrained |>
  mutate(file = sub('.clean', '', file), Model = 'Constrained') |>
  left_join(annotation) |>
  left_join(busted.general) |>
  unite(col = 'tmp', sep = ' ', remove = TRUE, c(branch, `rate class`)) |>
  pivot_wider(names_from = tmp, values_from = c(omega, proportion), names_sep = ' ') |>
  select(
    Orthogroup = file,
    Gene = symbol,
    Model,
    `Log likelihood`,
    `Estimated parameters`,
    `Proportion background 0` = `proportion Background 0` ,`Omega background 0` = `omega Background 0`,
    `Proportion test 0` = `proportion Test 0`, `Omega test 0` = `omega Test 0`,
    `Proportion background 1` = `proportion Background 1` ,`Omega background 1` = `omega Background 1`,
    `Proportion test 1` = `proportion Test 1`, `Omega test 1` = `omega Test 1`,
    `Proportion background 2` = `proportion Background 2` ,`Omega background 2` = `omega Background 2`,
    `Proportion test 2` = `proportion Test 2`, `Omega test 2` = `omega Test 2`
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-bustedph-constrained-model-fit.csv'),
    col_names = TRUE,
    na = ''
  )

# Unconstrained model
bustedph.obj$fits$unconstrained |>
  mutate(file = sub('.clean', '', file), Model = 'Unconstrained model') |>
  left_join(annotation) |>
  left_join(busted.general) |>
  unite(col = 'tmp', sep = ' ', remove = TRUE, c(branch, `rate class`)) |>
  pivot_wider(names_from = tmp, values_from = c(omega, proportion), names_sep = ' ') |>
  select(
    Orthogroup = file,
    Gene = symbol,
    Model,
    `Log likelihood`,
    `Estimated parameters`,
    `Proportion background 0` = `proportion Background 0` ,`Omega background 0` = `omega Background 0`,
    `Proportion test 0` = `proportion Test 0`, `Omega test 0` = `omega Test 0`,
    `Proportion background 1` = `proportion Background 1` ,`Omega background 1` = `omega Background 1`,
    `Proportion test 1` = `proportion Test 1`, `Omega test 1` = `omega Test 1`,
    `Proportion background 2` = `proportion Background 2` ,`Omega background 2` = `omega Background 2`,
    `Proportion test 2` = `proportion Test 2`, `Omega test 2` = `omega Test 2`
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-bustedph-unconstrained-model-fit.csv'),
    col_names = TRUE,
    na = ''
  )

# Shared distribution model
bustedph.obj$fits$shared |>
  mutate(file = sub('.clean', '', file), Model = 'Shared distribution model') |>
  left_join(annotation) |>
  left_join(busted.general) |>
  pivot_wider(names_from = `rate class`, values_from = c(omega, proportion), names_sep = ' ') |>
  select(
    Orthogroup = file,
    Gene = symbol,
    Model,
    `Log likelihood`,
    `Estimated parameters`,
    `Proportion 0` = `proportion 0` ,`Omega 0` = `omega 0`,
    `Proportion 1` = `proportion 1` ,`Omega 1` = `omega 1`,
    `Proportion 2` = `proportion 2` ,`Omega 2` = `omega 2`
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-bustedph-shared-model-fit.csv'),
    col_names = TRUE,
    na = ''
  )

# LRT statistics between the three models above for each gene
read_csv(
  file = here('selection','results','results-PSGs','PSGs-bustedph-corrected.csv'),
  col_names = TRUE,
  col_types = cols()
) |>
  left_join(annotation) |>
  select(
    Orthogroup = file,
    Gene = symbol,
    `LRT P-value (Test)` = `test results`,
    `LRT Adj. p-value (Test)` = adj_test,
    `LRT P-value (Background)` = `test results background`,
    `LRT Adj. p-value (Background)` = adj_background,
    `LRT Distributions` = `test results shared distribution`,
    `LRT Adj. p-value (Distributions)` = adj_dist,
    Signal = result
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-bustedph-LRT.csv'),
    col_names = TRUE
  )

# ------------------------------------------------------------------------------------------------ #
# Marine specific PSGs

busted.lrt |>
  left_join(paml.lrt) |>
  left_join(annotation) |>
  filter(
    str_detect(result, pattern = 'Selection associated with trait'),
    signal == 'PS_fg'
  ) |>
  unite(
    col = 'Branch-Site (null/alt)',
    sep = '/',
    remove = TRUE,
    c(null_x, alt_x)
  ) |>
  unite(
    col = 'Site (null/alt)',
    sep = '/',
    remove = TRUE,
    c(null_y, alt_y)
  ) |>
  select(
    Orthogroups = file,
    Gene = symbol,
    `LRT P-value (Test)` = `test results`,
    `LRT Adj. p-value (Test)` = adj_test,
    `LRT P-value (Background)` = `test results background`,
    `LRT Adj. p-value (Background)` = adj_background,
    `LRT Distributions` = `test results shared distribution`,
    `LRT Adj. p-value (Distributions)` = adj_dist,
    `Branch-Site (null/alt)`,
    `LRT (BS)` = lrt_x,
    `P-value (BS)` = pval_x,
    `Adj. P-value (BS)` = pval_x_adj,
    `Site (null/alt)`,
    `LRT (Site)` = lrt_y,
    `P-value (Site)` = pval_y,
    `Adj. P-value (Site)` = pval_y_adj,
    `Signal (BUSTED-PH)` = result,
    `Signal (PAML)` = signal
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-marinePSG.csv'),
    col_names = TRUE
  )

# ------------------------------------------------------------------------------------------------ #
# Write RELAX results to file
relax.fits <- relax$fits$general |> mutate(file = sub('\\..*', '', file))

relax$fits$`General descriptive` |>
  mutate(
    file = sub('\\..*', '', file),
    Model = 'General descriptive'
  ) |>
  left_join(annotation) |>
  left_join(relax.fits) |>
  pivot_wider(names_from = `rate class`, values_from = c(omega, proportion), names_sep = ' ') |>
  select(
    Orthogroups = file,
    Gene = symbol,
    Model,
    `AIC-c`, `Lnl` = `Log likelihood`, `Estimated parameters`,
    `Proportion 0` = `proportion 0`, `Omega 0` = `omega 0`,
    `Proportion 1` = `proportion 1`, `Omega 1` = `omega 1`,
    `Proportion 2` = `proportion 2`, `Omega 2` = `omega 2`,
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-relax-general_descriptive.csv'),
    col_names = TRUE,
    na = ''
  )

relax$fits$`RELAX alternative` |>
  mutate(
    file = sub('\\..*', '', file),
    Model = 'RELAX alternative'
  ) |>
  left_join(annotation) |>
  left_join(relax.fits) |>
  pivot_wider(names_from = c(branch, `rate class`), values_from = c(omega, proportion), names_sep = ' ') |>
  select(
    Orthogroups = file,
    Gene = symbol,
    Model,
    `AIC-c`, `Lnl` = `Log likelihood`, `Estimated parameters`,

    `Proportion reference 0` = `proportion Reference 0`, `Omega Reference 0` = `omega Reference 0`, `Omega Test 0` = `omega Test 0`,
    `Proportion reference 1` = `proportion Reference 1`, `Omega Reference 1` = `omega Reference 1`, `Omega Test 1` = `omega Test 1`,
    `Proportion reference 2` = `proportion Reference 2`, `Omega Reference 2` = `omega Reference 2`, `Omega Test 2` = `omega Test 2`,
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-relax-alternative.csv'),
    col_names = TRUE,
    na = ''
  )

relax$fits$`RELAX null` |>
  mutate(
    file = sub('\\..*', '', file),
    Model = 'RELAX null'
  ) |>
  left_join(annotation) |>
  left_join(relax.fits) |>
  pivot_wider(names_from = c(branch, `rate class`), values_from = c(omega, proportion), names_sep = ' ') |>
  select(
    Orthogroups = file,
    Gene = symbol,
    Model,
    `AIC-c`, `Lnl` = `Log likelihood`, `Estimated parameters`,

    `Proportion reference 0` = `proportion Reference 0`, `Omega Reference 0` = `omega Reference 0`, `Omega Test 0` = `omega Test 0`,
    `Proportion reference 1` = `proportion Reference 1`, `Omega Reference 1` = `omega Reference 1`, `Omega Test 1` = `omega Test 1`,
    `Proportion reference 2` = `proportion Reference 2`, `Omega Reference 2` = `omega Reference 2`, `Omega Test 2` = `omega Test 2`,
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-relax-null.csv'),
    col_names = TRUE,
    na = ''
  )

relax$fits$`RELAX partitioned descriptive` |>
  mutate(
    file = sub('\\..*', '', file),
    Model = 'General descriptive'
  ) |>
  left_join(annotation) |>
  left_join(relax.fits) |>
  pivot_wider(names_from = c(branch, `rate class`), values_from = c(omega, proportion), names_sep = ' ') |>
  select(
    Orthogroups = file,
    Gene = symbol,
    Model,
    `AIC-c`, `Lnl` = `Log likelihood`, `Estimated parameters`,

    `Proportion reference 0` = `proportion Reference 0`, `Omega Reference 0` = `omega Reference 0`, `Omega Test 0` = `omega Test 0`,
    `Proportion reference 1` = `proportion Reference 1`, `Omega Reference 1` = `omega Reference 1`, `Omega Test 1` = `omega Test 1`,
    `Proportion reference 2` = `proportion Reference 2`, `Omega Reference 2` = `omega Reference 2`, `Omega Test 2` = `omega Test 2`,
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-relax-partitioned_descriptive.csv'),
    col_names = TRUE,
    na = ''
  )

relax.lrt |>
  select(
    Orthogroups = orthogroup,
    Gene = symbol,
    k,
    LRT = lrt,
    `P-value` = pval,
    `Adj. P-value` = adj_pval
  ) |>
  write_csv(
    file = here('figures','supplementary','table-x-selection-relax-LRT.csv'),
    col_names = TRUE,
    na = ''
  )
