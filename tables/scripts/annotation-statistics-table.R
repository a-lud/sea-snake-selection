# ------------------------------------------------------------------------------------------------ #
# Table: Gene annotation statistics
#
# This script contains code to generate gene annotation statistics from AGAT and the GFF3's
# themselves.

# ------------------------------------------------------------------------------------------------ #
# Libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(magrittr)
  library(here)
})

# Order of rows in the table
lvls <- c(
  'Hydrophis major', 'Hydrophis curtus', 'Hydrophis cyanocinctus', 'Hydrophis ornatus',
  'Hydrophis curtus (AG)' ,'Hydrophis elegans', 'Notechis scutatus', 'Pseudonaja textilis',
  'Thamnophis elegans', 'Pantherophis guttatus', 'Protobothrops mucrosquamatus', 'Crotalus tigris',
  'Python bivittatus'
)

# ------------------------------------------------------------------------------------------------ #
# Helper functions
#
# parseMrnaStats: Gets the gene statistics for mRNA
parseMrnaStats <- function(lines) {

  # All mRNA sections (with isoforms AND without isoforms)
  mrna.from <- grep(pattern = 'Compute mrna', x = lines) + 2
  mrna.to <- grep(pattern = '---------', x = lines[mrna.from:length(lines)])[1] + mrna.from - 3

  # Subset all lines for region of interest
  lines.subset <- lines[mrna.from:mrna.to]

  # Index to split on
  idx <- grep(pattern = 'Re-compute mrna', x = lines.subset)

  # Create table from strings
  mrna.with.iso <- lines.subset[1:(idx - 2)] %>%
    gsub('\\s+', '_', .) %>%
    read_table(col_names = FALSE, col_types = cols()) %>%
    separate(col = 'X1', sep="_(?=[^_]+$)", into = c('desc', 'val')) %>%
    mutate(condition = 'with_isoforms', val = as.double(val))

  mrna.without.iso <- lines.subset[(idx + 2):length(lines.subset)] %>%
    gsub('\\s+', '_', .) %>%
    read_table(col_names = FALSE, col_types = cols()) %>%
    separate(col = 'X1', sep="_(?=[^_]+$)", into = c('desc', 'val')) %>%
    mutate(condition = 'without_isoforms', val = as.integer(val))

  return(bind_rows(mrna.with.iso, mrna.without.iso))
}

# ------------------------------------------------------------------------------------------------ #
# Read AGAT statistics
ann.stats <- fs::dir_ls(
  path = here('data','gff3','statistics'),
  glob = '*.statistics'
) %>%
  map(read_lines) %>%
  map(parseMrnaStats) %>%
  list_rbind(names_to = 'sample') |>
  mutate(
    sample = sub('.statistics', '', basename(sample)),
    sample = case_when(
      sample == 'hydrophis_curtus-AG' ~ 'Hydrophis curtus (AG)',
      sample == 'hydrophis_curtus' ~ 'Hydrophis curtus',
      sample == 'hydrophis_cyanocinctus' ~ 'Hydrophis cyanocinctus',
      sample == 'hydrophis_elegans' ~ 'Hydrophis elegans',
      sample == 'hydrophis_major' ~ 'Hydrophis major',
      sample == 'hydrophis_ornatus' ~ 'Hydrophis ornatus',
      sample == 'notechis_scutatus' ~ 'Notechis scutatus',
      sample == 'protobothrops_mucrosquamatus' ~ 'Protobothrops mucrosquamatus',
      sample == 'pseudonaja_textilis' ~ 'Pseudonaja textilis',
      sample == 'thamnophis_elegans' ~ 'Thamnophis elegans',
      sample == 'crotalus_tigris' ~ 'Crotalus tigris',
      sample == 'pantherophis_guttatus' ~ 'Pantherophis guttatus',
      sample == 'python_bivittatus' ~ 'Python bivittatus',
    )
  )

# ------------------------------------------------------------------------------------------------ #
# Filter AGAT statistics
ann.df <- ann.stats %>%
  filter(
    desc %in% c(
      'Number_of_gene', 'Number_of_mrna', 'Number_of_exon',
      'mean_gene_length', 'mean_mrna_length', 'mean_cds_length'
    ),
    condition == 'with_isoforms'
  ) |>
  mutate(
    method = case_when(
      sample %in% c('Hydrophis major', 'Hydrophis cyanocinctus', 'Hydrophis curtus') ~ 'Funannotate',
      sample %in% c('Hydrophis curtus (AG)', 'Hydrophis ornatus', 'Hydrophis elegans') ~ 'Liftoff',
      sample %in% c(
        'Crotalus tigris', 'Notechis scutatus', 'Protobothrops mucrosquamatus',
        'Pseudonaja textilis', 'Thamnophis elegans',
        'Pantherophis guttatus', 'Python bivittatus'
      ) ~ 'NCBI'
    ),
    sample = factor(sample, levels = lvls)
  ) |>
  pivot_wider(
    names_from = desc,
    values_from = val
  ) |>
  select(-condition) |>
  arrange(sample) |>
  rename(
    Sample = sample,
    Source = method,
    `# Genes` = Number_of_gene,
    `# mRNA` = Number_of_mrna,
    `# Exon` = Number_of_exon,
    `Avg. gene length` = mean_gene_length,
    `Avg. mRNA length` = mean_mrna_length,
    `Avg. CDS length` = mean_cds_length
  )

