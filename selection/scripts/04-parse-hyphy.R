# ------------------------------------------------------------------------------------------------ #
# Parse HyPhy results
#
# This script simply parses the HyPhy results (BUSTED-PH and RELAX) into tables. These tables
# are then saved as RDS objects for easy access.
#
# NOTE: All files have had '-nan' values replaced with 0.123456789, along with all 'omega: inf'
# fields
#
# The code below parses data for the following analyses:
#   - BUSTED-PH Marine: Positive selection testing for Marine samples (Foreground)
#   - BUSTED-PH Terrestrial: Positive selection testing for Terrestrial samples (inverse of above)
#   - RELAX: Test for intensification/relaxation of selection in Marine snakes (Marine = Foreground)

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

# Custom tools
source(here('selection', 'scripts', 'hyphy-parsing', 'busted-ph.R'))
source(here('selection', 'scripts', 'hyphy-parsing', 'general.R'))
source(here('selection', 'scripts', 'hyphy-parsing', 'relax.R'))

# ------------------------------------------------------------------------------------------------ #
# HyPhy data - This will take a while
fs::dir_create(path = here('selection', 'r-data'))

## BUSTED-PH 13-sample results: Marine PSGs
jsons.bustedph.13 <- loadJsons(dir = here('selection', 'results-13', 'hyphy', 'busted-ph-13'))
bustedph.13 <- parseBustedPh(jsons = jsons.bustedph.13)
write_rds(x = bustedph.13, file = here('selection', 'r-data', 'busted-ph-13.rds'),compress = 'gz')
rm(jsons.bustedph.13);rm(bustedph.13);gc()

## RELAX 13-sample results: Marine PSGs
jsons.relax.13 <- loadJsons(dir = here('selection', 'results-13', 'hyphy', 'relax-13'))
relax.13 <- parseRelax(jsons = jsons.relax.13)
write_rds(x = relax.13, file = here('selection', 'r-data', 'relax-13.rds'), compress = 'gz')
rm(jsons.relax.13);rm(relax.13);gc()

## BUSTED-PH 13-sample results: Terrestrial PSGs
jsons.bustedph.13 <- loadJsons(dir = here('selection', 'results-13', 'hyphy', 'busted-ph-13-terrestrial'))
bustedph.13 <- parseBustedPh(jsons = jsons.bustedph.13)
write_rds(x = bustedph.13, file = here('selection', 'r-data', 'busted-ph-13-terrestrial.rds'),compress = 'gz')
rm(jsons.bustedph.13);rm(bustedph.13);gc()
