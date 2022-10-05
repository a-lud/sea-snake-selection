Integrate Annotations
================
Alastair Ludington
2022-10-05

- <a href="#1-introduction" id="toc-1-introduction">1 Introduction</a>
- <a href="#2-annotate-orthologs-pipeline"
  id="toc-2-annotate-orthologs-pipeline">2 Annotate Orthologs Pipeline</a>
  - <a href="#21-parse-funannotate-annotationtxt-files-for-go-terms"
    id="toc-21-parse-funannotate-annotationtxt-files-for-go-terms">2.1 Parse
    Funannotate ‘annotation.txt’ files for GO Terms</a>
  - <a href="#22-weighted-go-term-annotations-using-wei2go"
    id="toc-22-weighted-go-term-annotations-using-wei2go">2.2 Weighted GO
    Term annotations using Wei2GO</a>
  - <a href="#23-blast-proteins-to-uniprotkb-swiss-prot---gene-symbols"
    id="toc-23-blast-proteins-to-uniprotkb-swiss-prot---gene-symbols">2.3
    BLAST proteins to UniProtKB (Swiss-Prot) - Gene Symbols</a>
  - <a
    href="#24-annotate-best-blast-hits-using-uniprotkb-and-ncbi-gff3-annotations"
    id="toc-24-annotate-best-blast-hits-using-uniprotkb-and-ncbi-gff3-annotations">2.4
    Annotate best-BLAST-hits using UniProtKB and NCBI GFF3 annotations</a>
  - <a href="#25-assign-go-terms-and-gene-symbols-to-each-orthogroup"
    id="toc-25-assign-go-terms-and-gene-symbols-to-each-orthogroup">2.5
    Assign GO Terms and gene-symbols to each orthogroup</a>

# 1 Introduction

This document details the methods used to annotate orthogroups, along
with retroactively assigning gene symbols to sequences that were
previously not annotated. The document is included in the selection
portion of the workflow, even though it is centred around annotation, as
this work was conducted during the selection testing phase of the
project.

# 2 Annotate Orthologs Pipeline

