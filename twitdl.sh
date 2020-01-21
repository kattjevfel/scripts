#!/bin/bash

if [ $# -eq 0 ]
then
    echo "Downloads all images from twitter post"
    echo ""
    echo "Usage: $0 *twitter post*"
    exit 1
fi

curl --fail --remote-time --remote-name-all -K /dev/fd/3 3<<< "$( \
    curl -s "$1" | \
    grep 'property=\"og:image\"' | \
    grep -Po 'content="*\K"[^"]*"' | \
    sed -e 's/.*/url=&/' -e 's/:large"/?name=orig"/'
)"

# Rename messed up twitter filenames
for f in *?name=orig; do
    mv "$f" "${f%?name=orig}"
done
