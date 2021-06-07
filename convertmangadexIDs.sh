#!/bin/bash
# This script assumes you have exported your SQLite database containing the gallery-dl archive.

echo 'Insert archive file location:'
read -r archivefile

grep -o "mangadex[[:digit:]]*_" "$archivefile" | grep -oP '\d+' | sort -u | while IFS= read -r legacyId; do
    echo -n "Looking up $legacyId... "
    newId=$(
        curl \
            --silent \
            --request POST \
            --header "Content-Type: application/json" \
            --data "{\"type\":\"chapter\",\"ids\":[$legacyId]}" \
            https://api.mangadex.org/legacy/mapping |
            grep -Po '"newId":*"\K[^"]*'
    )
    echo -n "done, replacing ID... "
    sed -i "s/$legacyId/$newId/g" "$archivefile"
    echo "done!"
done
