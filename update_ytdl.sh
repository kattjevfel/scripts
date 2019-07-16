#!/bin/sh
# Script to update youtube-dl on arch because the maintainer is lazy
# Remember to import the PGP keys from the PKGBUILD if you havent built this before.

# Create temporary working dir
dir=`mktemp -d`
# Find latest version
latestver=`curl -s https://api.github.com/repos/ytdl-org/youtube-dl/releases/latest | grep tag_name | cut -d\" -f4`
# Find sha256sum of latest version
hash=`curl -sL https://github.com/ytdl-org/youtube-dl/releases/download/$latestver/SHA2-256SUMS | grep tar | awk '{print $1;}'`

# Create working dir and download base PKGBUILD
cd $dir
curl -o PKGBUILD "https://git.archlinux.org/svntogit/community.git/plain/trunk/PKGBUILD?h=packages/youtube-dl"

# Update that shit
sed -i "s/pkgver="[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]"/pkgver="$latestver"/g" PKGBUILD
sed -i "/sha256sums/c\sha256sums=('$hash'" PKGBUILD

# Fingers crossed! package and install + remove dir if successful
makepkg -si && rm -rf $dir
