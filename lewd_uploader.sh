#!/bin/sh
host="https://lewd.se/upload"
token="YOUR TOKEN GOES HERE (https://lewd.se/user)"

if [ $# -eq 0 ]
then
    echo "Missing options! (run $0 -h for help)"
fi

while getopts "hfl" OPTION; do
    case $OPTION in

        f)
            curl -X POST -F "file=@$2" -H "token: $token" $host | grep -E -o "(https://){1}[^'\"]+" | head -1
        ;;

        l)
            while read -r LINE
                do curl -X POST -F "file=@$LINE" -H "token: $token" $host | grep -E -o "(https://){1}[^'\"]+" | head -1
            done < "$2"
        ;;

        h)
            echo "Usage:"
            echo "   -f file.jpg (single file)"
            echo "   -l list_of_files.txt (one file per line)"
        ;;

        *)
            echo "What the fuck did you just bring upon this cursed land"
        ;;

    esac
done
