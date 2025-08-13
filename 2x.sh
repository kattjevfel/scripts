#!/bin/bash

# Needs to be exactly 2 arguments, and they must be directories
if [[ $# -ne 2 ]] || [[ ! -d "$1" ]] || [[ ! -d "$2" ]]; then
    echo "Usage: ${0##*/} input_dir output_dir"
    exit
fi

# You can set these permanently and remove the above section
input_dir=${1%/}
output_dir=${2%/}

# Check if there's any files to process
filesfound=$(find "${input_dir}" -type f)
if [[ -z "${filesfound}" ]]; then
    echo 'No files to process, exiting!'
    exit
fi

while IFS= read -r fullfilepath; do
    # Path but without $input_dir
    shortfilepath="${fullfilepath#*"${input_dir}"}"

    # Create directory (remove everything after /)
    mkdir -p "${output_dir}/${shortfilepath%/*}"

    # Print current file being upscaled, without leading /
    echo -n "Upscaling ${shortfilepath#*/} "

    # Verbose, TTA, webp format
    fulloutput=$(
        waifu2x-ncnn-vulkan -v -x -f webp \
            -i "${input_dir}${shortfilepath}" \
            -o "${output_dir}${shortfilepath%.*}".webp 2>&1
    )

    if echo "${fulloutput}" | grep -q "done"; then
        echo "done!"
        rm "${input_dir}${shortfilepath}"
    else
        echo -n 'failed: '
        # Print error in red and move on
        ERROR=$(echo "${fulloutput}" | grep -v -e '^\[' -e 'Experimental compiler')
        echo -e "\033[0;31m${ERROR}\033[0m"
        continue
    fi
done <<<"${filesfound}"

# Remove any empty directories left behind
find "${input_dir}" -mindepth 1 -type d -empty -delete
