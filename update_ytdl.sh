#!/bin/sh
# Script to update youtube-dl on Arch Linux when the maintainer is slacking

# Find latest version
latestver=$(curl -s https://api.github.com/repos/ytdl-org/youtube-dl/releases/latest | grep tag_name | cut -d\" -f4)

# Quit if already latest version
if [ "$latestver" = "$(youtube-dl --version)" ]; then
    echo "youtube-dl is already the latest version, quitting."
    exit
fi

# Work dir
dir=$(mktemp -d)

# Find sha256sum of latest version
hash=$(curl -sL "https://github.com/ytdl-org/youtube-dl/releases/download/$latestver/SHA2-256SUMS" | grep tar | awk '{print $1;}')

# Download base PKGBUILD
cd "$dir" || exit
curl -o PKGBUILD "https://git.archlinux.org/svntogit/community.git/plain/trunk/PKGBUILD?h=packages/youtube-dl"

# Update pkgver, hash and reset pkgrel
sed -i "s/pkgver="[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]"/pkgver=$latestver/g" PKGBUILD
sed -i "/sha256sums/c\sha256sums=('$hash'" PKGBUILD
sed -i "/pkgrel/c\pkgrel=1" PKGBUILD

# Package, install and clean up
makepkg -i
rm -rf "$dir"
