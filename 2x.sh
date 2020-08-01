#!/bin/bash
set -e

# Input directory
in=/mnt/jupiter/Temp/2x_waiting
# Output directory
out=/mnt/jupiter/Temp/2x_done
# Log file
log=$(mktemp)

# Check if there's any files to process
if [ -z "$(ls -A $in)" ]; then
    echo 'No files to process, exiting!'
    exit
fi

cleanup() {
    # Exclude failed files, get all text inside double quotes
    grep --invert-match failed "$log" | grep -oP '(?<=").*(?=")' |
        # Add back full path and double quotes and delete source files
        sed -e "s|^|\"$in/|" -e "s|$|\"|" | xargs rm

    rm "$log"
    find "$in"/* -empty -delete 2>/dev/null
}

trap cleanup EXIT

# Force unbuffered for tee to work properly
stdbuf -o 0 \
    waifu2x-converter-cpp \
    --log-level 1 \
    --recursive-directory 1 \
    --generate-subdir 1 \
    --output-format webp \
    --auto-naming 0 \
    --tta 1 \
    --input $in \
    --output $out |
    tee "$log"

# If there are any errors we want to see them
if ! grep -q "0 files errored" "$log"; then
    grep failed "$log"
    echo "Check file://$log for more details."
fi
