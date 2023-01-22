# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)

# ------------------------------------------------------------------------------------------------ #
# RELAX

parseRelax <- function(jsons) {
  # General model statistics shared by all models
  modelStats <- list()
  branch.attributes <- list()
  test.results <- list()

  general <- list()

  mg94 <- list()
  mg94.eqfreq <- list()

  nucgtr <- list()
  nucgtr.eqfreq <- list()

  alternative <- list()

  nul <- list()

  for (i in 1:length(jsons)) {
    # File name
    file.name <- sub('.fa' , '', basename(path = jsons[[i]]$input$`file name`))

    test.results[[i]] <- .getTestResultsR(file.name, jsons[[i]])
    branch.attributes[[i]] <- .getBranchAttributesR(file.name, jsons[[i]]$`branch attributes`)

    out.general <- .getGeneralR(file.name, jsons[[i]]$fits$`General descriptive`)
    modelStats[[length(modelStats) + 1]] <- out.general[[1]]
    general[[i]] <- out.general[[2]]

    # MG94xREV output
    out.mg94Rev <- .getMG94RevR(file.name, jsons[[i]]$fits$`MG94xREV with separate rates for branch sets`)
    modelStats[[length(modelStats) + 1]] <- out.mg94Rev[[1]]
    mg94[[i]] <- out.mg94Rev[[2]]
    mg94.eqfreq[[i]] <- out.mg94Rev[[3]]

    # Nucleotide GTR
    out.nucGTR <- .getNucGTRR(file.name, jsons[[i]]$fits$`Nucleotide GTR`)
    modelStats[[length(modelStats) + 1]] <- out.nucGTR[[1]]
    nucgtr[[i]] <- out.nucGTR[[2]]
    nucgtr.eqfreq[[i]] <- out.nucGTR[[3]]

    # RELAX Alt
    out.alternative <- .getAlternativeNullR(file.name, jsons[[i]]$fits$`RELAX alternative`, "RELAX alternative")
    modelStats[[length(modelStats) + 1]] <- out.alternative[[1]]
    alternative <- out.alternative[[2]]

    # RELAX null
    out.null <- .getAlternativeNullR(file.name, jsons[[i]]$fits$`RELAX null`, "RELAX null")
    modelStats[[length(modelStats) + 1]] <- out.null[[1]]
    nul <- out.null[[2]]
  }

  # Return
  return(
    list(
      'test results' = bind_rows(test.results),
      'branch attributes' = bind_rows(branch.attributes),
      'fits' = list(
        'general' = bind_rows(modelStats),
        'General descriptive' = bind_rows(general),
        'mg94' = list('mg94' = bind_rows(mg94), 'eqFreq' = bind_rows(mg94.eqfreq)),
        'nucGTR' = list('nucGTR' = bind_rows(nucgtr), 'eqFreq' = bind_rows(nucgtr.eqfreq)),
        'RELAX alternative' = bind_rows(alternative),
        'RELAX null' = bind_rows(nul)
      )
    )
  )

}

# getTestResultsR Parse the `test results` information from RELAX JSONs.
.getTestResultsR <- function(file, json) {

  test.results <- tibble(
    file = file,
    lrt = json$`test results`$LRT,
    pval = json$`test results`$`p-value`,
    `relaxation or intensification parameter` = json$`test results`$`relaxation or intensification parameter`
  )

  return(test.results)
}

# getBranchAttributesR
.getBranchAttributesR <- function(file, json) {

  partitions <- json[-length(json)]

  # Iterate over partitions
  df_partition <- purrr::map(partitions, function(pt) {

    # Iterate over species within partition
    df_species <- purrr::imap(pt, ~{
      ss <- .x[names(.x) != 'original name']
      tibble(
        file = file,
        id = .y,
        models = names(ss),
        values = as.double(ss)
      )
    }) |>
      purrr::list_rbind()
  }) |>
    purrr::list_rbind()

  return(df_partition)
}


