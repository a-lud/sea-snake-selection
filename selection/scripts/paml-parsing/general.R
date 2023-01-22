# ------------------------------------------------------------------------------------------------ #
# General PAML helper functions

# pcorrPAML Expects a data-frame as input, where all rows contain the same model comparisons
# to make e.g. bsA1 vs bsA. This should mean the data-frame should have the same number of rows as
# your ortholog gene set. Pass in a table that has come from my NF pipeline WITHOUT changing the
# column names.
pcorrPAML <- function(df, p, method) {
  df.corrected <- df %>%
    mutate(
      pval_x_adj = p.adjust(pval_x, method),
      pval_y_adj = p.adjust(pval_y, method),
      signal = case_when(
        pval_x_adj <= p & pval_y_adj > p ~ 'PS_fg',
        pval_x_adj <= p & pval_y_adj <= p ~ 'PS_fg_bg',
        pval_x_adj > p & pval_y_adj <= p ~ 'PS_bg',
        pval_x_adj > p & pval_y_adj > p ~ 'no_PS',
        is.na(pval_x_adj) | is.na(pval_y_adj) ~ 'poor_fit'
      )
    )

  return(df.corrected)
}
