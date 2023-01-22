# ------------------------------------------------------------------------------------------------ #
# General accessory functions

# loadJsons Given a directory path (str), find all files that end with the extension '*.json'
# and read them into memory as a JSON list.
loadJsons <- function(dir) {
  j <- fs::dir_ls(
    path = dir,
    glob = "*.json"
  ) %>%
    purrr::map(jsonlite::read_json)

  return(j)
}

# pcorrBUSTEDPH Correct P-values for parsed BUSTED-PH results. Inputs are the parseed BUSTED-PH
# list-object, a P-value threshold and method of correction.
pcorrBUSTEDPH <- function(parsedList, p = 0.05, corrMethod = 'fdr') {
  df.corr <- parsedList$`test results` %>%
    select(-lrt) %>%
    pivot_wider(
      names_from = test,
      values_from = pval
    ) %>%
    mutate(
      adj_test = p.adjust(p = `test results`, method = corrMethod),
      adj_background = p.adjust(p = `test results background`, method = corrMethod),
      adj_dist = p.adjust(p = `test results shared distribution`, method = corrMethod),

      # Classify type of selection
      result = case_when(
        # Unconstrained model fits best on 'Test' branches. Shared distribution is also significantly different between 'Test' and 'Background'
        (adj_test < p) & (adj_dist < p) & (adj_background > p) ~ 'Selection associated with trait',

        # Unconstrained model fits best on 'Test' branches BUT shared distribution is not different between 'Test' and 'Background' (same)
        (adj_test < p) & (adj_background > p) & (adj_dist > p) ~ 'Selection associated with trait. No difference between FG-BG dist',

        # Unconstrained model fits best to 'Test' and 'Background' branches BUT significant difference in shared distribution (Check with RELAX)
        (adj_test < p) & (adj_background < p) & (adj_dist < p) ~ 'Selection acting on branches with phenotype. Also acting on background. Significant difference between FG-BG dist',

        # Unconstrained model fits best to 'Test' and 'Background' branches BUT no significant difference in shared distribution (same selective regime)
        (adj_test < p) & (adj_background < p) & (adj_dist > p) ~ 'Selection acting on branches with phenotype. Also acting on background. No significant difference between FG-BG dist',

        # No association between selection and phenotype.
        (adj_test > p) & (adj_background < p) & (adj_dist < p | adj_dist > p) ~ 'No evidence of episodic diversifying selection on test branches',

        # No significant results in any branch
        TRUE ~ 'No significant signals'
      )
    )

  # Append to object
  return(df.corr)
}

# pcorrRELAX Correct P-values in RELAX table.
pcorrRELAX <- function(parsedList, p = 0.05, corrMethod = 'fdr') {
  df.corr <- parsedList$`test results` %>%
    mutate(
      adj_pval = p.adjust(p = pval, method = corrMethod)
    )
  return(df.corr)
}
