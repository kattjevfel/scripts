#!/bin/bash
# lewd.se screenshotter and file uploader

#       >>> Options <<<
savedir="$HOME/Pictures/Screenshots"
filename="$(date '+%Y-%m-%d_%H-%M-%S')"
maxsize=1048576 # Max filesize before going with lossy avif (in bytes)

#LEWD_TOKEN='YOUR TOKEN GOES HERE (https://lewd.se/user)'
icon="$HOME/Pictures/lewd.svg"
shorturl=false

# Available options are: spectacle,scrot,gnome-screenshot
screenshot_tool="spectacle"

#       >>> Requirements <<<

# - Spectacle/scrot
# - curl
# - imagemagick
# - xclip / wl-clipboard
# - xdotool (opt. for getting windows' process name) (xorg only)

#       >>> The fun begins! <<<

help() {
    echo 'Usage:

-a  area screenshot
-w  window screenshot
-f  full screenshot

-u  upload file(s)
-l  upload list of files (one file per line)
-s  toggle short URL (must be first command)
-r  re-upload URL to lewd.se'
    exit
}

shorturlflipper() {
    if [ $shorturl = "false" ]; then
        shorturl=true
    elif [ $shorturl = "true" ]; then
        shorturl=false
    fi
}

reupload() {
    # Gotta store that shit somewhere
    tempfile=$(mktemp --dry-run --quiet)

    # Download file
    curl --silent --location --fail --output "$tempfile" "$1"

    # Check filetype and grab only first example `file` spits out
    fileext=$(file --extension --brief "$tempfile")
    fileext=${fileext%%/*}

    # Skip adding extension if `file` can't figure it out
    if [ "$fileext" = "???" ]; then
        unset fileext
        tempfilewithext=$tempfile
    else
        # Move file to have (hopefully) proper extension
        tempfilewithext=$(mktemp --dry-run --quiet --suffix=."$fileext")
        mv "$tempfile" "$tempfilewithext"
    fi

    # Force short url as we're not saving OG filename, upload file
    shorturl=true uploader "$tempfilewithext"

    # Remove temporary file
    rm "$tempfilewithext"
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
        echo "Deletion URL: $(echo "$output" | grep -Po '"deletionUrl":*"\K[^"]*')"
        echo "Link: $(echo "$output" | grep -Po '"link":*"\K[^"]*')"
    done
}

screenshotter() (
    # The file needs to go *somewhere* before processing
    tempfile=$(mktemp --dry-run --quiet --suffix=.png)

    # Pick screenshoot tool
    if [ "$screenshot_tool" = "spectacle" ]; then
        # Check spectacle version for changed clipboard command
        spectaclever="$(spectacle -v | awk '{print $2}')"
        if (( $(echo "$spectaclever" "21.07.70" | awk '{print ($1 < $2)}') )); then
            cliparg="--clipboard"
        else
            cliparg="--copy-image"
        fi

        screenshot_base_command() {
            spectacle "$@" --background --nonotify $cliparg --output "${tempfile}"
        }
        
        if [ "$1" = fullscreen ]; then
            screenshot_base_command --fullscreen
        elif [ "$1" = activewindow ]; then
            screenshot_base_command --activewindow
        elif [ "$1" = region ]; then
            screenshot_base_command --region
        fi
    elif [ "$screenshot_tool" = "scrot" ]; then
        screenshot_base_command() {
            scrot "$@" --quality 100 --silent --pointer "${tempfile}" -e 'xclip -selection clipboard -t image/png $f'
        }

        if [ "$1" = fullscreen ]; then
            screenshot_base_command
        elif [ "$1" = activewindow ]; then
            screenshot_base_command --focused --border --stack
        elif [ "$1" = region ]; then
            screenshot_base_command --select --freeze --stack
        fi
    elif [ "$screenshot_tool" = "gnome-screenshot" ]; then
        screenshot_base_command() {
            gnome-screenshot "$@" --clipboard --include-pointer --file="${tempfile}"
        }

        if [ "$1" = fullscreen ]; then
            screenshot_base_command
        elif [ "$1" = activewindow ]; then
            screenshot_base_command --window
        elif [ "$1" = region ]; then
            screenshot_base_command --area
        fi
    else
        echo "Invalid screenshot tool selected!"
        exit 1
    fi

    # Exit if file is empty (no screenshot taken)
    [ ! -f "$tempfile" ] && exit

    # If taking a window screenshot, prefix it with the process name (only works on xorg)
    if [ "$1" = "--activewindow" ]; then
        if ! [ "$XDG_SESSION_TYPE" = "wayland" ]; then
            currentwindow="$(</proc/"$(xdotool getactivewindow getwindowpid)"/comm)_"
        fi
    fi

    # Create directory if it doesn't exist
    [ ! -d "$savedir" ] && mkdir -p "$savedir"

    # Check filesize and convert if too big
    filesize=$(stat -c%s "${tempfile}")
    if (("$filesize" > "$maxsize")); then
        screenshot="${savedir}/${currentwindow}${filename}.avif"
        convert "${tempfile}" "${screenshot}"
        rm "${tempfile}"
    else
        screenshot="${savedir}/${currentwindow}${filename}.png"
        mv "${tempfile}" "$screenshot"
    fi

    # Upload file
    uploader "$screenshot"

    # Add to clipboard
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        clipboard_command="wl-copy --trim-newline"
    else
        clipboard_command="xclip -selection clipboard -rmlastnl"
    fi
    # Thanks Oba- KDE! https://bugs.kde.org/show_bug.cgi?id=469238
    echo "$output" | grep -Po '"link":*"\K[^"]*' | $clipboard_command > /dev/null

    # Send out desktop notifcation
    notify-send --urgency=low --expire-time=2000 --category=transfer.complete --icon "$icon" "$filename uploaded!"
)

while getopts awfulsr options; do
    case $options in
    a) screenshotter region ;;
    w) screenshotter activewindow ;;
    f) screenshotter fullscreen ;;
    u) uploader "${@:2}" ;;
    l) while IFS=$'\n' read -r line; do uploader "$line"; done <"$2" ;;
    s) shorturlflipper ;;
    r) reupload "${@:2}" ;;
    *) help ;;
    esac
done

# Display help if no argument passed
[ $# -eq 0 ] && help
