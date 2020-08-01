#!/bin/bash
# Find pixiv images with tag $2 in directory $1 (using gallery-dl)

find "$1" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_p*.*' -printf '%f\n' |
    while read -r filename; do
        id="${filename%_*}"
        gallery-dl -K https://www.pixiv.net/en/artworks/"$id" | grep -q "$2" && echo "File $filename contains $2!" 2>/dev/null
    done
