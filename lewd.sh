#!/bin/bash
# lewd.se screenshotter and file uploader

#       >>> Options <<<

# Screenshot related
savedir="$HOME/Pictures/Screenshots"
filename="$(date '+%Y-%m-%d_%H-%M-%S')"
maxsize=1048576 # Max filesize before going with jpg (in bytes)

# etc
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

help() {
    echo "Usage:

-a  area screenshot
-w  window screenshot
-f  full screenshot

-u  upload file(s)
-l  upload list of files (one file per line)"
    exit
}

# Display help if no argument passed
[ $# -eq 0 ] && help

uploader() {
    for file in "$@"; do
        output=$(curl --request POST \
            --form "file=@$file" \
            --header "shortUrl: $shorturl" \
            --header "token: $token" \
            $host)
        # If upload isn't successful, tell user
        if ! echo "$output" | grep -q 'status":200'; then
            echo "$output"
            exit
        fi
        echo "Link: $(echo "$output" | grep -Po '"link":*"\K[^"]*')"
        echo "Deletion URL: $(echo "$output" | grep -Po '"deleteionURL":*"\K[^"]*')"
    done
}

list() {
    # Allow non-POSIX text files
    while IFS= read -r line || [[ -n "$line" ]]; do
        uploader "$line"
    done <"$2"
}

screenshotter() {
    # Create directory if it doesn't exist
    [ ! -d "$savedir" ] && mkdir -p "$savedir"

    # The file needs to go *somewhere* before processing
    tempfile=$(mktemp)

    # If taking a window screenshot, prefix it with the process name
    [ "$1" = "--activewindow" ] && currentwindow="$(</proc/"$(xdotool getactivewindow getwindowpid)"/comm)_"

    # Take the screenshot
    spectacle "$1" -bno "$tempfile"

    # Exit if file is empty (no screenshot taken)
    [ ! -s "$tempfile" ] && exit

    # Check filesize and convert if too big
    filesize=$(stat -c%s "$tempfile")
    if (("$filesize" > "$maxsize")); then
        screenshot="$savedir/$currentwindow$filename.jpg"
        convert -format jpg "$tempfile" "$screenshot"
        rm "$tempfile"
    else
        screenshot="$savedir/$currentwindow$filename.png"
        mv "$tempfile" "$screenshot"
    fi

    # Load picture into clipboard (only works with png, fuck you xclip!)
    xclip -selection clipboard -t image/png "$screenshot"

    # Upload file and add to clipboard
    uploader "$screenshot"
    echo "$output" | grep -Po '"link":*"\K[^"]*' | xclip -selection clipboard -rmlastnl

    # Send out desktop notifcation
    notify-send --urgency=low --expire-time=2000 --category="transfer.complete" --icon "$icon" "$filename uploaded!"
}

while getopts "awful" options; do
    case $options in
    a) screenshotter --region ;;
    w) screenshotter --activewindow ;;
    f) screenshotter --fullscreen ;;
    u) uploader "${@:2}" ;;
    l) list "$2" ;;
    *) help ;;
    esac
done
