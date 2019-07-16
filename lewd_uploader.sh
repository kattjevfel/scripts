#!/bin/sh
savedir="$(xdg-user-dir PICTURES)/Screenshots"
date=`date '+%Y-%m-%d_%H-%M-%S'`
host="https://lewd.se/upload"
token="YOUR TOKEN GOES HERE (https://lewd.se/user)"
clip="xclip -f -selection clip"

# Requirements:
# - Spectacle (KDE screenshot tool)
# - curl
# - xclip (for clipboarding)
# - imagemagick (for webp, comment out accordingly otherwise)

# For ease of use set up hotkeys in KDE, remember to use full paths.


# Create directory if it doesn't exist
if [ ! -d $savedir ]; then
  mkdir -p $savedir;
fi

if [ $# -eq 0 ]
then
    echo "Missing options! (run $0 -h for help)"
fi

while getopts "hfawF" OPTION; do
    case $OPTION in

        f)
            spectacle -f -bno "$savedir/$date.png"
            convert "$savedir/$date.png" -define webp:lossless=true "$savedir/$date.webp"
            rm -f "$savedir/$date.png"
            curl -s -X POST -F "file=@$savedir/$date.webp" -H "token: $token" $host | egrep -o "(https://){1}[^'\"]+" | head -1 | tr -d '\n' | $clip
            notify-send -u low -t 2000 -c "transfer.complete" "$date.webp uploaded!"
        ;;


        w)
            spectacle -a -bno "$savedir/$date.png"
            convert "$savedir/$date.png" -define webp:lossless=true "$savedir/$date.webp"
            rm -f "$savedir/$date.png"
            curl -s -X POST -F "file=@$savedir/$date.webp" -H "token: $token" $host | egrep -o "(https://){1}[^'\"]+" | head -1 | tr -d '\n' | $clip
            notify-send -u low -t 2000 -c "transfer.complete" "$date.webp uploaded!"
        ;;

        a)
            spectacle -r -bno "$savedir/$date.png"
            convert "$savedir/$date.png" -define webp:lossless=true "$savedir/$date.webp"
            rm -f "$savedir/$date.png"
            curl -s -X POST -F "file=@$savedir/$date.webp" -H "token: $token" $host | egrep -o "(https://){1}[^'\"]+" | head -1 | tr -d '\n' | $clip
            notify-send -u low -t 2000 -c "transfer.complete" "$date.webp uploaded!"
        ;;

        F)
            curl --progress-bar -X POST -F "file=@$2" -H "token: $token" $host | egrep -o "(https://){1}[^'\"]+" | head -1
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

    esac
done
