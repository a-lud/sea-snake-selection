# ------------------------------------------------------------------------------------------------ #
# Annotate Orthogroups
#
# This script combines orthogroup annotation sources into a single annotation CSV. The sources of
# information include:
#
#     - NCBI GFF3 files: Gene symbols
#     - Funannotate 'annotations' file: Gene symbols/GO Terms
#     - Wei2GO: GO Terms
#     - Best-BLAST-hits to UniProt-SwissProt: GO Terms/Gene symbols
#
# Gene symbols and GO Term data are merged into a non-redundant set of annotations that can then be
# used for downstream analyses e.g. Enrichement testing. Examples of what each dataframe should look
# like are provided above each main variable name.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
  library(fs)
})

# ------------------------------------------------------------------------------------------------ #
# Ortholog data
orthogroups <- read_tsv(
  file = here('orthologs','ortholog-detection','results','orthologs','Orthogroups','Orthogroups.tsv'),
  col_names = TRUE,
  col_types = cols()
)

# Single copy orthologs
orthogroups.single.copy <- read_tsv(
  file = here('orthologs','ortholog-detection','results','orthologs','Orthogroups','Orthogroups_SingleCopyOrthologues.txt'),
  col_names = 'Orthogroup',
  col_types = cols()
)

# Single copy orthologs only
single.copy.orthologs <- left_join(orthogroups.single.copy, orthogroups) %>%
  pivot_longer(
    names_to = 'sample',
    values_to = 'transcriptID', 2:14
  ) %>%
  rename(orthogroup = Orthogroup)

# ------------------------------------------------------------------------------------------------ #
# Annotation data

# NCBI GFF3: Gene symbols
# A tibble: 181,505 × 3
#     sample              transcriptID       symbol_ncbi
#     <chr>               <chr>              <chr>
#   1 pseudonaja_textilis rna-XM_026703005.1 GATA3
#   2 pseudonaja_textilis rna-XM_026707001.1 CELF2
#   3 pseudonaja_textilis rna-XM_026707089.1 CELF2
ncbi.symbol <- read_csv(
  file = here('orthologs','ortholog-annotation','results','ncbi-genes','ncbi-gene-symbols.csv'),
  col_names = c('sample', 'transcriptID', 'symbol_ncbi'),
  col_types = cols()
) |>
  mutate(symbol_ncbi = toupper(symbol_ncbi))

# Funannotate 'annotations': Gene symbols + GO Terms
# A tibble: 31,287 × 4
#   transcriptID    symbol_funannotate GO_funannotate sample
#   <chr>           <chr>              <list>         <chr>
#   1 FUN_000007-T1 AKAP9              <chr [2]>      hydrophis_curtus
#   2 FUN_000008-T1 CYB5A              <chr [1]>      hydrophis_curtus
#   3 FUN_000009-T1 PLCB3              <chr [7]>      hydrophis_curtus
funannotate.symbol.go <- dir_ls(
  path = here('orthologs','ortholog-annotation','results','funannotate-annotations'),
  glob = "*.tsv"
) |>
  read_tsv(
    col_names = c('geneID', 'transcriptID', 'symbol_funannotate', 'GO_funannotate'),
    col_types = cols(),
    id = 'sample',
    col_select = -geneID
  ) |>
  mutate(
    sample = sub('.tsv', '', basename(sample)),
    sample = tolower(sample),

    symbol_funannotate = sub('_\\d+$', '', symbol_funannotate),
    symbol_funannotate = toupper(symbol_funannotate),

    GO_funannotate = str_split(GO_funannotate, ' ')
  ) |>
  filter(
    if_all(c(symbol_funannotate,GO_funannotate), ~ !is.na(.))
  )

# Wei2GO: GO Terms
# A tibble: 255,466 × 3
# sample          transcriptID       GO_wei2go
# <chr>           <chr>              <list>
# 1 crotalus_tigris rna-XM_039344534.1 <chr [16]>
# 2 crotalus_tigris rna-XM_039344533.1 <chr [5]>
# 3 crotalus_tigris rna-XM_039344537.1 <chr [11]>
wei2go.go <- dir_ls(
  path = here('orthologs','ortholog-annotation','results','wei2go'),
  glob = "*.tsv"
) |>
  vroom::vroom(
    col_names = TRUE,
    col_types = cols(),
    id = 'sample',
    col_select = -Score
  ) |>
  mutate(
    sample = sub('.tsv', '', basename(sample))
  ) |>
  rename(transcriptID = Protein, GO_wei2go = `GO term`) |>
  group_by(sample, transcriptID) |>
  mutate(GO_wei2go = list(GO_wei2go)) |>
  ungroup() |>
  select(sample, transcriptID, GO_wei2go) %>%
  distinct()

