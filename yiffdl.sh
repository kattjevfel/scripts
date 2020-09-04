#!/bin/bash
# This tool downloads full galleries off of yiff.party into your current dir.

if [ $# -eq 0 ]; then
    echo "Usage: ${0##*/} [yiff.party ID]"
    exit
fi

wget --quiet --show-progress --input-file /dev/fd/3 3<<<"$(
    wget -qO- https://yiff.party/"$1".json |

        # Prettify json
        python -mjson.tool |

        # Get only the file URLs
        grep -Po '"file_url": *"\K[^"]*'
)"
