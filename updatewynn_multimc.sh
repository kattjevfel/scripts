#!/bin/sh
# Get latest version of Wynntils and launch the Wynncraft profile

channel=Wynntils-DEV
modspath=$HOME/.local/share/multimc/instances/Wynncraft/.minecraft/mods

latest="$(curl -s https://ci.wynntils.com/job/$channel/lastSuccessfulBuild/api/json)"
local="$(find "$modspath" -name 'Wynntils*.jar' -printf '%f')"
remote="$(echo "$latest" | grep -Po '"fileName": *"\K[^"]*')"

if [ "$local" = "$remote" ]; then
    echo 'Wynntils is up-to-date.'
else
    echo 'Wynntils appears to be outdated, downloading latest version..'
    curl -Ro "$modspath"/"$remote" "https://ci.wynntils.com/job/$channel/lastSuccessfulBuild/artifact/build/libs/$remote" &&
        rm "$modspath"/"$local"
    echo 'Changes (latest build only):'
    echo "$latest" | grep -Po '"msg": *"\K[^"]*'
fi

multimc --launch Wynncraft &