#
.getGeneralR <- function(file, json) {
  aicc <- json[['AIC-c']]
  loglike <- json[['Log Likelihood']]
  estPar <- json[['estimated parameters']]

  # Rate distribution values
  rateDist <- unlist(json[['Rate Distributions']]) %>%
    tibble(
      file = file,
      temp = names(.),
      Values = .
    ) %>%
    separate(
      col = temp,
      into = c('branch',
               'rate class',
               'proportion'),
      sep = '\\.'
    ) %>%
    pivot_wider(
      names_from = proportion,
      values_from = Values
    ) %>%
    mutate(
      proportion = proportion * 100
    )

  # General model information
  df.general <- tibble::tibble(
    'file' = file,
    'Model' = 'General descriptive',
    'AIC-c' = aicc,
    'Log likelihood' = loglike,
    'Estimated parameters' = estPar
  )

  return(list(df.general, rateDist))
}

# getMG94RevR Parses the MG94xRev model information from the 'fits' key in the json. Returns
# general model information, rate distribution table and codon equilibrium frequencies.
.getMG94RevR <- function(file, json) {

  # For 'equilibrium frequencies'
  codons <- sort(names(Biostrings::getGeneticCode()))
  codons <- codons[ ! codons %in% c('TAG', 'TAA', 'TGA') ]

  # Tibble of codon frequencies
  eqFreq <- magrittr::set_names(
    x = unlist(json$`Equilibrium frequencies`),
    value = codons
  ) %>%
    tibble(
      file = file,
      codon = names(.),
      frequencies = .
    )

  # Rate distributions
  rateDist <- unlist(json[['Rate Distributions']]) %>%
    tibble(
      file = file,
      temp = names(.),
      values = .
    ) %>%
    separate(
      col = 'temp',
      into = c('a', 'b', 'c'),
      sep = "\\*"
    ) %>%
    select(-a) %>%
    mutate(c = ifelse(c == "1", 'dN', 'dS')) %>%
    rename('dN/dS rate ratio' = values, 'branch' = b) %>%
    pivot_wider(names_from = c, values_from = `dN/dS rate ratio`)

  # General model information
  aicc <- json[['AIC-c']]
  loglike <- json[['Log Likelihood']]
  estPar <- json[['estimated parameters']]
  df.general <- tibble(
    'file' = file,
    'Model' = 'MG94xRev with separate rates for branch sets',
    'AIC-c' = aicc,
    'Log likelihood' = loglike,
    'Estimated parameters' = estPar
  )

  return(list(df.general, rateDist, eqFreq))
}


# getNucGTRR Parses the Nucleotide GTR model information from the 'fits' key. Returns general
# model information, a rate distribution table and nucleotide equilibrium frequencies.
.getNucGTRR <- function(file, json) {
  aicc <- json[['AIC-c']]
  estPar <- json[['estimated parameters']]
  loglike <- json[['Log Likelihood']]

  # Nucleotide equilibrium frequencies
  eqFreq <- magrittr::set_names(
    x = unlist(json[['Equilibrium frequencies']]),
    value = c('A', 'C', 'G', 'T')
  ) %>%
    tibble(
      file = file,
      nucleotide = names(.),
      frequencies = .
    )

  # Substitution rate from nucleotide a -> b
  rateDist <- unlist(json[['Rate Distributions']]) %>%
    tibble(
      file = file,
      condition = names(.),
      `substitution rate` = .
    )

  # General model information
  df.general <- tibble::tibble(
    'file' = file,
    'Model' = 'Nucleotide GTR',
    'AIC-c' = aicc,
    'Log likelihood' = loglike,
    'Estimated parameters' = estPar
  )

  return(list(df.general, rateDist, eqFreq))
}


# getUnconstrainedBPH Parses the unconstrained model information from the 'fits' key. Returns
# general model information and rate distribution table.
.getAlternativeNullR <- function(file, json, mdl) {
  aicc <- json[['AIC-c']]
  loglike <- json[['Log Likelihood']]
  estPar <- json[['estimated parameters']]

  rateDist <- unlist(json[['Rate Distributions']]) %>%
    tibble(
      file = file,
      Names = names(.),
      Values = .
    ) %>%
    separate(
      col = Names,
      into = c('branch',
               'rate class',
               'proportion'),
      sep = '\\.'
    ) %>%
    pivot_wider(
      names_from = proportion,
      values_from = Values
    ) %>%
    mutate(
      proportion = proportion * 100
    )

  # General model information
  df.general <- tibble::tibble(
    'file' = file,
    'Model' = mdl,
    'AIC-c' = aicc,
    'Log likelihood' = loglike,
    'Estimated parameters' = estPar
  )

  return(list(df.general, rateDist))
}

