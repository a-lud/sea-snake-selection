Genome Assembly
================
Alastair Ludington
2023-03-02

- <a href="#1-introduction" id="toc-1-introduction">1 Introduction</a>
- <a href="#2-assembly-hydrophis-major"
  id="toc-2-assembly-hydrophis-major">2 Assembly: <em>Hydrophis
  major</em></a>
  - <a href="#assembly-pipeline" id="toc-assembly-pipeline">Assembly
    pipeline</a>
  - <a href="#assembly-curation-and-assessment"
    id="toc-assembly-curation-and-assessment">Assembly curation and
    assessment</a>
  - <a href="#synteny-to-h.-curtus-and-h.-cyanocinctus"
    id="toc-synteny-to-h.-curtus-and-h.-cyanocinctus">Synteny to <em>H.
    curtus</em> and <em>H. cyanocinctus</em></a>
  - <a href="#create-final-assemblies"
    id="toc-create-final-assemblies">Create final assemblies</a>
  - <a href="#repeat-annotation" id="toc-repeat-annotation">Repeat
    Annotation</a>
- <a
  href="#3-assembly-hydrophis-elegans-hydrophis-ornatus-and-hydrophis-curtus-ag"
  id="toc-3-assembly-hydrophis-elegans-hydrophis-ornatus-and-hydrophis-curtus-ag">3
  Assembly: <em>Hydrophis elegans</em>, <em>Hydrophis ornatus</em> and
  <em>Hydrophis curtus (AG)</em></a>
  - <a href="#hydrophis-elegans" id="toc-hydrophis-elegans">Hydrophis
    elegans</a>
    - <a href="#assembly" id="toc-assembly">Assembly</a>
    - <a href="#polish" id="toc-polish">Polish</a>
    - <a href="#genome-assessment" id="toc-genome-assessment">Genome
      assessment</a>
  - <a href="#h.-curtus-ag-and-h.-ornatus"
    id="toc-h.-curtus-ag-and-h.-ornatus">H. curtus (AG) and H. ornatus</a>
    - <a href="#assembly-1" id="toc-assembly-1">Assembly</a>
    - <a href="#scaffolding" id="toc-scaffolding">Scaffolding</a>
    - <a href="#polish-1" id="toc-polish-1">Polish</a>
    - <a href="#genome-assessment-1" id="toc-genome-assessment-1">Genome
      assessment</a>
  - <a href="#repeat-annotation-1" id="toc-repeat-annotation-1">Repeat
    annotation</a>

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
are informative where possible. The directories as as follows:

- **hifi-adapter-remove**: Adapter removal statistics for HiFi data
- **genome-size-est**: Genome size estimation using *GenomeScope2*
- **assembly-scaffold**: Scaffolding results from *pin_hic*
- **assembly-gap-filled**: Gap filling results using *TGS-GapCloser*
- **juicebox-out**: Output files from manual genome curation in *JBAT*
- **assembly-juicebox-to-fasta**: An output from the genome assessment
  pipeline, but the conversion of the JBAT *agp* files to FASTA sequence

## Assembly curation and assessment

**Script:**
[02-assembly_assessment.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_major/scripts/01-assembly/02-assembly_assessment.sh)  
**Outdir:**
[hydrophis_major/genome_assessment](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_major/genome_assessment)