# Annotated best-BLAST-hits
blast.best.hits <- read_csv(
  file = here('orthologs','ortholog-annotation','results','blast-uniprot', 'best-hits.csv'),
  col_names = TRUE,
  col_types = cols()
) |>
  rename(sample = species, transcriptID = qaccver, accession = saccver)

idmap.symbol <- read_csv(
  file = here('orthologs','ortholog-annotation','results','idmapping', 'idmapping.dat.csv'),
  col_names = TRUE,
  col_types = cols(),
  col_select = -idtype
) |>
  rename(symbol_blast = id) |>
  group_by(accession) |>
  # Some accessions have multiple associated symbols
  mutate(
    symbol_blast = toupper(symbol_blast),
    count = n(),
    symbol_blast = ifelse(count != 1, paste0(symbol_blast, collapse = '; '), symbol_blast)
  ) |>
  ungroup() |>
  distinct()

idmapping.go <- read_csv(
  file = here('orthologs','ortholog-annotation','results','idmapping', 'idmapping_selected.tab.csv'),
  col_names = TRUE,
  col_types = cols()
) |>
  rename(GO_blast = GO) |>
  mutate(GO_blast = str_split(GO_blast, '; '))

# A tibble: 57,564 × 4
#     sample            transcriptID                 symbol_blast GO_blast
#     <chr>             <chr>                        <chr>        <list>
#   1 python_bivittatus rna-NC_021479.1:15192..16305 MT-CYB       <chr [5]>
#   2 python_bivittatus rna-NC_021479.1:2589..3555   MT-ND1       <chr [4]>
#   3 python_bivittatus rna-NC_021479.1:6397..7998   MT-CO1       <chr [7]>
blast.symbols.go <- reduce(
  list(blast.best.hits, idmap.symbol, idmapping.go),
  left_join
) |>
  select(-accession, -count)

# ------------------------------------------------------------------------------------------------ #
# Join all annotation information into non-redundant dataset
# A tibble: 8,654 × 3
# orthogroup symbol GO
# <chr>      <chr>  <chr>
# 1 OG0005294  CALU GO:0016020 GO:0005794 GO:0042470 ... GO:0055091 ...
# 2 OG0005295  IRF5 GO:0003700 GO:0045944 GO:0042802 ... GO:0048468 ...
# 3 OG0005298  SEMA6A GO:0016021 GO:0005886 ... GO:0050919 GO:0038 ...
annotation <- reduce(
  .x = list(single.copy.orthologs, ncbi.symbol, funannotate.symbol.go, wei2go.go, blast.symbols.go),
  .f = left_join
) |>
  group_by(orthogroup) |>
  nest() |>
  ungroup() |>
  pmap(.progress = TRUE, \(orthogroup, data) {
    # 1. Unique GO Terms: Wei2GO/Funannotate/Best-BLAST
    go.wei2go <- data$GO_wei2go |> unlist() |> unique()
    go.fun <- data$GO_funannotate |> unlist() |> unique()
    go.blast <- data$GO_blast |> unlist() |> unique()
    go <- c(go.wei2go, go.fun, go.blast) |> unique()

    # 2. Gene symbols: NCBI/Funannotate/Best-BLAST
    symbol.ncbi <- data$symbol_ncbi |>
      unique()
    symbol.ncbi <- symbol.ncbi[!is.na(symbol.ncbi)]
    symbol.ncbi <- ifelse(length(symbol.ncbi) > 1, paste0(symbol.ncbi, collapse = ' '), symbol.ncbi)

    symbol.fun <- data$symbol_funannotate |>
      unique()
    symbol.fun <- symbol.fun[!is.na(symbol.fun)]
    symbol.fun <- ifelse(length(symbol.fun) > 1, paste0(symbol.fun, collapse = ' '), symbol.fun)

    symbol.blast <- data$symbol_blast |>
      unique()
    symbol.blast <- symbol.blast[!is.na(symbol.blast)]
    symbol.blast <- ifelse(length(symbol.blast) > 1, paste0(symbol.blast, collapse = ' '), symbol.blast)

    all.symbol <- c(symbol.ncbi, symbol.fun, symbol.blast)

    # Annotation hierarchy: NCBI > Funannotate > BLAST

    # If all annotation sources are NA
    if (all(is.na(all.symbol)) || all(is_empty(all.symbol))) {
      symbol <- NA_character_
    } else if (!is.na(symbol.ncbi) || !is_empty(symbol.ncbi)) {
      symbol <- symbol.ncbi
    } else if (!is.na(symbol.fun) | !is_empty(symbol.fun)) {
      symbol <- symbol.fun
    } else {
      symbol <- symbol.blast
    }

    # 3. Return tibble of ogid, gene-symbol, GO Terms
    tibble(
      'orthogroup' = orthogroup,
      'symbol' = symbol,
      'GO' = paste0(go, collapse = ' ')
    )
  }) |>
  list_rbind()


