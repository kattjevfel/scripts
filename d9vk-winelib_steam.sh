#!/bin/sh
# Script for updating d9vk on Steam Proton on arch(-based distros)
#
# For use with https://aur.archlinux.org/packages/d9vk-winelib-git
#   or non-git https://aur.archlinux.org/packages/d9vk-winelib

protonpath="$HOME/.local/share/Steam/steamapps/common/Proton 4.11"

# Backup original files
mv "$protonpath/dist/lib64/wine/dxvk/d3d9.dll" "$protonpath/dist/lib/wine/dxvk/d3d9.dll.bak"
mv "$protonpath/dist/lib64/wine/dxvk/d3d9.dll" "$protonpath/dist/lib64/wine/dxvk/d3d9.dll.bak"

# Install the 32 bit and 64 bit dlls
ln -s "/usr/share/d9vk/x32/d3d9.dll.so" "$protonpath/dist/lib/wine/dxvk/d3d9.dll"
ln -s "/usr/share/d9vk/x64/d3d9.dll.so" "$protonpath/dist/lib64/wine/dxvk/d3d9.dll"