This section details how the orthogroups from
[OrthoFinder](https://github.com/davidemms/OrthoFinder) were annotate
with gene names and GO Terms.

## 2.1 Parse Funannotate ‘annotation.txt’ files for GO Terms

One of the final output files from
[Funannotate](https://github.com/nextgenusfs/funannotate) is an
`<species>.annotation.txt` file that contains a range of functional
annotation information assigned to sequences. This can easily be parsed
to get useful information relating to each gene sequence.

I wrote a tool to parse the GO Terms for each gene into a *TSV* file,
similar to the `GOMap` file used by
[TopGO](https://bioconductor.org/packages/release/bioc/html/topGO.html).
This file has the following structure:

``` text
GeneID          TranscriptID    Gene symbol       GO Terms
FUN_000005      FUN_000005-T1                     GO:0004553 GO:0005975
FUN_000006      FUN_000006-T1
FUN_000006      FUN_000006-T2
FUN_000007      FUN_000007-T1   NUDT2             GO:0008796 GO:0016787
FUN_000007      FUN_000007-T2   NUDT2             GO:0008796 GO:0016787
FUN_000008      FUN_000008-T1                     GO:0003777 GO:0005524 GO:0008017 GO:0007018
```

The four snakes annotated using `Funannotate` include

- *Hydrophis major*      - New to this study
- *Aipysurus levis*       - New to this study
- *Hydrophis curtus*     - NCBI sample without public annotation
- *Hydrophis cyanocinctus*  - NCBI sample without public annotation

The full script used to build these files for each of the four snakes is
in `01-funannotate-to-go-map.sh`, however the key code is below:

``` bash
FILES=$(find <dir> -type f -name '*.annotations.txt')
for f in ${FILES}; do
    BN=$(basename "${f%.annotations.txt}")
    funAnn2Go" \
      -i "${f}" \
      -o "${BN}.tsv"
done
```

The `Funannotate` GO Terms are to be used as they are identified by
[InterProScan5](https://github.com/ebi-pf-team/interproscan).

## 2.2 Weighted GO Term annotations using Wei2GO

[Wei2GO](https://gitlab.com/mreijnders/wei2go) is an open-source,
sequence-similarity based functional prediction tool. Protein sequences
from the 11 snakes used in the ortholog analysis were searched against
[Pfam](https://pfam.xfam.org/) using [Hmmer3](http://hmmer.org/) and
[UniProtKB](https://www.uniprot.org/help/uniprotkb) (Swiss-Prot) using
[Diamond](https://github.com/bbuchfink/diamond).

The scripts used in the `Wei2GO` analysis include
`02-wei2go-homology.sh` and `03-wei2go.sh`. Examples of the main CLI
commands are below.

``` bash
# Diamond command to UniProtKB (Swiss-Prot)
diamond blastp \
        --threads "${SLURM_CPUS_PER_TASK}" \
        --query "${FILE}" \
        --db "${DB}" \
        --out "${OUT}/${BN}.tab"

# HMMER3 command to Pfam
 hmmscan \
        --cpu "${SLURM_CPUS_PER_TASK}" \
        --tblout "${OUT}/${BN}.out" \
        "${PF}" \
        "${FILE}"
        
# Wei2GO command
python wei2go.py "${DMND}" "${HMM}" "${OUT}/${BN}.tsv"
```

## 2.3 BLAST proteins to UniProtKB (Swiss-Prot) - Gene Symbols

Protein sequences were also searched against the Swiss-Prot database to
obtain gene symbols using
[BLASTP](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-10-421).
Custom fields were passed to the `BLAST` search tool including: qlen,
slen and qcovs.

The full script used for searching protein sequences is in
`04-blast-proteins-swissprot.sh`, with the main CLI call below:

``` bash
FILE=$(find "${PROT}" -type f -name '*.faa' | tr '\n' ' ' | cut -d ' ' -f "${SLURM_ARRAY_TASK_ID}")

if [[ ! -f "${OUT}/$(basename ${FILE%.*}).outfmt6" ]]; then
    blastp \
        -query "${FILE}" \
        -db "${DB}" \
        -out "${OUT}/$(basename ${FILE%.*}).outfmt6" \
        -evalue 1e-5 \
        -outfmt "6 qaccver saccver qlen slen length qcovs pident mismatch gapopen qstart qend sstart send evalue bitscore" \
        -max_target_seqs 100 \
        -num_threads "${SLURM_CPUS_PER_TASK}"
fi
```

## 2.4 Annotate best-BLAST-hits using UniProtKB and NCBI GFF3 annotations

Using the `BLAST` results from above, the script `annotateBlast.py` was
used to filter for high-confidence alignments, followed by gene-symbol
annotation.

The filtering criteria for high confidence `BLAST` hits was as follows:

- Percentage identity between query and subject $\geq$ 80%
- Query coverage $\geq$ 80%
- Proportion of query length relative to subject $\geq$ 80%
- After the above filters, take the top hit for each sequence (typically
  highest bitscore)

To obtain gene symbols, gene names were parsed from NCBI *GFF3* files
and matched up to their respective transcript. Additionally, the
[idmapping.dat.gz](https://www.uniprot.org/help/downloads) file was
parsed on the second column for `Gene_Name` entries, providing a
succinct version of its parent file. The UniProtKB identifiers were then
used to match best-BLAST-hits with their gene symbols (where possible).

The full script used for annotating the best-BLAST-hits is in
`05-annotate-best-blast.sh`, with a simplified version of the main
function call shown below:

``` bash
"annotateBlast.py" \
    "${BLASTDIR}" \                                 # Directory that contains BLAST output in outfmt6
    "${DB}/idmapping_selected.GO.tab.gz" \
    'blast-GO-annotations.csv' \                    # Output file
    "${OUT}" \                                      # Output directory
    -g "${GFF}" \                                   # Directory containing NCBI GFF3 annotations
    -a "${DB}/idmapping.geneNames.dat" \            # Three-column version of 'idmapping.dat.gz'
    -t "${TMP}
```

The output from this step is a single file containing the annotated
`BLAST` hits for all files in the `BLASTDIR` directory. The format of
the file is shown below:

``` text
file,qaccver,saccver,GO,symbol,ncbi_symbol
notechis_scutatus,rna-XM_026663883.1,Q8IUD2,GO:0070161; ... GO:0006355; GO:0042147,ERC1,ERC1
notechis_scutatus,rna-XM_026663887.1,Q8BID8,GO:0005737; ... GO:0031146; GO:0006511,Fbxl14,FBXL14
notechis_scutatus,rna-XM_026663888.1,Q5NVK2,GO:0005576; ... GO:2000052; GO:0016055,WNT5B,WNT5B
hydrophis_major,FUN_000002-T1,Q9UK45,GO:0071013; ... GO:0000398; GO:0000956,LSM7,
hydrophis_major,FUN_000007-T1,Q6GPY0,GO:0005743; ... GO:0046872; GO:0015031,timm13-a,
hydrophis_major,FUN_000018-T1,Q96HU8,GO:0005886; ... GO:0005525; GO:0003924; GO:0007165,DIRAS2,
hydrophis_major,FUN_000021-T1,P30671,GO:0005834; ... GO:0007186,GNG7,
```

## 2.5 Assign GO Terms and gene-symbols to each orthogroup

To recap, at this point we have

- GO Term tables built from the `Funannotate` annotation results
- GO Term tables from `wei2go`
- Gene symbol annotations from `Funannotate`, UniProtKB and NCBI *GFF3*
  files

The final step in the annotation is to assign not only GO Terms to each
sequence, but to also annotate the orthogroups generated by
`OrthoFinder`. By annotating the Orthogroups, specifically the
single-copy orthologs, we can then perform enrichment analyses using
tools like `TopGO`.

The script responsible for integrating GO Term annotations from multiple
sources is `06-annotate-orthogroups.R`, which provides more details
regarding how GO Terms were assigned. The final output from the script
looks like the following:

``` text
Orthogroup,Symbol,GO Terms
OG0005026,FKBP8,GO:0003755, GO:0005515
OG0005027,WDR18,GO:0005515
OG0005028,GATAD2A,GO:0000122, GO:0043565, GO:0006355
OG0005029,MAU2,GO:0005515, GO:0007064, GO:0000785, GO:0005654, GO:0005634, GO:0090694, GO:0032116, GO:0051301, GO:0071921, GO:0034088
OG0005030,SUGP1,GO:0003723, GO:0006396, GO:0003676
```

Each ortholog has had a gene symbol assigned to it where possible, along
with a list of non-redundant GO Terms. In situations where multiple gene
symbols were present, all symbols are reported.
