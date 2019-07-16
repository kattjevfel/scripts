#!/bin/sh
# Script for installing d9vk into Steam Proton 4.2 on arch(-based distros)
#
# For use with https://aur.archlinux.org/packages/d9vk-winelib-git
#   or non-git https://aur.archlinux.org/packages/d9vk-winelib

protonpath="$HOME/.local/share/Steam/steamapps/common/Proton 4.2"

# Create the required directories
mkdir "$protonpath/dist/lib/wine/d9vk/"
mkdir "$protonpath/dist/lib64/wine/d9vk/"

# Install the 32 bit and 64 bit dlls
ln -s "/usr/share/d9vk/x32/d3d9.dll.so" "$protonpath/dist/lib/wine/d9vk/d3d9.dll"
ln -s "/usr/share/d9vk/x64/d3d9.dll.so" "$protonpath/dist/lib64/wine/d9vk/d3d9.dll"

# Move to the proton directory
cd "$protonpath"

# Download and apply the d9vk patch to proton
curl -sL https://github.com/Joshua-Ashton/d9vk/files/3164526/proton-4.2-d9vk.patch.txt | patch -p1 -t