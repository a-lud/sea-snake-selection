Genome Assembly
================
Alastair Ludington
2022-10-24

- <a href="#1-introduction" id="toc-1-introduction">1 Introduction</a>
- <a href="#2-assembly-hydrophis-major"
  id="toc-2-assembly-hydrophis-major">2 Assembly: <em>Hydrophis
  major</em></a>
  - <a href="#21-assembly-pipeline" id="toc-21-assembly-pipeline">2.1
    Assembly pipeline</a>
  - <a href="#22-assembly-curation-and-assessment"
    id="toc-22-assembly-curation-and-assessment">2.2 Assembly curation and
    assessment</a>
  - <a href="#23-synteny-to-h-curtus-and-h-cyanocinctus"
    id="toc-23-synteny-to-h-curtus-and-h-cyanocinctus">2.3 Synteny to <em>H.
    curtus</em> and <em>H. cyanocinctus</em></a>
  - <a href="#24-create-final-assemblies"
    id="toc-24-create-final-assemblies">2.4 Create final assemblies</a>
  - <a href="#25-repeat-annotation" id="toc-25-repeat-annotation">2.5 Repeat
    Annotation</a>
- <a href="#3-assembly-hydrophis-elegans"
  id="toc-3-assembly-hydrophis-elegans">3 Assembly: <em>Hydrophis
  elegans</em></a>
  - <a href="#31-assembly" id="toc-31-assembly">3.1 Assembly</a>
  - <a href="#32-polish" id="toc-32-polish">3.2 Polish</a>
  - <a href="#33-genome-assessment" id="toc-33-genome-assessment">3.3 Genome
    assessment</a>

# 1 Introduction

In this repository you will find the scripts responsible for assembling
the genomes used in this paper. This document will outline the methods
used both for the Hifi/Hi-C *H. major* genome, as well as the methods
used for the Nanopore only assemblies for *H. elegans*.

# 2 Assembly: *Hydrophis major*

