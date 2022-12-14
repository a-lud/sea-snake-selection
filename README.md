# Sea snake selection

This repository contains the code for investigating positive selection in sea snakes relative to
terrestrial snakes. The repository is organised into sub-directories, each of which outlines the
methods used for that analysis, with examples. The analyses include:

- [Genome assembly][asm]
- [Genome annotation][ann]
- [Ortholog detection][det]
- [Ortholog Annotation][oann]
- Selection
- GO enrichment testing
- Gene family expansion/contraction

A few of the analyses listed above make use of Nextflow workflows that can be found [here][nf].
Specific details about the Nextflow workflows can be found at the [wiki][wiki] page.

[asm]: https://github.com/a-lud/sea-snake-selection/tree/main/assembly
[ann]: https://github.com/a-lud/sea-snake-selection/tree/main/annotation
[det]: https://github.com/a-lud/sea-snake-selection/tree/main/ortholgs/ortholog-detection
[oann]: https://github.com/a-lud/sea-snake-selection/tree/main/ortholgs/ortholog-annotation
[nf]: https://github.com/a-lud/nf-pipelines
[wiki]: https://github.com/a-lud/nf-pipelines/wiki
