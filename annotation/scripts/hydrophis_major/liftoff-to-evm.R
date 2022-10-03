# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(furrr)
  library(fs)
  library(magrittr)
  library(progressr)
})

plan(multisession, workers = 4)

# ------------------------------------------------------------------------------------------------ #
# Read liftoff GFF3
# Import LiftOff GFF3 - keep as S4 object
gffs <- dir_ls(
  path = 'assembly/annotation/liftoff',
  glob = '*.gff3'
) %>%
  as.character() %>%
  set_names(sub('.gff3', '', basename(.))) %>%
  extract(4) %>%
  imap(~{
    print(.y)
    gff <- .x %>%
      rtracklayer::readGFF(
        version = 3
      )

    # Turn to tibble
    print('DFame to tibble')
    gff.tibble <-  gff %>%
      as_tibble() %>%
      fill(gene_biotype)

    # These don't work in EVM
    print('Get transcripts')
    if ('transcript' %in% levels(gff.tibble$type)) {
      transcript.ids <- gff.tibble %>%
        filter(type == 'transcript') %>%
        pull(ID)

      # Filter out sequences that'll break EVM and extract IDs
      valid.ids <- gff.tibble %>%
        filter(
          gene_biotype == 'protein_coding',
          # Remove transcript entries as they break EVM
          type != 'transcript',
          ! Parent %in% transcript.ids
        ) %>%
        pull(ID)
    } else {
      valid.ids <- gff.tibble %>%
        filter(
          gene_biotype == 'protein_coding'
        ) %>%
        pull(ID)
    }

    # Subset for valid IDs
    print('Filter out Transcripts')
    gff <- gff[gff$ID %in% valid.ids, ]
    gff <- gff[ , colnames(gff) %in% c('seqid', 'source', 'type', 'start', 'end', 'score', 'strand', 'phase', 'ID', 'Parent', 'Name') ]

    # Get indices of gene positions
    gene.indicies <- grep(pattern = "gene", x = gff$type)#[-1]
    gff.grouping <- gff %>%
      as_tibble() %>%
      filter(type == 'gene') %>%
      mutate(gene.indicies)

    print('Splitting on gene indices')
    gff.tibble.split.gene <- gff %>%
      as_tibble() %>%
      left_join(gff.grouping, by = c('seqid', 'source', 'type', 'start', 'end', 'score', 'strand', 'phase', 'ID', 'Parent', 'Name') ) %>%
      fill(gene.indicies) %>%
      group_by(gene.indicies) %>%
      group_split()

    # Iterate over each gene
    print('Iterate over Gene features')
    with_progress(cleanup = TRUE, {
      p <- progressor(steps = length(gff.tibble.split.gene))

      valid <- gff.tibble.split.gene %>%
        future_map_dfr(~{
          p()
          df <- .x %>% ungroup()
          gene <- df %>% filter(type == 'gene')
          no.gene <- df %>% filter(type != 'gene')

          # mRNA indices
          n.mrna <- no.gene %>% count(type) %>% filter(type == 'mRNA') %>% pull('n')

          if(isTRUE(n.mrna) && n.mrna > 1) {
            # Get indices of mRNA rows
            mrna.indicies <- grep(pattern = "mRNA", x = no.gene$type)[-1]

            # Split data frame on mRNA and iterate over
            valid.mRNA <- no.gene %>%
              split(., cumsum(1:nrow(.) %in% mrna.indicies)) %>%
              # Iterate over each mRNA feature
              map_dfr(function(mrna) {
                types <- mrna %>%
                  pull(type) %>%
                  unique() %>%
                  as.character()

                lgl <- all(c('mRNA', 'exon', 'CDS') %in% types)
                if(lgl) {return(mrna)}
              })

            # prepend gene information to top of dataframe
            gene %>%
              bind_rows(valid.mRNA)
          } else {
            # Only one mRNA for the gene
            types <- df %>% pull(type) %>% unique() %>% as.character()
            lgl <- all(c('gene', 'mRNA', 'exon', 'CDS') %in% types)
            if(lgl) {df}
          }
        }) %>%
        pull(ID)
    })

    # Export valid GFF3
    print('Exporting GFF3')
    gff[gff$ID %in% valid, ] %>%
      rtracklayer::export.gff3(
        con = glue::glue("assembly/annotation/liftoff/{.y}.tmp.gff3"),
      )
    print(glue::glue("Finished {.y}"))
  })

