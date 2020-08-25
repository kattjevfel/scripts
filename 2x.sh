#!/bin/bash

# Input directory
in=/mnt/jupiter/Temp/2x_waiting
# Output directory
out=/mnt/jupiter/Temp/2x_done
# Log file
log=$(mktemp)

# Check if there's any files to process
if [ "$(find $in -empty)" ]; then
    echo 'No files to process, exiting!'
    exit
fi

cleanup() {
    # Get all processed files' sources and delete them
    grep ' done' "$log" | awk '{print $1}' | xargs rm

    find "$in"/* -empty -delete 2>/dev/null
}

trap cleanup EXIT

waifu2x-ncnn-vulkan \
    -v \
    -x \
    -f webp \
    -i $in \
    -o $out 2>&1 |
    tee "$log"

# If there are any errors we want to see them
grep failed "$log"
