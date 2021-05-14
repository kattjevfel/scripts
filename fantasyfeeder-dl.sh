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

pagedownloader() {
    echo -n "Downloading page $1.. "
    wget -qO "$1.tmp" "$baseurl/stories/view?id=$storyid&rowStart=$1"

    # Don't even get me started on how much I hate this, but fuck XML everything it brought.
    grep "<h3>" -A 2 -m 1 "$1.tmp" | sed \
        -e 's/&amp;/\&/g' \
        -e 's/&lt;/\</g' \
        -e 's/&gt;/\>/g' \
        -e 's/&quot;/\"/g' \
        -e "s/&apos;/\'/g" \
        -e "s/<h3>//g" \
        -e 's/<\/h3>//g' \
        -e "s/<div class='center margin-bottom-large'><\/div>//g" \
        -e 's/<br>/\
/g' \
        >"$1.txt"

    echo "done!"
    rm "$1.tmp"
}

for storyid in "$@"; do
(
    # Get main page
    wget -qO "$tmpfile" "$baseurl/stories/view?id=$storyid"

    # Get title
    title="$(grep -oP "(?<=<h\d class='title'>).*?(?=</h\d>)" "$tmpfile")"

    # If we're not in a dir called the submissions title, create and enter it.
    if [ ! "${PWD##*/}" = "$title" ]; then
        mkdir -vp "$title ($storyid)"
        cd "$title ($storyid)" || {
            echo "Can't enter \"$title ($storyid)\", skipping."
            continue
        }
    fi

    # Get cover image
    echo "Downloading cover image... ($title)"
    wget -q -nc "$(
        grep --max-count=1 "Upload/Story/Cover" "$tmpfile" |
            # Get string inside single quotes
            grep -oP "/.+.[a-z]+" |
            awk -v var="$baseurl" '{print var $0;}'
    )"

    # Get total pages
    pages="$(grep -o "rowStart=[[:digit:]]*" "$tmpfile" | tail -1 | sed 's/[^0-9]//g')"

    # Count from 0 to however many pages there are
    for ((page = 0; page <= pages; page++)); do
        # Don't re-download old pages
        if [ -f "$page.txt" ]; then
            echo "Page $page already downloaded, skipping."
            continue
        fi

        pagedownloader "$page"
    done)
done
