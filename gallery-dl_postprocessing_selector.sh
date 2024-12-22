#!/bin/bash
IFS=$'\n'
inputfile="${*:2}"

if [ "$1" = png ]; then
    webpifier.sh "$inputfile" >/dev/null
elif [ "$1" = jpg ] || [ "$1" = jpeg ]; then
    jpegoptim -p --strip-com --strip-iptc --strip-icc --strip-xmp "$inputfile" >/dev/null
elif [ "$1" = zip ] || [ "$1" = rar ] || [ "$1" = 7z ]; then
    7z x "$inputfile" -o"${inputfile%.*}" || exit 1
    rm "$inputfile"
    find "${inputfile%.*}" -iname "*.png" -exec webpifier.sh {} \;
    find "${inputfile%.*}" -iname "*.jpg" -exec jpegoptim -p --workers=max --strip-com --strip-iptc --strip-icc --strip-xmp {} +
else
    exit 0
fi
