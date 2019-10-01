#!/bin/sh
# Download all saved Reddit posts.

user=""

# Unsupported file list
unlist="$(grep -Po '"unsupportedfile": *\K"[^"]*"' "$HOME/.config/gallery-dl/config.json" | tr -d '"')"

# Base directory
basedir="$(grep -Po '"base-directory": *\K"[^"]*"' "$HOME/.config/gallery-dl/config.json" | tr -d '"')"

# Get everything we can through gallery-dl
gallery-dl https://www.reddit.com/user/$user/saved

urls=\
"$(
    grep "v.redd.it" "$unlist" | \
    # https://stackoverflow.com/questions/3074288/
    xargs -n 1 curl -Ls -o /dev/null -w %"{url_effective} "
)"

# Onwards noble steed!
cd "$basedir/reddit" || exit
youtube-dl --ignore-errors "$urls"