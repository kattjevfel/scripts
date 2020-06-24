#!/bin/bash
# Downloads all images from a twitter post

if [ $# -eq 0 ]; then
    echo "Usage: $0 [twitter post ID]"
    exit
fi

wget --quiet --show-progress --input-file /dev/fd/3 3<<<"$(
    wget -qO- "https://mobile.twitter.com/i/web/status/$1" |
        grep ':small' |
        grep -Po '"*"[^"]*"' |
        sed -e 's/"//' -e 's/:small"/?name=orig/'
)"

# Rename messed up twitter filenames
for f in *?name=orig; do
    mv "$f" "${f%?name=orig}"
done
