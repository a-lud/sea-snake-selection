 #!/usr/bin/env bash

 ## Location of where the pipeline is installed
 PIPE='/hpcfs/users/a1645424/software/nf-pipelines'
 DIR='/hpcfs/users/a1645424/analysis/selection'
 SEQS='/hpcfs/users/a1645424/analysis/orthologs/results/orthologs/clipkit'

 nextflow run "${PIPE}/main.nf" \
     --pipeline 'hyphy_analyses' \
     --outdir "${DIR}/results" \
     --out_prefix 'bustedph-terrestrial' \
     -profile 'conda,phoenix' \
     --partition 'skylake' \
     --msa "${SEQS}" \
     --tree "${DIR}/tree/snakes-13-terrestrial.nwk" \
     --testLabel 'Terrestrial' \
     --batchFile "BUSTED-PH.bf" \
     --hyphyDev '/hpcfs/users/a1645424/software/hyphy-develop' \
     --hyphyAnalysis '/hpcfs/users/a1645424/software/hyphy-analyses' \
     -resume
