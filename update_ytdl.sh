#!/bin/sh
# Script to update youtube-dl on Arch Linux

# Find latest version
latestver=$(curl -s https://api.github.com/repos/ytdl-org/youtube-dl/releases/latest | grep -Po '"tag_name": *"\K[^"]*')

# Quit if already latest version
if [ "$latestver" = "$(youtube-dl --version)" ]; then
    echo 'youtube-dl is already the latest version, quitting.'
    exit
fi

# Find sha256sum of latest version
hash=$(curl -sL "https://github.com/ytdl-org/youtube-dl/releases/download/$latestver/SHA2-256SUMS" | grep tar | awk '{print $1;}')

# Work dir
dir=$(mktemp -d)

# Download base PKGBUILD + Update pkgver, hash and reset pkgrel
cd "$dir" || exit
curl -s https://raw.githubusercontent.com/archlinux/svntogit-community/packages/youtube-dl/trunk/PKGBUILD |
    sed -e "s/^pkgver.*/pkgver=$latestver/g" \
        -e "s/^sha256sums.*/sha256sums=('$hash'/g" \
        -e "s/^pkgrel.*/pkgrel=1/g" >PKGBUILD

# Package, install and clean up
makepkg -i
rm -rf "$dir"