# ------------------------------------------------------------------------------------------------ #
# Read in GFF3 files
gff <- fs::dir_ls(
  path = here('data', 'gff3'),
  glob = '*.gff3'
) |>
  vroom::vroom(delim = '\t', id = 'sample', col_names = FALSE, col_types = cols(), comment = '#') |>
  filter(X3 == 'gene') |>
  mutate(
    sample = sub('.gff3', '', basename(sample)),
  ) |>
  select(sample, source = X2, chr = X1, type = X3, attributes = X9)

# Chromosome sequences in H. major, H.curtus (AG)/H. ornatus, H. cyano and H. curtus (NCBI)
chrs <- c(
  paste0(rep('HiC_scaffold_', 16), 1:16),
  c(paste0(rep('chr', 15), 1:15), 'chrZ'),
  paste0('CM0', 33584:33601, '.1'),
  paste0('CM0', 33602:33618, '.1')
)

# Temporary df that will store H. elegans data
tmp <- gff |>
  filter(sample %in% c(
    'hydrophis_major', 'hydrophis_curtus-AG',
    'hydrophis_ornatus', 'hydrophis_elegans',
    'hydrophis_curtus', 'hydrophis_cyanocinctus')
  ) |>
  group_by(sample) |>
  mutate(
    tmp = str_count(attributes, 'Name='),
    functional = sum(tmp)
  )

# Temporary df that has an extra field relating to gene count on chromosomes for chr assemblies
tmp2 <- tmp |>
  filter(chr %in% chrs) |>
  mutate(`# Gene (chromosome)` = n()) |>
  select(Sample = sample, `# Gene symbol` = functional, `# Gene (chromosome)`) |>
  distinct() |>
  mutate(
    Sample = case_when(
      Sample == 'hydrophis_curtus-AG' ~ 'Hydrophis curtus (AG)',
      Sample == 'hydrophis_major' ~ 'Hydrophis major',
      Sample == 'hydrophis_ornatus' ~ 'Hydrophis ornatus',
      Sample == 'hydrophis_curtus' ~ 'Hydrophis curtus',
      Sample == 'hydrophis_cyanocinctus' ~ 'Hydrophis cyanocinctus',
    )
  ) |>
  ungroup()

# Merge them together
gene.info <- tmp |>
  filter(sample == 'hydrophis_elegans') |>
  select(Sample = sample, `# Gene symbol` = functional) |>
  mutate(
    `# Gene (chromosome)` = NA_integer_,
    Sample = 'Hydrophis elegans'
  ) |>
  distinct() |>
  bind_rows(tmp2)

# ------------------------------------------------------------------------------------------------ #
# Get other annotation sources from GFF files (IPS/GO etc..)

# Read in GFF3s
gffs <-fs::dir_ls(
  path = here('data', 'gff3'),
  glob = '*.gff3'
) %>%
  extract(str_detect(., 'hydrophis')) |>
  read_tsv(col_names = FALSE, col_types = cols(), id = 'Sample', comment = '#') |>
  select(Sample, Type = X3, Attributes = X9)

# Step 1: Find all mRNA that have annotations in the form of IPS/PFAM/GO/BUSCO/COG/EGGNOG
#         and return their parent identifier (should match the 'gene' field)
parent.ids <- gffs |>
  filter(Type == 'mRNA') |>
  mutate(
    Sample = sub('.gff3', '', basename(Sample))
  ) |>
  filter(str_detect(Attributes, 'Dbxref|Ontology_term|note')) |>
  mutate(Parent = sub('.+Parent=(.*);product.*', '\\1', Attributes)) %>%
  split(.$Sample) |>
  map(pull, Parent)

# Step 2: Extract the 'gene' fields and summarise
tmp <- gffs |>
  filter(Type == 'gene') |>
  mutate(
    ID = str_replace_all(Attributes, pattern = 'ID=|;.*', ''),
    Sample = sub('.gff3', '', basename(Sample))
  ) |>
  select(Sample, ID) |>
  group_by(Sample)

gnames <- tmp |> group_keys() |> pull(Sample)

other.ann.df <- tmp |>
  group_split() |>
  set_names(gnames) |>
  imap(\(df, id) {
    df |>
      filter(ID %in% parent.ids[[id]]) |>
      group_by(Sample) |>
      summarise(`# Functionally annotated` = n())
  }) |>
  list_rbind() |>
  mutate(
    Sample = case_when(
      Sample == 'hydrophis_curtus-AG' ~ 'Hydrophis curtus (AG)',
      Sample == 'hydrophis_major' ~ 'Hydrophis major',
      Sample == 'hydrophis_ornatus' ~ 'Hydrophis ornatus',
      Sample == 'hydrophis_curtus' ~ 'Hydrophis curtus',
      Sample == 'hydrophis_cyanocinctus' ~ 'Hydrophis cyanocinctus',
      Sample == 'hydrophis_elegans' ~ 'Hydrophis elegans'
    )
  )

# ------------------------------------------------------------------------------------------------ #
# Join all info together and write to file
ann.df |>
  left_join(gene.info) |>
  left_join(other.ann.df) |>
  mutate(
    `% on chromosome` = `# Gene (chromosome)`/`# Genes` * 100,
    `% on chromosome` = round(`% on chromosome` , 3)
  ) |>
  select(
    Sample, Source, `# Genes`, `# mRNA`,
    `# Exon`, `Avg. gene length`, `Avg. mRNA length`,
    `Avg. CDS length`, `# Gene (chromosome)`, `% on chromosome`,
    `# Gene symbol`, `# Functionally annotated`
  ) |>
  write_csv(
    file = here('figures', 'supplementary', 'table-x-annotation-summary.csv'),
    col_names = TRUE,
    na = ''
  )
