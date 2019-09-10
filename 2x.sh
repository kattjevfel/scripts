#!/bin/bash
# Script to deal with batch waifu2x'ing files and clean up after itself like a good boy.


# Setup

# Input directory
in="/mnt/jupiter/Temp/2x_waiting"

# Output directory
out="/mnt/jupiter/Temp/2x_done"

# Converter
waifu="/usr/bin/waifu2x-converter-cpp"

# Arguments (less verbose, recursive, format, subdirs, no autonaming)
args="-v 1 -r 1 -g 1 -f webp -a 0 -i $in -o $out"

# Check if there's any files to process
if [ -z "$(ls -A $in)" ]; then
   echo "No files to process, exiting!"
   exit 1
fi


# Create log file and get going
log=$(mktemp)
script -q -c "$waifu $args" "$log"


# Clean output
sed -i '1d;$d' "$log"

# Check for errors
errors=$(grep -o "0 files errored" "$log" | awk '{print $1}')

# All files processed, with full paths and single quotes
files=$(grep -oP '"\K[^"\047]+(?=["\047])' "$log" | awk -v prefix="$in/" '{print prefix $0}' | sed -e "s/'/'\\\\''/g;s/\(.*\)/'\1'/")

# Delete source files and log if no errors, otherwise scream
if [ -z "$errors" ]; then
    failed=$(grep "too big" "$log" | grep -o '"[^"]\+"')
    echo -e "\e[0;31mFollowing file(s) are too big for WebP: $failed\e[0m"
    echo "Check out file://$log for more details."
else
    echo -e "\e[0;32mNo errors detected, deleting source files!\e[0m"
    echo "$files" | xargs rm
    rm "$log"
    find "$in"/* -empty -delete
fi
