#!/bin/bash

# lewd.se screenshotter (and duct taped on file uploader)
# For use only with KDE, as I don't care about other DEs.


# Where the screenshots are kept
savedir="$HOME/Pictures/Screenshots"
# Filename format
format="$(date '+%Y-%m-%d_%H-%M-%S')"
# Max filesize before going with jpg (in bytes)
maxsize=1048576
# Clipboard tool
clip="xclip -f -selection clip"

# lewd.se stuff
host="https://lewd.se/upload"
token="YOUR TOKEN GOES HERE (https://lewd.se/user)"
shorturl="false"


# Requirements:
# - Spectacle (KDE screenshot tool)
# - curl
# - imagemagick
# - xclip (for clipboarding)
# - xdotool (for getting current title)

# For ease of use set up hotkeys in KDE, remember to use full paths.


# Create directory if it doesn't exist
if [ ! -d "$savedir" ]; then
  mkdir -p "$savedir";
fi

if [ $# -eq 0 ]; then
    echo "Missing options! (run $0 -h for help)"
fi
 
screenshotter () {
    # The file needs to go *somewhere* before processing
    tempfile=$(mktemp)

    # Take the screenshot
    spectacle "$1" -bno "$tempfile"

    # If we're taking a window screenshot we want to prefix it with the process name
    if [ "$1" = "--activewindow" ]; then
        currentwindow="$(cat /proc/$(xdotool getwindowpid $(xdotool getwindowfocus))/comm)_"
    fi

    # Check filesize and convert if too big
    filesize=$(stat -c%s "$tempfile")
    if (( "$filesize" > "$maxsize" )); then
        output="$savedir/$currentwindow$format.jpg"
        convert -format jpg "$tempfile" "$output"
        rm "$tempfile"
    else
        output="$savedir/$currentwindow$format.png"
        mv "$tempfile" "$output"
    fi
    
    # Upload to lewd.se and do all the stuff
    curl -s -X POST -F "file=@$output" -H "shortUrl: $shorturl" -H "token: $token" $host | grep -Po '"link": *\K"[^"]*"' | tr -d '"' | tr -d '\n' | $clip
    notify-send -u low -t 2000 -c "transfer.complete" "$format uploaded!"
}

while getopts "hfawF" OPTION; do
    case $OPTION in

        f)
            screenshotter --fullscreen
        ;;

        w)
            screenshotter --activewindow
        ;;

        a)
            screenshotter --region
        ;;

        F)
            curl -X POST -F "file=@$2" -H "shortUrl: $shorturl" -H "token: $token" $host | grep -Po '"link": *\K"[^"]*"' | tr -d '"'
        ;;

        h)
            echo "Usage:"
            echo "   -h     take a wild guess dumbass"
            echo ""
            echo "   -f     full screenshot"
            echo "   -w     window screenshot"
            echo "   -a     area screenshot"
            echo ""
            echo "   -F     upload file"
        ;;

        *)
            echo "What the fuck did you just bring upon this cursed land"
        ;;

    esac
done