Following assembly, the contigs were oriented into chromosomes using
[JBAT](https://github.com/aidenlab/Juicebox/wiki). The outputs from
`JBAT` were then passed as inputs to the genome assessment pipeline.
This is another workflow I’ve put together hosted
[here](https://github.com/a-lud/nf-pipelines/wiki/Assembly-Assessment).
An overview of the pipeline is shown below.

1.  Generates a chromosome FASTA file using the `JBAT` ‘.assembly’ file
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

Most of the assessment files have been uploaded to GitHub, however I’ve
omitted any that were too large.

## Synteny to *H. curtus* and *H. cyanocinctus*

**Scripts:**
[liftoff-tiger-to-hyd.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_major/scripts/02-sequence-orientation/liftoff-tiger-to-hyd.sh)
/
[mcscan.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_major/scripts/02-sequence-orientation/mcscan.sh)  
**Outdir:**
[hydrophis_major/genome_assessment/mcscan-synteny](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_major/genome_assessment/mcscan-synteny)

Next, synteny to two previously published *Hydrophis* sea snakes was
carried out. This was predominantly used to check that there were no
obvious misassemblies (though this was handled mostly by the Hi-C data)
and check homology between chromosome sequences.

At the time of writing, gene annotations are not publicly available for
either of the published *Hydrophis* genomes. As such,
[Liftoff](https://github.com/agshumate/Liftoff) was used to lift the
gene annotations from *N. scutatus* to *H. major*, *H. curtus* and *H.
cyanocinctus*. This step was an initial check, so the gene annotations
did not have to be perfect, just good enough to explore homology
relationships.

The Liftoff command used is shown below.

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
details the main steps in the `MCscan` pipeline, but see the script
listed above for more details.

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

## Create final assemblies

**Script:**
[make-final-assemblies.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/hydrophis_major/scripts/03-final-assemblies/make-final-assemblies.sh)  
**Outdir:** Not uploaded here due to file size limits

After checking the synteny, the final assemblies were made by assigning
chromosome IDs based on sequence length (note: almost all chromosomes
shared significant homology to those in *H. curtus* and *H.
cyanocinctus*). Some sequences were also reversed to better match their
orientation to the previously published *Hydrophis* snakes.

## Repeat Annotation

**Scripts:**
[hydrophis_major/scripts/04-repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_major/scripts/04-repeats)  
**Outdir:**
[hydrophis_major/repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/hydrophis_major/repeats)

Repeat annotation was handled by the
[EDTA](https://github.com/oushujun/EDTA) repeat-annotation pipeline. The
[divide and
conquer](https://github.com/oushujun/EDTA#divide-and-conquer) approach
was used to *de novo* annotate repeats within the genome before fully
annotating and masking. I made a slight edit to the `EDTA.pl` script by
adding actual break-points for each stage of the pipeline. This enabled
me to run each stage in a reasonable amount of time on our cluster.

In the script directory listed above you’ll find all the relevant repeat
scripts needed to run the *EDTA* pipeline. The first step of the
pipeline was running the `EDTA_raw.pl` script to do the *de novo* repeat
identification in parallel.

``` bash
EDTA_raw.pl \
    --genome ${ASM} \
    --type '<tir|ltr|helitron>' \       # This is set in each separate script
    --threads ${SLURM_CPUS_PER_TASK}
```

Following *de novo* prediction, the rest of the scripts were run in a
step-wise manner. Again, this was done to prevent job times exceeding
the limit on our HPC. The remaining scripts to be run were:
`01-filter-p_ctg.sh`, `02-final-p_ctg.sh`, `03-anno-p_ctg.sh`

Following annotation of repeat elements, a soft and hard-masked genome
sequences were made using the *EDTA* accessory script `make_masked.pl`.
Parameters used here match those used in the repeat pipeline.

``` bash
# 04-softmask-p_ctg.sh
make_masked.pl \
    -genome "${ASM}" \
    -minlen 100 \
    -hardmask 0 \
    -t 4 \
    -rmout "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.anno/hydmaj-p_ctg-v1.fna.mod.EDTA.TEanno.out"
    
# 04-hardmask-p_ctg.sh
make_masked.pl \
    -genome "${ASM}" \
    -minlen 100 \
    -hardmask 1 \
    -t 4 \
    -rmout "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.anno/hydmaj-p_ctg-v1.fna.mod.EDTA.TEanno.out"
```

Finally, the LAI (LTR Assembly Index) was generated from the repeat
annotation using the [LAI](https://github.com/oushujun/LTR_retriever)
software that is packaged with `LTR_retriever`.

``` bash
# 05-lai-p_ctg.sh
LAI \
  -genome "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod" \
  -intact "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.raw/LTR/hydmaj-p_ctg-v1.fna.mod.pass.list" \
  -all "${EDTADIR}/hydmaj-p_ctg-v1.fna.mod.EDTA.anno/hydmaj-p_ctg-v1.fna.mod.out" \
  -t ${SLURM_CPUS_PER_TASK}
```

# 3 Assembly: *Hydrophis elegans*, *Hydrophis ornatus* and *Hydrophis curtus (AG)*

These three snakes were assembled using different data types to *H.
major* above. Therefore, I’ve grouped their assembly approaches here.
I’ll detail the different methods used for each snake, along with the QC
approaches used to asses overall quality.

The assembly for *H. elegans* was done by me, and will be described in
its own section, while *H. ornatus* and *H. curtus (AG)* were done by
Jill **(provide her details!)** and are both in their own respective
section.

## Hydrophis elegans

### Assembly

**Script**:
[01-fye-hydrophis_elegans.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/other-snakes/scripts/01_assembly/01-flye-hydrophis_elegans.sh)  
**Outdir**: Not uploaded here due to file size limits

To assemble *H. elegans*, we generated two PromethION flow-cells worth
of Nanopore data, along with 60x coverage of short-read Illumina for
polishing. The primary assembly was generated using the program
[Flye](https://github.com/fenderglass/Flye). The command used is shown
below:

``` bash
flye \
  --nano-hq "${SEQ}/hydrophis_elegans.fastq.gz" \
  --out-dir "${OUT}" \
  --threads "${PBS_NCPUS}" \
  --scaffold
```

### Polish

**Scripts**:
[02-medaka-hydrophis_elegans.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/other-snakes/scripts/01_assembly/02-medaka-hydrophis_elegans.sh)
/
[03-nextpolish-hydrophis_elegans.sh](https://github.com/a-lud/sea-snake-selection/blob/main/assembly/other-snakes/scripts/01_assembly/03-nextpolish-hydrophis_elegans.sh)  
**Outdir**: Not uploaded here due to file size limits

Following assembly, [Medaka](https://github.com/nanoporetech/medaka) was
used to polish the contig-assembly using the long-read data.

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

### Genome assessment

**Scripts**:
[other-snakes/scripts/02_assembly_assessment](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/other-snakes/scripts/02_assembly_assessment)  
**Outdir**:
[other-snakes/scripts/genome_assessment](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/other-snakes/scripts/02_assembly_assessment)

Similar to the HiFi/Hi-C pipeline, `Merqury`, `BUSCO` , `GenomeScope2`
and `QUAST` were used to assess the quality of the assembled *H.
elegans* genome. The scripts used to generate these metrics are found at
the link above.

## H. curtus (AG) and H. ornatus

Need to get this information from Jill/Ira!

### Assembly

Need to get this information from Jill/Ira!

### Scaffolding

Need to get this information from Jill/Ira!

### Polish

Need to get this information from Jill/Ira!

### Genome assessment

Need to get this information from Jill/Ira!

## Repeat annotation

**Scripts**:
[script10](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/other-snakes/scripts/03_repeats)  
**Outdir**:
[other-snakes/repeats](https://github.com/a-lud/sea-snake-selection/tree/main/assembly/other-snakes/repeats)

*De novo* repeat annotation of each snake was performed using `EDTA` in
an identical manner to *H. major* above. The scripts used to annotate
each snake are found in the directory listed above, with some of the
outputs from the repeat annotation being found in the `03_repeats`
directory.
