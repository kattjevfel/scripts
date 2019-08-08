#!/bin/sh
savedir="$(xdg-user-dir PICTURES)/Screenshots"
date=$(date '+%Y-%m-%d_%H-%M-%S')
host="https://lewd.se/upload"
token="YOUR TOKEN GOES HERE (https://lewd.se/user)"
clip="xclip -f -selection clip"

# Requirements:
# - Spectacle (KDE screenshot tool)
# - curl
# - xclip (for clipboarding)

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
            spectacle -f -bno "$savedir/$date.png"
            curl -s -X POST -F "file=@$savedir/$date.png" -H "token: $token" $host | grep -Po '"link": *\K"[^"]*"' | tr -d '"' | tr -d '\n' | $clip
            notify-send -u low -t 2000 -c "transfer.complete" "$date.png uploaded!"
        ;;


        w)
            spectacle -a -bno "$savedir/$date.png"
            curl -s -X POST -F "file=@$savedir/$date.png" -H "token: $token" $host | grep -Po '"link": *\K"[^"]*"' | tr -d '"' | tr -d '\n' | $clip
            notify-send -u low -t 2000 -c "transfer.complete" "$date.png uploaded!"
        ;;

        a)
            spectacle -r -bno "$savedir/$date.png"
            curl -s -X POST -F "file=@$savedir/$date.png" -H "token: $token" $host | grep -Po '"link": *\K"[^"]*"' | tr -d '"' | tr -d '\n' | $clip
            notify-send -u low -t 2000 -c "transfer.complete" "$date.png uploaded!"
        ;;

        F)
            curl -X POST -F "file=@$2" -H "token: $token" $host | grep -Po '"link": *\K"[^"]*"' | tr -d '"'
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
