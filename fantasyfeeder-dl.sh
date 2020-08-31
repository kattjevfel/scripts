#!/bin/bash
# Download stories from fantasyfeeder.com
baseurl=https://fantasyfeeder.com
tmpfile=$(mktemp)

if [ $# -eq 0 ]; then
    echo "Usage: $(basename "$0") [story ID(s)]"
    exit
fi

cleanup() {
    rm "$tmpfile"
}

trap cleanup EXIT

for storyid in "$@"; do
    # Get main page
    wget --quiet --output-document="$tmpfile" "$baseurl/stories/view?id=$storyid"

    # Get title
    title="$(grep -oP "(?<=<h1 class='title'>).*?(?=</h1>)" "$tmpfile")"

    # If we're not in a dir called the submissions title, create and enter it.
    if [ "${PWD##*/}" != "$title" ]; then
        echo "Creating and entering directory \"$title\""
        mkdir -p "$title"
        cd "$title" || exit 1
    fi

    # Get cover image
    echo 'Downloading cover image...'
    wget --quiet --show-progress --no-clobber "$(
        grep -m 1 "Upload/Story/Cover" "$tmpfile" |
            # Get string inside single quotes
            grep -oP "/.+.[a-z]+" |
            awk -v var="$baseurl" '{print var $0;}'
    )"

    # Get total pages
    pages="$(grep -m 1 -o "page 1 of [[:digit:]]*" "$tmpfile" | awk 'NF>1{print $NF}')"
    echo "There are $pages pages!"

    # Count from 0 to however many pages there are
    for ((i = 0; i <= ((pages - 1)); i++)); do
        if [ -f "$i.html" ]; then
            echo "Page $i already downloaded, skipping..."
            continue
        fi
        wget --quiet --show-progress --output-document="$i.tmp" "$baseurl/stories/view?id=$storyid&rowStart=$i"
        grep subheading -A 1 "$i.tmp" >"$i.html"
        rm "$i.tmp"
    done

    # Leave directory we created earlier
    cd ..
done
