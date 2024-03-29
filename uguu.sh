#!/bin/bash
# uguu.se screenshotter and file uploader

#       >>> Options <<<
savedir="$HOME/Pictures/Screenshots"
filename="$(date '+%Y-%m-%d_%H-%M-%S')"
maxsize=1048576 # Max filesize before going with jpg (in bytes)

icon="$HOME/Pictures/uguu.png"

# Available options are: spectacle,scrot
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
-r  re-upload URL to uguu.se'
    exit
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

    # Upload file
    uploader "$tempfilewithext"

    # Remove temporary file
    rm "$tempfilewithext"
}

uploader() {
    for file in "$@"; do
        output=$(curl --form "files[]=@$file" --progress-bar https://uguu.se/upload.php)
        # If upload isn't successful, tell user
        if ! echo "$output" | grep -q 'success": true'; then
            echo "$output"
            exit 1
        fi
        echo "Link: $(echo "$output" | grep -Po '"url": "\K[^"]*' | sed 's/\\//g')"
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
            spectacle "$@" --background --nonotify $cliparg --output ${tempfile}
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
    else
        echo "Invalid screenshot tool selected!"
        exit 1
    fi

    # Exit if file is empty (no screenshot taken)
    [ ! -f "$tempfile" ] && exit

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

    # Upload file
    uploader "$screenshot"

    # Add to clipboard
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        clipboard_command="wl-copy --trim-newline"
    else
        clipboard_command="xclip -selection clipboard -rmlastnl"
    fi
    echo "$output" | grep -Po '"url": "\K[^"]*' | sed 's/\\//g' | $clipboard_command

    # Send out desktop notifcation
    notify-send --urgency=low --expire-time=2000 --category=transfer.complete --icon "$icon" "$filename uploaded!"
)

while getopts awfulr options; do
    case $options in
    a) screenshotter region ;;
    w) screenshotter activewindow ;;
    f) screenshotter fullscreen ;;
    u) uploader "${@:2}" ;;
    l) while IFS=$'\n' read -r line; do uploader "$line"; done <"$2" ;;
    r) reupload "${@:2}" ;;
    *) help ;;
    esac
done

# Display help if no argument passed
[ $# -eq 0 ] && help
