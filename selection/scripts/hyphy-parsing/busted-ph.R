# ------------------------------------------------------------------------------------------------ #
# Libraries
library(tidyverse)

# ------------------------------------------------------------------------------------------------ #
# BUSTED-PH
#
# Functions in this script are used to parse the JSON output from BUSTED-PH.
#
# Briefly, BUSTED-PH is an extension of the BUSTED method, whereby it tests if a specific
# phenotype/trait is associated with positive selection. The method fits a unrestricted branch-site
# (BS-REL) to Test and Background sets, allowing independent omega distributions. A constrained
# model is then fit to the Test data (omega <= 1) and a LRT is used to determine if the Test
# branches are subject to episodic diversifying selection. A constrained model is also fit to the
# Background branches to test whether they also are experiencing episodic diversifying selection.
# Finally, a constrained model is fit to both the Test and Background sets where the omega
# distribution is the same. A LRT of this shared model against the unrestricted model is used to
# determine if the selective regimes differ between the Test and Background sets.
#
# As such, the following outcomes can be observed:
#   - Selection associated with phenotype for Test only:
#       - Unconstrained model is best fit AND shared distribution model is significantly different
#   - Significant selection Test and Background BUT different distributions
#       - Unconstrained model significant for both Test/Background BUT omega distributions are different
#   - Significant selection Test and Background BUT share omega distribution
#   - Foreground shows no signal of episodic diversifying selection


# parseBustedPh Takes a list of JSON objects (from loadJsons()) as input and parses relevant
# information from each file, aggregating results into long-format tables. This is the wrapper
# function around worker functions that do all the work.
parseBustedPh <- function(jsons) {
  # Initialise empty variables

  # General model statistics shared by all models
  modelStats <- list()
  branch.attributes <- list()
  test.results <- list()

  # Model specific results
  constrained <- list()

  mg94 <- list()
  mg94.eqfreq <- list()

  nucgtr <- list()
  nucgtr.eqfreq <- list()

  shared <- list()

  unconstrained <- list()

  # Iterate over each JSON file and append information to each output
  for (i in 1:length(jsons)) {
    # File name
    file.name <- sub('.fa' , '', basename(path = jsons[[i]]$input$`file name`))

    # LRT/P-value statistics + branch atrributes
    test.results[[i]] <- .getTestResultsBPH(file.name, jsons[[i]])
    branch.attributes[[i]] <- .getBranchAttributesBPH(file.name, jsons[[i]]$`branch attributes`)

    # Unconstrained model
    out.unconstrained <- .getUnconstrainedBPH(file.name, jsons[[i]]$fits$`Unconstrained model`)
    modelStats[[length(modelStats) + 1]] <- out.unconstrained[[1]]
    unconstrained[[i]] <- out.unconstrained[[2]]

    # Constrained output - won't be run if unconstrained shows NO signal of positive selection
    if ('Constrained model' %in% names(jsons[[i]]$fits)) {
      out.constrained <- .getConstrainedBPH(file.name, jsons[[i]]$fits$`Constrained model`)
      modelStats[[length(modelStats) + 1]] <- out.constrained[[1]]
      constrained[[i]] <- out.constrained[[2]]
    }

    # MG94xREV output
    out.mg94Rev <- .getMG94RevBPH(file.name, jsons[[i]]$fits$`MG94xREV with separate rates for branch sets`)
    modelStats[[length(modelStats) + 1]] <- out.mg94Rev[[1]]
    mg94[[i]] <- out.mg94Rev[[2]]
    mg94.eqfreq[[i]] <- out.mg94Rev[[3]]

    # Nucleotide GTR
    out.nucGTR <- .getNucGTRBPH(file.name, jsons[[i]]$fits$`Nucleotide GTR`)
    modelStats[[length(modelStats) + 1]] <- out.nucGTR[[1]]
    nucgtr[[i]] <- out.nucGTR[[2]]
    nucgtr.eqfreq[[i]] <- out.nucGTR[[3]]

    # Shared distribution model
    out.sharedDist <- .getSharedBPH(file.name, jsons[[i]]$fits$`Shared distribution model`)
    modelStats[[length(modelStats) + 1]] <- out.sharedDist[[1]]
    shared[[i]] <- out.sharedDist[[2]]
  }

  # Return
  return(
    list(
      'test results' = bind_rows(test.results),
      'branch attributes' = bind_rows(branch.attributes),
      'fits' = list(
        'general' = bind_rows(modelStats),
        'constrained' = bind_rows(constrained),
        'mg94' = list('mg94' = bind_rows(mg94), 'eqFreq' = bind_rows(mg94.eqfreq)),
        'nucGTR' = list('nucGTR' = bind_rows(nucgtr), 'eqFreq' = bind_rows(nucgtr.eqfreq)),
        'shared' = bind_rows(shared),
        'unconstrained' = bind_rows(unconstrained)
      )
    )
  )
}


