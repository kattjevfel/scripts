#!/bin/bash
# lewd.se screenshotter and file uploader

#       >>> Options <<<
savedir="$HOME/Pictures/Screenshots"
filename="$(date '+%Y-%m-%d_%H-%M-%S')"
maxsize=1048576 # Max filesize before going with jpg (in bytes)

#LEWD_TOKEN='YOUR TOKEN GOES HERE (https://lewd.se/user)'
icon="$HOME/Pictures/lewd.svg"
shorturl=false

#       >>> Requirements <<<

# - Spectacle
# - curl
# - imagemagick
# - xclip
# - xdotool (opt. for getting windows' process name)

#       >>> The fun begins! <<<

help() {
    echo 'Usage:

-a  area screenshot
-w  window screenshot
-f  full screenshot

-u  upload file(s)
-l  upload list of files (one file per line)'
    exit
}

uploader() {
    for file in "$@"; do
        output=$(curl --request POST \
            --form "file=@$file" \
            --header "shortUrl: $shorturl" \
            --header "token: $LEWD_TOKEN" \
            --progress-bar \
            https://lewd.se/upload)
        # If upload isn't successful, tell user
        if ! echo "$output" | grep -q 'status":200'; then
            echo "$output"
            exit 1
        fi
        echo "Deletion URL: $(echo "$output" | grep -Po '"deleteionURL":*"\K[^"]*')"
        echo "Link: $(echo "$output" | grep -Po '"link":*"\K[^"]*')"
    done
}

screenshotter() {
    # The file needs to go *somewhere* before processing
    tempfile=$(mktemp --dry-run --quiet --suffix=.png)

    # Check spectacle version for changed clipboard command
    spectaclever="$(spectacle -v | awk '{print $2}')"
    if (( $(echo "$spectaclever" "21.07.70" | awk '{print ($1 < $2)}') )); then
        cliparg="--clipboard"
    else
        cliparg="--copy-image"
    fi

    # Take the screenshot and load into clipboard
    spectacle "$@" --background --nonotify $cliparg --output "${tempfile}"

    # Exit if file is empty (no screenshot taken)
    [ ! -f "$tempfile" ] && exit

    # If taking a window screenshot, prefix it with the process name
    [ "$1" = "--activewindow" ] && currentwindow="$(</proc/"$(xdotool getactivewindow getwindowpid)"/comm)_"

    # Create directory if it doesn't exist
    [ ! -d "$savedir" ] && mkdir -p "$savedir"

    # Check filesize and convert if too big
    filesize=$(stat -c%s "${tempfile}")
    if (("$filesize" > "$maxsize")); then
        screenshot="${savedir}/${currentwindow}${filename}.jpg"
        convert -format jpg "${tempfile}" "${screenshot}"
        rm "${tempfile}"
    else
        screenshot="${savedir}/${currentwindow}${filename}.png"
        mv "${tempfile}" "$screenshot"
    fi

    # Upload file and add to clipboard
    uploader "$screenshot"
    echo "$output" | grep -Po '"link":*"\K[^"]*' | xclip -selection clipboard -rmlastnl

    # Send out desktop notifcation
    notify-send --urgency=low --expire-time=2000 --category=transfer.complete --icon "$icon" "$filename uploaded!"
}

while getopts awful options; do
    case $options in
    a) screenshotter --region ;;
    w) screenshotter --activewindow ;;
    f) screenshotter --fullscreen ;;
    u) uploader "${@:2}" ;;
    l) while IFS=$'\n' read -r line; do uploader "$line"; done <"$2" ;;
    *) help ;;
    esac
done

# Display help if no argument passed
[ $# -eq 0 ] && help
