Gene Annotation
================
Alastair Ludington
2023-06-20

- [1 Introduction](#1-introduction)
- [2 *De novo* Annotation](#2-de-novo-annotation)
  - [Preparation](#preparation)
    - [RefSeq annotations to *Hydrophis*
      genomes](#refseq-annotations-to-hydrophis-genomes)
    - [Curated snake protein evidence](#curated-snake-protein-evidence)
    - [MetaEuk easy-predict](#metaeuk-easy-predict)
    - [Preparation summary](#preparation-summary)
  - [Funannotate](#funannotate)
    - [Funannotate Train](#funannotate-train)
    - [Funannotate Predict](#funannotate-predict)
    - [Funannotate Update](#funannotate-update)
    - [Funannotate Annotate](#funannotate-annotate)
- [3 Lift-over annotation](#3-lift-over-annotation)

# 1 Introduction

This sub-directory contains the resources relating to gene annotation.

The *de novo* annotated snakes include:

- *Hydrophis major* - New to this study.
- *Hydrophis curtus (East)* - Previously published ([Li et al.,
  2021](https://academic.oup.com/mbe/article/38/11/4867/6329831)) but no
  RefSeq annotation.
- *Hydrophis cyanocinctus* - Previously published ([Li et al.,
  2021](https://academic.oup.com/mbe/article/38/11/4867/6329831)) but no
  RefSeq annotation.

The [Liftoff](https://github.com/agshumate/Liftoff) annotated snakes
are:

- *Hydrophis elegans* - New to this study.
- *Hydrophis ornatus* - New to this study
- *Hydrophis curtus (AG)* - New to this study

The methods for each of the annotation approaches are detailed below

# 2 *De novo* Annotation

The *de novo* annotation process involved three distinct approaches that
were integrated to form a final annotation.

1.  Homology-based annotation
2.  *De novo* annotation
3.  Transcriptomic evidence

For *de novo* annotation, we used the annotation pipeline [Funannotate
(v1.8.11)](https://github.com/nextgenusfs/funannotate). Like many
prediction pipelines, it integrates the annotation sources listed above
and forms a non-redundant set of gene models.

The *de novo* annotation steps below relate to *H. major*, *H. curtus
(East)* and *H. cyanocinctus*. Please note that I ran the first two
stages of the *Funannotate* pipeline twice for *H. major*: once on the
soft-masked genome and once on the standard assembly. I did this to
maximise gene prediction, but also becuse I had the time and resources.
I was not able to do this for *H. curtus (East)* or *H. cyanocinctus*.

## Preparation

Prior to running the `Funannotate` pipeline, we generated additional
lines of gene evidence.

### RefSeq annotations to *Hydrophis* genomes

**Scripts:**
[00-liftoff-genomes-to-hmaj.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/scripts-general/00-liftoff-genomes-to-snakes.sh)
/
[liftoff-to-evm.R](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/scripts-general/liftoff-to-evm.R)  
**Outdir:** Too large to upload

[Liftoff](https://github.com/agshumate/Liftoff) was used to lift RefSeq
annotations to each of the three *Hydrophis* snakes (RefSeq samples
included: [Notechis
scutatus](https://www.ncbi.nlm.nih.gov/genome/?term=Notechis%20scutatus),
[Pseudonaja
textilis](https://www.ncbi.nlm.nih.gov/genome/?term=pseudonaja+textilis),
[Naja
naja](https://www.ncbi.nlm.nih.gov/data-hub/genome/GCA_009733165.1/),
[Protobothrops
mucrosquamatus](https://www.ncbi.nlm.nih.gov/genome/?term=Protobothrops+mucrosquamatus),
[Thamnophis
elegans](https://www.ncbi.nlm.nih.gov/genome/?term=thamnophis+elegans)
and [Anolis
Carolinensis](https://www.ncbi.nlm.nih.gov/genome/?term=Anolis+carolinensis)).

``` bash
# NCBI annotated samples
SMP='anolis_carolinensis naja_naja notechis_scutatus protobothrops_mucrosquamatus pseudonaja_textilis thamnophis_elegans'

# Iterate over each NCBI annotation and lift it over to our 'refernece' of interest
for SAMPLE in ${SMP}; do
    mkdir -p "${OUT}/liftoff-${SAMPLE}"

    if [[ ! -f "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-reference.gff3" ]]; then
       printf '[LiftOff] %s\n' "${SAMPLE} to reference"

       # Lift annotations over
       liftoff \
           "${ASM}" \
           "${REF}/${SAMPLE}.fna" \
           -g "${GFF}/${SAMPLE}.gff3" \
           -o "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-reference.gff3" \
           -u "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-reference.unmapped.txt" \
           -exclude_partial \
           -flank 0.1 \
           -dir "${OUT}/${SAMPLE}-intermediates" \
           -p 50 &> "${OUT}/liftoff-${SAMPLE}/${SAMPLE}.log"

        # Extract CDS as nuc/pep
        gffread "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-reference.gff3" \
            -g "${ASM}" \
            -y "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-reference.faa" \
            -x "${OUT}/liftoff-${SAMPLE}/${SAMPLE}-to-reference.fna"
   fi
done
```

The lifted annotations for each *Hydrophis* snake was used as `OTHER`
evidence during *Funannotate predict*.

### Curated snake protein evidence

**Script:**
[00-mmseqs2-cluster-snake-proteins.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/scripts-general/00-mmseqs2-cluster-snake-proteins.sh)  
**Outdir:** Too large to upload

Next, protein squences from the RefSeq samples above, plus the
lifted-over annotations and the
[UniProt-SwissProt](https://www.uniprot.org/) curated protein database
were pooled together and passed to
[MMseqs2](https://github.com/soedinglab/MMseqs2) to generate a
non-redundant set of representative protein sequences. This was achieved
using the `easy-cluster` argument, which uses a cascade clustering
algorithm.

``` bash
# Reduce the protein set down to a 'representative', non-redundant set
mmseqs easy-cluster \
    "${PROT}/snake-proteins.faa" \
    "${PROT}/snake-proteins-clustered" \
    "${PROT}/mmtemp" \
    --min-seq-id 0.9 \
    -c 0.9 \
    --cluster-reassign \
    --threads "${PBS_NCPUS}"
```

These representative proteins were passed as protein evidence to
*Funannotate predict*.

### MetaEuk easy-predict

**Scripts:**
[00-metaeuk-easypredict](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/scripts-general/00-metaeuk-easypredict.sh)
/
[metaeuk-to-evm.R](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/scripts-general/metaeuk-to-evm.R)  
**Outdir:** Too large to upload

Finally, we generated external homology-based gene models using
[MetaEuk](https://github.com/soedinglab/metaeuk#easy-predict-workflow).
The curated snake proteins and SwissProt database were each provided to
MetaEuk easy-predict\` module for each of the three snakes.

``` bash
# Predict gene models based on protein homology
metaeuk easy-predict \
    genome.fa \
    proteins.fa \
    "${OUT}/metaeuk-predictions" \
    "${OUT}" \
    --min-seq-id 0.7 \
    --max-intron 150000 \
    --threads 50 \
    --headers-split-mode 1 \
    --remove-tmp-files
```

### Preparation summary

To summarise, we generated three additional sources of gene evidence for
each snakes:

1.  A non-redundant set of protein sequences generated by `MMseqs2`
2.  *Liftoff* annotations that are `EVM` compatible
3.  *MetaEuk* `easy-predict` annotations that are EVM\` compatible

These external sources of gene evidence were used as inputs to
*Funannotate* (see below)

## Funannotate

[Funannotate](https://github.com/nextgenusfs/funannotate) is a gene
prediction software package. It acts as a wrapper around a bunch of
common gene prediction tools, linking common annotation processes
together in a single pipeline. The beauty of `Funannotate` is that it
automates a lot of the annoying, manual processes that users normally
have to deal with.

There are four main stages to `Funannotate` which are: *Train*,
*Predict*, *Update*, *Annotate*. Below is a summary of each stage.

### Funannotate Train

**Scripts:**

- [01-train.sh (Hydrophis
  major)](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_major/scripts/01-train.sh)
- [01-train-hydrophis_curtus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_curtus-east/scripts/01-train-hydrophis_curtus.sh)
- [01-train-hydrophis_cyanocinctus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_cyanocinctus/scripts/01-train-hydrophis_cyanocinctus.sh)

**Outdir:** Raw outputs not uploaded due to file size limits

*Funannotate train* is essentially a wrapper around [Genome Guided
Trinity](https://github.com/trinityrnaseq/trinityrnaseq/wiki/Genome-Guided-Trinity-Transcriptome-Assembly)
and [PASA](https://github.com/PASApipeline/PASApipeline/wiki). RNA-seq
data is used as input and is first asembled into transcripts by
*Trinity* before *PASA* is used to generate transcript-derived gene
models. As the RNA-seq data has already been QC’d, I didn’t run the
included *Trimmomatic* step.

``` bash
# Generate a range of useful data from the RNA-seq
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate train \
    --input "${ASM}" \
    --out "${OUT}" \
    --left "${RNA}/left.fastq.gz" \
    --right "${RNA}/right.fastq.gz" \
    --no_trimmomatic \
    --max_intronlen 150000 \
    --species "Hydrophis major" \
    --cpus "${PBS_NCPUS}"
```

### Funannotate Predict

**Script:**

- [02-predict.sh (H.
  major)](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_major/scripts/02-predict.sh)
- [02-predict-hydrophis_curtus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_curtus-east/scripts/02-predict-hydrophis_curtus.sh)
- [02-predict-hydrophis_cyanocinctus](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_cyanocinctus/scripts/02-predict-hydrophis_cyanocinctus.sh)

**Outdir:** Raw outputs not uploaded due to file size limits

*Funannotate predict* does nearly all of the gene prediction. The
*predict* module performs the following tasks:

- Parse the outputs generated by *Funannotate train* and train the *de
  novo* prediction tools:
  - [AUGUSTUS](https://github.com/Gaius-Augustus/Augustus)
  - [SNAP](https://github.com/KorfLab/SNAP)
  - [GeneMark](http://exon.gatech.edu/GeneMark/)
  - [GlimmerHMM](https://ccb.jhu.edu/software/glimmerhmm/)
- Run each of the trained *de novo* gene prediction tools.
- Align protein sequences to the reference genome using
  [Exonerate](https://www.ebi.ac.uk/about/vertebrate-genomics/software/exonerate)
  (curated proteins and SwissProt).
- Generate a non-redundant set of gene predictions by integrating all
  sources of evidence:
  - *De novo* gene model predictions (*AUGUSTUS*, *SNAP*, *GeneMark*,
    *GlimmerHMM*)
  - Homology gene models (*Exonerate* protein alignments)
  - Transcript gene models (*PASA* gene models)
  - Other forms of evidence (*MetaEuk* and *Liftoff* gene evidence)

``` bash
# Predict gene models using a range of tools
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate predict \
    --input "${ASM}" \
    --out "${OUT}" \
    --species "Hydrophis major_nm" \
    --weights genemark:1 \
    --other_gff "metaeuk-evm_valid.gff3:3" "anolis_carolinensis-to-hydrophis_major-evm_valid.gff3:3" "naja_naja-to-hydrophis_major-evm_valid.gff3:3" "notechis_scutatus-to-hydrophis_major-evm_valid.gff3:3" "protobothrops_mucrosquamatus-to-hydrophis_major-evm_valid.gff3:3" "pseudonaja_textilis-to-hydrophis_major-evm_valid.gff3:3" "thamnophis_elegans-to-hydrophis_major-evm_valid.gff3:3" "${EVM}:3" \
    --database '/home/566/al4518/al/database/funannotate_db' \
    --busco_db 'tetrapoda' \
    --organism 'other' \
    --max_intronlen 150000 \
    --genemark_gtf "${DIR}/genemark-es-out/genemark.gtf" \
    --protein_evidence "${PRO}/snake-proteins-clustered_rep_seq.fasta" \
    --tmpdir "${DIR}" \
    --cpus "${PBS_NCPUS}" \
    --force
```

This stage of the annotation pipeline returns a non-redundant set of
gene models which have been formed by considering all sources of
evidence.

### Funannotate Update

**Script:**

- [03-update.sh (H.
  major)](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_major/scripts/03-update.sh)
- [03-update-hydrophis_curtus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_curtus-east/scripts/03-update-hydrophis_curtus.sh)
- [03-update-hydrophis_cyanocinctus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_cyanocinctus/scripts/03-update-hydrophis_cyanocinctus.sh)

**Outdir:** Raw outputs not uploaded due to file size limits

*Funannotate update* is used to update the structure of the predicted
gene set. Specifically, the pipeline runs two rounds of *PASA*,
comparing the predicted gene models to the *PASA* gene models,
correcting 5’- and 3’-UTR regions, along with intron/exon boundaries.
Genes that pass the update stages are then filtered based on their
expression profile using
[Kallisto](https://pachterlab.github.io/kallisto/about).

``` bash
# Update command to improve gene model accuracy
singularity exec ${CONTAINER}/funannotate-v1.8.11.sif funannotate update \
    -i '/g/data/xl04/al4518/hydmaj-genome/funannotate/annotation-funannotate-no-mask' \
    --cpus "${PBS_NCPUS}"
```

### Funannotate Annotate

**Script:**

- [04-emapper.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_major/scripts/04-emapper.sh)
  /
  [05-ips5.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_major/scripts/05-ips5.sh)
  /
  [06-annotate-no-mask.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_major/scripts/06-annotate-no-mask.sh)
- [04-emapper-hydrophis_curtus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_curtus-east/scripts/04-emapper-hydrophis_curtus.sh)
  /
  [05-ips5-hydrophis_curtus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_curtus-east/scripts/05-ips5-hydrophis_curtus.sh)
  /
  [06-annotate-hydrophis_curtus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_curtus-east/scripts/06-annotate-hydrophis_curtus.sh)
- [04-emapper-hydrophis_cyanocinctus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_cyanocinctus/scripts/04-emapper-hydrophis_cyanocinctus.sh)
  /
  [05-ips5-hydrophis_cyanocinctus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_cyanocinctus/scripts/05-ips5-hydrophis_cyanocinctus.sh)
  /
  [06-annotate-hydrophis_cyanocinctus.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_cyanocinctus/scripts/06-annotate-hydrophis_cyanocinctus.sh)

**Outdir:** Raw outputs not uploaded due to file size limits

The last stage of the pipeline is assigning functional annotations to
each gene (where possible). This is handled by *Funannotate annotate*.
Functional annotations were assigned to genes by first screening the
predicted protein sequences against functional databases.

The first functional database we screened against was the
[eggNOG](http://eggnog5.embl.de/#/app/home) database. Proteins were
aligned to the database using the accessory tool
[eggnog-mapper](https://github.com/eggnogdb/eggnog-mapper).

``` bash
# Map the protein sequences to the EggNOG v5 database
emapper.py \
    --cpu "${PBS_NCPUS}" \
    -i "${PROT}" \
    --itype 'proteins' \
    --pident 80 \
    --query_cover 80 \
    --output 'genome-emapper' \
    --output_dir "${OUT}"
```

Next, we screened the proteins against
[InterPro](https://github.com/ebi-pf-team/interproscan), using all the
default databases included in the distribution.

``` bash
# Annotate the updated protein sequences using IPS and its default databases
"${IPS}/interproscan.sh" \
    --cpu "${SLURM_CPUS_PER_TASK}" \
    --output-file-base "${OUT}/genome" \
    --disable-precalc \
    --goterms \
    --input "${PROT}" \
    --iprlookup \
    --pathways
```

After running *EggNOG-mapper* and *InterProScan*, we passed their
outputs to *Funannotate annotate* to aggregate the functional terms and
build the final annotated gene set.

``` bash
# Annotate updated protein coding gene models
singularity exec "${CONTAINER}/funannotate-v1.8.11.sif" funannotate annotate \
    -i "path \
    --cpus "${PBS_NCPUS}" \
    --eggnog "${EGG}" \
    --iprscan "${IPS}" \
    --busco_db 'tetrapoda' \
    --database '/home/566/al4518/al/database/funannotate_db' \
    --tmpdir "${PWD}" \
    --no-progress
```

# 3 Lift-over annotation

**Scripts:**

- [liftoff-to-genomes.sh](https://github.com/a-lud/sea-snake-selection/blob/main/annotation/hydrophis_ornatus/scripts/liftoff-to-genomes.sh)

NOTE: The same script has been copied into each snakes `script`
directory. A single SLURM array job annotated each snake at once.

**Outdir:** Raw outputs not uploaded due to file size limits

As there was not RNA-seq data for *H. ornatus*, *H. curtus (West)* and
*H. elegans* (from the same sample that was assembled), we chose to lift
gene annotations from *H. major* to each of these snakes. The *H. major*
genome had the highest *BUSCO* score of the *de novo* annotated snakes,
and were evolutionarily closer than any RefSeq annotated snakes. We used
the program [Liftoff](https://github.com/agshumate/Liftoff) to do this.

``` bash
liftoff \
    "${QRY_ASM}" \
    "${TGT_ASM}" \
    -g "${TGT_GFF}" \
    -o "${OUT}/${BN}/${BN}.gff3" \
    -u "${OUT}/${BN}/${BN}-unmapped.txt" \
    -exclude_partial \
    -dir "${OUT}/${BN}/intermediates" \
    -p "${SLURM_CPUS_PER_TASK}" \
    -polish
```
