Genome Assembly
================
Alastair Ludington
2023-06-19

- [1 Introduction](#1-introduction)
- [2 Assembly: *Hydrophis major*](#2-assembly-hydrophis-major)
  - [Assembly pipeline](#assembly-pipeline)
  - [Assembly curation and
    assessment](#assembly-curation-and-assessment)
  - [Synteny to *H. curtus* and *H.
    cyanocinctus*](#synteny-to-h.-curtus-and-h.-cyanocinctus)
  - [Create final assemblies](#create-final-assemblies)
- [3 Assembly: *Hydrophis elegans*](#3-assembly-hydrophis-elegans)
  - [Assembly](#assembly)
  - [Polish](#polish)
  - [Genome assessment](#genome-assessment)
- [4 Assembly: *Hydrophis ornatus* and *Hydrophis curtus
  (West)*](#4-assembly-hydrophis-ornatus-and-hydrophis-curtus-west)
  - [Assembly](#assembly-1)
  - [Polish](#polish-1)
  - [Purging heterozygous sequences](#purging-heterozygous-sequences)
  - [Chromosome scaffolding](#chromosome-scaffolding)
  - [Genome assessment](#genome-assessment-1)
- [5 Repeat Annotation](#5-repeat-annotation)
  - [Repeat annotation assessment](#repeat-annotation-assessment)

# 1 Introduction

This repository contains the scripts and (some) output files from the
assembly and repeat annotation of the *H. major*, *H. ornatus*, *H.
curtus (West)* and *H. elegans* genomes.

# 2 Assembly: *Hydrophis major*

A predominant amount of *H. major*’s assembly is handled by my automated
workflow, which is hosted
[here](https://github.com/a-lud/nf-pipelines/wiki/Genome-Assembly). See
the link and the repository for an overview and code, respectively.

## Assembly pipeline

**Script:**
[01-assembly.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_major/scripts/01-assembly/01-assembly.sh)  
**Outdir:**
[hydrophis_major/assembly](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_major/assembly)

The assembly pipeline is outlined in the link above but broadly runs the
following processes:

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

I’ve tried to include as many outputs from the tools as possible. I’ve
omitted sequence files due to their size, but have kept other files that
are informative where possible. The output directories are as follows:

- **hifi-adapter-remove**: Adapter removal statistics for HiFi data
- **genome-size-est**: Genome size estimation using *GenomeScope2*
- **assembly-scaffold**: Scaffolding results from *pin_hic*
- **assembly-gap-filled**: Gap filling results using *TGS-GapCloser*
- **juicebox-out**: Output files from manual genome curation in *JBAT*
- **assembly-juicebox-to-fasta**: An output from the genome assessment
  pipeline, but the conversion of the JBAT *agp* files to FASTA sequence

NOTE: There is an `assembly-contig` directory, however all files were
too large to upload to GitHub.

## Assembly curation and assessment

**Script:**
[02-assembly_assessment.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_major/scripts/01-assembly/02-assembly_assessment.sh)  
**Outdir:**
[hydrophis_major/genome_assessment](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_major/genome_assessment)

After running the assembly pipeline and manually orienting the
contigs/scaffolds in [JBAT](https://github.com/aidenlab/Juicebox/wiki),
the resulting `.assembly` files were used as input to the
`Genome Assessment` pipeline. This is another *Nextflow* workflow that
I’ve written that is hosted
[here](https://github.com/a-lud/nf-pipelines/wiki/Assembly-Assessment).
The pipelines overview is below:

1.  Generates a chromosome FASTA file using the *JBAT* `.assembly` file
    (see ‘assembly-juicebox-to-fasta’ above’)
2.  Closes gaps in the assembly using
    [TGS-GapCloser](https://github.com/BGI-Qingdao/TGS-GapCloser).
3.  Run a variety of genome-quality assessment tools
    - [MosDepth](https://github.com/brentp/mosdepth) to check average
      coverage
    - [Merqury](https://github.com/marbl/merqury) for K-mer completeness
      and genome quality
    - [BUSCO](https://gitlab.com/ezlab/busco) to assess final gene
      completeness
    - [QUAST](https://github.com/ablab/quast) for general assembly
      statistics

Again, output files that were not too large have been uploaded.

## Synteny to *H. curtus* and *H. cyanocinctus*

**Scripts:**
[liftoff-tiger-to-hyd.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_major/scripts/02-sequence-orientation/liftoff-tiger-to-hyd.sh)
/
[mcscan.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_major/scripts/02-sequence-orientation/mcscan.sh)  
**Outdir:**
[hydrophis_major/genome_assessment/mcscan-synteny](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_major/genome_assessment/mcscan-synteny)

Following the Genome Assessment pipeline, which generated the final *H.
major* assembly, we wanted to compare our assembly to two previously
assembled *Hydrophis* snakes ([Li et al.,
2021](https://academic.oup.com/mbe/article/38/11/4867/6329831)). This
was more of an informal validation of our assembly, with a proper
synteny analysis being carried out
[here](https://github.com/a-lud/sea-snake-selection/tree/main/synteny).

Gene annotations were not available for the *H. curtus (East)* or *H.
cyanocinctus* genomes, or for our *H. major* assembly at this point in
the assembly pipeline. Consequently, we used
[Liftoff](https://github.com/agshumate/Liftoff) to lift the annotations
from *Notechis scutatus* to each of the three assemblies to generate
rough gene annotations for each of the three *Hydrophis* snakes.

The `Liftoff` command was:

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

We then used
[GffRead](http://ccb.jhu.edu/software/stringtie/gff.shtml#gffread) to
extract the coding sequences (CDS) from each snake.

``` bash
for f in ${QRY}/*fa; do
    BN=$(basename "${f%%.*}")
    printf '[GffRead] %s\n' $BN
    gffread "${OUT}/${BN}-notechisScutatus.gff3" \
        -g "${f}" \
        -y "${OUT}/${BN}-notechisScutatus.faa" \
        -x "${OUT}/${BN}-notechisScutatus.cds"
done
```

The
[MCscan](https://github.com/tanghaibao/jcvi/wiki/MCscan-(Python-version))
(Python) pipeline was then used to identify and visualise the synteny
between the three snakes. Briefly, `MCscan` uses `LAST` aligner to
identify orthologous proteins between snake-pairs (anchors) before
extending the anchors to identify syntenic regions. These syntenyic
chunks are then visualised as ribbon plots.

Below are the key `MCscan` commands used to format the input files,
align the CDS between snakes, before filtering the anchors and
visualising the alignments.

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

Using the information from these alignments, we were able to validate
our assembly and confirm which chromosome sequence was the Z-chromosome.

## Create final assemblies

**Script:**
[make-final-assemblies.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_major/scripts/03-final-assemblies/make-final-assemblies.sh)  
**Outdir:** Assemblies not uploaded here due to file size limits

Following the check against the [Li et
al. (2021)](https://academic.oup.com/mbe/article/38/11/4867/6329831)
genomes, we made the final assembly files by assigning chromosome IDs.
The Z-chromosome identified and named using the information from the
synteny check. The remaining chromosomes were labelled from chromosome
1 - 15 based on their length.

# 3 Assembly: *Hydrophis elegans*

*Hydrophis elegans* was assembled from *Nanopore* ultra long-reads and
*MGI* short-read data. Consequently, a different assembly pipeline was
used for this sample which is detailed below.

## Assembly

**Script**:
[01-fye-hydrophis_elegans.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_elegans/scripts/01-assembly/01-flye-hydrophis_elegans.sh)  
**Outdir**:
[hydrophis_elegans/assembly/flye](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_elegans/assembly/flye)

The assembly program [Flye](https://github.com/fenderglass/Flye) was
used to assembly two flowcells worth of *H. elegans* *Nanopore* data
into the initial primary assembly.

``` bash
flye \
  --nano-hq "${SEQ}/hydrophis_elegans.fastq.gz" \
  --out-dir "${OUT}" \
  --threads "${PBS_NCPUS}" \
  --scaffold
```

## Polish

**Scripts**:
[02-medaka-hydrophis_elegans.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_elegans/scripts/01-assembly/02-medaka-hydrophis_elegans.sh)
/
[03-nextpolish-hydrophis_elegans.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_elegans/scripts/01-assembly/03-nextpolish-hydrophis_elegans.sh)  
**Outdir**: Not uploaded here due to file size limits

The primary contigs were then polished with the consensus polishing tool
[Medaka](https://github.com/nanoporetech/medaka). This program uses the
*Nanopore* data to perform an initial polish the assembly, before
polishing with the more accurate short-read data.

``` bash
medaka_consensus \
  -i "${READS}/hydrophis_elegans.fastq.gz" \
  -d "${FASTA}" \
  -o "${OUT}" \
  -m 'r941_prom_sup_g507'
```

The software
[NextPolish](https://nextpolish.readthedocs.io/en/latest/index.html) was
then used to perform two rounds of short-read polishing. The alignment
pipeline recommended in the `NextPolish` documentation was manually
implemented before running the polishing software.

Two iterations of the following alignment pipeline were applied to:

- Round 1: `Medaka` polished genome as the reference
- Round 2: Round 1 `NextPolish` genome as the reference

The

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

# Second round of polish
python nextpolish1.py \
    -g "${ASM}" \             # Output from first round
    -t 2 \
    -p 24 \
    -s "${OUT_ONE}/sr.bam" > "${OUT_ONE}/${BN}.round-${ROUND}.fa"
```

## Genome assessment

**Scripts**:
[hydrophis_elegans/scripts/02-assembly_assessment](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_elegans/scripts/02-assembly_assessment)  
**Outdir**:
[hydrophis_elegans/genome_assessment](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_elegans/genome_assessment)

The same assembly assessment techniques used for *H. major* were used
for *H. elegans*. This included running the programs *GenomeScope2* for
genome estimation size estmiates ,*Merqury* for k-mer completeness and
QV estimates, *BUSCO* for gene-level completeness metrics and *QUAST*
for general assembly metrics.

The scripts used to run these programs can be found in the directory
listed above, with some of the relevant outputs found in the `Outdir`
link.

# 4 Assembly: *Hydrophis ornatus* and *Hydrophis curtus (West)*

The *H. ornatus* and *H. curtus (West)* samples were sequenced and
assembled in the same way. *Nanopore* ultra long-reads, Hi-C and
Illumina short-read sequencing libraries were generated for each sample.

## Assembly

**Scripts**:
[01-flye-hydrophis_ornatus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_ornatus/scripts/01-assembly/01-flye-hydrophis_ornatus.sh)
/
[01-flye-hydrophis_curtus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_curtus_west/scripts/01-assembly/01-flye-hydrophis_curtus.sh)  
**Outdir**: Not uploaded due to size

Assembly of the *Nanopore* long-reads was performed by *Flye* assembler,
specifying two internal polishing iterations.

``` bash
flye \
  --nano-hq "${SEQ}/${FQ}" \
  --out-dir "${OUT}" \
  --threads "${NCPUS}" \
  -i 2
```

## Polish

**Scripts**:
[02-hypo-hydrpophis_ornatus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_ornatus/scripts/01-assembly/02-hypo-hydrophis_ornatus.sh)
/
[02-hypo-hydrophis_curtus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_curtus_west/scripts/01-assembly/02-hypo-hydrophis_curtus.sh)  
**Outdir**: Not uploaded due to size

The primary assemblies of each snake were then polished using the long-
and short-read libraries using the software
[HyPo](https://github.com/kensung-lab/hypo). This is a program that
corrects draft assemblies by separating genomic regions into ‘strong’
and ‘weak’ regions (based on solid k-mers). Weak regions are polished
using POA, with short, accurate reads taking precedence over long, noisy
reads (if both are provided).

``` bash
hypo \
  --reads-short "${FQ}" \
  --draft "${ASM}" \
  --bam-sr "${BAM_SR}" \
  --coverage-short 'Cx' \
  --size-ref '2g' \
  --bam-lr "${BAM_LR}" \
  --output "..." \
  --threads 30
  
```

## Purging heterozygous sequences

**Scripts**:
[03-purge_hap-hydrpophis_ornatus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_ornatus/scripts/01-assembly/03-purge_hap-hydrophis_ornatus.sh)
/
[03-purge_hap-hydrophis_curtus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_curtus_west/scripts/01-assembly/03-purge_hap-hydrophis_curtus.sh)  
**Outdir**: Not uploaded due to size

After polishing the contigs, the pipeline [Purge
Haplotigs](https://bitbucket.org/mroachawri/purge_haplotigs/src/master/#markdown-header-citation)
was run to remove heterozygous haplotigs. Without trio information or
high accuracy long-reads and Hi-C data, it’s difficult to produce a
phased genome assembly. Consequently, assemblers try to assemble a
haploid representation of the genome, typically choosing one allele to
include in the genome and ignoring the other. However, assembly tools
aren’t always the best when it comes to heterozygous regions, typically
assembling each haplotype as a separate contig once a nucleotide
diversity threshold is crossed, rather than a haplotype-fused contig.

*Purge Haplotigs* uses sequence coverage and self-alignments to find
contigs that are duplicated, representing separate contigs of the same
homozygous region. The program identifies these redundant contigs and
‘purges’ them, resulting in a curated haploid assembly with reduced
redundancy. The main steps of the pipeline are shown below:

``` bash
# Step 1: Align Nanopore to genome
minimap2 -t 4 -ax map-ont "${ASM}" "${READS}" --secondary=no |
  samtools sort -m 1G -o "${OUT}/asm-lr.bam"

# Step 2: Coverage histogram
purge_haplotigs hist -t 30 -b "${OUT}/asm-lr.bam" -g "${ASM}"

# Step 3: Contig coverage stats (mark suspect contigs)
purge_haplotigs cov -i aligned.bam.genecov -l ... -m ... -h ... -o "${OUT}/coverage_stats.csv"

# Step 4: Purge the haplotigs
purge_haplotigs purge -g "${ASM}" -c "${OUT}/coverage_stats.csv" 
```

## Chromosome scaffolding

**Scripts**: 04-juicer-hydrophis_ornatus.sh /
04-juicer-hydrophis_curtus.sh  
**Outdir**: Not uploaded due to size

Finally, the contig assemblies were scaffolded using the program
[Juicer](https://github.com/aidenlab/juicer). *Juicer* is a Hi-C
analysis pipeline that starts with Fastq files and generates Hi-C
contact matrices from the data.

``` bash
# idk
```

## Genome assessment

**Scripts**:

- [hydrophis_ornatus/scripts/02-assembly_assessment](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_ornatus/scripts/02-assembly_assessment)
- [hydrophis_curtus_west/scripts/02-assembly_assessment](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_curtus_west/scripts/02-assembly_assessment)

**Outdir**:

- [hydrophis_ornatus/genome_assessment](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_ornatus/genome_assessment)
- [hydrophis_curtus_west/genome_assessment](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_curtus_west/genome_assessment)

Similar to above, the same genome assessment techniques were used:
*GenomeScope2*, *BUSCO*, *Merqury* and *QUAST*. The scripts used to run
these programs can be found in the directory listed above, with some of
the relevant outputs found in the `Outdir` link.

# 5 Repeat Annotation

**Scripts:**

- [hydrophis_major/scripts/04-repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_major/scripts/04-repeats)
- [hydrophis_ornatus/scripts/03-repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_ornatus/scripts/03-repeats)
- [hydrophis_curtus_west/scripts/03-repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_curtus_west/scripts/03-repeats)
- [hydrophis_elegans/scripts/03-repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_elegans/scripts/03-repeats)

**Outdir:**

- [hydrophis_major/repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_major/repeats)
- [hydrophis_ornatus/repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_ornatus/repeats)
- [hydrophis_curtus_west/repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_curtus_west/repeats)
- [hydrophis_elegans/repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_elegans/repeats)

The same repeat annotation pipeline was run for all snakes. *De novo*
annotation was first performed by the program
[EDTA](https://github.com/oushujun/EDTA), before final repeat
annotations were created using the homology-based program
[RepeatMasker](https://www.repeatmasker.org/).

The *EDTA* [divide and
conquer](https://github.com/oushujun/EDTA#divide-and-conquer) pipeline
was used to *de novo* annotate the genome. The `EDTA.pl` script was
edited to stop after each major module in the pipeline to assist with
running the program on our cluster. In the script directory listed above
you’ll find all the relevant repeat scripts needed to run the *EDTA*
pipeline.

Before running the main pipeline, we first ran `EDTA_raw.pl` in parallel
to first find TIR, LTR and Helitron repeats:

``` bash
EDTA_raw.pl \
    --genome ${ASM} \
    --type '<tir|ltr|helitron>' \       # This is set in each separate script
    --threads ${SLURM_CPUS_PER_TASK}
```

Next, we ran the remainder of the *EDTA* pipeline in a step-wise manner
(see the numbered scripts in the scripts directory listed above).
Importantly, we supplied the coding sequences from *Notechis scutatus*
to *EDTA* as a form of (relatively) evolutionarily close protein
evidence to help prevent the mis-classification of gene sequences as
repeats.

Below is the main *EDTA* commandline call with elements included from
each stage:

``` bash
# Main command call
EDTA.pl \
  --genome ${ASM} \
  --step <filter, final, anno>= \
  --overwrite 0 \
  --sensitive 1 \
  --anno 1 \
  --cds "${CDS}" \
  --threads ${SLURM_CPUS_PER_TASK}
```

The *TElib* library generated by *EDTA* was then merged with the
*RepBase RepeatMasker* library and passed to *RepeatMasker* to perform
the final homology-based repeat annotation. This generated the final
soft-masked files, repeat GFF3 files and repeat summary files.

``` bash
RepeatMasker \
    -e rmblast \
    -pa 10 \
    -no_is \
    -norna \
    -div 40 \
    -lib "${DIR}/edta-libraries/${BN}.edta-repbase.fa" \
    -dir . \
    -xsmall \
    -gff \
    -a \
    -inv \
    "${ASM}"
    
# NOTE: Kimura divergence profiles were created using the following commands
calcDivergenceFromAlign.pl -s ${ASM}.divsum ${ASM}.out.align
tail -n 72 ${ASM}.divsum > ${ASM}.kimura.divergence
```

### Repeat annotation assessment

**Script:**

- [busco-hardmask.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/scripts-general/busco-hardmask.sh)
- [04-lai-p_ctg.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_major/scripts/04-repeats/04-lai-p_ctg.sh)
- [06-lai.sh (H.
  ornatus)](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_ornatus/scripts/03-repeats/06-lai.sh)
- [06-lai.sh (H. curtus
  (west))](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_curtus_west/scripts/03-repeats/06-lai.sh)
- [06-lai.sh (H.
  elegans)](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_elegans/scripts/03-repeats/06-lai.sh)

**Outdir:**

- [data/busco/genomes/hardmask-RM](https://github.com/a-lud/sea-snake-selection/tree/main/data/busco/genomes/hardmask-RM)
- [hydrophis_major/repeats/lai](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_major/repeats/lai)
- [hydrophis_ornatus/repeats/lai](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_ornatus/repeats/lai)
- [hydrophis_curtus_west/repeats/lai](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_curtus_west/repeats/lai)
- [hydrophis_elegans/repeats/lai](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_elegans/repeats/lai)

To assess the quality of the annotated repeats, we performed two checks.
The first used the formal measure of LTR completeness using the program
[LAI](https://github.com/oushujun/LTR_retriever). The second involved
running [BUSCO](https://gitlab.com/ezlab/busco) on the hard-masked
genome files to see how many single-copy orthologs were lost following
repeat masking (fewer complete *BUSCOs* lost is better).

The *LAI* program was run using outputs from the *EDTA* pipeline, using
the command below:

``` bash
# 05-lai-p_ctg.sh
LAI \
  -genome "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod" \
  -intact "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.raw/LTR/hydmaj-p_ctg-v1.fna.mod.pass.list" \
  -all "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.anno/hydmaj-p_ctg-v1.fna.mod.out" \
  -t ${SLURM_CPUS_PER_TASK}
```

While *BUSCO* was run on the *RepeatMasker* hard-masked genomes against
the Tetrapoda (odb10) database.

``` bash
# Where ASM is the hard-masked genome
busco \
  -i "${ASM}" \
  -o "busco-${BN}" \
  -m 'geno' \
  -l "${DB}" \
  --cpu 30 \
  --metaeuk_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
  --metaeuk_rerun_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
  --out_path "${OUT}" \
  --tar \
  --offline
```

<!-- [script16]:  -->
<!-- [script17]: -->