# ------------------------------------------------------------------------------------------------ #
# All orthogroups
all.orthogroups <- orthogroups |> pivot_longer(
  names_to = 'sample',
  values_to = 'transcriptID', 2:14
) %>%
  rename(orthogroup = Orthogroup) |>
  filter(!is.na(transcriptID)) |>
  mutate(transcriptID = str_split(transcriptID, ', ')) |>
  unnest(cols = transcriptID)

annotation.all <- reduce(
  .x = list(all.orthogroups, ncbi.symbol, funannotate.symbol.go, wei2go.go, blast.symbols.go),
  .f = left_join
) |>
  group_by(orthogroup) |>
  nest() |>
  ungroup() |>
  pmap(.progress = TRUE, \(orthogroup, data) {
    # 1. Unique GO Terms: Wei2GO/Funannotate/Best-BLAST
    go.wei2go <- data$GO_wei2go |> unlist() |> unique()
    go.fun <- data$GO_funannotate |> unlist() |> unique()
    go.blast <- data$GO_blast |> unlist() |> unique()
    go <- c(go.wei2go, go.fun, go.blast) |> unique()

    # 2. Gene symbols: NCBI/Funannotate/Best-BLAST
    symbol.ncbi <- data$symbol_ncbi |>
      unique()
    symbol.ncbi <- symbol.ncbi[!is.na(symbol.ncbi)]
    symbol.ncbi <- ifelse(length(symbol.ncbi) > 1, paste0(symbol.ncbi, collapse = ' '), symbol.ncbi)

    symbol.fun <- data$symbol_funannotate |>
      unique()
    symbol.fun <- symbol.fun[!is.na(symbol.fun)]
    symbol.fun <- ifelse(length(symbol.fun) > 1, paste0(symbol.fun, collapse = ' '), symbol.fun)

    symbol.blast <- data$symbol_blast |>
      unique()
    symbol.blast <- symbol.blast[!is.na(symbol.blast)]
    symbol.blast <- ifelse(length(symbol.blast) > 1, paste0(symbol.blast, collapse = ' '), symbol.blast)

    all.symbol <- c(symbol.ncbi, symbol.fun, symbol.blast)

    # Annotation hierarchy: NCBI > Funannotate > BLAST

    # If all annotation sources are NA
    if (all(is.na(all.symbol)) || all(is_empty(all.symbol))) {
      symbol <- NA_character_
    } else if (!is.na(symbol.ncbi) || !is_empty(symbol.ncbi)) {
      symbol <- symbol.ncbi
    } else if (!is.na(symbol.fun) | !is_empty(symbol.fun)) {
      symbol <- symbol.fun
    } else {
      symbol <- symbol.blast
    }

    # 3. Return tibble of ogid, gene-symbol, GO Terms
    tibble(
      'orthogroup' = orthogroup,
      'symbol' = symbol,
      'GO' = paste0(go, collapse = ' ')
    )
  }) |>
  list_rbind()

# ------------------------------------------------------------------------------------------------ #
# Write annotated orthogroups to file
dir_create(path = here('orthologs','ortholog-annotation','results','ortholog-annotation'))

write_csv(
  x = annotation,
  file = here('orthologs','ortholog-annotation','results','ortholog-annotation', 'orthologs.csv'),
  col_names = TRUE
)

write_csv(
  x = annotation.all,
  file = here('orthologs','ortholog-annotation','results','ortholog-annotation', 'orthologs.all.csv'),
  col_names = TRUE
)

