#!/bin/bash
# shellcheck disable=SC2312
# Checks for pixiv users (downloaded via gallery-dl) that the user is not following,
# it then moves those folders to a separate specified folder.

# Folder where pixiv artists folders reside.
inputdir=$1
# Folder where the unfollowed folders will be moved (will be relative to $inputdir).
outputfolder=$2

# Exit if folder doesn't exist.
cd "${inputdir}" || exit

# Create an array of all the folders, removing anything after the space,
# assuming default gallery-dl folder names should leave only user IDs.
mapfile -t pixivusersuniq < <(
    for pixivusers in */; do
        echo "${pixivusers%% *}" | sort -u
    done
)

# Check the is_followed keyword with gallery-dl for each ID, then move it to $outputfolder if it returns False.
for pixivsingleuser in "${pixivusersuniq[@]}"; do
    if gallery-dl --list-keywords "${pixivsingleuser[@]/#/https://www.pixiv.net/en/users/}" | grep is_followed -A1 | grep False -q; then
        mv -v -t "${outputfolder}" "${pixivsingleuser}"*
    fi
done
