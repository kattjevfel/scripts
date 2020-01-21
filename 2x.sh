#!/bin/bash
set -e

# Input directory
in="/mnt/jupiter/Temp/2x_waiting"

# Output directory
out="/mnt/jupiter/Temp/2x_done"

# Log file
log=$(mktemp)


# Check if there's any files to process
if [ -z "$(ls -A $in)" ]; then
   echo "No files to process, exiting!"
   exit 0
fi


/usr/bin/waifu2x-converter-cpp \
    --log-level 1 \
    --recursive-directory 1 \
    --generate-subdir 1 \
    --output-format webp \
    --auto-naming 0 \
    --tta 1 \
    --input $in \
    --output $out | \
tee "$log"


# Delete source files and log if no errors, otherwise scream
if ! grep -q "0 files errored" "$log"
then
    echo "Shit's whack yo! Check file://$log for more details."
    exit 1
else
    echo -e "\e[0;32mNo errors detected, deleting source files!\e[0m"
    grep -oP '"\K[^"\047]+(?=["\047])' "$log" | awk -v prefix="$in/" '{print prefix $0}' | xargs rm
    rm "$log"
    find "$in"/* -empty -delete 2> /dev/null
    exit 0
fi