# getConstrainedBPH Parses information for the constrained model under the 'fits' key. Returns
# general model fit information, along with a rate distribution table.
.getConstrainedBPH <- function(file, json) {
  aicc <- json[['AIC-c']]
  lnl <- json[['Log Likelihood']]
  ep <- json[['estimated parameters']]

  # Build rate distribution table
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
    dplyr::mutate(proportion = proportion * 100)

  # Tibble of model statistics
  df.general <- tibble(
    'file' = file,
    'Model' = "Constrained",
    'AIC-c' = aicc,
    'Log likelihood' = lnl,
    'Estimated parameters' = ep
  )

  return(list(df.general, rateDist))
}


# getMG94RevBPH Parses the MG94xRev model information from the 'fits' key in the json. Returns
# general model information, rate distribution table and codon equilibrium frequencies.
.getMG94RevBPH <- function(file, json) {

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


# getNucGTRBPH Parses the Nucleotide GTR model information from the 'fits' key. Returns general
# model information, a rate distribution table and nucleotide equilibrium frequencies.
.getNucGTRBPH <- function(file, json) {
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


# getSharedBPH Parses the shared distribution model information from the 'fits' key. Returns general
# model information and a rate distribution table.
.getSharedBPH <- function(file, json) {
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
    'Model' = 'Shared distribution model',
    'AIC-c' = aicc,
    'Log likelihood' = loglike,
    'Estimated parameters' = estPar
  )

  return(list(df.general, rateDist))
}


# getUnconstrainedBPH Parses the unconstrained model information from the 'fits' key. Returns
# general model information and rate distribution table.
.getUnconstrainedBPH <- function(file, json) {
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
    'Model' = 'Unconstrained model',
    'AIC-c' = aicc,
    'Log likelihood' = loglike,
    'Estimated parameters' = estPar
  )

  return(list(df.general, rateDist))
}


# getTestResultsBPH Parses the overall test results of the BUSTED-PH model. This includes the
# LRT and P-values for the internal model comparisons performed by the workflow.
.getTestResultsBPH <- function(file, json) {

  # Test results
  test.results <- tibble(
    file = file,
    test = 'test results',
    lrt = json$`test results`$LRT,
    pval = json$`test results`$`p-value`
  )

  # Test results background
  test.results.background <- tibble(
    file = file,
    test = 'test results background',
    lrt = json$`test results background`$LRT,
    pval = json$`test results background`$`p-value`
  )

  # Test results shared distribution
  test.results.shared <- tibble(
    file = file,
    test = 'test results shared distribution',
    lrt = json$`test results shared distributions`$LRT,
    pval = json$`test results shared distributions`$`p-value`
  )

  return(bind_rows(test.results, test.results.background, test.results.shared))
}



# getBranchAttributesBPH Parses the branch-attributes key from the provided JSON. Returns the
# data in a tibble format.
.getBranchAttributesBPH <- function(file, json) {
  # Remove descriptive 'attributes' field
  partitions <- json[-length(json)]

  # Iterate over partitions - most of the time it's '0' but can be more
  df_partition <- map_dfr(partitions, function(pt) {

    # Iterate over species within partition
    df_species <- imap_dfr(pt, ~{
      tibble(
        file = file,
        id = .y,
        models = names(.x),
        values = .x
      ) %>%
        filter(models != 'original name') %>%
        mutate(values = as.double(values))
    })
  })

  return(df_partition)
}
