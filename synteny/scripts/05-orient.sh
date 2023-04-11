#!/user/bin/env bash

# This script orients WHOLE chromosomes to better represent synteny. When a whole
# sequence is inverted in MCscan plots, it means it's in the opposite direction to
# what it is being compared to. Therefore, if we reverse transcribe one of the two sequences,
# we end up with a nicer looking plot that makes more sense.

DIR='/hpcfs/users/a1645424/analysis/synteny-hydrophis-snakes'
TD="${DIR}/temp-files"
GENOMES="${DIR}/genomes/genomes-subset/renamed"
OUT="${DIR}/genomes-mcscan"

mkdir -p "${OUT}" "${TD}"

for FA in "${GENOMES}/"*.fa; do
    BN=$(basename "${FA%.*}")
    echo -e "[Current]\t${BN}"

    case "${BN}" in 
        'hydrophis_ornatus')
            CHR='chr1 chr3 chr8 chr10'
            echo -e "chr1\nchr3\nchr8\nchr10" > "${TD}/${BN}.ids"
            ;;
        'hydrophis_curtus-AG')
            CHR='chr4 chr5 chr7 chr12 chrZ'
            echo -e "chr4\nchr5\nchr7\nchr12\nchrZ" > "${TD}/${BN}.ids"
            ;;
        'hydrophis_curtus')
            CHR='chr6 chr15'
            echo -e "chr6\nchr15" > "${TD}/${BN}.ids"
            ;;
        'hydrophis_cyanocinctus')
            CHR='chr3 chr4 chr7 chr8 chr9 chr10 chr11 chr16'
            echo -e "chr3\nchr4\nchr7\nchr8\nchr9\nchr10\nchr11\nchr16" > "${TD}/${BN}.ids"
            ;;
        'hydrophis_major')
            CHR='chr12 chr13'
            echo -e "chr12\nchr13" > "${TD}/${BN}.ids"
            ;;
        *)
            echo -e "[Skip]\tSkipping ${BN}"
            continue
            ;;
    esac

    CONDA_BASE=$(conda info --base)
    source "${CONDA_BASE}/etc/profile.d/conda.sh"
    conda activate hts

    echo -e "[SAMtools]\tReverse complement ${CHR}"
    samtools faidx \
        -o "${TD}/${BN}.revComp" \
        --reverse-complement \
        --mark-strand no \
        "${FA}" \
        ${CHR}
    conda deactivate

    echo -e "[Seqkit]\tGet normal sequences"
    seqkit grep \
        --invert-match \
        -f "${TD}/${BN}.ids" \
        -o "${TD}/${BN}.normal" \
        "${FA}"

    echo -e "[cat]\tMerging sequences to form final file"
    cat "${TD}/${BN}.normal" "${TD}/${BN}.revComp" |
    seqkit sort -N -o "${OUT}/${BN}.fa"

    rm "${TD}/${BN}.ids" "${TD}/${BN}.revComp" "${TD}/${BN}.normal"
done

