# ------------------------------------------------------------------------------------------------ #
# Process PANTHER
#
# Parses the PANTHER JSON files to obtain a hierarchical table of significant GO terms. Two JSON
# files were generated for each ontology: All results (significant and insignificant) and significant
# only.
#
# The significant set is used for the REVIGO analysis/summary tables, while the full dataset is used
# to get GO term mappings to the provided gene list.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# GO database - Used for GO term descriptions
go <- as.list(GO.db::GOTERM)
go <- tibble(
  GO = names(go),
  Description = unlist(map(go, AnnotationDbi::Definition))
)

# ------------------------------------------------------------------------------------------------ #
# PANTHER JSON parser
parsePanther <- function(path, glob, exclude=NULL, go_df) {
  # Read JSON files
  jsons <- fs::dir_ls(
    path = path,
    glob = glob,
    recurse = FALSE
  ) %>%
    set_names(sub('*\\..*', '\\1', basename(.)))

  if(!is.null(exclude)) {
    jsons <- jsons[!str_detect(names(jsons), exclude)]
  }

  jsons <- jsons |>
    map(jsonlite::read_json)

  jsons |>
    map(\(json) {
      # Data is hierachical (most interesting term first). Get the 'group' field
      # with interesting data
      group <- json |>
        pluck(1,'group')

      # Iterate over each 'result' field. The results are nested under the top level
      map(group, \(iter) {

        # This will be 'NULL' if there are multiple nested terms below the top term
        lvl <- iter |> pluck('result', 'term')
        if (is.null(lvl)) {

          # Multiple sub-levels - need to iterate over each
          iter |>
            pluck('result') |>
            map(\(iter2) {
              tibble(
                'level' = iter2$term$level,
                'GO' = iter2$term$id,
                'label' = iter2$term$label,
                'Total' = iter2$number_in_reference,
                'Expected' = iter2$input_list$expected,
                'Observed' = iter2$input_list$number_in_list,
                'Fold enrichment' = iter2$input_list$fold_enrichment,
                'FDR' = iter2$input_list$fdr,
                'P-value' = iter2$input_list$pValue,
                'Direction' = iter2$input_list$plus_minus,
                'Genes' = paste(unlist(iter2$input_list$mapped_id_list$mapped_id), collapse = ' ')
              )
            }) |>
            list_rbind()
        } else {
          # Only one term - make the dataframe from the results
          result <- iter |> pluck('result')
          tibble(
            'level' = result$term$level,
            'GO' = result$term$id,
            'label' = result$term$label,
            'Total' = result$number_in_reference,
            'Expected' = result$input_list$expected,
            'Observed' = result$input_list$number_in_list,
            'Fold enrichment' = result$input_list$fold_enrichment,
            'P-value' = result$input_list$pValue,
            'FDR' = result$input_list$fdr,
            'Direction' = result$input_list$plus_minus,
            'Genes' = paste(unlist(result$input_list$mapped_id_list$mapped_id), collapse = ' ')
          )
        }
      }) |>
        list_rbind()
    }) |>
    list_rbind(names_to = 'Ontology') |>
    filter(label != 'UNCLASSIFIED') |>
    left_join(go_df) |>
    select(
      Ontology, level, GO, label, Description, everything()
    ) |>
    mutate(Ontology = str_remove(Ontology, 'overrepresentation-panther-'))
}

# ------------------------------------------------------------------------------------------------ #
# Parse results
panther.human.all <- parsePanther(here('go-enrichment', 'results', 'panther'), glob = '*.json', exclude = "sig", go_df = go) |>
  mutate(Ontology = str_extract(Ontology, 'BP|CC|MF'))
panther.human.sig <- parsePanther(here('go-enrichment', 'results', 'panther'), glob = '*-sig.json', go_df = go) |>
  mutate(Ontology = str_extract(Ontology, 'BP|CC|MF'))

# ------------------------------------------------------------------------------------------------ #
# Export GO terms for REVIGO - top level (most specific) only
panther.human.sig |>
  filter(level == 0) |>
  select(GO, FDR) |>
  write_tsv(
    file = here('go-enrichment', 'results', 'enriched-GO-terms-REVIGO.txt'),
    col_names = FALSE
  )

# ------------------------------------------------------------------------------------------------ #
# Supplementary files
panther.human.sig |>
  write_csv(
    file = here('figures', 'supplementary', 'table-x-enrichment-panther.csv'),
    col_names = TRUE
  )

# ------------------------------------------------------------------------------------------------ #
# GO Terms - Gene mapping
panther.human.all |>
  select(GO, Genes) |>
  mutate(Genes = str_split(Genes, ' ')) |>
  unnest(cols = Genes) |>
  arrange(GO) |>
  write_csv(
    file = here('go-enrichment', 'results', 'genes-annotated-GO.csv'),
    col_names = TRUE
  )
