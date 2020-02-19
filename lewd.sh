#!/bin/bash
# lewd.se screenshotter and file uploader


#       >>> Options <<<

# Screenshot related
savedir="$HOME/Pictures/Screenshots"
filename="$(date '+%Y-%m-%d_%H-%M-%S')"
maxsize=1048576 # Max filesize before going with jpg (in bytes)

# etc
clip="xclip -f -selection clip -rmlastnl"
icon="$HOME/Pictures/lewd.svg"

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

help () {
    echo "Usage:
-h  help

-f  full screenshot
-w  window screenshot
-a  area screenshot

-u  upload file(s)
-l  upload list of files (one file per line)"
    exit
}

# Display help if no argument passed
[ $# -eq 0 ] && help

uploader () {
    if [ "$1" = "files" ]; then
        for file in "${@:2}"; do
            echo $file
            curl --request POST \
                --form "file=@$file" \
                --header "shortUrl: $shorturl" \
                --header "token: $token" \
            $host | \
            
            # Get only URL (inside quotes)
            grep -Po '"link": *\K"[^"]*"' | \
            
            # Remove surrounding quotes
            tr -d '"'
        done
    elif [ "$1" = "list" ]; then
        # Allow non-POSIX text files
        while IFS= read -r line || [[ -n "$line" ]]; do
            uploader files "$line"
        done < "$2"
    fi
}

screenshotter () {
    # Create directory if it doesn't exist
    [ ! -d "$savedir" ] && mkdir -p "$savedir"

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
    
    # Upload file and add to
    uploader files "$output" | $clip

    # Send out desktop notifcation
    notify-send --urgency=low --expire-time=2000 --category="transfer.complete" --icon "$icon" "$filename uploaded!"
}

while getopts "hawful" options; do
    case $options in
        f)  screenshotter --fullscreen;;
        w)  screenshotter --activewindow;;
        a)  screenshotter --region;;
        u)  uploader files "${@:2}";;
        l)  uploader list "$2";;
        h)  help;;
        *)  help;;
    esac
done
