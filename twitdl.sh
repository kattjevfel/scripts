#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Downloads all images from a twitter post

Usage: $0 [twitter post URL]"
    exit
fi

wget --quiet --show-progress --input-file /dev/fd/3 3<<<"$(
    wget -qO- "$1" |
        grep 'property=\"og:image\"' |
        grep -Po 'content="*\K"[^"]*"' |
        sed -e 's/"//' -e 's/:large"/?name=orig/'
)"

# Rename messed up twitter filenames
for f in *?name=orig; do
    mv "$f" "${f%?name=orig}"
done
