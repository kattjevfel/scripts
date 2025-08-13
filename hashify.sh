#!/bin/zsh
hasher=crc32

# Fuckup protection
if [ ! "${PWD##*/}" = "${hasher%sum}" ]; then
    read -q REPLY\?"Not in ${hasher%sum} directory, proceed?"
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit
fi

# For all files in current directory with a file extension
for file in "$PWD"/*.*; do
    # Rename file to hash_hashsum.ext
    mv -vn "$file" "${hasher%sum}"_${$($hasher "$file")[1]}."${file##*.}"
done
