Annotating orthogroups
================
Alastair Ludington
2023-06-21

- [1 Introduction](#1-introduction)
- [2 Functional annotation sources](#2-functional-annotation-sources)
  - [Funannotate annotations: Gene symbols and GO
    terms](#funannotate-annotations-gene-symbols-and-go-terms)
  - [Parse RefSeq GFF3 files: Gene
    symbols](#parse-refseq-gff3-files-gene-symbols)
  - [Best-BLAST-hits to SwissProt: GO terms and gene
    symbols](#best-blast-hits-to-swissprot-go-terms-and-gene-symbols)
- [3 Annotate orthogroups: Assign non-redundant
  annotations](#3-annotate-orthogroups-assign-non-redundant-annotations)
  - [Gene symbol hierarchy](#gene-symbol-hierarchy)
  - [GO Term filtering](#go-term-filtering)
- [4 Final output](#4-final-output)

# 1 Introduction

This document details the methods I used to annotate ortholog clusters,
as identified by
[Orthofinder](https://github.com/davidemms/OrthoFinder). To annotate
orthologs, I integrated functional annotation data from multiple
sources, including:

- Gene symbols from NCBI annotated samples
- Gene symbols and GO terms from
  [Funannotate](https://github.com/nextgenusfs/funannotate) annotated
  samples
- Gene symbols and GO terms from
  [UniProt-SwissProt](https://www.uniprot.org/help/uniprotkb) curated
  database

A few other annotation sources were explored (you’ll see the scripts in
this directory), but we did not end up using their output. I’ve left
them here as they may be helpful to some.

# 2 Functional annotation sources

To simplify the document, I’ll detail the methods used to get key
information for each of the above sources, detailing the outputs that
were generated. I’ll then go over the method used to integrate the
results into a non-redundant set of annotations for each ortholog at the
end.

All of the annotation tools that I use below can be found at my
[AnnotateOrthologs](https://github.com/a-lud/annotateOrthologs)
repository. The scripts used to run the tools/generate the final output
can be found in the
[scripts](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation/scripts)
directory.

## Funannotate annotations: Gene symbols and GO terms

**Script**:
[01-parse-funannotate.sh](https://github.com/a-lud/sea-snake-selection/blob/main/orthologs/ortholog-annotation/scripts/01-parse-funannotate.sh)  
**Outdir**:
[results/funannotate-annotations](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation/results/funannotate-annotations)

Part of the [Funannotate](https://github.com/nextgenusfs/funannotate)
output is a `<species>.annotation.txt` file. This is a tab-separated
file where the rows are gene identifiers and the columns are functional
annotation data from different sources. These files can get pretty
large, so I wrote a tool
[parseFunannotate](https://github.com/a-lud/annotateOrthologs/tree/main/parseFunannotate)
to pull out gene symbols and GO terms for all annotated genes as a CSV
file.

Three snakes were *de novo* annotated in this study: *Hydrophis curtus*,
*Hydrophis cyanocinctus* and *Hydrophis major*.

The commandline call to run `parseFunannotate` is

``` bash
FILES=$(find <dir> -type f -name '*.annotations.txt')
for f in ${FILES}; do
    BN=$(basename "${f%.annotations.txt}")
    parseFunannotate" \
      -i "${f}" \
      -o "${BN}.tsv"
done
```

Output from the `parseFunannotate` tool is shown below:

``` text
GeneID          TranscriptID    Gene symbol       GO terms
FUN_000005      FUN_000005-T1                     GO:0004553 GO:0005975
FUN_000006      FUN_000006-T1
FUN_000006      FUN_000006-T2
FUN_000007      FUN_000007-T1   NUDT2             GO:0008796 GO:0016787
FUN_000007      FUN_000007-T2   NUDT2             GO:0008796 GO:0016787
FUN_000008      FUN_000008-T1                     GO:0003777 GO:0005524 GO:0008017 GO:0007018
```

## Parse RefSeq GFF3 files: Gene symbols

**Script**:
[02-parse-NCBI.sh](https://github.com/a-lud/sea-snake-selection/blob/main/orthologs/ortholog-annotation/scripts/02-parse-NCBI.sh)  
**Outdir**:
[results/ncbi-genes](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation/results/ncbi-genes)

Gene symbols were parsed from RefSeq annotated GFF3 files. This was used
as the highest form of evidence for each orthogroup. The custom tool
[parseNcbiGff3.py](https://github.com/a-lud/annotateOrthologs/tree/main/parseNcbiGFF3)
was used to extract the gene symbols from each file.

The following snakes had NCBI gene annotations whose data were parsed in
this manner

- *Crotalus tigris*
- *Notechis scutatus*
- *Pantherophis guttatus*
- *Protobothrops mucrosquamatus*
- *Pseudonaja textilis*
- *Python bivittatus*
- *Thamnophis elegans*

The commandline call is shown below

``` bash
"parseNcbiGff3.py" $(pwd) '.gff3' 'ncbi-gene-symbols.csv'
```

With the output looking like the following

``` text
pseudonaja_textilis,rna-XM_026703005.1,GATA3
pseudonaja_textilis,rna-XM_026707001.1,CELF2
pseudonaja_textilis,rna-XM_026707264.1,CELF2
pseudonaja_textilis,rna-XM_026707708.1,USP6NL
pseudonaja_textilis,rna-XM_026707832.1,ECHDC3
...
crotalus_tigris,rna-XM_039321002.1,SPATA1
crotalus_tigris,rna-XM_039321004.1,GNG5
crotalus_tigris,rna-XM_039321017.1,RPF1
crotalus_tigris,rna-XM_039321037.1,SAMD13
```

## Best-BLAST-hits to SwissProt: GO terms and gene symbols

**Script**:
[05-blast-proteins-swissprot.sh](https://github.com/a-lud/sea-snake-selection/blob/main/orthologs/ortholog-annotation/scripts/05-blast-proteins-swissprot.sh)
/
[06-best-blast.sh](https://github.com/a-lud/sea-snake-selection/blob/main/orthologs/ortholog-annotation/scripts/06-best-blast.sh)
/
[07-parse-idmapping.sh](https://github.com/a-lud/sea-snake-selection/blob/main/orthologs/ortholog-annotation/scripts/07-parse-idmapping.sh)  
**Outdir**:
[results/blast-uniprot](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation/results/blast-uniprot)
/
[results/idmapping](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation/results/idmapping)

Protein sequences from all 13 snakes were searched against the
[SwissProt](https://www.uniprot.org/help/uniprotkb) curated database.

``` bash
FILE=$(find "${PROT}" -type f -name '*.faa' | tr '\n' ' ' | cut -d ' ' -f "${SLURM_ARRAY_TASK_ID}")

if [[ ! -f "${OUT}/$(basename "${FILE%.*}").outfmt6" ]]; then
    blastp \
        -query "${FILE}" \
        -db "${DB}" \
        -out "${OUT}/$(basename "${FILE%.*}").outfmt6" \
        -evalue 1e-5 \
        -outfmt "6 qaccver saccver qlen slen length qcovs pident mismatch gapopen qstart qend sstart send evalue bitscore" \
        -max_target_seqs 100 \
        -num_threads "${SLURM_CPUS_PER_TASK}"
fi
```

The SwissProt database has a range of meta-data affiliated with it,
which can be accessed via the publicly available
[idmapping](https://www.uniprot.org/help/downloads) files. There are two
files to consider:

- **idmapping.dat.gz**
- **idmapping_selected.tab.gz**

These files are huge, and are the backbone to UniProt’s `ID Mapping`
web-portal. As such, being able to parse these files programatically to
get key annotation data - specifically gene symbols and GO Terms - would
be super useful.

As such, I wrote a couple of complementary tools to take a set of BLAST
hits in custom `outfmt 6` format (basically a few extra columns added to
the default - see above or
[here](https://github.com/a-lud/annotateOrthologs/tree/main/bestBlast)),
and generate annotation CSV files.

The first tool is
[bestBlast.py](https://github.com/a-lud/annotateOrthologs/tree/main/bestBlast).
Given a directory that contains the unprocessed BLAST tables with the
required custom fields, this tool will filter for ‘best-BLAST-hits’.
Best-BLAST-hits require:

- High sequence identity between the query and target
- High coverage of the query relative to the target
- Roughly proportional length between the query and target

If all of the above requirements are met, a query hit will be considered
a best-BLAST-hit. The minimum threshold used for each of the filters
above was 80%.

The `bestBlast.py` command is shown below.

``` bash
python3 bestBlast.py $(pwd) best-hits.csv
```

The output from `bestBlast.py` is as follows.

``` text
python_bivittatus,rna-NC_021479.1:15192..16305,O48106
python_bivittatus,rna-NC_021479.1:2589..3555,O79546
python_bivittatus,rna-NC_021479.1:6397..7998,O79548
...
notechis_scutatus,rna-XM_026695068.1,Q3UHG7
notechis_scutatus,rna-XM_026695073.1,Q95KK4
notechis_scutatus,rna-XM_026695076.1,P63090
```

The next tool,
[parseIdMap.go](https://github.com/a-lud/annotateOrthologs/tree/main/parseIdMap),
takes the UniProtKB accessions from the third column in the
`bestBlast.py` output and parses the *idmapping* files for user
requested fields. In this case, we asked for `Gene_Names` from
*idmapping.dat.gz* and `GO` Terms from *idmapping_selected.tab.gz*.

``` bash
# Gene Names from 'idmapping.dat.gz'
"${DIR}/scripts/parseIdMap" \
  -a "${DIR}/best-hits.csv" \
  -m "${DB}/idmapping.dat.gz" \
  -i 'Gene_Name' \
  -o "${DIR}/results/idmapping.dat.csv"

# GO terms from 'idmapping_selected.tab.gz'
"${DIR}/scripts/parseIdMap" \
  -a "${DIR}/best-hits.csv" \
  -m "${DB}/idmapping_selected.tab.gz" \
  -i 'GO' \
  -o "${DIR}/results/idmapping_selected.tab.csv"
```

The CSV output from the *idmapping.dat.gz* file looks like the
following:

``` text
accession,idtype,id
A4K2U9,Gene_Name,YWHAB
P62262,Gene_Name,YWHAE
...
Q52M98,Gene_Name,ywhaq
Q5ZKC9,Gene_Name,YWHAZ
P63102,Gene_Name,Ywhaz
```

While the parsed CSV output from the *idmapping_selected.dat.gz* file
looks like this:

``` text
accession,GO
Q60495,GO:0030424; GO:0009986; GO:0005905; ... GO:0006417; GO:0008542
P79307,GO:0030424; GO:0009986; GO:0005905; ... GO:0006417; GO:0008542
P63116,GO:0097440; GO:0016021; GO:0043025; ... GO:0042942; GO:0015804
```

# 3 Annotate orthogroups: Assign non-redundant annotations

**Script**:
[08-annotate-orthogroups.R](https://github.com/a-lud/sea-snake-selection/blob/main/orthologs/ortholog-annotation/scripts/08-annotate-orthogroups.R)  
**Outdir**:
[results/ortholog-annotation](https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation/results/ortholog-annotation)

To recap what we have generated so far:

- Gene symbol table generated from NCBI annotation files
- Gene symbol and GO Term table generated from Funannotate
  ‘annotation.txt’ files
- Gene symbol and GO Term table generated from best-BLAST-hits using
  UniProt-SwissProt

Using these tables, it is possible to match the annotations back with
their transcripts within each orthogroup.

## Gene symbol hierarchy

The hierarchy for assigning gene symbols is as follows:

``` text
NCBI > Funannotate > Best-BLAST > No symbol assigned
```

Where possible, NCBI annotations are used. Failing that, gene symbols
identified via Funannotate are used. If Funannotate failed to assign a
gene symbol, best-BLAST-hits are relied upon. If none of the annotation
methods could assign a gene symbol, no symbol is set.

## GO Term filtering

NOTE: These were not used in the end as we used the tool *PANTHER*.

GO terms are obtained from `Wei2GO`, `Funannotate` (which uses
[InterProScan](https://github.com/ebi-pf-team/interproscan)) and the
UniProt *idmapping* files. For each gene, the `08-annotate-orthologs.R`
script collects the GO terms from each source and generates a
non-redundant set of GO terms. These are then assigned to the
orthogroup.

# 4 Final output

The output from all this is a single CSV file that has the following
format.

``` text
orthogroup,symbol,GO
OG0005080,BANP,GO:0006325 GO:0003677 ... GO:0042802 GO:1901796
OG0005081,CA5A,GO:0004089 GO:0005739 ... GO:0045124 GO:0035722
OG0005082,SLC7A5,GO:0015807 GO:0005765 ... GO:0015829 GO:0042908
OG0005083,KLHDC4,GO:0005515 GO:0006338 ... GO:0000775 GO:0008270
OG0005084,JPH3,GO:0030314 GO:0005789 ... GO:0001047 GO:0000122
```
