#!/bin/bash
IFS=$'\n'

if [ "$1" = png ]; then
    webpifier.sh "${*:2}" >/dev/null
elif [ "$1" = jpg ] || [ "$1" = jpeg ]; then
    jpegoptim -p --strip-com --strip-iptc --strip-icc --strip-xmp "${*:2}" >/dev/null
else
    exit 0
fi
