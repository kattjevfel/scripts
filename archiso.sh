#!/bin/bash
# Download latest archiso for use with bittorrent watch folder + cron

# What day is it today
today=$(date +%Y.%m.%d)

# Where is the file expected to be
file="/mnt/jupiter/OS/archlinux-$today-x86_64.iso"

# Where does your torrent client look for torrents
watch="/mnt/jupiter/etc/qbt/watch/os"

# Check if file exists
if [ -f "$file" ]; then
  exit 0
else
  # And download if it doesn't, if it's released yet.
  curl -sfo "$watch/arch.torrent" "https://www.archlinux.org/releng/releases/$today/torrent/"
fi
