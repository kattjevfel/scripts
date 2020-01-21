#!/bin/bash
# Download all saved Reddit posts.

user=""


# Unsupported file list
unlist="$(grep -Po '"unsupportedfile": *\K"[^"]*"' "$HOME/.config/gallery-dl/config.json" | tr -d '"')"

# Base directory
basedir="$(grep -Po '"base-directory": *\K"[^"]*"' "$HOME/.config/gallery-dl/config.json" | tr -d '"')"

# Get everything we can through gallery-dl
gallery-dl https://www.reddit.com/user/$user/saved

# Get the rest with youtube-dl
cd "$basedir/reddit" || exit

youtube-dl --ignore-errors --batch-file /dev/fd/3 3<<< "$( \
    grep "v.redd.it" "$unlist" | \

    # https://stackoverflow.com/questions/3074288
    xargs -n 1 curl -Ls -o /dev/null -w %"{url_effective}\n" 2> /dev/null
)"

xdg-open https://www.reddit.com/user/$user/saved
