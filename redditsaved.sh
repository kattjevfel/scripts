#!/bin/sh
# Download all saved Reddit posts.

user=""


# Temp batch file because youtube-dl is a bitch
# https://github.com/ytdl-org/youtube-dl/blob/05446d483d089d0bc7fa3037900dadc856d3e687/youtube_dl/options.py#L683
out=$(mktemp)

# Unsupported file list
unlist="$(grep -Po '"unsupportedfile": *\K"[^"]*"' "$HOME/.config/gallery-dl/config.json" | tr -d '"')"

# Base directory
basedir="$(grep -Po '"base-directory": *\K"[^"]*"' "$HOME/.config/gallery-dl/config.json" | tr -d '"')"

# Get everything we can through gallery-dl
gallery-dl https://www.reddit.com/user/$user/saved

# https://stackoverflow.com/questions/3074288
grep "v.redd.it" "$unlist" | xargs -n 1 curl -Ls -o /dev/null -w %"{url_effective}\n" > "$out" 2> /dev/null

# Onwards noble steed!
cd "$basedir/reddit" || exit
youtube-dl --ignore-errors --batch-file "$out"

# Cleanup
rm "$out"
xdg-open https://www.reddit.com/user/$user/saved