A predominant amount of the genome assembly is handled by my automated
workflow, which is hosted
[here](https://github.com/a-lud/nf-pipelines/wiki/Genome-Assembly). See
the link and the repository for an overview and code, respectively.

## 2.1 Assembly pipeline

The assembly pipeline is outlined in the link above. Briefly, the
assembly pipeline involved the following processes.

1.  Filter Hifi reads for adapter content using
    [HifiAdapterFilt](https://github.com/sheinasim/HiFiAdapterFilt).
2.  Assemble Hifi reads using
    [Hifiasm](https://github.com/chhylp123/hifiasm).
    - Hi-C reads are used here to guide contig-to-haplotype assignment.
3.  Pre-process Hi-C reads using an adapted
    [Arima](https://github.com/ArimaGenomics/mapping_pipeline) mapping
    pipeline.
4.  Scaffold the `Hifiasm` contigs into scaffolds using
    [pin_hic](https://github.com/dfguan/pin_hic).
5.  Generate the Hi-C contact matrix from the aligned Hi-C reads using
    [Matlock](https://github.com/phasegenomics/matlock).
6.  Gene content assessment using
    [BUSCO](https://gitlab.com/ezlab/busco)
7.  Genome size estimation using the HiFi reads and
    [GenomeScope2](https://github.com/tbenavi1/genomescope2.0)

The script responsible for running the genome assembly pipeline is
`01-assembly.sh`.

## 2.2 Assembly curation and assessment

Following genome assembly, the genome scaffolds were oriented into
chromosomes using [JBAT](https://github.com/aidenlab/Juicebox/wiki). The
outputs from `JBAT` were then passed as inputs to the genome assessment
pipeline. This is another workflow I’ve put together hosted
[here](https://github.com/a-lud/nf-pipelines/wiki/Assembly-Assessment).
Breifly, the pipeline does the following:

1.  Generates a chromosome fasta file using the `JBAT` ‘.assembly’ file.
2.  Closes gaps in the assembly using
    [TGS-GapCloser](https://github.com/BGI-Qingdao/TGS-GapCloser).
3.  Run a variet of genome-quality assessment tools
    - [MosDepth](https://github.com/brentp/mosdepth) to check average
      coverage
    - [Merqury](https://github.com/marbl/merqury) for K-mer completeness
      and genome quality
    - [BUSCO](https://gitlab.com/ezlab/busco) to assess final gene
      completeness
    - [QUAST](https://github.com/ablab/quast) for general assembly
      statistics

The script that kicks off the assembly assessment pipeline is
`02-assembly_assessment.sh`.

## 2.3 Synteny to *H. curtus* and *H. cyanocinctus*

Next, synteny to two previously published hydrophis sea snakes was
carried out. This was predominantly used to check that there were no
obvious misassemblies (though this was handled mostly by the Hi-C data),
as well as to potentially assign chromosome names.

At the time of writing, gene annotations are not publicly available for
either of the published *Hydrophis* genomes. As such,
[Liftoff](https://github.com/agshumate/Liftoff) was used to lift the
gene annotations from *N. scutatus* to *H. major*, *H. curtus* and *H.
cyanocinctus*.

``` bash
liftoff \
    "${QUERY}" \                                                    # Query genome
    "${REF}/GCF_900518725.1_TS10Xv2-PRI_genomic.fna" \              # Subject genome
    -db "${REF}/GCF_900518725.1_TS10Xv2-PRI_genomic.gff_db" \       # Subject annotation
    -o "${OUT}/${BN}-notechisScutatus.gff3" \                       # Output annotation
    -u "${OUT}/${BN}-notechisScutatus-unmapped.txt" \
    -exclude_partial \
    -flank 0.3 \
    -dir "${BN}-intermediates" \
    -p 16 &> "${OUT}/${BN}.log" || exit 1 &
```

Using the `GFF3` file generated by `Liftoff`,
[GffRead](http://ccb.jhu.edu/software/stringtie/gff.shtml#gffread) was
used to extract protein-translated and nucleotide coding sequences.

The coding sequence files were then passed to
[MCscan](https://github.com/tanghaibao/jcvi/wiki/MCscan-(Python-version))
to generate synteny figures to assess homology. The code chunk below
details the main steps in the `MCscan` pipeline:

``` bash
# GFF-to-BED
python3 -m jcvi.formats.gff bed --type=mRNA --key=ID "${BN}.gff3" -o "${BN}.bed"

# Find orthologs between samples
python3 -m jcvi.compara.catalog ortholog \
  --cpus=6 \
  --no_strip_names \
  -n 20 \
  hydrophis_major-p_ctg hydrophis_cyanocinctus

# Generate a more succinct form of the anchors file (.simple file)
python3 -m jcvi.compara.synteny screen \
  --minspan=30 \
  --simple \
  hydrophis_major-p_ctg.hydrophis_cyanocinctus.anchors hydrophis_major-p_ctg.hydrophis_cyanocinctus.anchors.new
  
# Generate ribbon plots
python3 -m jcvi.graphics.karyotype seqids layout
```

The script `mcscan.sh` in directory `02-sequence-orientation` provides
the actual code used to generate the plots for each sample-comparison.

## 2.4 Create final assemblies

After checking the synteny, the final assemblies were made by assigning
chromosome IDs based on sequence length (note: almost all chromosomes
shared significant homology to those in *H. curtus* and *H.
cyanocinctus*). Some sequences were also reversed to better match their
orientation to the previously published *Hydrophis* snakes.

The code and identifier mappings used to make the final genome files can
be found in `03-final-assemblies`. Specifically, the
`make-final-assemblies.sh` script.

## 2.5 Repeat Annotation

Repeat annotation was handled by the
[EDTA](https://github.com/oushujun/EDTA) repeat-annotation pipeline. The
[divide and
conquer](https://github.com/oushujun/EDTA#divide-and-conquer) approach
was used to *de novo* annotate repeats within the genome before fully
annotating and masking.

In `04-repeats` you will find all relevant scripts relating to the
annotation of repeat elements. First, repeat types were found using the
`EDTA_raw.pl` script:

``` bash
EDTA_raw.pl \
    --genome ${ASM} \
    --type '<tir|ltr|helitron>' \       # This is set in each separate script
    --threads ${SLURM_CPUS_PER_TASK}
```

Following detection of the raw repeats, the rest of the pipeline was run
in step-wise manner as to not exceed our clusters time limit. The
relevant scripts for the annotation of repeats include:

- `01-filter-p_ctg.sh`
- `02-final-p_ctg.sh`
- `03-anno-p_ctg.sh`

Following annotation of repeat elements, a soft-masked version of the
genome was generated using the accessory script `make_masked.pl`.
Parameters used here match those used in the repeat pipeline.

``` bash
make_masked.pl \
    -genome "${ASM}" \
    -minlen 100 \
    -hardmask 0 \
    -t 4 \
    -rmout "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.anno/hydmaj-p_ctg-v1.fna.mod.EDTA.TEanno.out"
```

The script used to make the soft-masked genome is
`04-softmask-p_ctg.sh`.

Finally, the LAI (LTR Assembly Index) was generated from the repeat
annotation using the [LAI](https://github.com/oushujun/LTR_retriever)
software that is packaged with `LTR_retriever` (`05-lai-p_ctg.sh`) and
visualised using the script `plot-LAI.R`.

``` bash
LAI \
  -genome "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod" \
  -intact "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.raw/LTR/hydmaj-p_ctg-v1.fna.mod.pass.list" \
  -all "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.anno/hydmaj-p_ctg-v1.fna.mod.out" \
  -t ${SLURM_CPUS_PER_TASK}
```

# 3 Assembly: *Hydrophis elegans*

This snake was assembled using a different approach to *H. major*. This
assembly was produced using only Nanopore long-reads.

## 3.1 Assembly

Assembly was carried out by the software
[Flye](https://github.com/fenderglass/Flye), with the exact code being
found in `01-fye-hydrophis_elegans.sh`.

``` bash
flye \
  --nano-hq "${SEQ}/hydrophis_elegans.fastq.gz" \
  --out-dir "${OUT}" \
  --threads "${PBS_NCPUS}" \
  --scaffold
```

## 3.2 Polish

Following assembly, [Medaka](https://github.com/nanoporetech/medaka) was
used to polish the contigs using the long-read sequences. The script
used to run `Medaka` can be found at `02-medaka.sh`.

``` bash
medaka_consensus \
  -i "${READS}/hydrophis_elegans.fastq.gz" \
  -d "${FASTA}" \
  -o "${OUT}" \
  -m 'r941_prom_sup_g507'
```

The software
[NextPolish](https://nextpolish.readthedocs.io/en/latest/index.html) was
then used to perfrom two rounds of short-read polishing. The alignment
pipeline recommended in the `NextPolish` documentation was manually
implemented before running the polishing software.

Two iterations of the following alignment pipeline were applied to:

- Round 1: `Medaka` polished genome as the reference
- Round 2: Round 1 NextPolish genome as the reference

``` bash
# Align, filter, sort and mark duplicates
bwa-mem2 mem \
    -t 30 \
    "${ASM}" "${R1}" "${R2}" | \
    "${NIB}/samtools" view -u --threads 4 -F 0x4 -b - | \
    "${NIB}/samtools" fixmate -m --threads 4 - - | \
    "${NIB}/samtools" sort -m 2g --threads 5 - | \
    "${NIB}/samtools" markdup -O 'BAM' --threads 5 -r - "${OUT_ONE}/sr.bam"

# First round of polish
python nextpolish1.py \
    -g "${ASM}" \
    -t 1 \
    -p 24 \
    -s "${OUT_ONE}/sr.bam" > "${OUT_ONE}/${BN}.round-${ROUND}.fa"
```

**NOTE**: The `-t 1` parameter in the `nextpolish1.py` command was
changed to `-t 2` in the second round of polishing as per the
`read-the-docs` example.

## 3.3 Genome assessment

Similar to the HiFi/Hi-C pipeline, `Merqury` and `BUSCO` were used to
assess the quality of the assembled genomes.

``` bash
# BUSCO
busco \
    -i "hydrophis_elegans-polished.fa" \
    -o 'hydrophis_elegans-nextpolish' \
    -m 'geno' \
    -l "${DB}" \
    --cpu 50 \
    --metaeuk_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
    --metaeuk_rerun_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
    --out_path "${PWD}" \
    --tar \
    --offline

# Merqury
meryl count \
    k=21 \
    threads=30 \
    memory=100 \
    "${READS}/Hydrophis_elegans-KLS1121_R1.fastq.gz" \
    "${READS}/Hydrophis_elegans-KLS1121_R2.fastq.gz" \
    output Hydrophis_elegans-reads.meryl

# Compare genome to reads
merqury.sh \
    'Hydrophis_elegans-reads.meryl' \
    'hydrophis_elegans-polished.fa' \
    'Hydrophis_elegans-to-reads'
```
