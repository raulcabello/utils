#!/bin/bash
set -euo pipefail

list="kubewarden-images.txt"
images="kubewarden-images.tar.gz"

usage () {
    echo "USAGE: $0 [--image-list kubewarden-images.txt] [--images kubewarden-images.tar.gz]"
    echo "  [-l|--image-list path] text file with list of images; one image per line."
    echo "  [-i|--images path] tar.gz generated by docker save."
    echo "  [-h|--help] Usage message"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    shift
    case $key in
        -i|--images)
        images="$1"
        shift # past value
        ;;
        -l|--image-list)
        list="$1"
        shift # past value
        ;;
        -h|--help)
        help="true"
        ;;
        *)
        usage
        exit 1
        ;;
    esac
done

if [[ -v help ]]; then
    usage
    exit 0
fi

pulled=()
while IFS= read -r i; do
    [ -z "${i}" ] && continue
    if docker pull "${i}" > /dev/null 2>&1; then
        echo "Image pull success: ${i}"
        pulled+=("${i}")
    else
        if docker inspect "${i}" > /dev/null 2>&1; then
            pulled+=("${i}")
        else
            echo "Image pull failed: ${i}"
        fi
    fi
done < "${list}"

echo "Creating ${images} with ${#pulled[@]} images"
docker save "${pulled[@]}" --output "${images}"