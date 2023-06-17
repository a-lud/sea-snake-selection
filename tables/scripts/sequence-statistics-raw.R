options(scipen = 999)
library(tidyverse)

# Match file with species
hmaj <- c('350844', '350840', '350841', '350842', '350843', '350845')
horn <- c('SRR16961052', 'SRR17056027', 'SRR17056026', 'SRR16961054')
hcur <- c('SRR16961053', 'SRR17056029', 'SRR17056028', 'SRR16961058', 'SRR16961055')
hele <- c('hydrophis', 'Hydrophis')

fs::dir_ls(
  path = 'data/sequence/statistics',
  glob = '*.tsv',
  recurse = TRUE
) |>
  read_tsv(id = 'data', col_names = TRUE, col_types = cols()) |>
  mutate(
    Stage = basename(dirname(dirname(data))),
    data = basename(dirname(data)),
    data = case_when(
      data == 'hifi' ~ 'HiFi',
      data == 'hic' ~ 'Hi-C',
      data == 'rna' ~ 'RNA',
      data == 'nanopore' ~ 'Nanopore',
      data == 'wgs' ~ 'WGS'
    ),
    Stage = case_when(
      Stage == 'raw' ~ 'Raw',
      Stage == 'trimmed' ~ 'Trimmed'
    ),
    data = factor(data, levels = c('HiFi', 'Hi-C', 'RNA', 'Nanopore', 'WGS')),
    file = str_remove(file, '_.*|-.*|.fast.*'),
    Sample = case_when(
      file %in% hmaj ~ 'Hydrophis major',
      file %in% horn ~ 'Hydrophis ornatus',
      file %in% hcur ~ 'Hydrophis curtus (AG)',
      file %in% hele ~ 'Hydrophis elegans'
    ),
    Sample = factor(Sample, levels = c('Hydrophis major', 'Hydrophis ornatus', 'Hydrophis curtus (AG)', 'Hydrophis elegans'))
  ) |>
  arrange(Sample, Stage, data) |>
  select(
    Sample,
    Stage,
    Data = data,
    File = file,
    `Total seqs` = num_seqs,
    `Total length` = sum_len,
    `Avg. length` = avg_len,
    N50,
    `Q20(%)`, `Q30(%)`
  ) |> write_csv(
    'tables/table-x-sequence-statistics.csv',
    col_names = TRUE
  )
