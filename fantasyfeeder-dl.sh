#!/bin/bash
# Download stories from fantasyfeeder.com
baseurl=https://fantasyfeeder.com
tmpfile=$(mktemp)

if [ $# -eq 0 ]; then
    echo "Usage: ${0##*/} [story ID(s)]"
    exit
fi

cleanup() {
    rm "$tmpfile"
}

trap cleanup EXIT

for storyid in "$@"; do
    # Get main page
    wget -qO "$tmpfile" "$baseurl/stories/view?id=$storyid"

    # Get title
    title="$(grep -oP "(?<=<h1 class='title'>).*?(?=</h1>)" "$tmpfile")"

    # If we're not in a dir called the submissions title, create and enter it.
    if [ ! "${PWD##*/}" = "$title" ]; then
        mkdir -vp "$title"
        cd "$title" || { echo "Can't enter $title"; continue; }
    fi

    # Get cover image
    echo 'Downloading cover image...'
    wget -q --show-progress -nc "$(
        grep -m 1 "Upload/Story/Cover" "$tmpfile" |
            # Get string inside single quotes
            grep -oP "/.+.[a-z]+" |
            awk -v var="$baseurl" '{print var $0;}'
    )"

    # Get total pages
    pages="$(grep -m 1 -o "page 1 of [[:digit:]]*" "$tmpfile" | awk 'NF>1{print $NF}')"
    echo "There are $pages pages!"

    # Count from 0 to however many pages there are
    for ((page = 0; page <= ((pages - 1)); page++)); do
        if [ -f "$page.html" ]; then
            echo "Page $page already downloaded, skipping..."
            continue
        fi
        wget -q --show-progress -O "$page.tmp" "$baseurl/stories/view?id=$storyid&rowStart=$page"
        grep subheading -A 1 "$page.tmp" >"$page.html"
        rm "$page.tmp"
    done
done
