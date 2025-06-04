#!/bin/bash
IFS=$'\n'
inputfile="${*:3}"

if [ "$1" = png ]; then
    webpifier.sh "$inputfile" >/dev/null
elif [ "$1" = jpg ] || [ "$1" = jpeg ]; then
    if [ "$2" = kemono ]; then
        identify -format "%G %i\n" "$inputfile" 2>/dev/null | grep -Po '1200x630 \K.*' | while IFS= read -r file; do rm -f -- "$file"; done
    else
        jpegoptim -p --strip-com --strip-iptc --strip-icc --strip-xmp "$inputfile" >/dev/null
    fi
elif [ "$1" = zip ] || [ "$1" = rar ] || [ "$1" = 7z ]; then
    LC_CTYPE=ja_JP.UTF-8 7z x "$inputfile" -o"${inputfile%.*}" || exit 1
    rm "$inputfile"
    find "${inputfile%.*}" -iname "*.png" -exec webpifier.sh {} \;
    find "${inputfile%.*}" -iname "*.jpg" -exec jpegoptim -p --strip-com --strip-iptc --strip-icc --strip-xmp {} +
    find "${inputfile%.*}" -type d \( -name ".DS_Store" -o -name "__MACOSX" \) -exec rm -rf {} \;
    find "${inputfile%.*}" -type f \( -name "Thumbs.db" -o -name ".DS_Store" -o -iname \*.clip -o -iname \*.psd -o -iname \*.psb -o -iname \*.twd -o -iname \*.sai -o -iname \*.blend -o -iname \*.sut \) -delete
    find "${inputfile%.*}" -type d -empty -delete
else
    exit 0
fi
