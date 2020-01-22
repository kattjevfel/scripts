#!/bin/bash

if [ $# -eq 0 ]
then
    echo "This tool downloads full galleries off of yiff.party into your current dir."
    echo ""
    echo "Usage: $0 *yiff.party ID*"
    exit 1
fi

wget --no-verbose --show-progress --input-file /dev/fd/3 3<<< "$(
wget -qO- https://yiff.party/"$1".json | \

    # Prettify json
    python -mjson.tool | \

    # Get only the file URLs (in quotes)
    grep -Po '"file_url": *\K"[^"]*"' | \

    # Delete quotes
    tr -d '"' \
)"