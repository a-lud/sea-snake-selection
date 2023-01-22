library(GO.db)
library(graph)
library(dnet)
library(magrittr)
library(tidyverse)

graphs <- c(BP = "bp", CC = "cc", MF = "mf") %>%
  purrr::map(makeGOGraph) %>%
  purrr::map(\(x)removeNode("all", x)) %>%
  purrr::map(dDAGreverse)

goSummaries <- lapply(graphs, function(x){
  lng <- dDAGlevel(x, "longest_path") - 1
  shrt <- dDAGlevel(x, "shortest_path") - 1
  tips <- dDAGtip(x)
  tibble(
    id = unique(c(names(lng), names(shrt))),
    shortest_path = shrt,
    longest_path = lng,
    terminal_node = id %in% tips
  )
}) %>%
  bind_rows() %>%
  mutate(ontology = Ontology(id))

saveRDS(
  object = goSummaries,
  file = 'selection/r-data/goSummarise.rds'
)
