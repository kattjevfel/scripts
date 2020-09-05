#!/bin/bash
hasher=md5sum

# Fuckup protection
if [ ! "${PWD##*/}" = "${hasher%sum}" ]; then
    read -r "Not in ${hasher%sum} directory, proceed?"
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit
fi

# For all files in current directory with a file extension
for file in "$PWD"/*.*; do
    hashsum=$($hasher "$file")
    # Rename file to hash_hashsum.ext
    mv -vn "$file" "${hasher%sum}"_"${hashsum[0]}"."${file##*.}"
done
