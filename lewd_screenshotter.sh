#!/bin/sh

# lewd.se screenshotter (and duct taped on file uploader)
# For use only with KDE, as I don't care about other DEs.


# Where the screenshots are kept
savedir="$(xdg-user-dir PICTURES)/Screenshots"
# Filename format
format=$(date '+%Y-%m-%d_%H-%M-%S')
# Clipboard tool
clip="xclip -f -selection clip"
# Get active window name, comment out to disable
currentwindow="$(cat /proc/$(xdotool getwindowpid $(xdotool getwindowfocus))/comm)_"

# lewd.se stuff
host="https://lewd.se/upload"
token="YOUR TOKEN GOES HERE (https://lewd.se/user)"
shorturl="false"


# Requirements:
# - Spectacle (KDE screenshot tool)
# - curl
# - xclip (for clipboarding)
# - xdotool (for getting current title, )

# For ease of use set up hotkeys in KDE, remember to use full paths.


# Create directory if it doesn't exist
if [ ! -d "$savedir" ]; then
  mkdir -p "$savedir";
fi
 
if [ $# -eq 0 ]
then
    echo "Missing options! (run $0 -h for help)"
fi

while getopts "hfawF" OPTION; do
    case $OPTION in

        f)
            spectacle -f -bno "$savedir/$format.png"
            curl -s -X POST -F "file=@$savedir/$format.png" -H "shortUrl: $shorturl" -H "token: $token" $host | grep -Po '"link": *\K"[^"]*"' | tr -d '"' | tr -d '\n' | $clip
            notify-send -u low -t 2000 -c "transfer.complete" "$format.png uploaded!"
        ;;


        w)
            spectacle -a -bno "$savedir/$currentwindow$format.png"
            curl -s -X POST -F "file=@$savedir/$currentwindow$format.png" -H "shortUrl: $shorturl" -H "token: $token" $host | grep -Po '"link": *\K"[^"]*"' | tr -d '"' | tr -d '\n' | $clip
            notify-send -u low -t 2000 -c "transfer.complete" "$currentwindow$format.png uploaded!"
        ;;

        a)
            spectacle -r -bno "$savedir/$format.png"
            curl -s -X POST -F "file=@$savedir/$format.png" -H "shortUrl: $shorturl" -H "token: $token" $host | grep -Po '"link": *\K"[^"]*"' | tr -d '"' | tr -d '\n' | $clip
            notify-send -u low -t 2000 -c "transfer.complete" "$format.png uploaded!"
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
