#!/bin/bash
# Re-download furaffinity pics if you think they're impure

if [ $# -eq 0 ]; then
    echo "Usage: ${0##*/} /path/to/files"
    exit
fi

wget --no-verbose --show-progress --input-file  /dev/fd/3 3<<<"$(
    find "$1" -maxdepth 1 -type f -name "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].*.*" -printf '%f\n' |
        while read -r fullfile; do

            # Filename without extension
            filename="${fullfile%.*}"

            # Artist name only
            artist=$(echo "${filename#*.}" | cut -d_ -f1)

            # File ID only (not the same as post ID, so good fucking luck finding the original post!)
            id="${filename%%.*}"

            # Let's try both jpg and png because we don't know which one it is.
            echo "https://d2.facdn.net/art/$artist/$id/$filename.jpg"
            echo "https://d2.facdn.net/art/$artist/$id/$filename.png"
        done
)"
