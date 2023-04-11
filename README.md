# Sea snake selection

This repository contains the code for investigating positive selection in sea snakes relative to
terrestrial snakes. The repository is organised into sub-directories, each of which outlines the
methods used for that analysis, with examples. The analyses include:

- [Genome assembly][asm]
- [Genome annotation][ann]
- [Genome synteny][syn]
- [Ortholog detection][det]
- [Ortholog annotation][oann]
- [Selection testing][sel]
- [GO over-representation][go]

A few of the analyses listed above make use of Nextflow workflows that can be found [here][nf].
Specific details about the Nextflow workflows can be found at the [wiki][wiki] page.

[asm]: https://github.com/a-lud/sea-snake-selection/tree/main/assembly
[ann]: https://github.com/a-lud/sea-snake-selection/tree/main/annotation
[syn]: https://github.com/a-lud/sea-snake-selection/tree/main/synteny
[det]: https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-detection
[oann]: https://github.com/a-lud/sea-snake-selection/tree/main/orthologs/ortholog-annotation
[sel]: https://github.com/a-lud/sea-snake-selection/tree/main/selection
[go]: https://github.com/a-lud/sea-snake-selection/tree/main/go-enrichment
[nf]: https://github.com/a-lud/nf-pipelines
[wiki]: https://github.com/a-lud/nf-pipelines/wiki
