library(tidyverse)
library(furrr)

# Set up parallel workers
plan(multisession, workers = 6)

# Metaeuk GFF3
gff <- rtracklayer::readGFF(filepath = '~/Desktop/metaeuk-predictions.gff', version = 3)
gff.us <- rtracklayer::readGFF('assembly/annotation/metaeuk/metaeuk-predictions-uniprot_sprot.gff', version = 3)

# Make valid GFF3 for EVM
gff.split <- gff %>%
  as_tibble() %>%
  select(-Parent) %>%
  group_by(Target_ID) %>%
  split(., .$Target_ID) %>%
  future_map(~{
    df <- .x %>% ungroup()
    genes <- df %>% filter(type == 'gene') %>% mutate(gene_id = 1:nrow(.))
    df %>%
      left_join(
        genes,
        by = c('seqid', 'source', 'type', 'start', 'end', 'score', 'strand', 'phase', 'Target_ID' ,'TCS_ID')
      ) %>%
      fill(gene_id) %>%
      mutate(
        ID = paste(gsub('^(seq_.*)\\|.*\\|.*\\|(.*$)', '\\1_\\2', TCS_ID), gene_id, sep = '_'),
        Parent = case_when(
          type == 'gene' ~ NA_character_,
          type == 'mRNA' ~ sub('_mRNA', '', ID),
          type == 'exon' ~ sub('_exon_\\d+', '_mRNA', ID),
          type == 'CDS' ~ sub('_CDS_\\d+', '_mRNA', ID)
        )
      ) %>%
      select(seqid, source, type, start, end, score, strand, phase, ID, Parent)
  }) %>%
  bind_rows() %>%
  rtracklayer::as.data.frame() %>%
  rtracklayer::export.gff3(
    con = '~/Desktop/metaeuk.test.gff3'
  )

# Uniprot-sprot
gff.split <- gff.us %>%
  as_tibble() %>%
  select(-Parent) %>%
  group_by(Target_ID) %>%
  split(., .$Target_ID) %>%
  future_map(~{
    df <- .x %>% ungroup()
    genes <- df %>% filter(type == 'gene') %>% mutate(gene_id = 1:nrow(.))
    df %>%
      left_join(
        genes,
        by = c('seqid', 'source', 'type', 'start', 'end', 'score', 'strand', 'phase', 'Target_ID' ,'TCS_ID')
      ) %>%
      fill(gene_id) %>%
      mutate(
        ID = paste(gsub('^(.*)\\|.*\\|.*\\|(.*$)', '\\1_\\2', TCS_ID), gene_id, sep = '_'),
        Parent = case_when(
          type == 'gene' ~ NA_character_,
          type == 'mRNA' ~ sub('_mRNA', '', ID),
          type == 'exon' ~ sub('_exon_\\d+', '_mRNA', ID),
          type == 'CDS' ~ sub('_CDS_\\d+', '_mRNA', ID)
        )
      ) %>%
      select(seqid, source, type, start, end, score, strand, phase, ID, Parent)
  }) %>%
  bind_rows() %>%
  rtracklayer::as.data.frame() %>%
  rtracklayer::export.gff3(
    con = 'assembly/annotation/metaeuk/hydrophis_major-metaeuk-uniprot_sprot-evm_valid.gff3'
  )
