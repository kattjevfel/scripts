#!/bin/sh
# Tool to download entire pages off of https://yiff.party/

if [ $# -eq 0 ]
then
    echo "Usage: $0 *yiff.party ID*"
    exit 1
fi

# Download list, prettify, get URLs, clean up the output and prepare for mass download.
list=$(wget -qO- https://yiff.party/$1.json | python -mjson.tool | grep file_url | awk '{print $2}' | tr -d ',' | tr '\n' ' ' | tr -d '"')

# Make dir to download into and enter (or exit if shit fails)
mkdir -p "$1" && cd "$1" || exit

# Download that shit
wget --no-verbose --show-progress $list