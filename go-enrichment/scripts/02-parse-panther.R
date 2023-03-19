# ------------------------------------------------------------------------------------------------ #
# Process PANTHER
#
# Parses the PANTHER JSON files to obtain a hierarchical table of significant GO terms.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# ------------------------------------------------------------------------------------------------ #
# GO database
go <- as.list(GO.db::GOTERM)
go <- tibble(
  GO = names(go),
  Description = unlist(map(go, AnnotationDbi::Definition))
)

# ------------------------------------------------------------------------------------------------ #
# PANTHER JSON parser
parsePanther <- function(path) {
  # Read JSON files
  jsons <- fs::dir_ls(
    path = path,
    glob = '*.json'
  ) %>%
    set_names(sub('*\\..*', '\\1', basename(.))) |>
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
                'Direction' = iter2$plus_minus,
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
            'Direction' = result$plus_minus,
            'Genes' = paste(unlist(result$input_list$mapped_id_list$mapped_id), collapse = ' ')
          )
        }
      }) |>
        list_rbind()
    }) |>
    list_rbind(names_to = 'Ontology') |>
    filter(label != 'UNCLASSIFIED') |>
    left_join(go) |>
    select(
      Ontology, level, GO, label, Description, everything()
    ) |>
    mutate(Ontology = str_remove(Ontology, 'overrepresentation-panther-'))
}

# ------------------------------------------------------------------------------------------------ #
# Parse results
sig.panther <- parsePanther(here('go-enrichment', 'results', 'panther'))

# ------------------------------------------------------------------------------------------------ #
# Export GO terms for REVIGO and a table for supp. material
sig.panther |>
  pull(GO) |>
  write_lines(file = here('go-enrichment', 'results', 'panther', 'enriched-GO-terms-for-REVIGO.txt'))

# Write to supplementary table
sig.panther |>
  write_csv(
    file = here('figures', 'supplementary', 'table-x-enrichment-panther.csv'),
    col_names = TRUE
  )


