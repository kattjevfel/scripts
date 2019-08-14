#!/bin/bash
# Download latest archiso for use with qBittorrent + cron

# Save path
path="/mnt/jupiter/OS"

# What day is it today
today=$(date +%Y.%m.%d)

if [ -f "$path/archlinux-$today-x86_64.iso" ]; then
  exit 0
else
  qbittorrent-nox --save-path=$path --category=OS "$(curl -s https://www.archlinux.org/releng/releases/$today/ | grep "magnet:" | grep -o '"[^"]\+"')"
fi
