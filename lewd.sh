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

# - scrot
# - curl
# - imagemagick
# - xclip
# - xdotool (opt. for getting windows' process name)

#       >>> The fun begins! <<<

# Dependency checking
for deps in scrot curl convert xclip; do
    if [ ! "$(command -v $deps)" ]; then
        echo "$deps missing!"
        exit
    fi
done

# pls send help
help() {
    echo 'Usage:

-a  area screenshot
-w  window screenshot
-f  full screenshot

-u  upload file(s)
-l  upload list of files (one file per line)'
    exit
}

# Display help if no argument passed
[ $# -eq 0 ] && help

uploader() {
    for file in "$@"; do
        output=$(curl --request POST \
            --form "file=@$file" \
            --header "shortUrl: $shorturl" \
            --header "token: $LEWD_TOKEN" \
            https://lewd.se/upload)
        # If upload isn't successful, tell user
        if ! echo "$output" | grep -q 'status":200'; then
            echo "$output"
            exit
        fi
        echo "Deletion URL: $(echo "$output" | grep -Po '"deleteionURL":*"\K[^"]*')"
        echo "Link: $(echo "$output" | grep -Po '"link":*"\K[^"]*')"
    done
}

list() {
    # Allow non-POSIX text files
    while IFS= read -r line || [[ -n "$line" ]]; do
        uploader "$line"
    done <"$2"
}

screenshotter() {
    # The file needs to go *somewhere* before processing
    tempfile=$(mktemp --dry-run --quiet)

    # Take the screenshot and load into clipboard (or exit if none was taken)
    scrot "$@" --quality 100 --silent --pointer "${tempfile}.png" -e 'xclip -selection clipboard -t image/png $f' | exit

    # If taking a window screenshot, prefix it with the process name
    [ "$1" = "--focused" ] && currentwindow="$(</proc/"$(xdotool getactivewindow getwindowpid)"/comm)_"

    # Create directory if it doesn't exist
    [ ! -d "$savedir" ] && mkdir -p "$savedir"

    # WebP 4 lyfe
    mogrify -define webp:lossless=true -format webp "${tempfile}.png" && rm "${tempfile}.png"

    # Check filesize and convert if too big
    filesize=$(stat -c%s "${tempfile}.webp")
    if (("$filesize" > "$maxsize")); then
        screenshot="${savedir}/${currentwindow}${filename}.jpg"
        mogrify -format jpg "${tempfile}" "${screenshot}"
        rm "${tempfile}.webp"
    else
        screenshot="${savedir}/${currentwindow}${filename}.webp"
        mv "${tempfile}.webp" "$screenshot"
    fi

    # Upload file and add to clipboard
    uploader "$screenshot"
    echo "$output" | grep -Po '"link":*"\K[^"]*' | xclip -selection clipboard -rmlastnl

    # Send out desktop notifcation
    notify-send --urgency=low --expire-time=2000 --category=transfer.complete --icon "$icon" "$filename uploaded!"
}

while getopts awful options; do
    case $options in
    a) screenshotter --select --freeze --stack ;;
    w) screenshotter --focused --border --stack ;;
    f) screenshotter ;;
    u) uploader "${@:2}" ;;
    l) list "$2" ;;
    *) help ;;
    esac
done
