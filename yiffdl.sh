#!/bin/bash
# Tool to download entire pages off of https://yiff.party/
# Does not like files with identical filenames, but neither do I.
# "error: 416" is normal and just means it has already downloaded that file.

# Exit if no 
if [ $# -eq 0 ]
then
    echo "Usage: $0 *yiff.party ID*"
    exit 1
fi

# Make temporary list because I can't figure this out
list=$(mktemp)

# Download list, prettify, get URLs, clean up the output and prepare for curl mass download.
curl -s https://yiff.party/$1.json | python -mjson.tool | grep file_url | awk '{print $2}' | tr -d , | awk '{print "url="$0}' > "$list"

# Make dir to download into and enter (or exit if shit fails)
mkdir -p "$1" && cd "$1" || exit

# Download that shit
curl --fail --continue-at - --remote-time --remote-name-all -K "$list"

# Remove previously mentioned list
rm "$list"