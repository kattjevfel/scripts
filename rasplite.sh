#!/bin/sh
# Download latest Raspbian Lite for use with qBittorrent + cron

# Save path
path="/mnt/jupiter/OS"

# Torrent link
url="https://downloads.raspberrypi.org/raspbian_lite_latest.torrent"

# Find latest version
latest=$(curl -sI $url | grep http | sed 's:.*/::' | tr -d '\r')

if [ -f "$path/${latest%.*}" ]; then
  exit 0
else
  qbittorrent-nox --save-path=$path --category=OS $url
fi
