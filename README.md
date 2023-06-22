# Sea snake selection

This repository contains the code relating to the assembly, annotation and
genomic investigation into the newly sampled *Hydrophis* snakes *H. major*, *H. ornatus*,
*H. curtus (West)* and *H. elegans* (along with already existing *Hydrophis* and terrestrial
samples). The repository is organised into sub-directories, each of which contains the code
used in the analyses, along with a summary of the overall approach.

The approximate order of the analyses are below:

- [Genome assembly][asm]
- [Genome annotation][ann]
- [Phylogenetics][phy]
- [Genome synteny][syn]
- [Ortholog detection][det]
- [Ortholog annotation][oann]
- [Selection testing][sel]
- [GO over-representation][go]

Additional directories include the following;

- [data][data]
- [figures][fig]
- [tables][tab]

The `data` directory contains data that are not specific to any one analysis,
while the `figure` and `tables` directories contain the figures and tables that
are found in the manuscript.

A few of the analyses listed above make use of custom Nextflow workflows that can be found [here][nf].
Specific details about the Nextflow workflows can be found at the [wiki][wiki] page. Some custom tools
are also used for processing some output data which can be found here:

- [AnnotateOrthologs][anno]
- [EteTools][etetool]

I've tried to be as detailed as possible, however this is a large project and it's difficult to
include everything. Many auxilliary files from analyses are included in this directory, however
some files are too large and could not be uploaded. Additionally, some scripts have been edited
down to include their main function calls rather than include additional information that is not relevant.

[asm]: https://github.com/a-lud/sea-snake-selection/tree/main/assembly
[ann]: https://github.com/a-lud/sea-snake-selection/tree/main/annotation
[phy]: https://github.com/a-lud/sea-snake-selection/tree/main/phylogenetics
[syn]: https://github.com/a-lud/sea-snake-selection/tree/main/synteny
[det]: https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-detection
[oann]: https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation
[sel]: https://github.com/a-lud/sea-snake-selection/tree/main/selection
[go]: https://github.com/a-lud/sea-snake-selection/tree/main/go-overrepresentation
[data]: https://github.com/a-lud/sea-snake-selection/tree/main/data
[fig]: https://github.com/a-lud/sea-snake-selection/tree/main/figures
[tab]: https://github.com/a-lud/sea-snake-selection/tree/main/tables
[nf]: https://github.com/a-lud/nf-pipelines
[wiki]: https://github.com/a-lud/nf-pipelines/wiki
[anno]: https://github.com/a-lud/annotateOrthologs
[etetool]: https://github.com/a-lud/eteTools