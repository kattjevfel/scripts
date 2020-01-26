#!/bin/bash

# lewd.se screenshotter (and duct taped on file uploader)
# For use only with KDE, as I don't care about other DEs.

#       >>> Options <<<

# Files
savedir="$HOME/Pictures/Screenshots"
filename="$(date '+%Y-%m-%d_%H-%M-%S')"
maxsize=1048576 # Max filesize before going with jpg (in bytes)

# Clipboard tool
clip="xclip -f -selection clip -rmlastnl"

# lewd.se settings
host="https://lewd.se/upload"
token="YOUR TOKEN GOES HERE (https://lewd.se/user)"
shorturl="false"


#       >>> Requirements <<<
# - Spectacle
# - curl
# - imagemagick
# - xclip
# - xdotool (opt. for getting windows' process name)


#       >>> The fun begins! <<<
# Create directory if it doesn't exist
[ ! -d "$savedir" ] && mkdir -p "$savedir"


[ $# -eq 0 ] && echo "Missing options! (run $0 -h for help)"


screenshotter () {
    # The file needs to go *somewhere* before processing
    tempfile=$(mktemp)

    # Take the screenshot
    spectacle "$1" -bno "$tempfile"

    # Exit if file is empty (no screenshot taken)
    [ ! -s "$tempfile" ] && exit 1

    # If we're taking a window screenshot we want to prefix it with the process name
    [ "$1" = "--activewindow" ] && currentwindow="$(</proc/"$(xdotool getactivewindow getwindowpid)"/comm)_"

    # Check filesize and convert if too big
    filesize=$(stat -c%s "$tempfile")
    if (( "$filesize" > "$maxsize" )); then
        output="$savedir/$currentwindow$filename.jpg"
        convert -format jpg "$tempfile" "$output"
        rm "$tempfile"
    else
        output="$savedir/$currentwindow$filename.png"
        mv "$tempfile" "$output"
    fi
    
    # Upload file
    curl --silent \
        --request POST \
        --form "file=@$output" \
        --header "shortUrl: $shorturl" \
        --header "token: $token" \
    $host | \

    # Get only URL (inside quotes)
    grep -Po '"link": *\K"[^"]*"' | \

    # Remove surrounding quotes and add to clipboard
    tr -d '"' | $clip

    # Send out desktop notifcation
    notify-send --urgency=low --expire-time=2000 --category="transfer.complete" --icon "/home/katt/Pictures/lewd.svg" "$filename uploaded!"
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
